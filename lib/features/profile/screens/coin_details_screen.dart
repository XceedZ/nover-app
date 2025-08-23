import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nover/main.dart';
import 'package:nover/src/models/coin_transaction.dart';
import 'package:nover/src/models/wallet.dart';
import 'package:nover/src/repositories/transaction_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/date_convert.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shimmer/shimmer.dart';

class CoinDetailsScreen extends StatefulWidget {
  const CoinDetailsScreen({super.key});

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final TransactionRepository _transactionRepository = TransactionRepository();

  late Future<List<CoinTransaction>> _earnHistoryFuture;
  late Future<List<CoinTransaction>> _useHistoryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistories();
  }

  void _loadHistories() {
    setState(() {
      _earnHistoryFuture =
          _transactionRepository.getTransactions(TransactionType.earn);
      _useHistoryFuture =
          _transactionRepository.getTransactions(TransactionType.spend);
    });
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
    Color mainTextColorOnCard =
    ThemeData.estimateBrightnessForColor(cardActualBgColor) ==
        Brightness.light
        ? Colors.black87
        : Colors.white;
    Color subtleTextColorOnCard =
    ThemeData.estimateBrightnessForColor(cardActualBgColor) ==
        Brightness.light
        ? Colors.black54
        : Colors.white70;

    return ValueListenableBuilder<Wallet?>(
      valueListenable: walletNotifier,
      builder: (context, wallet, child) {
        if (wallet == null) {
          return Container(
            margin: EdgeInsets.all(_responsiveFontSize(context, 16)),
            height: 250,
            child: Shimmer.fromColors(
              baseColor: themeProvider.value == ThemeMode.dark
                  ? Colors.grey[800]!
                  : Colors.grey[300]!,
              highlightColor: themeProvider.value == ThemeMode.dark
                  ? Colors.grey[700]!
                  : Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(_responsiveFontSize(context, 12)),
                ),
              ),
            ),
          );
        }

        return Container(
          margin: EdgeInsets.all(_responsiveFontSize(context, 16)),
          padding: EdgeInsets.all(_responsiveFontSize(context, 20)),
          decoration: BoxDecoration(
            color: cardActualBgColor,
            borderRadius:
            BorderRadius.circular(_responsiveFontSize(context, 12)),
            boxShadow: cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('label.remainingBalance'),
                style: GoogleFonts.montserrat(
                  fontSize: _responsiveFontSize(context, 13),
                  color: subtleTextColorOnCard,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: _responsiveFontSize(context, 4)),
              Text(
                wallet.totalCoins.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: _responsiveFontSize(context, 40),
                  fontWeight: FontWeight.bold,
                  color: mainTextColorOnCard,
                ),
              ),
              SizedBox(height: _responsiveFontSize(context, 16)),
              Row(
                children: [
                  Icon(Remix.copper_coin_line,
                      color: Colors.orange.shade600,
                      size: _responsiveFontSize(context, 18)),
                  SizedBox(width: _responsiveFontSize(context, 6)),
                  Text(
                    "${translate('label.coins')} ${wallet.paidCoins}",
                    style: GoogleFonts.montserrat(
                        fontSize: _responsiveFontSize(context, 13),
                        color: subtleTextColorOnCard),
                  ),
                  const Spacer(),
                  Icon(Remix.gift_line,
                      color: Colors.blue.shade500,
                      size: _responsiveFontSize(context, 18)),
                  SizedBox(width: _responsiveFontSize(context, 6)),
                  Text(
                    "${translate('label.bonusCoins')} ${wallet.bonusCoins}",
                    style: GoogleFonts.montserrat(
                        fontSize: _responsiveFontSize(context, 13),
                        color: subtleTextColorOnCard,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: _responsiveFontSize(context, 4)),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  translate('label.expirationWarning'),
                  style: GoogleFonts.montserrat(
                      fontSize: _responsiveFontSize(context, 10),
                      color: subtleTextColorOnCard.withOpacity(0.8)),
                ),
              ),
              SizedBox(height: _responsiveFontSize(context, 20)),
              ElevatedButton(
                onPressed: () {/* TODO: Aksi Top Up */},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize:
                  Size(double.infinity, _responsiveFontSize(context, 48)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(_responsiveFontSize(context, 8)),
                  ),
                ),
                child: Text(translate('label.topUp'),
                    style: GoogleFonts.montserrat(
                        fontSize: _responsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryListItem(BuildContext context, CoinTransaction item) {
    ThemeData theme = Theme.of(context);
    bool isDebit = item.amount < 0;
    final locale = Localizations.localeOf(context).toString();

    IconData icon;
    switch (item.transactionType) {
      case 'CHECK_IN':
        icon = Remix.calendar_check_line;
        break;
      case 'REGISTRATION':
        icon = Remix.user_add_line;
        break;
      case 'UNLOCK_CHAPTER':
        icon = Remix.book_open_line;
        break;
      case 'MISSION_REWARD':
        icon = Remix.award_line;
        break;
      case 'PURCHASE':
        icon = Remix.shopping_cart_2_line;
        break;
      default:
        icon = Remix.checkbox_blank_circle_line;
    }

    return Padding(
      padding:
      EdgeInsets.symmetric(vertical: _responsiveFontSize(context, 12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: _responsiveFontSize(context, 18),
            backgroundColor: isDebit
                ? Colors.red.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon,
                size: _responsiveFontSize(context, 18),
                color:
                isDebit ? Colors.red.shade700 : theme.colorScheme.primary),
          ),
          SizedBox(width: _responsiveFontSize(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description ??
                      translate('label.${item.transactionType.toLowerCase()}'),
                  style: GoogleFonts.montserrat(
                    fontSize: _responsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: _responsiveFontSize(context, 2)),
                Text(
                  DateFormatter.formatFullDateTime(item.createDatetime,
                      locale: locale),
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
                (isDebit ? "" : "+") + item.amount.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: _responsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: isDebit
                      ? Colors.red.shade700
                      : theme.colorScheme.primary,
                ),
              ),
              if (item.expiryDate != null && item.expiryDate!.isNotEmpty) ...[
                SizedBox(height: _responsiveFontSize(context, 2)),
                Text(
                  "${translate('label.validUntil')} ${DateFormatter.formatApiDate(item.expiryDate, locale: locale)}",
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

  Widget _buildEmptyHistoryPlaceholder(
      {required IconData icon, required String message}) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(responsiveFontSize(context, 16)),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle),
            child: Icon(icon,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: responsiveFontSize(context, 32)),
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context,
      Future<List<CoinTransaction>> future, TransactionType type) {
    return FutureBuilder<List<CoinTransaction>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ✨ PERBAIKAN: Gunakan loading indicator yang konsisten
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text(translate('label.failedToLoadHistory')));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyHistoryPlaceholder(
            icon: type == TransactionType.earn
                ? Remix.hand_coin_line
                : Remix.hourglass_2_line,
            message: translate(type == TransactionType.earn
                ? 'label.noCoinEarnHistory'
                : 'label.noCoinUsageHistory'),
          );
        }

        final history = snapshot.data!;
        return ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: _responsiveFontSize(context, 16),
              vertical: _responsiveFontSize(context, 8)),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return _buildHistoryListItem(context, history[index]);
          },
          separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              height: 0.5,
              thickness: 0.5),
        );
      },
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
        title: Text(translate('label.coinDetails'),
            style: AppFonts.titleLarge(color: appBarContentColor)
                .copyWith(fontSize: _responsiveFontSize(context, 18))),
        backgroundColor:
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0.5,
        surfaceTintColor:
        theme.appBarTheme.surfaceTintColor ?? theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Remix.question_line, color: appBarContentColor),
            onPressed: () {/* TODO: Aksi bantuan */},
          ),
          IconButton(
            icon: Icon(Remix.whatsapp_line, color: appBarContentColor),
            onPressed: () {/* TODO: Aksi WhatsApp */},
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
              unselectedLabelColor:
              theme.colorScheme.onBackground.withOpacity(0.3),
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
                Tab(text: translate('label.earn')),
                Tab(text: translate('label.use')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(
                    context, _earnHistoryFuture, TransactionType.earn),
                _buildHistoryTab(
                    context, _useHistoryFuture, TransactionType.spend),
              ],
            ),
          ),
        ],
      ),
    );
  }
}