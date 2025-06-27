// lib/src/widgets/book_stats_row_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart'; // Pastikan path ini benar

class BookStatsRowWidget extends StatelessWidget {
  final int pages;
  final String language;
  final double rating;

  const BookStatsRowWidget({
    super.key,
    required this.pages,
    required this.language,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final Color statsBackgroundColor = Theme.of(context).colorScheme.surface;
    final Color statValueColor = Theme.of(context).colorScheme.onSurface;
    final Color statLabelColor = Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: responsiveFontSize(context, 14), // Sedikit dikurangi dari 16
          horizontal: responsiveFontSize(context, 10)),
      decoration: BoxDecoration(
        color: statsBackgroundColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)), // Radius lebih kecil
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Gunakan spaceAround agar merata
        children: [
          _buildStatItem(context, pages.toString(), 'Chapters', statValueColor, statLabelColor),
          _buildVerticalDivider(context),
          _buildStatItem(context, language, 'Language', statValueColor, statLabelColor),
          _buildVerticalDivider(context),
          _buildStatItem(context, rating.toStringAsFixed(1), 'Rating', statValueColor, statLabelColor),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: responsiveFontSize(context, 30),
      width: 1,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color valueColor, Color labelColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 15), // Ukuran disesuaikan
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        SizedBox(height: responsiveFontSize(context, 3)),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: responsiveFontSize(context, 11), // Ukuran disesuaikan
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}