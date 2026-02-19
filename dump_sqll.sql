-- ============================================================
-- B.1.1 BUAT DATABASE
-- ============================================================
-- Buat database baru bernama rsit_db
CREATE DATABASE rsit_db;
USE rsit_db;

-- ============================================================
-- B.1.2 TABEL MASTER (Data Pokok)
-- ============================================================

-- TABEL 1: SPESIALISASI (Poli: Umum, Gigi, Jantung, Anak)
-- Kenapa: Setiap dokter punya spesialisasi
CREATE TABLE spesialisasi (
    id_spesialisasi INT PRIMARY KEY AUTO_INCREMENT,
    nama_spesialisasi VARCHAR(50) NOT NULL,
    deskripsi TEXT
);

-- TABEL 2: KATEGORI OBAT (Tablet, Sirup, Kapsul, dll)
-- Kenapa: Obat perlu dikelompokkan
CREATE TABLE kategori_obat (
    id_kategori INT PRIMARY KEY AUTO_INCREMENT,
    nama_kategori VARCHAR(50),
    bentuk_sediaan VARCHAR(20)
);

-- TABEL 3: DOKTER
-- Kenapa: Simpan data tenaga medis
-- Foreign Key: id_spesialisasi → menghubungkan ke tabel spesialisasi
CREATE TABLE dokter (
    id_dokter INT PRIMARY KEY AUTO_INCREMENT,
    nama_dokter VARCHAR(100),
    id_spesialisasi INT,
    no_telp VARCHAR(15),
    FOREIGN KEY (id_spesialisasi) REFERENCES spesialisasi(id_spesialisasi)
);

-- TABEL 4: PASIEN
-- Kenapa: Simpan data pasien yang berobat
CREATE TABLE pasien (
    id_pasien INT PRIMARY KEY AUTO_INCREMENT,
    nama_pasien VARCHAR(100),
    jenis_kelamin ENUM('L', 'P'),  -- L = Laki-laki, P = Perempuan
    alamat VARCHAR(255),
    kota VARCHAR(50),
    no_telp VARCHAR(15)
);

-- TABEL 5: OBAT
-- Kenapa: Simpan master data obat
-- Foreign Key: id_kategori → menghubungkan ke tabel kategori_obat
CREATE TABLE obat (
    id_obat VARCHAR(20) PRIMARY KEY,  -- Contoh: OBT-001
    nama_obat VARCHAR(100),
    id_kategori INT,
    stok INT DEFAULT 0,
    harga_beli DECIMAL(12,2),
    harga_jual DECIMAL(12,2),
    FOREIGN KEY (id_kategori) REFERENCES kategori_obat(id_kategori)
);

-- ============================================================
-- B.1.3 TABEL TRANSAKSI (Data Operasional)
-- ============================================================

-- TABEL 6: TRANSAKSI (Header/Nota utama)
-- Kenapa: Simpan setiap kunjungan pasien
-- Foreign Key: id_pasien dan id_dokter → menghubungkan ke pasien & dokter
CREATE TABLE transaksi (
    id_transaksi INT PRIMARY KEY AUTO_INCREMENT,
    tanggal DATETIME DEFAULT NOW(),
    id_pasien INT,
    id_dokter INT,
    keluhan TEXT,
    total_biaya DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien),
    FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter)
);

-- TABEL 7: DETAIL OBAT (Obat yang diresepkan)
-- Kenapa: Satu transaksi bisa banyak obat
-- Foreign Key: id_transaksi → transaksi, id_obat → obat
CREATE TABLE detail_obat (
    id_detail INT PRIMARY KEY AUTO_INCREMENT,
    id_transaksi INT,
    id_obat VARCHAR(20),
    quantity INT,
    harga_satuan DECIMAL(12,2),
    FOREIGN KEY (id_transaksi) REFERENCES transaksi(id_transaksi),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);

-- ============================================================
-- B.1.4 TABEL LOG (Audit Trail)
-- ============================================================

-- TABEL 8: LOG RESTOCK (Riwayat penambahan stok)
-- Kenapa: Lacak siapa yang menambah stok, kapan, berapa
CREATE TABLE log_restock (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_obat VARCHAR(20),
    jumlah_masuk INT,
    stok_sebelum INT,
    stok_sesudah INT,
    petugas VARCHAR(50),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);

-- TABEL 9: LOG HARGA (Riwayat perubahan harga)
-- Kenapa: Lacak perubahan harga untuk audit
CREATE TABLE log_harga (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_obat VARCHAR(20),
    harga_lama DECIMAL(12,2),
    harga_baru DECIMAL(12,2),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);


