-- Kategoriler
INSERT INTO kategori (ad) VALUES
('Elektronik'),
('Giyim'),
('Ev & Yaşam'),
('Spor'),
('Kitap');

-- Satıcılar
INSERT INTO satici (ad, adres) VALUES
('TechnoMarket', 'İstanbul, Türkiye'),
('ModaDura', 'Ankara, Türkiye'),
('HomeLine', 'İzmir, Türkiye');

-- Müşteriler
INSERT INTO musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
('Ayşe', 'Yılmaz', 'ayse@example.com', 'İstanbul', NOW() - INTERVAL '200 days'),
('Mehmet', 'Demir', 'mehmet@example.com', 'Ankara', NOW() - INTERVAL '150 days'),
('Zeynep', 'Kara', 'zeynep@example.com', 'İzmir', NOW() - INTERVAL '100 days'),
('Ali', 'Çelik', 'ali@example.com', 'Bursa', NOW() - INTERVAL '50 days'),
('Ece', 'Arslan', 'ece@example.com', 'Antalya', NOW() - INTERVAL '10 days'),
('Mert', 'Aksoy', 'mert@example.com', 'İstanbul', NOW() - INTERVAL '5 days');

-- Ürünler
INSERT INTO urun (ad, fiyat, stok, kategori_id, satici_id) VALUES
('Akıllı Telefon X', 15000, 50, (SELECT id FROM kategori WHERE ad='Elektronik'), (SELECT id FROM satici WHERE ad='TechnoMarket')),
('Bluetooth Kulaklık', 1500, 200, (SELECT id FROM kategori WHERE ad='Elektronik'), (SELECT id FROM satici WHERE ad='TechnoMarket')),
('Kadın Tişört', 249, 500, (SELECT id FROM kategori WHERE ad='Giyim'), (SELECT id FROM satici WHERE ad='ModaDura')),
('Erkek Eşofman', 599, 350, (SELECT id FROM kategori WHERE ad='Spor'), (SELECT id FROM satici WHERE ad='ModaDura')),
('Yastık', 199, 1000, (SELECT id FROM kategori WHERE ad='Ev & Yaşam'), (SELECT id FROM satici WHERE ad='HomeLine')),
('Roman: Veri Bilimi', 179, 150, (SELECT id FROM kategori WHERE ad='Kitap'), (SELECT id FROM satici WHERE ad='HomeLine'));

-- Siparişler
INSERT INTO siparis (musteri_id, tarih, odeme_turu) VALUES
(1, NOW() - INTERVAL '40 days', 'kredi_karti'),
(1, NOW() - INTERVAL '5 days',  'wallet'),
(2, NOW() - INTERVAL '20 days', 'havale'),
(3, NOW() - INTERVAL '2 days',  'kredi_karti'),
(4, NOW() - INTERVAL '1 days',  'kapida_odeme');

-- Sipariş Detayları
-- S1
INSERT INTO siparis_detay (siparis_id, urun_id, adet, fiyat) VALUES
(1, 1, 1, 15000),
(1, 2, 2, 1500);
-- S2
INSERT INTO siparis_detay (siparis_id, urun_id, adet, fiyat) VALUES
(2, 2, 1, 1400),
(2, 6, 2, 170);
-- S3
INSERT INTO siparis_detay (siparis_id, urun_id, adet, fiyat) VALUES
(3, 3, 3, 249);
-- S4
INSERT INTO siparis_detay (siparis_id, urun_id, adet, fiyat) VALUES
(4, 1, 1, 14500),
(4, 5, 4, 199);
-- S5
INSERT INTO siparis_detay (siparis_id, urun_id, adet, fiyat) VALUES
(5, 4, 1, 599);


UPDATE urun SET fiyat = fiyat * 0.95 WHERE ad = 'Bluetooth Kulaklık';

-- Bir sipariş detayını güncelleme
UPDATE siparis_detay SET adet = 3 WHERE siparis_id = 3 AND urun_id = (SELECT id FROM urun WHERE ad='Kadın Tişört');

-- Bir ürünü satılamaz hale getirmek yerine stok sıfırlamak
UPDATE urun SET stok = 0 WHERE ad = 'Roman: Veri Bilimi';

-- Bir sipariş satırını sil
DELETE FROM siparis_detay WHERE siparis_id = 2 AND urun_id = (SELECT id FROM urun WHERE ad='Roman: Veri Bilimi');
