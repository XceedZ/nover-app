// lib/features/collections/widgets/collection_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/features/collections/models/book_collection_model.dart';
import 'package:palette_generator/palette_generator.dart';

// Fungsi Helper untuk Font Adaptif
double responsiveFontSize(BuildContext context, double baseFontSize) {
  const double referenceWidth = 375.0;
  double screenWidth = MediaQuery.of(context).size.width;
  double scaleFactor = screenWidth / referenceWidth;
  return baseFontSize * scaleFactor.clamp(0.85, 1.25);
}

class CollectionCardWidget extends StatefulWidget {
  final BookCollection collection;

  const CollectionCardWidget({super.key, required this.collection});

  @override
  State<CollectionCardWidget> createState() => _CollectionCardWidgetState();
}

class _CollectionCardWidgetState extends State<CollectionCardWidget> {
  Color? _cardBackgroundColor;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    // Hindari error NetworkImage("") jika URL kosong, meskipun seharusnya tidak terjadi dengan data yang valid
    if (widget.collection.mainBookCoverUrl.isNotEmpty) {
      _imageProvider = NetworkImage(widget.collection.mainBookCoverUrl);
      _updateBackgroundColor();
    } else {
      _cardBackgroundColor = widget.collection.fallbackCardColor ?? Colors.grey[300];
    }
  }

  @override
  void didUpdateWidget(covariant CollectionCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collection.mainBookCoverUrl != oldWidget.collection.mainBookCoverUrl &&
        widget.collection.mainBookCoverUrl.isNotEmpty) {
      _imageProvider = NetworkImage(widget.collection.mainBookCoverUrl);
      _updateBackgroundColor();
    } else if (widget.collection.mainBookCoverUrl.isEmpty && mounted) {
      setState(() {
        _cardBackgroundColor = widget.collection.fallbackCardColor ?? Colors.grey[300];
      });
    }
  }

  Future<void> _updateBackgroundColor() async {
    if (!mounted || _imageProvider == null) {
      if (mounted) {
        setState(() {
          _cardBackgroundColor = widget.collection.fallbackCardColor ?? Colors.grey[300];
        });
      }
      return;
    }

    // Set warna loading/fallback awal
    if (mounted) {
      setState(() {
        _cardBackgroundColor = widget.collection.fallbackCardColor ?? Colors.grey[300];
      });
    }

    try {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        _imageProvider!,
        size: const Size(100, 150),
        maximumColorCount: 20,
      );
      if (mounted) {
        Color? chosenColor;
        // Prioritaskan Muted, lalu Dominant, lalu Vibrant untuk latar belakang
        chosenColor = paletteGenerator.mutedColor?.color ??
            paletteGenerator.dominantColor?.color ??
            paletteGenerator.vibrantColor?.color;

        setState(() {
          _cardBackgroundColor = chosenColor ?? // Jika semua dari palet null
              widget.collection.fallbackCardColor ?? // Gunakan fallback dari model
              Colors.grey[400]; // Fallback absolut terakhir
        });
      }
    } catch (e) {
      print('Error generating palette for ${widget.collection.title}: $e');
      if (mounted) {
        setState(() {
          _cardBackgroundColor = widget.collection.fallbackCardColor ?? Colors.grey[300];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColorToUse = _cardBackgroundColor ?? widget.collection.fallbackCardColor ?? Colors.grey.shade300!;
    final Color onCardColor = cardColorToUse.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final Color subtleTextColor = onCardColor.withOpacity(0.75);
    final Color genreChipBackgroundColor = onCardColor.withOpacity(0.15);
    final Color genreChipBorderColor = onCardColor.withOpacity(0.25);

    // Tingkatkan base height untuk cardHeight, misal dari 180 menjadi 205 atau 210
    final double cardHeight = responsiveFontSize(context, 205); // PENYESUAIAN TINGGI KARTU

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: cardColorToUse,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: cardHeight, // Terapkan tinggi kartu yang sudah disesuaikan
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian Kiri: Satu Cover Buku
            Container(
              // Lebar bisa disesuaikan, misal sedikit lebih kecil dari tinggi untuk aspek rasio buku
              width: cardHeight * (2.2/3) + 10, // Lebar disesuaikan sedikit
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _imageProvider != null ? Image(
                  image: _imageProvider!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[300], child: Icon(Icons.broken_image, color: Colors.grey[500])),
                ) : Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0))),
              ),
            ),

            // Bagian Kanan: Informasi Teks
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: widget.collection.genres.map((genre) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveFontSize(context, 8),
                              vertical: responsiveFontSize(context, 3),
                            ),
                            decoration: BoxDecoration(
                              color: genreChipBackgroundColor,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: genreChipBorderColor, width: 0.5),
                            ),
                            child: Text(
                              genre,
                              style: GoogleFonts.montserrat(
                                fontSize: responsiveFontSize(context, 9),
                                color: onCardColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.collection.title,
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 16), // Sedikit dikurangi jika perlu
                            fontWeight: FontWeight.w600,
                            color: onCardColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.collection.mainAuthorName,
                          style: GoogleFonts.montserrat(
                            fontSize: responsiveFontSize(context, 10.5), // Sedikit dikurangi jika perlu
                            color: subtleTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            widget.collection.totalChapters.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: responsiveFontSize(context, 38), // Sedikit dikurangi jika perlu
                              fontWeight: FontWeight.w700,
                              color: onCardColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0), // Disesuaikan agar baseline lebih pas
                            child: Text(
                              'Chapters',
                              style: GoogleFonts.montserrat(
                                fontSize: responsiveFontSize(context, 10.5), // Sedikit dikurangi jika perlu
                                color: subtleTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}