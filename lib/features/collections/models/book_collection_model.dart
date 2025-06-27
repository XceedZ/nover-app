// lib/features/collections/models/book_collection_model.dart
import 'package:flutter/material.dart';

class BookCollection {
  final String id;
  final String mainBookCoverUrl; // Diubah: Hanya satu URL untuk cover utama
  // List<String> otherBookCoverUrls; // Opsional: Jika masih ingin menyimpan cover lain untuk detail
  final List<String> genres;
  final String title; // Judul koleksi seperti "Masterpieces"
  final String mainAuthorName; // Diubah: Nama author utama
  final int totalChapters;    // Total chapter untuk koleksi/buku utama
  final Color? fallbackCardColor; // Warna fallback jika palette gagal

  BookCollection({
    required this.id,
    required this.mainBookCoverUrl,
    // this.otherBookCoverUrls = const [],
    required this.genres,
    required this.title,
    required this.mainAuthorName,
    required this.totalChapters,
    this.fallbackCardColor,
  });
}