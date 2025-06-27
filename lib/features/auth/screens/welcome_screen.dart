// lib/features/auth/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/auth/screens/login_screen.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/app_fonts.dart'; // <-- 1. IMPORT BARU
import 'package:nover/features/auth/screens/signup_screen.dart';

// Hapus 'package:google_fonts/google_fonts.dart' jika masih ada

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final bool isDarkMode = theme.brightness == Brightness.dark;
    final String lottiePath = isDarkMode
        ? 'assets/images/AnimationBookDark.json'
        : 'assets/images/AnimationBookLight.json';

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).viewPadding.top,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveFontSize(context, 24),
                vertical: responsiveFontSize(context, 20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Lottie.asset(
                          lottiePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: responsiveFontSize(context, 30)),
                      Text(
                        tl('welcomeTitle'),
                        textAlign: TextAlign.center,
                        // UBAH: Menggunakan AppFonts
                        style: AppFonts.headlineLarge(color: colorScheme.onBackground).copyWith(
                            fontSize: responsiveFontSize(context, 30) // Tetap responsif
                        ),
                      ),
                      SizedBox(height: responsiveFontSize(context, 16)),
                      Text(
                        tl('welcomeSub'),
                        textAlign: TextAlign.center,
                        // UBAH: Menggunakan AppFonts
                        style: AppFonts.titleMedium(
                          color: colorScheme.onBackground.withOpacity(0.7),
                        )?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                  SizedBox(height: responsiveFontSize(context, 40)),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
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
                          child: Text(
                            tl('login'),
                            // UBAH: Menggunakan AppFonts
                            style: AppFonts.titleMedium()?.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: responsiveFontSize(context, 16)),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.outline, width: 1.5),
                            padding: EdgeInsets.symmetric(
                              vertical: responsiveFontSize(context, 16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
                            ),
                          ),
                          child: Text(
                            tl('signup'),
                            // UBAH: Menggunakan AppFonts
                            style: AppFonts.titleMedium()?.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}