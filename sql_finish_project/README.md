# Online Alışveriş Platformu Veri Tabanı — Tam Paket

Bu paket; **ER Diyagramı (DBML + Mermaid)**, **SQL kurulum ve örnek veri**, **raporlama sorguları**, ve **kısa dokümantasyon** içerir.

## İçerik
- `schema.sql` — PostgreSQL şema ve kısıtlar
- `sample_data.sql` — Örnek veri ekleme (INSERT)
- `reports.sql` — Raporlama/analiz sorguları (JOIN, GROUP BY, HAVING)
- `docs.md` — Tasarım kararları ve açıklamalar
- `erd.dbml` — DBML biçiminde ER diyagramı (dbdiagram.io ile görselleştirilebilir)
- `erd_mermaid.md` — Mermaid ER diyagramı kodu

## Hızlı Başlangıç (PostgreSQL)
```bash
# 1) Boş bir veritabanı oluşturun (ör. ecommerce_db)
createdb ecommerce_db

# 2) Şema ve örnek verileri yükleyin
psql -d ecommerce_db -f schema.sql
psql -d ecommerce_db -f sample_data.sql

# 3) Raporları çalıştırın
psql -d ecommerce_db -f reports.sql
```

> Not: SQL'ler **PostgreSQL 13+** için yazılmıştır ve `GENERATED ALWAYS AS IDENTITY`, `CHECK` kısıtları, `ENUM yerine CHECK`, `INDEX` ve `TRIGGER` kullanımını içerir.
