## 1) Tasarım Özeti
- **Temel varlıklar**: `musteri`, `satici`, `kategori`, `urun`, `siparis`, `siparis_detay`.
- **Bağlar**: 
  - `musteri (1) — (n) siparis`
  - `siparis (1) — (n) siparis_detay`
  - `urun (1) — (n) siparis_detay`
  - `kategori (1) — (n) urun`
  - `satici (1) — (n) urun`
- **Toplam tutar** mağaza mantığında satırların `(adet * fiyat)` toplamıdır; `siparis.toplam_tutar` tetikleyici ile otomatik güncellenir.
- **Stok yönetimi** sipariş satırı ekleme/güncelleme/silmede **tetikleyici** ile garanti altına alınır.
- **Ödeme türü** kontrollü değerlerle (`CHECK`) sınırlandırılmıştır.
- **E-posta** alanı `CITEXT` ile case-insensitive unique tutulur.

## 2) Veri Bütünlüğü
- `CHECK` kısıtları (negatif fiyat/stok engeli, pozitif adet, ödeme türü doğrulaması).
- `UNIQUE (siparis_id, urun_id)` ile bir siparişte aynı ürünün tek satırda tutulması.
- Tüm dış anahtarlar `ON UPDATE CASCADE` ve uygun `ON DELETE` kurallarıyla.

## 3) Performans
- Sık sorgulanan sütunlarda indeksler (`musteri.sehir`, `urun.kategori_id`, `siparis.tarih` vb.).
- Raporlamayı kolaylaştıran iki görünüm: `vw_satis_ozet`, `vw_urun_satis`.

## 4) Örnek Veri ve Komutlar
- `sample_data.sql` örnek müşteriler, satıcılar, kategoriler, ürünler ve çoklu siparişler içerir.
- TRUNCATE/UPDATE/DELETE örnekleri dahil.

## 5) Raporlama Sorguları
- Temel listeler (çok sipariş verenler, en çok satılanlar, en yüksek ciro).
- `GROUP BY` ve `HAVING` içeren özetler (şehir, kategori, ay).
- JOIN zincirleri (müşteri + ürün + satıcı).
- Boş/listelenmeyenler (hiç satılmamış ürünler, hiç sipariş vermemiş müşteriler).
- İleri düzey: en çok kazandıran ilk 3 kategori, ortalamanın üstü siparişler, en az bir kez elektronik alan müşteriler.

## 6) Karşılaşılan Sorunlar ve Çözümler
- **Stok yarış koşulları**: Aynı ürüne eşzamanlı eklemelerde hatasız düşüm için `FOR UPDATE` ile satır kilitleme kullanıldı.
- **Toplam tutar tutarlılığı**: Sipariş toplamının her değişimde doğru kalması için ayrı tetikleyici yazıldı.
- **Email benzersizliği ve büyük/küçük harf**: `citext` eklentisi etkinleştirilerek `UNIQUE` çakışmalarının önüne geçildi.