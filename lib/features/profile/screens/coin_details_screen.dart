// lib/features/profile/screens/coin_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/app_fonts.dart'; // Sesuaikan path jika perlu
import 'package:nover/src/utils/ui_helpers.dart'; // Sesuaikan path jika perlu
import 'package:remixicon/remixicon.dart';
import 'package:flutter_translate/flutter_translate.dart'; // Pastikan ini di-uncomment dan library sudah tersetup

// Fungsi _translatePlaceholder dan map translations dihilangkan

// Model data dummy (sama seperti sebelumnya)
class CoinHistoryItem {
  final String title;
  final String date;
  final String amount;
  final String validity;
  final IconData icon;

  CoinHistoryItem({
    required this.title,
    required this.date,
    required this.amount,
    this.validity = "",
    this.icon = Remix.checkbox_blank_circle_line,
  });
}

class CoinDetailsScreen extends StatefulWidget {
  const CoinDetailsScreen({super.key});

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  // Menggunakan fungsi translate() dari library i18n
  late final List<CoinHistoryItem> _earnHistory = [
    CoinHistoryItem(title: translate("label.checkInBonus"), date: "25/05/24 02:10", amount: "+3", validity: "1/06/24", icon: Remix.calendar_check_line),
    CoinHistoryItem(title: translate("label.checkInBonus"), date: "24/05/24 02:42", amount: "+4", validity: "31/05/24", icon: Remix.calendar_check_line),
    CoinHistoryItem(title: translate("label.registrationBonus"), date: "23/05/24 01:00", amount: "+30", validity: "23/06/24", icon: Remix.user_add_line),
  ];

