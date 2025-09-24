DROP TABLE IF EXISTS siparis_detay CASCADE;
DROP TABLE IF EXISTS siparis CASCADE;
DROP TABLE IF EXISTS urun CASCADE;
DROP TABLE IF EXISTS kategori CASCADE;
DROP TABLE IF EXISTS satici CASCADE;
DROP TABLE IF EXISTS musteri CASCADE;


CREATE TABLE musteri (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ad              VARCHAR(80)   NOT NULL,
    soyad           VARCHAR(80)   NOT NULL,
    email           CITEXT        NOT NULL UNIQUE,
    sehir           VARCHAR(80)   NOT NULL,
    kayit_tarihi    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    CONSTRAINT email_format_chk CHECK (position('@' in email) > 1)
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'citext') THEN
        CREATE EXTENSION citext;
    END IF;
END$$;

CREATE TABLE satici (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ad          VARCHAR(120) NOT NULL,
    adres       VARCHAR(255) NOT NULL
);

CREATE TABLE kategori (
    id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ad      VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE urun (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ad           VARCHAR(200) NOT NULL,
    fiyat        NUMERIC(12,2) NOT NULL CHECK (fiyat >= 0),
    stok         INTEGER       NOT NULL CHECK (stok >= 0),
    kategori_id  BIGINT        NOT NULL REFERENCES kategori(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    satici_id    BIGINT        NOT NULL REFERENCES satici(id)   ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Siparişlerde ödeme_turu metinsel alan; kontrollü değerler için CHECK
CREATE TABLE siparis (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    musteri_id    BIGINT      NOT NULL REFERENCES musteri(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    tarih         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    toplam_tutar  NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (toplam_tutar >= 0),
    odeme_turu    VARCHAR(20) NOT NULL,
    CONSTRAINT odeme_turu_chk CHECK (odeme_turu IN ('kredi_karti','havale','kapida_odeme','wallet'))
);

CREATE TABLE siparis_detay (
    id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    siparis_id   BIGINT NOT NULL REFERENCES siparis(id) ON UPDATE CASCADE ON DELETE CASCADE,
    urun_id      BIGINT NOT NULL REFERENCES urun(id)    ON UPDATE CASCADE ON DELETE RESTRICT,
    adet         INTEGER NOT NULL CHECK (adet > 0),
    fiyat        NUMERIC(12,2) NOT NULL CHECK (fiyat >= 0),
    UNIQUE (siparis_id, urun_id)  -- aynı siparişte aynı üründen tek satır
);


CREATE INDEX idx_musteri_sehir ON musteri(sehir);
CREATE INDEX idx_urun_kategori ON urun(kategori_id);
CREATE INDEX idx_urun_satici   ON urun(satici_id);
CREATE INDEX idx_siparis_musteri ON siparis(musteri_id);
CREATE INDEX idx_siparis_tarih ON siparis(tarih);
CREATE INDEX idx_siparis_detay_urun ON siparis_detay(urun_id);



-- Stok yetersizliğini engelleme
CREATE OR REPLACE FUNCTION fn_stok_azalt() RETURNS TRIGGER AS $$
DECLARE
    mevcut_stok INTEGER;
    fark INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT stok INTO mevcut_stok FROM urun WHERE id = NEW.urun_id FOR UPDATE;
        IF mevcut_stok < NEW.adet THEN
            RAISE EXCEPTION 'Yetersiz stok: urun_id=% stok=% istenen=%', NEW.urun_id, mevcut_stok, NEW.adet;
        END IF;
        UPDATE urun SET stok = stok - NEW.adet WHERE id = NEW.urun_id;
    ELSIF TG_OP = 'UPDATE' THEN
        -- adet değişim farkını uygula
        SELECT stok INTO mevcut_stok FROM urun WHERE id = NEW.urun_id FOR UPDATE;
        fark := NEW.adet - OLD.adet;
        IF fark > 0 AND mevcut_stok < fark THEN
            RAISE EXCEPTION 'Yetersiz stok: urun_id=% stok=% ek_istenen=%', NEW.urun_id, mevcut_stok, fark;
        END IF;
        UPDATE urun SET stok = stok - fark WHERE id = NEW.urun_id;
        -- Ürün değişimi durumunda eski ürüne stok iadesi
        IF NEW.urun_id <> OLD.urun_id THEN
            UPDATE urun SET stok = stok + OLD.adet WHERE id = OLD.urun_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
      
        UPDATE urun SET stok = stok + OLD.adet WHERE id = OLD.urun_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Sipariş toplamını güncelleme
CREATE OR REPLACE FUNCTION fn_siparis_toplam_guncelle() RETURNS TRIGGER AS $$
BEGIN
    UPDATE siparis s
    SET toplam_tutar = COALESCE( (
        SELECT SUM(sd.adet * sd.fiyat)::NUMERIC(14,2)
        FROM siparis_detay sd
        WHERE sd.siparis_id = s.id
    ), 0)
    WHERE s.id = COALESCE(NEW.siparis_id, OLD.siparis_id);
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tetikleyici
DROP TRIGGER IF EXISTS trg_stok_azalt ON siparis_detay;
CREATE TRIGGER trg_stok_azalt
AFTER INSERT OR UPDATE OR DELETE ON siparis_detay
FOR EACH ROW EXECUTE FUNCTION fn_stok_azalt();

DROP TRIGGER IF EXISTS trg_siparis_toplam ON siparis_detay;
CREATE TRIGGER trg_siparis_toplam
AFTER INSERT OR UPDATE OR DELETE ON siparis_detay
FOR EACH ROW EXECUTE FUNCTION fn_siparis_toplam_guncelle();


CREATE OR REPLACE VIEW vw_satis_ozet AS
SELECT
    s.id AS siparis_id,
    s.tarih,
    m.id AS musteri_id,
    m.ad || ' ' || m.soyad AS musteri_ad,
    s.odeme_turu,
    s.toplam_tutar
FROM siparis s
JOIN musteri m ON m.id = s.musteri_id;

CREATE OR REPLACE VIEW vw_urun_satis AS
SELECT
    u.id AS urun_id,
    u.ad AS urun_ad,
    SUM(sd.adet) AS toplam_adet,
    SUM(sd.adet * sd.fiyat)::NUMERIC(14,2) AS toplam_tutar
FROM siparis_detay sd
JOIN urun u ON u.id = sd.urun_id
GROUP BY u.id, u.ad;
