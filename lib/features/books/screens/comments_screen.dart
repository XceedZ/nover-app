// lib/features/books/screens/comments_screen.dart
import 'package:flutter/material.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:remixicon/remixicon.dart';

class CommentsScreen extends StatefulWidget {
  final int bookId;

  const CommentsScreen({super.key, required this.bookId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  final _bookRepository = BookRepository();
  double _currentRating = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentRating == 0.0) {
      AppSnackbar.showError(context, message: tl('ratingRequired')); // Anda perlu menambahkan key ini
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _bookRepository.postReview(
        bookId: widget.bookId,
        content: _reviewController.text,
        rating: _currentRating,
      );

      if (mounted) {
        AppSnackbar.showSuccess(context, message: tl('reviewSubmittedSuccess')); // Key baru
        Navigator.of(context).pop(true); // Kirim sinyal sukses
      }

    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tl('writeReview'), style: AppFonts.appBarTitle(color: colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Remix.close_line),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  tl('howWasTheBook'), // Key baru
                  style: AppFonts.titleLarge(color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _currentRating ? Remix.star_fill : Remix.star_line,
                        color: Colors.amber.shade600,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _reviewController,
                validator: (val) => val!.isEmpty ? tl('validationRequired') : null,
                maxLines: 8,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: tl('shareYourThoughts'), // Key baru
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(tl('submitReview'), style: AppFonts.titleMedium(color: colorScheme.onPrimary)?.copyWith(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