  late final List<CoinHistoryItem> _useHistory = [
    CoinHistoryItem(title: translate("label.unlockChapter", args: {'chapterNumber': 5}), date: "26/05/24 10:30", amount: "-10", icon: Remix.book_open_line),
    CoinHistoryItem(title: translate("label.buyTheme", args: {'themeName': "Gelap Eksklusif"}), date: "25/05/24 15:00", amount: "-50", icon: Remix.palette_line),
    CoinHistoryItem(title: translate("label.unlockChapter", args: {'chapterNumber': 4}), date: "24/05/24 08:15", amount: "-10", icon: Remix.book_open_line),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  double _responsiveFontSize(BuildContext context, double baseFontSize) {
    return responsiveFontSize(context, baseFontSize);
  }

  Widget _buildBalanceSummaryCard(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Color cardActualBgColor = theme.brightness == Brightness.light
        ? Colors.grey.shade50
        : theme.colorScheme.surfaceVariant.withOpacity(0.5);

    List<BoxShadow> cardShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.08),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    Brightness cardContentBrightness = ThemeData.estimateBrightnessForColor(cardActualBgColor);

    Color mainTextColorOnCard = cardContentBrightness == Brightness.light ? Colors.black87 : Colors.white;
    Color subtleTextColorOnCard = cardContentBrightness == Brightness.light ? Colors.black54 : Colors.white70;

    final Color topUpButtonBgColor = Theme.of(context).colorScheme.primary;
    final Color topUpButtonTextColor = Theme.of(context).colorScheme.onPrimary;

    Color regularCoinIconColor = Colors.orange.shade600;
    Color bonusCoinIconColor = Colors.blue.shade500;
    if (cardContentBrightness == Brightness.dark) {
      regularCoinIconColor = Colors.orange.shade400;
      bonusCoinIconColor = Colors.blue.shade300;
    }

    return Container(
      margin: EdgeInsets.all(_responsiveFontSize(context, 16)),
      padding: EdgeInsets.all(_responsiveFontSize(context, 20)),
      decoration: BoxDecoration(
        color: cardActualBgColor,
        borderRadius: BorderRadius.circular(_responsiveFontSize(context, 12)),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('label.remainingBalance'), // Menggunakan translate()
            style: GoogleFonts.montserrat(
              fontSize: _responsiveFontSize(context, 13),
              color: subtleTextColorOnCard,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: _responsiveFontSize(context, 4)),
          Text(
            "37", // Saldo utama
            style: GoogleFonts.montserrat(
              fontSize: _responsiveFontSize(context, 40),
              fontWeight: FontWeight.bold,
              color: mainTextColorOnCard,
            ),
          ),
          SizedBox(height: _responsiveFontSize(context, 16)),
          Row(
            children: [
              Icon(Remix.copper_coin_line, color: regularCoinIconColor, size: _responsiveFontSize(context, 18)),
              SizedBox(width: _responsiveFontSize(context, 6)),
              Text(
                "${translate('label.coins')} 0", // Menggunakan translate()
                style: GoogleFonts.montserrat(fontSize: _responsiveFontSize(context, 13), color: subtleTextColorOnCard),
              ),
              const Spacer(),
              Icon(Remix.gift_line, color: bonusCoinIconColor, size: _responsiveFontSize(context, 18)),
              SizedBox(width: _responsiveFontSize(context, 6)),
              Text(
                "${translate('label.bonusCoins')} 37", // Menggunakan translate()
                style: GoogleFonts.montserrat(fontSize: _responsiveFontSize(context, 13), color: subtleTextColorOnCard, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: _responsiveFontSize(context, 4)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              translate('label.expirationWarning'), // Menggunakan translate()
              style: GoogleFonts.montserrat(fontSize: _responsiveFontSize(context, 10), color: subtleTextColorOnCard.withOpacity(0.8)),
            ),
          ),
          SizedBox(height: _responsiveFontSize(context, 20)),
          ElevatedButton(
            onPressed: () { /* TODO: Aksi Top Up */ },
            style: ElevatedButton.styleFrom(
              backgroundColor: topUpButtonBgColor,
              foregroundColor: topUpButtonTextColor,
              minimumSize: Size(double.infinity, _responsiveFontSize(context, 48)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_responsiveFontSize(context, 8)),
              ),
              textStyle: GoogleFonts.montserrat(
                fontSize: _responsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(translate('label.topUp')), // Menggunakan translate()
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryListItem(BuildContext context, CoinHistoryItem item) {
    ThemeData theme = Theme.of(context);
    bool isDebit = item.amount.startsWith('-');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _responsiveFontSize(context, 12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: _responsiveFontSize(context, 18),
            backgroundColor: isDebit
                ? Colors.red.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
                item.icon,
                size: _responsiveFontSize(context, 18),
                color: isDebit ? Colors.red.shade700 : theme.colorScheme.primary
            ),
          ),
          SizedBox(width: _responsiveFontSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title, // title sudah hasil translate() dari _earnHistory/_useHistory
                  style: GoogleFonts.montserrat(
                    fontSize: _responsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: _responsiveFontSize(context, 2)),
                Text(
                  item.date,
                  style: GoogleFonts.montserrat(
                    fontSize: _responsiveFontSize(context, 11),
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: GoogleFonts.montserrat(
                  fontSize: _responsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: isDebit ? Colors.red.shade700 : theme.colorScheme.primary,
                ),
              ),
              if (item.validity.isNotEmpty) ...[
                SizedBox(height: _responsiveFontSize(context, 2)),
                Text(
                  "${translate('label.validUntil')} ${item.validity}", // Menggunakan translate()
                  style: GoogleFonts.montserrat(
                    fontSize: _responsiveFontSize(context, 10),
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarnTab(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: _responsiveFontSize(context, 16), vertical: _responsiveFontSize(context, 8)),
      itemCount: _earnHistory.length,
      itemBuilder: (context, index) {
        return _buildHistoryListItem(context, _earnHistory[index]);
      },
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor.withOpacity(0.3),
        height: 0.5,
        thickness: 0.5,
      ),
    );
  }

  Widget _buildUseTab(BuildContext context) {
    if (_useHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(_responsiveFontSize(context, 16)),
          child: Text(
            translate('label.noCoinUsageHistory'), // Menggunakan translate()
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: _responsiveFontSize(context, 16), vertical: _responsiveFontSize(context, 8)),
      itemCount: _useHistory.length,
      itemBuilder: (context, index) {
        return _buildHistoryListItem(context, _useHistory[index]);
      },
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).dividerColor.withOpacity(0.3),
        height: 0.5,
        thickness: 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color appBarContentColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: appBarContentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
            translate('label.coinDetails'), // Menggunakan translate()
            style: AppFonts.titleLarge(color: appBarContentColor).copyWith(fontSize: _responsiveFontSize(context, 18))
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0.5,
        surfaceTintColor: theme.appBarTheme.surfaceTintColor ?? theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Remix.question_line, color: appBarContentColor),
            onPressed: () { /* TODO: Aksi bantuan */ },
          ),
          IconButton(
            icon: Icon(Remix.whatsapp_line, color: appBarContentColor),
            onPressed: () { /* TODO: Aksi WhatsApp */ },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildBalanceSummaryCard(context),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.3),
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 0,
              labelStyle: GoogleFonts.montserrat(
                fontSize: _responsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontSize: _responsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: translate('label.earn')), // Menggunakan translate()
                Tab(text: translate('label.use')), // Menggunakan translate()
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEarnTab(context),
                _buildUseTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}