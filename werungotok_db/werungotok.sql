-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 09 Sep 2026 pada 11.17
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `werungotok`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `alur_pelayanans`
--

CREATE TABLE `alur_pelayanans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `judul_langkah` varchar(255) NOT NULL,
  `deskripsi` text NOT NULL,
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `alur_pelayanans`
--

INSERT INTO `alur_pelayanans` (`id`, `judul_langkah`, `deskripsi`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'Masyarakat', 'Membawa Surat Pengantar RT/RW, FC KK, FC KTP, dan dokumen pendukung sesuai surat keterangan yang dibutuhkan.', 0, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(2, 'Kelurahan Memeriksa', 'Memeriksa kelengkapan berkas. Jika lengkap, diproses 5-10 menit. Jika belum lengkap, dikembalikan untuk dilengkapi.', 1, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(3, 'Proses Kelurahan', 'Proses pengerjaan 10-15 menit (jika ada revisi 5-7 menit).', 2, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(4, 'Verifikasi & Pengesahan', 'Proses verifikasi Kasi dan Sekretaris Kelurahan. Kemudian register surat dan proses tanda tangan Lurah.', 3, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(5, 'Selesai', 'Kelurahan memberikan Surat Pelayanan melalui WhatsApp pemohon yang aktif berupa file PDF ke warga.', 4, '2026-09-04 21:16:54', '2026-09-04 21:16:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `jenis_sampahs`
--

CREATE TABLE `jenis_sampahs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `jenis_sampahs`
--

