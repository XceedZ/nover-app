// lib/features/author/screens/became_author_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import lottie tidak lagi diperlukan
// import 'package:lottie/lottie.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/author/widgets/author_application_bottom_sheet.dart';

class BecameAuthorScreen extends StatelessWidget {
  const BecameAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBgColor = theme.scaffoldBackgroundColor;
    final primaryTextColor = colorScheme.onSurface;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tl('becomeAuthor'),
          style: GoogleFonts.montserrat(
              color: primaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: responsiveFontSize(context, 18)),
        ),
        centerTitle: true,
      ),
      body: ListView(
        // Beri sedikit padding atas untuk menggantikan ruang dari Lottie
        padding: EdgeInsets.only(
          left: responsiveFontSize(context, 16.0),
          right: responsiveFontSize(context, 16.0),
          top: responsiveFontSize(context, 16.0),
          bottom: responsiveFontSize(context, 32.0),
        ),
        children: [
          // Lottie dan SizedBox di atasnya sudah dihapus

          Container(
            padding: EdgeInsets.all(responsiveFontSize(context, 20)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tl('joinAsNoverAuthor'),
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: responsiveFontSize(context, 8)),
                Text(
                  tl('joinDesc'),
                  style: GoogleFonts.montserrat(
                    fontSize: responsiveFontSize(context, 14),
                    color: theme.textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: responsiveFontSize(context, 32)),

                // --- BAGIAN BARU: Menggunakan Divider dengan Teks ---
                _buildDividerWithText(context: context, text: tl('benefitsTitle')),
                SizedBox(height: responsiveFontSize(context, 20)),

                _buildBenefitItem(
                  context,
                  Remix.wallet_3_line,
                  tl('benefitsMonetizeTitle'),
                  tl('benefitsMonetizeDesc'),
                  Colors.orange.shade600,
                ),
                SizedBox(height: responsiveFontSize(context, 18)),
                _buildBenefitItem(
                  context,
                  Remix.group_line,
                  tl('benefitsAudienceTitle'),
                  tl('benefitsAudienceDesc'),
                  Colors.blue.shade600,
                ),
                SizedBox(height: responsiveFontSize(context, 18)),
                _buildBenefitItem(
                  context,
                  Remix.medal_line,
                  tl('benefitsBrandTitle'),
                  tl('benefitsBrandDesc'),
                  Colors.green.shade600,
                ),
                SizedBox(height: responsiveFontSize(context, 32)),

                // --- BAGIAN BARU: Menggunakan Divider dengan Teks ---
                _buildDividerWithText(context: context, text: tl('requirementsTitle')),
                SizedBox(height: responsiveFontSize(context, 20)),

                _buildRequirementItem(context, tl('requirementsOriginal')),
                _buildRequirementItem(context, tl('requirementsQuality')),
                _buildRequirementItem(context, tl('requirementsUpdates')),

                SizedBox(height: responsiveFontSize(context, 32)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton( // Diubah dari ElevatedButton.icon
                    onPressed: () {
                      // --- KODE UNTUK MENAMPILKAN BOTTOM SHEET ---
                      showModalBottomSheet(
                        context: context,
                        // Penting agar bottom sheet bisa di-scroll dan tidak tertutup keyboard
                        isScrollControlled: true,
                        // Memberi sudut melengkung di atas
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => const AuthorApplicationBottomSheet(),
                      );
                      // --- AKHIR DARI KODE BOTTOM SHEET ---
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12))),
                        textStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: responsiveFontSize(context, 15)
                        )
                    ),
                    child: Text(tl('applyNow')), // 'label' menjadi 'child'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARU: Divider dengan Teks ---
  Widget _buildDividerWithText({required BuildContext context, required String text}) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withOpacity(0.5);
    final textColor = theme.textTheme.bodySmall?.color?.withOpacity(0.8);

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              color: textColor,
              fontSize: responsiveFontSize(context, 12),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
      ],
    );
  }

  // Widget _buildSectionHeader sudah tidak diperlukan lagi dan bisa dihapus

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String subtitle, Color iconColor) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: responsiveFontSize(context, 20),
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: responsiveFontSize(context, 20)),
        ),
        SizedBox(width: responsiveFontSize(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                    color: theme.colorScheme.onSurface,
                    fontSize: responsiveFontSize(context, 14.5),
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: responsiveFontSize(context, 4)),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: responsiveFontSize(context, 13),
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(Remix.checkbox_circle_line, color: Colors.green.shade600, size: responsiveFontSize(context, 16)),
          ),
          SizedBox(width: responsiveFontSize(context, 12)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: responsiveFontSize(context, 14),
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}