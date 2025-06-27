// lib/components/author_application_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:nover/src/models/bank.dart';
import 'package:nover/src/repositories/bank_repository.dart';
import 'package:nover/src/utils/app_fonts.dart'; // <-- PASTIKAN IMPORT INI ADA
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/widgets/custom_bank_dropdown.dart';

class AuthorApplicationBottomSheet extends StatefulWidget {
  const AuthorApplicationBottomSheet({super.key});

  @override
  State<AuthorApplicationBottomSheet> createState() =>
      _AuthorApplicationBottomSheetState();
}

class _AuthorApplicationBottomSheetState
    extends State<AuthorApplicationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Bank>> _bankListFuture;
  Bank? _selectedBank;
  bool _isLoading = false;

  final _penNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  final _accountNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bankListFuture = BankRepository().getBankList();
  }

  @override
  void dispose() {
    _penNameController.dispose();
    _phoneController.dispose();
    _portfolioLinkController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate() && _selectedBank != null) {
      setState(() {
        _isLoading = true;
      });

      final applicationData = {
        'penName': _penNameController.text,
        'phone': _phoneController.text,
        'portfolio': _portfolioLinkController.text,
        'bankId': _selectedBank?.bankId,
        'accountNumber': _accountNumberController.text,
      };

      print('Data Pendaftaran: $applicationData');

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tl('author.form.successMessage')),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tl('bankRequired')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- PERUBAHAN: Menggunakan AppFonts ---
              Text(
                tl('formTitle'),
                style: AppFonts.titleLarge(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                tl('formSub'),
                style: AppFonts.titleSmall(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                  controller: _penNameController,
                  labelText: tl('penName'),
                  icon: Remix.pen_nib_line),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _phoneController,
                  labelText: tl('phone'),
                  icon: Remix.phone_line,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _portfolioLinkController,
                  labelText: tl('instagram'),
                  icon: Remix.instagram_line),
              const SizedBox(height: 24),
              _buildDividerWithText(context: context, text: tl('paymentInfo')),
              const SizedBox(height: 16),

              FutureBuilder<List<Bank>>(
                future: _bankListFuture,
                builder: (context, snapshot) {
                  bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  bool isError = snapshot.hasError;

                  return CustomBankDropdown(
                    labelText: tl('bankName'),
                    hintText: isLoading
                        ? 'Memuat bank...'
                        : isError
                        ? 'Gagal memuat'
                        : tl('bankName'),
                    value: _selectedBank,
                    items: snapshot.data ?? [],
                    isDisabled: isLoading || isError,
                    onChanged: (Bank selectedBank) {
                      setState(() {
                        _selectedBank = selectedBank;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _accountNumberController,
                labelText: tl('accountNumber'),
                icon: Remix.bank_card_2_line,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                      : Text(
                    tl('submitForm'),
                    // --- PERUBAHAN: Menggunakan AppFonts ---
                    style: AppFonts.titleMedium(color: theme.colorScheme.onPrimary)
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return tl('validationRequired');
        }
        return null;
      },
      // --- PERUBAHAN: Menggunakan AppFonts ---
      style: AppFonts.titleMedium(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        // --- PERUBAHAN: Menggunakan AppFonts ---
        labelStyle:
        AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.6)),
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
      ),
    );
  }

  Widget _buildDividerWithText(
      {required BuildContext context, required String text}) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodySmall?.color?.withOpacity(0.8);
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: theme.dividerColor.withOpacity(0.5), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          // --- PERUBAHAN: Menggunakan AppFonts ---
          child: Text(text, style: AppFonts.titleSmall(color: textColor)?.copyWith(fontSize: 12)),
        ),
        Expanded(
            child: Divider(
                color: theme.dividerColor.withOpacity(0.5), thickness: 1)),
      ],
    );
  }
}