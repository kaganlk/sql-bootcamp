-- 1) ŞEMA
CREATE TABLE books (
    book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    genre TEXT,
    price NUMERIC(7,2) CHECK (price >= 0),
    stock_qty INT CHECK (stock_qty >= 0),
    published_year INT CHECK (published_year BETWEEN 1900 AND 2025),
    added_at DATE
);

-- 2) Veriler
BEGIN;

INSERT INTO books (title, author, genre, price, stock_qty, published_year, added_at) VALUES
('Kayıp Zamanın İzinde',     'M. Proust',              'roman',           129.90, 25, 1913, '2025-08-20'),
('Simyacı',                  'P. Coelho',              'roman',            89.50, 40, 1988, '2025-08-21'),
('Sapiens',                  'Y. N. Harari',           'tarih',           159.00, 18, 2011, '2025-08-25'),
('İnce Memed',               'Y. Kemal',               'roman',            99.90, 12, 1955, '2025-08-22'),
('Körlük',                   'J. Saramago',            'roman',           119.00,  7, 1995, '2025-08-28'),
('Dune',                     'F. Herbert',             'bilim',           149.00, 30, 1965, '2025-09-01'),
('Hayvan Çiftliği',          'G. Orwell',              'roman',            79.90, 55, 1945, '2025-08-23'),
('1984',                     'G. Orwell',              'roman',            99.00, 35, 1949, '2025-08-24'),
('Nutuk',                    'M. K. Atatürk',          'tarih',          139.00, 20, 1927, '2025-08-27'),
('Küçük Prens',              'A. de Saint-Exupéry',    'çocuk',            69.90, 80, 1943, '2025-08-26'),
('Başlangıç',                'D. Brown',               'roman',          109.00, 22, 2017, '2025-09-02'),
('Atomik Alışkanlıklar',     'J. Clear',               'kişisel gelişim', 129.00, 28, 2018, '2025-09-03'),
('Zamanın Kısa Tarihi',      'S. Hawking',             'bilim',          119.50, 16, 1988, '2025-08-29'),
('Şeker Portakalı',          'J. M. de Vasconcelos',   'roman',           84.90, 45, 1968, '2025-08-30'),
('Bir İdam Mahkûmunun Son Günü','V. Hugo',            'roman',           74.90, 26, 1829, '2025-08-31');

COMMIT;


-- 3) GÖREVLER 

-- 1) Tüm kitapların title, author, price (fiyat artan)
SELECT title, author, price
FROM books
ORDER BY price ASC;

-- 2) Türü 'roman' olanlar
SELECT *
FROM books
WHERE genre = 'roman'
ORDER BY title ASC;

-- 3) Fiyatı 80–120 arası olanlar
SELECT *
FROM books
WHERE price BETWEEN 80 AND 120
ORDER BY price ASC;

-- 4) Stok adedi 20’den az 
SELECT title, stock_qty
FROM books
WHERE stock_qty < 20
ORDER BY stock_qty ASC;

-- 5) title içinde 'zaman' 
SELECT *
FROM books
WHERE title ILIKE '%zaman%';


-- 6) genre IN ('roman','bilim')
SELECT *
FROM books
WHERE genre IN ('roman', 'bilim')
ORDER BY title ASC;

-- 7) published_year >= 2000 
SELECT *
FROM books
WHERE published_year >= 2000
ORDER BY published_year DESC, title ASC;

-- 8) Son 10 günde eklenenler
SELECT *
FROM books
WHERE added_at >= CURRENT_DATE - INTERVAL '10 day'
ORDER BY added_at DESC;


-- 9) En pahalı 5 kitap
SELECT *
FROM books
ORDER BY price DESC
LIMIT 5;

-- 10) Stok 30–60 arası
SELECT *
FROM books
WHERE stock_qty BETWEEN 30 AND 60
ORDER BY price ASC;