-- ============================================================
-- B.2.1 ISI DATA MASTER
-- ============================================================

-- Isi Spesialisasi
INSERT INTO spesialisasi (nama_spesialisasi, deskripsi) VALUES
('Umum', 'Poliklinik Umum'),
('Gigi', 'Spesialis Gigi'),
('Jantung', 'Spesialis Jantung'),
('Anak', 'Spesialis Anak');

-- Isi Kategori Obat
INSERT INTO kategori_obat (nama_kategori, bentuk_sediaan) VALUES
('Analgesik', 'Tablet'),
('Antibiotik', 'Kapsul'),
('Vitamin', 'Tablet'),
('Antiseptik', 'Cairan');

-- Isi Dokter
-- id_spesialisasi: 1=Umum, 2=Gigi, 3=Jantung, 4=Anak
INSERT INTO dokter (nama_dokter, id_spesialisasi, no_telp) VALUES
('Dr. Hartono', 1, '081234567890'),
('Drg. Ratna', 2, '081234567891'),
('Dr. Susan', 3, '081234567892'),
('Dr. Bambang', 4, '081234567893');

-- Isi Pasien
INSERT INTO pasien (nama_pasien, jenis_kelamin, alamat, kota, no_telp) VALUES
('Budi Santoso', 'L', 'Jl. Mawar 10', 'Surabaya', '081111111111'),
('Siti Aminah', 'P', 'Jl. Melati 5', 'Sidoarjo', '081222222222'),
('Andi Wijaya', 'L', 'Jl. Anggrek 3', 'Gresik', '081333333333');

-- Isi Obat
-- id_kategori: 1=Analgesik, 2=Antibiotik, 3=Vitamin, 4=Antiseptik
INSERT INTO obat (id_obat, nama_obat, id_kategori, stok, harga_beli, harga_jual) VALUES
('OBT-001', 'Paracetamol 500mg', 1, 100, 200, 500),
('OBT-002', 'Amoxicillin 500mg', 2, 50, 800, 1200),
('OBT-003', 'Vitamin C 500mg', 3, 200, 500, 1000),
('OBT-004', 'Betadine', 4, 30, 10000, 15000);

-- ============================================================
-- B.2.2 ISI DATA TRANSAKSI (Contoh: Pasien Budi berobat)
-- ============================================================

-- Langkah 1: Buat transaksi header
INSERT INTO transaksi (id_pasien, id_dokter, keluhan) 
VALUES (1, 1, 'Demam dan pusing');

-- Anggap transaksi ID yang terbuat adalah 1

-- Langkah 2: Isi detail obat yang diresepkan
-- Transaksi 1: Paracetamol 10 tablet @500 = 5000
INSERT INTO detail_obat (id_transaksi, id_obat, quantity, harga_satuan) 
VALUES (1, 'OBT-001', 10, 500);

-- Transaksi 1: Vitamin C 5 tablet @1000 = 5000
INSERT INTO detail_obat (id_transaksi, id_obat, quantity, harga_satuan) 
VALUES (1, 'OBT-003', 5, 1000);

-- Langkah 3: Update total biaya transaksi
UPDATE transaksi 
SET total_biaya = 10000  -- 5000 + 5000
WHERE id_transaksi = 1;


B. Trigger dan Delimiter 

-- ============================================================
-- B.3.1 STORED PROCEDURE: INPUT TRANSAKSI SEDERHANA
-- ============================================================
-- Fungsi: Membuat transaksi baru dengan otomatis hitung total

DELIMITER //

CREATE PROCEDURE sp_TransaksiBaru(
    IN p_id_pasien INT,      -- Input: ID pasien
    IN p_id_dokter INT,      -- Input: ID dokter
    IN p_id_obat VARCHAR(20), -- Input: Kode obat
    IN p_qty INT,             -- Input: Jumlah obat
    OUT p_total DECIMAL(12,2) -- Output: Total biaya
)
BEGIN
    DECLARE v_harga DECIMAL(12,2);
    DECLARE v_id_transaksi INT;
    
    -- 1. Ambil harga obat dari tabel master
    SELECT harga_jual INTO v_harga FROM obat WHERE id_obat = p_id_obat;
    
    -- 2. Buat transaksi header
    INSERT INTO transaksi (id_pasien, id_dokter, keluhan) 
    VALUES (p_id_pasien, p_id_dokter, 'Auto-generated');
    
    -- 3. Ambil ID transaksi yang baru dibuat
    SET v_id_transaksi = LAST_INSERT_ID();
    
    -- 4. Insert detail obat
    INSERT INTO detail_obat (id_transaksi, id_obat, quantity, harga_satuan)
    VALUES (v_id_transaksi, p_id_obat, p_qty, v_harga);
    
    -- 5. Hitung total
    SET p_total = p_qty * v_harga;
    
    -- 6. Update total di header
    UPDATE transaksi SET total_biaya = p_total WHERE id_transaksi = v_id_transaksi;
    
