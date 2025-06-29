// lib/src/widgets/custom_chips.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/splitter.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:remixicon/remixicon.dart';

// ===================================================================
// == SISTEM 1: CHIP NORMAL (Latar Belakang Gelap Konsisten) ==
// ===================================================================
class CustomChip extends StatelessWidget {
  final String label;

  const CustomChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final Color chipBackgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFF424242);
    const Color chipTextColor = Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveFontSize(context, 7),
        vertical: responsiveFontSize(context, 2.5),
      ),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 5)),
      ),
      child: Text(
        label,
        style: AppFonts.titleSmall(color: chipTextColor)?.copyWith(
          fontSize: responsiveFontSize(context, 9.5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class GenreChips extends StatelessWidget {
  final String? genreString;
  const GenreChips({super.key, this.genreString});

  @override
  Widget build(BuildContext context) {
    if (genreString == null || genreString!.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<String> genres = splitGenres(genreString!);

    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: genres.map((genre) => CustomChip(label: genre)).toList(),
    );
  }
}


// ===================================================================
// == SISTEM 2: CHIP DINAMIS (Warna Bisa Disesuaikan) ==
// ===================================================================
class StyledChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const StyledChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveFontSize(context, 10),
        vertical: responsiveFontSize(context, 4),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: borderColor != null ? Border.all(color: borderColor!, width: 0.5) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: responsiveFontSize(context, 10),
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class DynamicGenreChips extends StatelessWidget {
  final String? genreString;
  final Color backgroundColor;
  final Color textColor;

  const DynamicGenreChips({
    super.key,
    this.genreString,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (genreString == null || genreString!.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<String> genres = splitGenres(genreString!);

    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: genres.map((genre) {
        return StyledChip(
          label: genre.trim(),
          backgroundColor: backgroundColor,
          textColor: textColor,
          borderColor: textColor.withOpacity(0.3),
        );
      }).toList(),
    );
  }
}


// ===================================================================
// == WIDGET BARU: CHIP STATUS (Diperbarui dengan Gaya Tema) ==
// ===================================================================

class ChipStatus extends StatelessWidget {
  final String status;

  const ChipStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color baseColor;
    IconData iconData;
    String label;

    // Tentukan warna dasar, ikon, dan label berdasarkan status
    switch (status) {
      case 'D': // Draft
        baseColor = Colors.amber;
        iconData = Remix.edit_box_line;
        label = tl('draft');
        break;
      case 'P': // Published
        baseColor = Colors.blue.shade600; // Menggunakan warna primer dari tema
        iconData = Remix.global_line;
        label = tl('published');
        break;
      case 'C': // Completed
        baseColor = Colors.green.shade600;
        iconData = Remix.checkbox_circle_line;
        label = tl('completed');
        break;
      case 'H': // On Hold
        baseColor = Colors.orange.shade700;
        iconData = Remix.pause_circle_line;
        label = tl('onHold');
        break;
      default: // Fallback
        baseColor = Colors.grey.shade600;
        iconData = Remix.question_mark;
        label = status;
    }

    // Terapkan gaya "Unpublish Button"
    // Latar belakang dengan opasitas rendah, teks/ikon dengan warna solid
    final Color backgroundColor = baseColor.withOpacity(0.1);
    final Color contentColor = baseColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: contentColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppFonts.titleSmall(color: contentColor)?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}