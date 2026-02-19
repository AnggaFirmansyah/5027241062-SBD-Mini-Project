// ============================================================
// C.1.1 GUNAKAN DATABASE
// ============================================================
use rsit_nosql;

// ============================================================
// C.1.2 INSERT DATA REKAM MEDIS (Poli Umum - Sederhana)
// ============================================================
// Struktur: Data pasien poli umum dengan gejala sederhana

db.rekam_medis.insertOne({
    nama_pasien: "Budi Santoso",
    no_rm: "RM-001",
    poli: "Umum",
    tanggal: new Date("2026-02-01"),
    status: "Rawat Jalan",
    gejala: ["Demam", "Pusing", "Batuk"],
    tanda_vital: {
        suhu: 38.5,
        tensi: "120/80",
        nadi: 90
    },
    diagnosa: "Demam Viral",
    biaya: 85000
});

// ============================================================
// C.1.3 INSERT DATA REKAM MEDIS (Poli Gigi - Kompleks)
// ============================================================
// Struktur: Array of objects untuk kondisi gigi

db.rekam_medis.insertOne({
    nama_pasien: "Siti Aminah",
    no_rm: "RM-002",
    poli: "Gigi",
    tanggal: new Date("2026-02-01"),
    status: "Rawat Jalan",
    odontogram: [  // Array of objects
        { gigi: "Geraham Atas Kanan", kondisi: "Berlubang", tindakan: "Tambal" },
        { gigi: "Geraham Bawah Kiri", kondisi: "Karang Gigi", tindakan: "Scaling" }
    ],
    catatan: "Pasien takut jarum suntik",
    biaya: 750000
});

// ============================================================
// C.1.4 INSERT DATA REKAM MEDIS (Poli Jantung - Nested Object)
// ============================================================
// Struktur: Nested object untuk hasil lab

db.rekam_medis.insertOne({
    nama_pasien: "Andi Wijaya",
    no_rm: "RM-003",
    poli: "Jantung",
    tanggal: new Date("2026-02-01"),
    status: "Rawat Jalan",
    hasil_lab: {  // Nested object
        kolesterol: { total: 240, ldl: 160, hdl: 40 },
        gula_darah: { puasa: 110, post_prandial: 140 }
    },
    diagnosa: "Hipertensi",
    biaya: 1200000
});

// ============================================================
// C.1.5 INSERT BANYAK DATA SEKALIGUS (Rawat Inap)
// ============================================================

db.rekam_medis.insertMany([
    {
        nama_pasien: "Ahmad Fauzi",
        no_rm: "RM-004",
        poli: "Jantung",
        tanggal_masuk: new Date("2026-02-05"),
        status: "Rawat Inap",
        kategori: "VIP",
        biaya_kamar: 2000000
    },
    {
        nama_pasien: "Rina Wulandari",
        no_rm: "RM-005",
        poli: "Umum",
        tanggal_masuk: new Date("2026-02-08"),
        status: "Rawat Inap",
        kategori: "VIP",
        biaya_kamar: 1500000
    },
    {
        nama_pasien: "Bambang Sutejo",
        no_rm: "RM-006",
        poli: "Jantung",
        tanggal_masuk: new Date("2026-02-01"),
        status: "Rawat Inap",
        kategori: "Reguler",
        biaya_kamar: 500000
    }
]);



Query dasar FInd : 
// ============================================================
// C.2.1 CARI SEMUA PASIEN
// ============================================================
db.rekam_medis.find();

// ============================================================
// C.2.2 CARI PASIEN POLI TERTENTU
// ============================================================
// Cari pasien poli Umum saja
db.rekam_medis.find({ poli: "Umum" });

// ============================================================
// C.2.3 CARI PASIEN DENGAN KONDISI TERTENTU
// ============================================================
// Cari pasien rawat inap saja
db.rekam_medis.find({ status: "Rawat Inap" });