INSERT INTO `jenis_sampahs` (`id`, `nama`, `icon`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'Botol Plastik', 'bottle-water', 0, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(2, 'Kardus & Kertas', 'box', 1, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(3, 'Kaleng / Besi', 'can-food', 2, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(4, 'Botol Kaca', 'glass-water', 3, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(5, 'Kabel Bekas', 'plug', 4, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(6, 'Minyak Jelantah', 'oil-can', 5, '2026-09-04 21:16:54', '2026-09-04 21:16:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `ketentuan_sampahs`
--

CREATE TABLE `ketentuan_sampahs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `isi` text NOT NULL,
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `ketentuan_sampahs`
--

INSERT INTO `ketentuan_sampahs` (`id`, `isi`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'Sampah harus dalam keadaan bersih (wajib dibilas air jika bekas botol minuman / kaleng makanan).', 0, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(2, 'Sampah sudah dipilah sesuai jenisnya (plastik keras, plastik kemasan, kertas, dan besi/logam).', 1, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(3, 'Wajib membawa buku tabungan Bank Sampah saat jadwal penimbangan rutin (Setiap Minggu ke-2).', 2, '2026-09-04 21:16:54', '2026-09-04 21:16:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_01_01_000001_add_profile_fields_to_users_table', 1),
(5, '2026_01_01_000002_create_surat_pengajuans_table', 1),
(6, '2026_01_01_000003_create_posyandu_jadwals_table', 1),
(7, '2026_01_01_000004_create_posyandu_infos_table', 1),
(8, '2026_01_01_000005_create_jenis_sampahs_table', 1),
(9, '2026_01_01_000006_create_ketentuan_sampahs_table', 1),
(10, '2026_01_01_000007_create_syarat_surats_table', 1),
(11, '2026_01_01_000008_create_alur_pelayanans_table', 1),
(12, '2026_01_01_000009_create_site_settings_table', 1),
(13, '2026_09_05_040737_create_personal_access_tokens_table', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(6, 'App\\Models\\User', 2, 'werungotok-app', '2d70917bbce5285eb66e2d5c8600ab6c19e945f2c0470bb407be888d57a878b0', '[\"*\"]', '2026-09-09 02:13:24', NULL, '2026-09-09 02:12:35', '2026-09-09 02:13:24');

-- --------------------------------------------------------

--
-- Struktur dari tabel `posyandu_infos`
--

CREATE TABLE `posyandu_infos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `judul` varchar(255) NOT NULL,
  `isi` text NOT NULL,
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `posyandu_infos`
--

INSERT INTO `posyandu_infos` (`id`, `judul`, `isi`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'Posyandu ILP', 'Layanan Integrasi Layanan Primer (ILP) mencakup wilayah Bulakmojo, Weru, Babadan, Ngotok, Ngates, dan Perumnas yang dilaksanakan secara rutin tiap bulan.', 0, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(2, 'Posyandu Lansia', 'Khusus melayani pemeriksaan kesehatan lansia secara berkala (terutama di wilayah Perumnas).', 1, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(3, 'Pertemuan Kader & Imunisasi Balita', 'Agenda bulanan untuk evaluasi kader PKK serta pemberian imunisasi lengkap bagi balita.', 2, '2026-09-04 21:16:53', '2026-09-04 21:16:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `posyandu_jadwals`
--

CREATE TABLE `posyandu_jadwals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama_posyandu` varchar(255) NOT NULL,
  `kategori` varchar(255) DEFAULT NULL,
  `jan` tinyint(3) UNSIGNED DEFAULT NULL,
  `feb` tinyint(3) UNSIGNED DEFAULT NULL,
  `mar` tinyint(3) UNSIGNED DEFAULT NULL,
  `apr` tinyint(3) UNSIGNED DEFAULT NULL,
  `mei` tinyint(3) UNSIGNED DEFAULT NULL,
  `jun` tinyint(3) UNSIGNED DEFAULT NULL,
  `jul` tinyint(3) UNSIGNED DEFAULT NULL,
  `agu` tinyint(3) UNSIGNED DEFAULT NULL,
  `sep` tinyint(3) UNSIGNED DEFAULT NULL,
  `okt` tinyint(3) UNSIGNED DEFAULT NULL,
  `nop` tinyint(3) UNSIGNED DEFAULT NULL,
  `des` tinyint(3) UNSIGNED DEFAULT NULL,
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `posyandu_jadwals`
--

INSERT INTO `posyandu_jadwals` (`id`, `nama_posyandu`, `kategori`, `jan`, `feb`, `mar`, `apr`, `mei`, `jun`, `jul`, `agu`, `sep`, `okt`, `nop`, `des`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'ILP BULAKMOJO', 'ilp', 5, 2, 2, 1, 2, 2, 1, 1, 1, 1, 2, 1, 0, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(2, 'ILP WERU', 'ilp', 6, 3, 3, 2, 4, 3, 2, 3, 2, 5, 3, 2, 1, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(3, 'ILP BABADAN', 'ilp', 7, 4, 4, 7, 5, 4, 4, 4, 3, 3, 4, 3, 2, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(4, 'ILP NGOTOK', 'ilp', 8, 5, 5, 8, 6, 8, 6, 5, 8, 6, 5, 8, 3, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(5, 'ILP NGATES', 'ilp', 12, 9, 9, 9, 7, 9, 7, 6, 7, 7, 9, 7, 4, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(6, 'ILP PERUMNAS', 'ilp', 10, 7, 7, 11, 9, 6, 11, 8, 5, 10, 7, 5, 5, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(7, 'LANSIA PERUMNAS', 'lansia', 14, 11, 11, 15, 13, 10, 15, 12, 9, 14, 11, 16, 6, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(8, 'PERTEMUAN KADER', 'kader', 20, 24, 17, 21, 19, 17, 21, 18, 22, 21, 17, 22, 7, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(9, 'IMUNISASI BALITA', 'imunisasi', 21, 21, 26, 20, 20, 20, 20, 20, 21, 20, 21, 21, 8, '2026-09-04 21:16:53', '2026-09-04 21:16:53');

-- --------------------------------------------------------

--
-- Struktur dari tabel `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('3bqUMrrAUTJAKeNyj0TiJ0q7HGSABlitHTfMO9pg', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.136.1 Chrome/148.0.7778.280 Electron/42.10.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNGFybHgzdWg1NnFZWDlwOFR0V1paRDU0WUpjQzhUSUxsblZ1RGtpWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMCI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1788581996);

-- --------------------------------------------------------

--
-- Struktur dari tabel `site_settings`
--

CREATE TABLE `site_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `site_settings`
--

INSERT INTO `site_settings` (`id`, `key`, `value`, `created_at`, `updated_at`) VALUES
(1, 'posyandu_ketua_pkk', 'Beattealeas', '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(2, 'posyandu_koordinator_kader', 'Endang Dwi Purwanti', '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(3, 'bank_sampah_deskripsi', 'Mari ubah sampah menjadi berkah. Tukarkan sampah anorganik Anda yang sudah dipilah di rumah dengan tabungan di Kelurahan Werungotok.', '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(4, 'bank_sampah_jadwal', 'Setiap Minggu ke-2', '2026-09-04 21:16:54', '2026-09-04 21:16:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `surat_pengajuans`
--

CREATE TABLE `surat_pengajuans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `jenis_surat` varchar(255) NOT NULL,
  `dokumen_pendukung` varchar(255) NOT NULL,
  `status` enum('diproses','selesai','ditolak') NOT NULL DEFAULT 'diproses',
  `file_hasil` varchar(255) DEFAULT NULL,
  `catatan_admin` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `surat_pengajuans`
--

INSERT INTO `surat_pengajuans` (`id`, `user_id`, `jenis_surat`, `dokumen_pendukung`, `status`, `file_hasil`, `catatan_admin`, `created_at`, `updated_at`) VALUES
(1, 2, 'USAHA', 'surat/dokumen_pendukung/SljcQvwqx7XQLMt3MPKRGAdEx9B73KzxXiay7KFH.pdf', 'selesai', 'surat/hasil/VTF9AmxRSCXiVV6ehixETSDnzFonlyp7XTAtPOjB.pdf', 'jos', '2026-09-09 02:09:23', '2026-09-09 02:12:10');

-- --------------------------------------------------------

--
-- Struktur dari tabel `syarat_surats`
--

CREATE TABLE `syarat_surats` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama_surat` varchar(255) NOT NULL,
  `daftar_syarat` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`daftar_syarat`)),
  `urutan` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `syarat_surats`
--

INSERT INTO `syarat_surats` (`id`, `nama_surat`, `daftar_syarat`, `urutan`, `created_at`, `updated_at`) VALUES
(1, 'Surat Kematian', '[\"Pengantar RT\\/RW (WAJIB)\",\"FC KK\\/KTP yang meninggal (WAJIB)\",\"Surat Kematian RS (PENDUKUNG)\",\"Materai 10.000 jika lewat 3 bln\"]', 0, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(2, 'SKCK', '[\"Pengantar RT\\/RW (WAJIB)\",\"FC KK & KTP (WAJIB)\"]', 1, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(3, 'SKTM', '[\"Pengantar RT\\/RW (WAJIB)\",\"FC KK\\/KTP (WAJIB)\",\"Surat RS untuk Pasien Darurat\"]', 2, '2026-09-04 21:16:54', '2026-09-04 21:16:54'),
(4, 'Keterangan Usaha', '[\"Pengantar RT\\/RW (WAJIB)\",\"FC KK\\/KTP (WAJIB)\",\"Surat Pernyataan Bermaterai (WAJIB)\",\"Foto Usaha (PENDUKUNG)\"]', 3, '2026-09-04 21:16:54', '2026-09-04 21:16:54');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `wa` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `ktp_photo` varchar(255) DEFAULT NULL,
  `pas_foto` varchar(255) DEFAULT NULL,
  `ktp_status` enum('unverified','valid','invalid') NOT NULL DEFAULT 'unverified',
  `role` enum('warga','admin') NOT NULL DEFAULT 'warga',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `nama`, `email`, `wa`, `alamat`, `ktp_photo`, `pas_foto`, `ktp_status`, `role`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'Administrator', 'admin@werungotok.local', NULL, NULL, NULL, NULL, 'valid', 'admin', NULL, '$2y$12$ML.C39LRDBO3qYADRJvbRu0xOWBn2Qrmd2vFwpwpRyUDp8NaGCb7O', NULL, '2026-09-04 21:16:53', '2026-09-04 21:16:53'),
(2, 'brianevan', 'Brian', 'brianevan67@gmail.com', '123456789', 'werungotok', 'ktp/GoF1O8TGtjkoBIBEeGCdifTvSDxbjbznKju82rKw.jpg', 'pasfoto/jwQZ6u0Jjn8IdWE20KT9Ear6YhDYBS742AWEBpie.jpg', 'valid', 'warga', NULL, '$2y$12$0DoDjjKnI74GaZHz9AwpEeCKrAXBjS07WDstWHbYeU95LjnMPhIQ2', NULL, '2026-09-09 01:57:26', '2026-09-09 02:06:39');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `alur_pelayanans`
--
ALTER TABLE `alur_pelayanans`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indeks untuk tabel `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indeks untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indeks untuk tabel `jenis_sampahs`
--
ALTER TABLE `jenis_sampahs`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indeks untuk tabel `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `ketentuan_sampahs`
--
ALTER TABLE `ketentuan_sampahs`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indeks untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indeks untuk tabel `posyandu_infos`
--
ALTER TABLE `posyandu_infos`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `posyandu_jadwals`
--
ALTER TABLE `posyandu_jadwals`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indeks untuk tabel `site_settings`
--
ALTER TABLE `site_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `site_settings_key_unique` (`key`);

--
-- Indeks untuk tabel `surat_pengajuans`
--
ALTER TABLE `surat_pengajuans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `surat_pengajuans_user_id_foreign` (`user_id`);

--
-- Indeks untuk tabel `syarat_surats`
--
ALTER TABLE `syarat_surats`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `alur_pelayanans`
--
ALTER TABLE `alur_pelayanans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `jenis_sampahs`
--
ALTER TABLE `jenis_sampahs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `ketentuan_sampahs`
--
ALTER TABLE `ketentuan_sampahs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `posyandu_infos`
--
ALTER TABLE `posyandu_infos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `posyandu_jadwals`
--
ALTER TABLE `posyandu_jadwals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT untuk tabel `site_settings`
--
ALTER TABLE `site_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `surat_pengajuans`
--
ALTER TABLE `surat_pengajuans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `syarat_surats`
--
ALTER TABLE `syarat_surats`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `surat_pengajuans`
--
ALTER TABLE `surat_pengajuans`
  ADD CONSTRAINT `surat_pengajuans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
