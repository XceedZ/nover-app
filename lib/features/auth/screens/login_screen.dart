// lib/features/auth/screens/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nover/features/home/screens/home_page.dart';
import 'package:nover/features/auth/screens/signup_screen.dart';
import 'package:nover/main.dart';
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:snackify/snackify.dart';
import 'package:snackify/enums/snack_enums.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      // Baris ini sekarang akan menerima Map<String, dynamic>, bukan void
      final userData = await _authRepository.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // Baris ini sekarang valid karena userData tidak lagi void
        authNotifier.value = userData;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Snackify.show(
          context: context,
          type: SnackType.error,
          title: Text(
            tl('error'),
            style: AppFonts.titleMedium(color: Theme.of(context).colorScheme.onError)
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            e.toString(),
            style: AppFonts.titleSmall(color: Theme.of(context).colorScheme.onError),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
                  Text(
                    tl('continueYourStory'),
                    style: AppFonts.headlineLarge(color: colorScheme.onBackground),
                  ),
                  SizedBox(height: responsiveFontSize(context, 10)),
                  Text(
                    tl('loginToPickup'),
                    style: AppFonts.titleMedium(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: responsiveFontSize(context, 40)),
                  _buildTextField(
                    context: context,
                    controller: _usernameController,
                    label: tl('username'),
                    icon: Remix.shield_user_line,
                    theme: theme,
                    validator: (value) {
                      if (value == null || value.isEmpty) return tl('usernameRequired');
                      return null;
                    },
                  ),
                  SizedBox(height: responsiveFontSize(context, 20)),
                  _buildTextField(
                    context: context,
                    controller: _passwordController,
                    label: tl('password'),
                    icon: Remix.lock_2_line,
                    theme: theme,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return tl('passwordRequired');
                      return null;
                    },
                  ),
                  SizedBox(height: responsiveFontSize(context, 12)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        tl('forgotPassword'),
                        style: AppFonts.titleSmall(
                          color: colorScheme.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveFontSize(context, 20)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: responsiveFontSize(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: responsiveFontSize(context, 20),
                        width: responsiveFontSize(context, 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.onPrimary,
                        ),
                      )
                          : Text(
                        tl('login'),
                        style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: responsiveFontSize(context, 30)),
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          tl('or'),
                          style: AppFonts.titleSmall(color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.5))),
                    ],
                  ),
                  SizedBox(height: responsiveFontSize(context, 30)),
                  _buildSocialButton(
                    context: context,
                    icon: Remix.google_fill,
                    text: "GOOGLE",
                    theme: theme,
                    onPressed: () {},
                  ),
                  SizedBox(height: responsiveFontSize(context, 40)),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        style: AppFonts.titleSmall(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(text: tl('dontHaveAcc') + " "),
                          TextSpan(
                            text: tl('register'),
                            style: AppFonts.titleSmall()?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
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

  Widget _buildTextField(
      {required BuildContext context,
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required ThemeData theme,
        String? Function(String?)? validator,
        bool isPassword = false,
        bool isPasswordVisible = false,
        VoidCallback? onToggleVisibility}) {
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword && !isPasswordVisible,
      style: AppFonts.titleMedium(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        AppFonts.titleMedium(color: colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Remix.eye_line : Remix.eye_off_line,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      {required BuildContext context,
        required IconData icon,
        required String text,
        required ThemeData theme,
        required VoidCallback onPressed}) {
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(
          text,
          style: AppFonts.titleMedium()?.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onBackground.withOpacity(0.85),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          padding:
          EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14)),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(responsiveFontSize(context, 12)),
          ),
        ),
      ),
    );
  }
}