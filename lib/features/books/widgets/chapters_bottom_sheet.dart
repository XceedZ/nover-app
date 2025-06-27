// lib/features/books/widgets/chapters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/features/home/screens/home_screen_content.dart' show Book; // For Book model
import 'package:nover/src/utils/ui_helpers.dart'; // Pastikan path ini benar
import 'package:remixicon/remixicon.dart';

// Model for chapter info
class ChapterInfo {
  final String title;
  final String date;
  ChapterInfo({required this.title, required this.date});
}

class ChaptersBottomSheet extends StatelessWidget {
  final Book book;
  final List<ChapterInfo> chapters;
  final int totalChapters;

  const ChaptersBottomSheet({
    super.key,
    required this.book,
    required this.chapters,
    required this.totalChapters,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dari tema aplikasi saat ini untuk bottom sheet terang
    final Color sheetBackgroundColor = Theme.of(context).colorScheme.surface; // Biasanya putih di tema terang
    final Color onSheetColor = Theme.of(context).colorScheme.onSurface;     // Biasanya hitam di tema terang
    final Color subtleOnSheetColor = onSheetColor.withOpacity(0.65);       // Abu-abu untuk teks sekunder
    final Color dividerColor = Theme.of(context).colorScheme.secondary;                      // Warna divider untuk tema terang
    final Color iconColor = onSheetColor.withOpacity(0.7);                // Warna ikon umum
    final Color accentColor = Theme.of(context).colorScheme.primary;      // Warna aksen (tombol)

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        child: Container(
          color: sheetBackgroundColor,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(responsiveFontSize(context, 16.0)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(responsiveFontSize(context, 4.0)),
                      child: Image.network(
                        book.imageUrl,
                        width: responsiveFontSize(context, 48.0),
                        height: responsiveFontSize(context, 48.0 * 1.5),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          width: responsiveFontSize(context, 48.0),
                          height: responsiveFontSize(context, 48.0 * 1.5),
                          color: Colors.grey[200], // Warna placeholder gambar lebih terang
                          child: Icon(Remix.image_line, color: Colors.grey[400], size: responsiveFontSize(context, 24)),
                        ),
                      ),
                    ),
                    SizedBox(width: responsiveFontSize(context, 12.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: GoogleFonts.montserrat(
                              fontSize: responsiveFontSize(context, 15.0),
                              fontWeight: FontWeight.w600,
                              color: onSheetColor, // Teks utama
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: responsiveFontSize(context, 4.0)),
                          Row(
                            children: [
                              SizedBox(width: responsiveFontSize(context, 4.0)),
                              Expanded(
                                child: Text(
                                  book.author,
                                  style: GoogleFonts.montserrat(
                                    fontSize: responsiveFontSize(context, 12.0),
                                    color: subtleOnSheetColor, // Teks sekunder
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Remix.close_line, color: iconColor, size: responsiveFontSize(context, 24.0)), // Warna ikon
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: dividerColor, height: 1), // Warna divider
              // Sub-Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0), vertical: responsiveFontSize(context, 10.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chapters ($totalChapters)",
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 14.0),
                        fontWeight: FontWeight.w500,
                        color: onSheetColor, // Teks utama
                      ),
                    ),
                    Icon(Remix.filter_3_line, color: iconColor, size: responsiveFontSize(context, 22.0)), // Warna ikon
                  ],
                ),
              ),
              // Chapter List
              Expanded(
                child: chapters.isEmpty
                    ? Center(
                  child: Text(
                    "No chapters yet",
                    style: GoogleFonts.montserrat(color: subtleOnSheetColor, fontSize: responsiveFontSize(context, 14)),
                  ),
                )
                    : ListView.separated(
                  itemCount: chapters.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext listContext, int index) {
                    final chapter = chapters[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
                      title: Text(
                        chapter.title,
                        style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 14.0),
                            color: onSheetColor, // Teks utama
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      subtitle: Text(
                        chapter.date,
                        style: GoogleFonts.montserrat(
                          fontSize: responsiveFontSize(context, 11.0),
                          color: subtleOnSheetColor, // Teks sekunder
                        ),
                      ),
                      onTap: () {
                        print("Tapped on ${chapter.title}");
                        Navigator.pop(context);
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(color: dividerColor.withOpacity(0.5), height: 0.5, indent: responsiveFontSize(context, 16), endIndent: responsiveFontSize(context,16)), // Warna divider lebih subtle
                ),
              ),
              // Footer Button
              if (chapters.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(responsiveFontSize(context, 16.0)).copyWith(bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : responsiveFontSize(context, 16.0)),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor, // Warna aksen (hitam di tema Anda)
                      padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14.0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12.0)),
                      ),
                    ),
                    onPressed: () {
                      print("Unlock Chapters tapped");
                    },
                    child: Text(
                      "UNLOCK CHAPTERS",
                      style: GoogleFonts.montserrat(
                        fontSize: responsiveFontSize(context, 14.0),
                        fontWeight: FontWeight.w600,
                        // Teks tombol menjadi putih karena accentColor (primary) Anda adalah hitam
                        color: accentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}