import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nover/src/models/genre.dart';
import 'package:nover/src/repositories/book_repository.dart';
import 'package:nover/src/repositories/genre_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookRepository = BookRepository();
  final _genreRepository = GenreRepository();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _coverImage;
  final Set<Genre> _selectedGenres = {};

  late Future<List<Genre>> _genresFuture;

  @override
  void initState() {
    super.initState();
    _genresFuture = _genreRepository.getGenres();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _publishBook() async {
    // 1. Validasi semua input
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_coverImage == null) {
      AppSnackbar.showError(context, message: tl('coverImageRequired'));
      return;
    }
    if (_selectedGenres.isEmpty) {
      AppSnackbar.showError(context, message: tl('genreRequired'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Panggil repository untuk membuat buku
      await _bookRepository.createBook(
        title: _titleController.text,
        description: _descriptionController.text,
        genreIds: _selectedGenres.map((g) => g.genreId).toList(),
        coverImageFile: _coverImage!,
      );

      // 3. Jika berhasil, tampilkan notifikasi dan kembali ke halaman sebelumnya dengan sinyal 'true'
      if (mounted) {
        AppSnackbar.showSuccess(context, message: tl('bookCreatedSuccess'));
        Navigator.of(context).pop(true);
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
        title: Text(tl('createBook'), style: AppFonts.appBarTitle(color: colorScheme.onSurface)),
        leading: IconButton(icon: const Icon(Remix.close_line), onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverImagePicker(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _titleController,
                      label: tl('title'),
                      icon: Remix.book_2_line,
                      validator: (val) => val!.isEmpty ? tl('validationRequired') : null,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _descriptionController,
                      label: tl('description'),
                      icon: Remix.file_text_line,
                      validator: (val) => val!.isEmpty ? tl('validationRequired') : null,
                      maxLines: 5, // Batas tinggi maksimal 5 baris
                      minLines: 1, // Tinggi awal 1 baris
                    ),
                    const SizedBox(height: 24),
                    Text(tl('genres'), style: AppFonts.titleMedium(color: colorScheme.onSurface)?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildGenresSelection(),
                  ],
                ),
              ),
            ),
          ),
          _buildPublishButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int? maxLines = 1,
    int? minLines,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: (maxLines ?? 1) > 1 ? TextInputAction.newline : TextInputAction.next,
      style: AppFonts.titleMedium(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  Widget _buildGenresSelection() {
    return FutureBuilder<List<Genre>>(
      future: _genresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text(tl('error.loadFailed')));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(tl('noGenresAvailable')));
        }

        final availableGenres = snapshot.data!;

        return Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: availableGenres.map((genre) {
            final bool isSelected = _selectedGenres.contains(genre);
            return FilterChip(
              label: Text(tl(genre.genreTl)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenres.add(genre);
                  } else {
                    _selectedGenres.remove(genre);
                  }
                });
              },
              labelStyle: AppFonts.titleSmall(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              shape: StadiumBorder(side: BorderSide(color: Theme.of(context).dividerColor)),
              backgroundColor: Colors.transparent,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPublishButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _publishBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(tl('publishBook'), style: AppFonts.titleMedium(color: colorScheme.onPrimary)?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCoverImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            image: _coverImage != null
                ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                : null,
          ),
          child: _coverImage == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Remix.image_add_line, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(tl('addCover'), style: AppFonts.titleSmall(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          )
              : null,
        ),
      ),
    );
  }
}