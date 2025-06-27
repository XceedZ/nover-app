// lib/features/auth/screens/signup_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nover/features/auth/screens/login_screen.dart';
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:snackify/snackify.dart';
import 'package:snackify/enums/snack_enums.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      await _authRepository.register(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Snackify.show(
          context: context,
          type: SnackType.success,
          title: Text(tl('success'), style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.onPrimary)),
          subtitle: Text(tl('signupSuccess'), style: AppFonts.titleSmall(color: Theme.of(context).colorScheme.onPrimary)),
          position: SnackPosition.top,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Snackify.show(
          context: context,
          type: SnackType.error,
          title: Text(tl('error'), style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.onError)?.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(e.toString(), style: AppFonts.titleSmall(color: Theme.of(context).colorScheme.onError), maxLines: 2, overflow: TextOverflow.ellipsis),
          position: SnackPosition.top,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveFontSize(context, 24),
              vertical: responsiveFontSize(context, 20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsiveFontSize(context, 30)),
                  Text(tl('yourNextChapter'), style: AppFonts.headlineLarge(color: colorScheme.onBackground)),
                  SizedBox(height: responsiveFontSize(context, 10)),
                  Text(tl('startExploringStories'), style: AppFonts.titleMedium(color: colorScheme.onBackground.withOpacity(0.7))),
                  SizedBox(height: responsiveFontSize(context, 40)),

                  // Form Fields
                  _buildTextField(context: context, controller: _fullNameController, label: tl('fullName'), icon: Remix.user_3_line, theme: theme, validator: (val) => val!.isEmpty ? tl('fullNameRequired') : null),
                  SizedBox(height: responsiveFontSize(context, 20)),
                  _buildTextField(context: context, controller: _usernameController, label: tl('username'), icon: Remix.shield_user_line, theme: theme, validator: (val) => val!.isEmpty ? tl('usernameRequired') : null),
                  SizedBox(height: responsiveFontSize(context, 20)),
                  _buildTextField(context: context, controller: _emailController, label: tl('email'), icon: Remix.at_line, theme: theme, keyboardType: TextInputType.emailAddress, validator: (val) => val!.isEmpty ? tl('emailRequired') : null),
                  SizedBox(height: responsiveFontSize(context, 20)),
                  _buildTextField(context: context, controller: _passwordController, label: tl('password'), icon: Remix.lock_2_line, theme: theme, isPassword: true, isPasswordVisible: _isPasswordVisible, onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible), validator: (val) => val!.isEmpty ? tl('passwordRequired') : null),

                  SizedBox(height: responsiveFontSize(context, 30)),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12))),
                      ),
                      child: _isLoading
                          ? SizedBox(height: responsiveFontSize(context, 20), width: responsiveFontSize(context, 20), child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onPrimary))
                          : Text(tl('register'), style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: responsiveFontSize(context, 40)),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.7)),
                        children: [
                          TextSpan(text: tl('alreadyHaveAcc') + " "),
                          TextSpan(
                            text: tl('in'),
                            style: AppFonts.titleSmall()?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pop(); // Kembali ke halaman login
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget ini sama persis dengan di login screen
  Widget _buildTextField({required BuildContext context, required TextEditingController controller, required String label, required IconData icon, required ThemeData theme, String? Function(String?)? validator, bool isPassword = false, bool isPasswordVisible = false, VoidCallback? onToggleVisibility, TextInputType? keyboardType}) {
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      style: AppFonts.titleMedium(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
        suffixIcon: isPassword ? IconButton(icon: Icon(isPasswordVisible ? Remix.eye_line : Remix.eye_off_line, color: colorScheme.onSurface.withOpacity(0.6)), onPressed: onToggleVisibility) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)), borderSide: BorderSide(color: colorScheme.primary)),
      ),
    );
  }
}