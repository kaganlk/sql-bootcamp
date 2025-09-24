```mermaid
erDiagram
    MUSTERI {
        BIGINT id PK
        VARCHAR ad
        VARCHAR soyad
        CITEXT email
        VARCHAR sehir
        TIMESTAMPTZ kayit_tarihi
    }
    SATICI {
        BIGINT id PK
        VARCHAR ad
        VARCHAR adres
    }
    KATEGORI {
        BIGINT id PK
        VARCHAR ad
    }
    URUN {
        BIGINT id PK
        VARCHAR ad
        NUMERIC fiyat
        INTEGER stok
        BIGINT kategori_id FK
        BIGINT satici_id FK
    }
    SIPARIS {
        BIGINT id PK
        BIGINT musteri_id FK
        TIMESTAMPTZ tarih
        NUMERIC toplam_tutar
        VARCHAR odeme_turu
    }
    SIPARIS_DETAY {
        BIGINT id PK
        BIGINT siparis_id FK
        BIGINT urun_id FK
        INTEGER adet
        NUMERIC fiyat
    }

    MUSTERI ||--o{ SIPARIS : "verir"
    SIPARIS ||--o{ SIPARIS_DETAY : "içerir"
    URUN ||--o{ SIPARIS_DETAY : "satır"
    KATEGORI ||--o{ URUN : "sınıflandırır"
    SATICI ||--o{ URUN : "sunar"
```