END //

DELIMITER ;

-- ============================================================
-- CARA PAKAI:
-- ============================================================
-- Panggil procedure dengan parameter:
CALL sp_TransaksiBaru(1, 1, 'OBT-001', 5, @total);

-- Lihat hasil total:
SELECT @total AS Total_Biaya;

-- Lihat transaksi yang terbuat:
SELECT * FROM transaksi ORDER BY id_transaksi DESC LIMIT 1;


-- ============================================================
-- B.3.2 STORED PROCEDURE: RESTOCK OBAT
-- ============================================================
-- Fungsi: Menambah stok obat dan catat di log

DELIMITER //

CREATE PROCEDURE sp_Restock(
    IN p_id_obat VARCHAR(20),  -- Kode obat
    IN p_jumlah INT,           -- Jumlah masuk
    IN p_petugas VARCHAR(50)   -- Nama petugas
)
BEGIN
    DECLARE v_stok_lama INT;
    DECLARE v_stok_baru INT;
    
    -- 1. Ambil stok lama
    SELECT stok INTO v_stok_lama FROM obat WHERE id_obat = p_id_obat;
    
    -- 2. Hitung stok baru
    SET v_stok_baru = v_stok_lama + p_jumlah;
    
    -- 3. Update stok obat
    UPDATE obat SET stok = v_stok_baru WHERE id_obat = p_id_obat;
    
    -- 4. Catat di log
    INSERT INTO log_restock (id_obat, jumlah_masuk, stok_sebelum, stok_sesudah, petugas)
    VALUES (p_id_obat, p_jumlah, v_stok_lama, v_stok_baru, p_petugas);
    
END //

DELIMITER ;

-- ============================================================
-- CARA PAKAI:
-- ============================================================
-- Tambah stok Paracetamol 50 pcs oleh petugas "Admin":
CALL sp_Restock('OBT-001', 50, 'Admin');

-- Cek hasil:
SELECT * FROM obat WHERE id_obat = 'OBT-001';
SELECT * FROM log_restock WHERE id_obat = 'OBT-001';

-- ============================================================
-- B.4.2 TRIGGER: AUDIT HARGA
-- ============================================================
-- Fungsi: Otomatis catat jika harga obat diubah

DELIMITER //

CREATE TRIGGER audit_harga AFTER UPDATE ON obat
FOR EACH ROW
BEGIN
    -- Jika harga jual berubah, catat ke log
    IF OLD.harga_jual != NEW.harga_jual THEN
        INSERT INTO log_harga (id_obat, harga_lama, harga_baru)
        VALUES (NEW.id_obat, OLD.harga_jual, NEW.harga_jual);
    END IF;
END //

DELIMITER ;

-- ============================================================
-- CARA TEST:
-- ============================================================
-- Ubah harga Paracetamol dari 500 menjadi 600:
UPDATE obat SET harga_jual = 600 WHERE id_obat = 'OBT-001';

-- Cek log perubahan:
SELECT * FROM log_harga WHERE id_obat = 'OBT-001';

-- ============================================================
-- B.5.1 LAPORAN: KINERJA DOKTER
-- ============================================================
-- Menampilkan: Nama dokter, spesialisasi, jumlah pasien, total pendapatan

SELECT 
    d.nama_dokter,
    s.nama_spesialisasi,
    COUNT(t.id_transaksi) AS jumlah_pasien,
    SUM(t.total_biaya) AS total_pendapatan
FROM dokter d
JOIN spesialisasi s ON d.id_spesialisasi = s.id_spesialisasi
LEFT JOIN transaksi t ON d.id_dokter = t.id_dokter
GROUP BY d.id_dokter, d.nama_dokter, s.nama_spesialisasi;

-- ============================================================
-- HASIL CONTOH:
-- ============================================================
-- nama_dokter  | nama_spesialisasi | jumlah_pasien | total_pendapatan
-- Dr. Hartono  | Umum              | 5             | 2500000
-- Drg. Ratna   | Gigi              | 3             | 5000000
-- Dr. Susan    | Jantung           | 2             | 7500000
