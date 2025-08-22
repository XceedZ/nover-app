// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nover/features/auth/screens/welcome_screen.dart';
import 'package:nover/src/repositories/auth_repository.dart';
import 'package:nover/src/repositories/dicebear_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/features/settings/screens/settings_screen.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/main.dart';
import 'coin_details_screen.dart';
import 'package:nover/features/event_center/screens/event_center_screen.dart';
import 'package:nover/features/author/screens/became_author_screen.dart';
import 'package:nover/features/posts/screens/my_posts_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Variabel warna dan gaya
    final onSurfaceColor = colorScheme.onSurface;
    final subtleTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;
    final balanceCardBackgroundColor = theme.brightness == Brightness.light
        ? Colors.grey.shade50
        : colorScheme.surfaceVariant.withOpacity(0.5);
    final warningTextColor = theme.brightness == Brightness.light
        ? Colors.orange.shade800
        : Colors.orange.shade300;
    final warningBackgroundColor = theme.brightness == Brightness.light
        ? Colors.orange.shade100
        : Colors.orange.shade900.withOpacity(0.5);
    final coinsIconColor = Colors.orange.shade600;
    final bonusCoinsIconColor = Colors.lightBlue.shade500;
    final dividerColor = theme.dividerColor;
    final cardShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.08),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
    final accentBadgeColor = Colors.green.shade600;

    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: authNotifier,
      builder: (context, currentUser, child) {
        final bool isLoggedIn = currentUser != null;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildProfileHeader(context, theme, isLoggedIn, currentUser),
                Padding(
                  padding: EdgeInsets.only(
                    top: isLoggedIn ? responsiveFontSize(context, 20) : responsiveFontSize(context, 24),
                    left: responsiveFontSize(context, 16.0),
                    right: responsiveFontSize(context, 16.0),
                  ),
                  child: isLoggedIn
                      ? _buildBalanceCard(
                      context,
                      balanceCardBackgroundColor,
                      onSurfaceColor,
                      subtleTextColor,
                      colorScheme.primary,
                      colorScheme.onPrimary,
                      warningTextColor,
                      warningBackgroundColor,
                      coinsIconColor,
                      bonusCoinsIconColor,
                      dividerColor,
                      cardShadow)
                      : _buildLoginPromptCard(context, theme, cardShadow),
                ),
                SizedBox(height: responsiveFontSize(context, 24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16.0)),
                  child: _buildMenuListContainer(
                      context,
                      onSurfaceColor,
                      subtleTextColor,
                      accentBadgeColor,
                      colorScheme.primary,
                      colorScheme.onPrimary,
                      theme.cardColor,
                      cardShadow,
                      dividerColor,
                      isLoggedIn),
                ),
                SizedBox(height: responsiveFontSize(context, 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, bool isLoggedIn, Map<String, dynamic>? userData) {
    if (!isLoggedIn || userData == null) return const SizedBox.shrink();

    final dicebearRepo = DicebearRepository();
    final colorScheme = theme.colorScheme;
    final String fullName = userData['fullName'] ?? tl('user');
    final String? userAvatarUrl = userData['avatarUrl'];

    Widget avatarWidget;
    if (userAvatarUrl != null && userAvatarUrl.isNotEmpty) {
      avatarWidget = userAvatarUrl.endsWith('.svg')
          ? SvgPicture.network(userAvatarUrl, fit: BoxFit.cover)
          : Image.network(userAvatarUrl, fit: BoxFit.cover);
    } else {
      final String dicebearUrl = dicebearRepo.getAvatarUrl(fullName);
      avatarWidget = SvgPicture.network(dicebearUrl, fit: BoxFit.cover);
    }

    return Padding(
      padding: EdgeInsets.only(top: responsiveFontSize(context, 24), left: responsiveFontSize(context, 16), right: responsiveFontSize(context, 16), bottom: responsiveFontSize(context, 16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: responsiveFontSize(context, 32),
            backgroundColor: colorScheme.surfaceVariant,
            child: ClipOval(child: avatarWidget),
          ),
          SizedBox(width: responsiveFontSize(context, 16)),
          Expanded(
            child: Text(
              fullName,
              style: AppFonts.headerStyle.copyWith(fontSize: responsiveFontSize(context, 24), color: colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Remix.edit_2_line, size: responsiveFontSize(context, 24), color: colorScheme.onSurface.withOpacity(0.7)),
            onPressed: () => print('Edit Profile tapped'),
            tooltip: tl('editProfileTooltip'),
          )
        ],
      ),
    );
  }

  Widget _buildLoginPromptCard(BuildContext context, ThemeData theme, List<BoxShadow> boxShadow) {
    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 24)),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(responsiveFontSize(context, 20)), boxShadow: boxShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(responsiveFontSize(context, 8)),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Remix.login_circle_line, color: theme.colorScheme.primary, size: responsiveFontSize(context, 24)),
          ),
          SizedBox(height: responsiveFontSize(context, 24)),
          Text(
            tl('label.accStatus'),
            style: AppFonts.labelSmall(color: theme.colorScheme.onSurface.withOpacity(0.6))?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: responsiveFontSize(context, 4)),
          Text(
            tl('label.youNotLoggedIn'),
            style: AppFonts.headlineMediumM(color: theme.colorScheme.onSurface),
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          Text(
            tl('label.loginDesc'),
            style: AppFonts.bodyMedium(color: theme.colorScheme.onSurface.withOpacity(0.7))?.copyWith(height: 1.5),
          ),
          SizedBox(height: responsiveFontSize(context, 24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 14)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 12))),
              ),
              child: Text(
                tl('label.login'),
                style: AppFonts.titleSmall(color: theme.colorScheme.onPrimary)?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, Color cardBgColor, Color onCardColor, Color subtleOnCardColor, Color buttonBgColor, Color buttonTextColor, Color warningTextColor, Color warningBackgroundColor, Color coinsIconColor, Color bonusCoinsIconColor, Color dividerColor, List<BoxShadow> boxShadow) {
    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 20)),
      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)), boxShadow: boxShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tl('profile.balance.remainingBalance'),
                style: AppFonts.titleSmall(color: subtleOnCardColor)?.copyWith(fontWeight: FontWeight.w500),
              ),
              ElevatedButton(
                onPressed: () => print('Top Up tapped'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBgColor,
                  foregroundColor: buttonTextColor,
                  padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 20), vertical: responsiveFontSize(context, 10)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 20))),
                  elevation: 2,
                ),
                child: Text(tl('profile.balance.topUpButton'), style: AppFonts.bodySmall(color: buttonTextColor)?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: responsiveFontSize(context, 8)),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CoinDetailsScreen())),
            borderRadius: BorderRadius.circular(responsiveFontSize(context, 8)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: responsiveFontSize(context, 4.0)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('37', style: AppFonts.displayLargeM(color: onCardColor)),
                  SizedBox(width: responsiveFontSize(context, 4)),
                  Padding(
                    padding: EdgeInsets.only(top: responsiveFontSize(context, 4)),
                    child: Icon(Remix.arrow_right_s_line, size: responsiveFontSize(context, 26), color: onCardColor.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveFontSize(context, 18)),
          Divider(color: dividerColor.withOpacity(0.5), thickness: 0.6, height: 1),
          SizedBox(height: responsiveFontSize(context, 18)),
          _buildBalanceItem(context, Remix.copper_coin_line, tl('profile.balance.coins'), '0', onCardColor, subtleOnCardColor, coinsIconColor),
          SizedBox(height: responsiveFontSize(context, 14)),
          _buildBalanceItem(context, Remix.gift_2_line, tl('profile.balance.bonusCoins'), '37', onCardColor, subtleOnCardColor, bonusCoinsIconColor),
          SizedBox(height: responsiveFontSize(context, 18)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 12), vertical: responsiveFontSize(context, 8)),
            decoration: BoxDecoration(color: warningBackgroundColor, borderRadius: BorderRadius.circular(responsiveFontSize(context, 8))),
            child: Row(
              children: [
                Icon(Remix.alarm_warning_fill, color: warningTextColor, size: responsiveFontSize(context, 18)),
                SizedBox(width: responsiveFontSize(context, 8)),
                Expanded(
                  child: Text(
                    tl('profile.balance.bonusCoinsExpirationWarning'),
                    style: AppFonts.labelSmall(color: warningTextColor)?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceItem(BuildContext context, IconData icon, String label, String value, Color onCardColor, Color subtleOnCardColor, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: responsiveFontSize(context, 22), color: iconColor),
        SizedBox(width: responsiveFontSize(context, 12)),
        Text(label, style: AppFonts.titleMedium(color: onCardColor)),
        const Spacer(),
        Text(value, style: AppFonts.titleMedium(color: onCardColor)?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMenuListContainer(BuildContext context, Color onSurfaceColor, Color subtleTextColor, Color accentBadgeColor, Color primaryColor, Color onPrimaryColor, Color menuContainerBgColor, List<BoxShadow> boxShadow, Color dividerColor, bool isLoggedIn) {
    final AuthRepository authRepository = AuthRepository();

    Future<void> handleLogout() async {
      await authRepository.logout();
      authNotifier.value = null;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
    }

    return Container(
      decoration: BoxDecoration(color: menuContainerBgColor, borderRadius: BorderRadius.circular(responsiveFontSize(context, 16)), boxShadow: boxShadow),
      child: Column(
        children: [
          _buildMenuListItem(context, Remix.calendar_event_line, tl('eventCenter'), onSurfaceColor, subtleTextColor, dividerColor, trailing: _buildBadge(context, tl('freeCoins'), accentBadgeColor, Colors.white), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventCenterScreen()))),
          _buildMenuListItem(context, Remix.coupon_3_line, tl('myCoupons'), onSurfaceColor, subtleTextColor, dividerColor),
          _buildMenuListItem(context, Remix.archive_line, tl('myPosts'), onSurfaceColor, subtleTextColor, dividerColor, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPostsScreen()))),
          _buildMenuListItem(context, Remix.quill_pen_line, tl('becomeAuthor'), onSurfaceColor, subtleTextColor, dividerColor, trailing: _buildBadge(context, tl('new'), primaryColor, onPrimaryColor), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BecameAuthorScreen()))),
          _buildMenuListItem(context, Remix.feedback_line, tl('feedback'), onSurfaceColor, subtleTextColor, dividerColor),
          _buildMenuListItem(context, Remix.settings_line, tl('settings'), onSurfaceColor, subtleTextColor, dividerColor, isLast: !isLoggedIn, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 8), vertical: responsiveFontSize(context, 3.5)),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(responsiveFontSize(context, 10))),
      child: Text(
        text,
        style: AppFonts.labelTiny(color: textColor),
      ),
    );
  }

  Widget _buildMenuListItem(BuildContext context, IconData icon, String title, Color onSurfaceColor, Color subtleTextColor, Color dividerColor, {Widget? trailing, bool isLast = false, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => print('$title tapped - default action'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 16), vertical: responsiveFontSize(context, 15)),
          decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: dividerColor.withOpacity(0.5), width: 0.6))),
          child: Row(
            children: [
              Icon(icon, size: responsiveFontSize(context, 22), color: onSurfaceColor),
              SizedBox(width: responsiveFontSize(context, 16)),
              Expanded(
                child: Text(title, style: AppFonts.titleMedium(color: onSurfaceColor)),
              ),
              if (trailing != null) ...[trailing, SizedBox(width: responsiveFontSize(context, 8))],
              if (onTap != null)
                Icon(Remix.arrow_right_s_line, size: responsiveFontSize(context, 20), color: subtleTextColor),
            ],
          ),
        ),
      ),
    );
  }
}