// ============================================================
// C.2.4 CARI PASIEN DENGAN BIAYA TERTENTU
// ============================================================
// Cari pasien dengan biaya > 500000
db.rekam_medis.find({ biaya: { $gt: 500000 } });

// ============================================================
// C.2.5 TAMPILKAN FIELD TERTENTU SAJA
// ============================================================
// Hanya tampilkan nama dan poli (sembunyikan _id)
db.rekam_medis.find({}, { nama_pasien: 1, poli: 1, _id: 0 });

Update Data : 
// ============================================================
// C.3.1 UPDATE SATU DOKUMEN
// ============================================================
// Ubah diagnosa Budi Santoso
db.rekam_medis.updateOne(
    { nama_pasien: "Budi Santoso" },  // Kondisi cari
    { $set: { diagnosa: "Demam Berdarah" } }  // Data baru
);

// ============================================================
// C.3.2 UPDATE MASSAL: TAMBAH JADWAL KONTROL (H+7)
// ============================================================
// Untuk semua pasien rawat inap, tambahkan jadwal kontrol 7 hari lagi

db.rekam_medis.updateMany(
    { status: "Rawat Inap" },  // Kondisi: yang rawat inap saja
    {
        $set: {
            jadwal_kontrol: new Date(new Date().getTime() + 7*24*60*60*1000)
        }
    }
);

// ============================================================
// C.3.3 UPDATE: NAIKKAN BIAYA KAMAR 10% UNTUK VIP
// ============================================================

db.rekam_medis.updateMany(
    { kategori: "VIP", status: "Rawat Inap" },  // Kondisi: VIP & rawat inap
    { $mul: { biaya_kamar: 1.10 } }  // Kalikan dengan 1.10 (naik 10%)
);

// Cek hasil:
db.rekam_medis.find({ kategori: "VIP" }, { nama_pasien: 1, biaya_kamar: 1 });

Aggregation : 

// ============================================================
// C.4.1 HITUNG JUMLAH PASIEN PER POLI
// ============================================================

db.rekam_medis.aggregate([
    { $group: { _id: "$poli", jumlah: { $sum: 1 } } },
    { $sort: { jumlah: -1 } }
]);

// Hasil contoh:
// { "_id": "Umum", "jumlah": 10 }
// { "_id": "Gigi", "jumlah": 5 }
// { "_id": "Jantung", "jumlah": 3 }

// ============================================================
// C.4.2 HITUNG TOTAL BIAYA PER POLI
// ============================================================

db.rekam_medis.aggregate([
    { $group: { 
        _id: "$poli", 
        total_biaya: { $sum: "$biaya" },
        rata_rata: { $avg: "$biaya" }
    }}
]);

// ============================================================
// C.4.3 ANALISIS GEJALA PALING SERING (TOP 5)
// ============================================================

db.rekam_medis.aggregate([
    // Pecah array gejala menjadi dokumen terpisah
    { $unwind: "$gejala" },
    
    // Kelompokkan dan hitung
    { $group: { _id: "$gejala", frekuensi: { $sum: 1 } } },
    
    // Urutkan dari yang terbanyak
    { $sort: { frekuensi: -1 } },
    
    // Ambil 5 teratas
    { $limit: 5 }
]);

// Hasil contoh:
// { "_id": "Demam", "frekuensi": 50 }
// { "_id": "Batuk", "frekuensi": 30 }
// { "_id": "Pusing", "frekuensi": 25 }

// ============================================================
// C.4.4 STATISTIK PASIEN USIA > 40 (RISIKO TINGGI)
// ============================================================

// Asumsikan kita punya field usia
db.rekam_medis.aggregate([
    // Filter usia > 40
    { $match: { usia: { $gt: 40 } } },
    
    // Kelompokkan berdasarkan diagnosa
    { $group: { 
        _id: "$diagnosa", 
        jumlah_pasien: { $sum: 1 },
        rata_rata_biaya: { $avg: "$biaya" }
    }},
    
    // Urutkan dari risiko tertinggi (biaya tertinggi)
    { $sort: { rata_rata_biaya: -1 } }
]);
