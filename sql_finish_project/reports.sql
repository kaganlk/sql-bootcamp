--En çok sipariş verenler
SELECT m.id, m.ad, m.soyad, COUNT(s.id) AS siparis_sayisi
FROM musteri m
LEFT JOIN siparis s ON s.musteri_id = m.id
GROUP BY m.id, m.ad, m.soyad
ORDER BY siparis_sayisi DESC, m.id
LIMIT 5;

--En çok satılan ürünler
SELECT u.id, u.ad, COALESCE(SUM(sd.adet),0) AS toplam_adet
FROM urun u
LEFT JOIN siparis_detay sd ON sd.urun_id = u.id
GROUP BY u.id, u.ad
ORDER BY toplam_adet DESC, u.id;

--En yüksek ciroya sahip satıcılar
SELECT sa.id AS satici_id, sa.ad AS satici_ad,
       COALESCE(SUM(sd.adet * sd.fiyat),0)::NUMERIC(14,2) AS ciro
FROM satici sa
LEFT JOIN urun u ON u.satici_id = sa.id
LEFT JOIN siparis_detay sd ON sd.urun_id = u.id
GROUP BY sa.id, sa.ad
ORDER BY ciro DESC, sa.id;

-- Şehirlere göre müşteri sayısı
SELECT sehir, COUNT(*) AS musteri_sayisi
FROM musteri
GROUP BY sehir
ORDER BY musteri_sayisi DESC, sehir;

--Kategori bazlı toplam satışlar (tutar)
SELECT k.id AS kategori_id, k.ad AS kategori_ad,
       COALESCE(SUM(sd.adet * sd.fiyat),0)::NUMERIC(14,2) AS toplam_satis
FROM kategori k
LEFT JOIN urun u ON u.kategori_id = k.id
LEFT JOIN siparis_detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY toplam_satis DESC, k.id;

--Aylara göre sipariş sayısı
SELECT TO_CHAR(DATE_TRUNC('month', tarih), 'YYYY-MM') AS ay,
       COUNT(*) AS siparis_sayisi
FROM siparis
GROUP BY DATE_TRUNC('month', tarih)
ORDER BY ay;

--Siparişlerde müşteri + ürün + satıcı
SELECT s.id AS siparis_id, s.tarih, m.ad || ' ' || m.soyad AS musteri,
       u.ad AS urun, sa.ad AS satici, sd.adet, sd.fiyat,
       (sd.adet * sd.fiyat)::NUMERIC(12,2) AS satir_tutar
FROM siparis s
JOIN musteri m ON m.id = s.musteri_id
JOIN siparis_detay sd ON sd.siparis_id = s.id
JOIN urun u ON u.id = sd.urun_id
JOIN satici sa ON sa.id = u.satici_id
ORDER BY s.id, u.ad;

--Hiç satılmamış ürünler
SELECT u.id, u.ad
FROM urun u
LEFT JOIN siparis_detay sd ON sd.urun_id = u.id
WHERE sd.id IS NULL
ORDER BY u.id;

--Hiç sipariş vermemiş müşteriler
SELECT m.id, m.ad, m.soyad
FROM musteri m
LEFT JOIN siparis s ON s.musteri_id = m.id
WHERE s.id IS NULL
ORDER BY m.id;

--En çok kazanç sağlayan ilk 3 kategori
SELECT k.id, k.ad,
       COALESCE(SUM(sd.adet * sd.fiyat),0)::NUMERIC(14,2) AS ciro
FROM kategori k
LEFT JOIN urun u ON u.kategori_id = k.id
LEFT JOIN siparis_detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY ciro DESC
LIMIT 3;

--Ortalama sipariş tutarını geçen siparişler
WITH ort AS (
    SELECT AVG(toplam_tutar) AS ort_tutar FROM siparis
)
SELECT s.id, s.tarih, s.toplam_tutar
FROM siparis s, ort
WHERE s.toplam_tutar > ort.ort_tutar
ORDER BY s.toplam_tutar DESC;

--En az bir kez elektronik ürün satın alan müşteriler
SELECT DISTINCT m.id, m.ad, m.soyad
FROM musteri m
JOIN siparis s ON s.musteri_id = m.id
JOIN siparis_detay sd ON sd.siparis_id = s.id
JOIN urun u ON u.id = sd.urun_id
JOIN kategori k ON k.id = u.kategori_id
WHERE k.ad = 'Elektronik'
ORDER BY m.id;
