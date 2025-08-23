import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // ✨ 1. Impor package markdown
import 'package:lottie/lottie.dart';
import 'package:nover/features/settings/services/update_service.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/src/utils/translation.dart';

class UpdateAvailableBottomSheet extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateAvailableBottomSheet({super.key, required this.updateInfo});

  @override
  State<UpdateAvailableBottomSheet> createState() =>
      _UpdateAvailableBottomSheetState();
}

class _UpdateAvailableBottomSheetState
    extends State<UpdateAvailableBottomSheet> {
  bool _isDownloading = false;
  double _progress = 0.0;

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    final updateService = UpdateService();
    updateService.downloadAndInstall(widget.updateInfo.downloadUrl, (progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 32 + MediaQuery.of(context).viewPadding.bottom),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: Lottie.asset('assets/images/updateAnimateLight.json'),
          ),
          const SizedBox(height: 10),
          Text(
            tl('updateAvailable'),
            textAlign: TextAlign.center,
            style: AppFonts.titleLarge(color: theme.colorScheme.onSurface)
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${tl('version')} ${widget.updateInfo.latestVersion}',
            textAlign: TextAlign.center,
            style: AppFonts.titleMedium(
                color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          _buildReleaseNotes(context),
          const SizedBox(height: 24),
          _isDownloading
              ? _buildDownloadProgress(context)
              : _buildActionButtons(context),
        ],
      ),
    );
  }

  // ✨ 2. Widget diperbarui untuk menggunakan Markdown
  Widget _buildReleaseNotes(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: responsiveFontSize(context, 150)), // Sedikit lebih tinggi
      padding: const EdgeInsets.symmetric(horizontal: 4), // Padding horizontal dikurangi
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: Markdown(
          data: widget.updateInfo.releaseNotes,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Sesuaikan gaya Markdown agar cocok dengan gaya aplikasi Anda
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: AppFonts.bodyMedium(
                color: theme.colorScheme.onSurface.withOpacity(0.8)),
            listBullet: AppFonts.bodyMedium(
                color: theme.colorScheme.onSurface.withOpacity(0.8)),
            h2: AppFonts.titleMedium(
                color: theme.colorScheme.onSurface),
            h3: AppFonts.titleSmall(
                color: theme.colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold),
          ),
          shrinkWrap: true,
        ),
      ),
    );
  }

  Widget _buildDownloadProgress(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: theme.dividerColor,
            color: theme.colorScheme.primary,
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${tl('downloading')}... ${(_progress * 100).toStringAsFixed(0)}%',
          textAlign: TextAlign.center,
          style: AppFonts.titleSmall(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: AppFonts.titleMedium(color: theme.colorScheme.onPrimary)
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          onPressed: _startDownload,
          child: Text(tl('downloadUpdate')),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            tl('notNow'),
            style: AppFonts.titleMedium(
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ),
      ],
    );
  }
}