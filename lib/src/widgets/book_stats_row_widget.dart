// lib/src/widgets/book_stats_row_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';

/// #1: Widget untuk Latar Belakang/Container Utama
class StatsRowContainer extends StatelessWidget {
  final List<Widget> children;

  const StatsRowContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsiveFontSize(context, 14),
        horizontal: responsiveFontSize(context, 10),
      ),
      decoration: BoxDecoration(
        // --- PERUBAHAN DI SINI ---
        // Menggunakan cardColor agar sama dengan kartu status
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)), // Radius disamakan dengan kartu status
        boxShadow: [ // Menambahkan sedikit shadow agar konsisten
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}

// ... (Widget StatItem dan StatDivider tidak ada perubahan)
/// #2: Widget untuk Satu Item Statistik (Nilai & Label)
class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = Theme.of(context).colorScheme.onSurface;
    final labelColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 15),
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 3)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 11),
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// #3: Widget untuk Garis Pemisah Vertikal
class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: responsiveFontSize(context, 30),
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}