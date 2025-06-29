// lib/features/author/screens/became_author_screen.dart

import 'package:flutter/material.dart';
import 'package:nover/main.dart';
import 'package:nover/src/repositories/author_repository.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/author/widgets/author_application_bottom_sheet.dart';
import 'package:nover/src/utils/app_fonts.dart';

class BecameAuthorScreen extends StatefulWidget {
  const BecameAuthorScreen({super.key});

  @override
  State<BecameAuthorScreen> createState() => _BecameAuthorScreenState();
}

class _BecameAuthorScreenState extends State<BecameAuthorScreen> {
  final AuthorRepository _authorRepository = AuthorRepository();
  late Future<Map<String, dynamic>> _authorStatusFuture;

  @override
  void initState() {
    super.initState();
    _authorStatusFuture = _authorRepository.getAuthorStatus();
  }

  void _refreshAuthorStatus() {
    setState(() {
      _authorStatusFuture = _authorRepository.checkAndRefreshAuthorStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tl('becomeAuthor'),
          // UBAH: Menggunakan style AppBar yang baru dan konsisten
          style: AppFonts.appBarTitle(color: primaryTextColor)?.copyWith(
            fontSize: responsiveFontSize(context, 18),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _authorStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          }
          final bool isAuthor = snapshot.data?['isAuthor'] ?? false;

          return _buildContent(context, theme, isAuthor);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isAuthor) {
    final colorScheme = theme.colorScheme;
    return ListView(
      padding: EdgeInsets.only(
        left: responsiveFontSize(context, 16.0),
        right: responsiveFontSize(context, 16.0),
        top: responsiveFontSize(context, 16.0),
        bottom: responsiveFontSize(context, 32.0),
      ),
      children: [
        if (isAuthor) ...[
          _buildAuthorStatusCard(context, theme),
          SizedBox(height: responsiveFontSize(context, 24)),
        ],
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
                style: AppFonts.titleLarge(color: colorScheme.onSurface)?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(context, 22),
                ),
              ),
              SizedBox(height: responsiveFontSize(context, 8)),
              Text(
                tl('joinDesc'),
                style: AppFonts.titleSmall(color: theme.textTheme.bodySmall?.color)?.copyWith(height: 1.5),
              ),
              SizedBox(height: responsiveFontSize(context, 32)),
              _buildDividerWithText(context: context, text: tl('benefitsTitle')),
              SizedBox(height: responsiveFontSize(context, 20)),
              _buildBenefitItem(context, Remix.wallet_3_line, tl('benefitsMonetizeTitle'), tl('benefitsMonetizeDesc'), Colors.orange.shade600),
              SizedBox(height: responsiveFontSize(context, 18)),
              _buildBenefitItem(context, Remix.group_line, tl('benefitsAudienceTitle'), tl('benefitsAudienceDesc'), Colors.blue.shade600),
              SizedBox(height: responsiveFontSize(context, 18)),
              _buildBenefitItem(context, Remix.medal_line, tl('benefitsBrandTitle'), tl('benefitsBrandDesc'), Colors.green.shade600),
              SizedBox(height: responsiveFontSize(context, 32)),
              _buildDividerWithText(context: context, text: tl('requirementsTitle')),
              SizedBox(height: responsiveFontSize(context, 20)),
              _buildRequirementItem(context, tl('requirementsOriginal')),
              _buildRequirementItem(context, tl('requirementsQuality')),
              _buildRequirementItem(context, tl('requirementsUpdates')),
              SizedBox(height: responsiveFontSize(context, 32)),
              if (!isAuthor)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (context) => const AuthorApplicationBottomSheet(),
                      ).then((result) {
                        if (result == 'submitted') {
                          _refreshAuthorStatus();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12))),
                    ),
                    child: Text(
                      tl('applyNow'),
                      style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.bold, fontSize: responsiveFontSize(context, 15)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorStatusCard(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(responsiveFontSize(context, 8)),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Remix.verified_badge_fill,
              color: colorScheme.primary,
              size: responsiveFontSize(context, 24),
            ),
          ),
          SizedBox(width: responsiveFontSize(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tl('alreadyAuthor'),
                  style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: responsiveFontSize(context, 4)),
                Text(
                  tl('alreadyAuthorDesc'),
                  style: AppFonts.titleSmall(color: theme.textTheme.bodySmall?.color)?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerWithText({required BuildContext context, required String text}) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withOpacity(0.5);
    final textColor = theme.textTheme.bodySmall?.color?.withOpacity(0.8);

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(text, style: AppFonts.titleSmall(color: textColor)?.copyWith(fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Divider(color: dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String subtitle, Color iconColor) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: responsiveFontSize(context, 20), backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: responsiveFontSize(context, 20))),
        SizedBox(width: responsiveFontSize(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.titleMedium(color: theme.colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold, fontSize: responsiveFontSize(context, 14.5)),
              ),
              SizedBox(height: responsiveFontSize(context, 4)),
              Text(
                subtitle,
                style: AppFonts.titleSmall(color: theme.textTheme.bodySmall?.color)?.copyWith(fontSize: responsiveFontSize(context, 13), height: 1.5),
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
              style: AppFonts.titleSmall(color: theme.textTheme.bodySmall?.color?.withOpacity(0.9))?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
