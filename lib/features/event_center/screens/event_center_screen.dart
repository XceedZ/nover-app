import 'package:flutter/material.dart';
import 'package:nover/main.dart';
import 'package:nover/src/models/event_center_data.dart';
import 'package:nover/src/models/wallet.dart';
import 'package:nover/src/repositories/event_repository.dart';
import 'package:nover/src/repositories/wallet_repository.dart';
import 'package:nover/src/utils/app_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/profile/screens/coin_details_screen.dart';
import 'package:remixicon/remixicon.dart';
import 'package:nover/src/widgets/custom_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EventCenterScreen extends StatefulWidget {
  const EventCenterScreen({super.key});

  @override
  State<EventCenterScreen> createState() => _EventCenterScreenState();
}

class _EventCenterScreenState extends State<EventCenterScreen> {
  final EventRepository _eventRepository = EventRepository();
  CheckinStatus? _checkinStatus;
  List<MissionStatus> _missions = [];
  bool _isLoading = true;
  String? _error;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _eventRepository.getCheckinStatus(),
        _eventRepository.getMissions(),
      ]);

      if (mounted) {
        setState(() {
          _checkinStatus = results[0] as CheckinStatus;
          _missions = results[1] as List<MissionStatus>;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _performCheckIn() async {
    if (_isCheckingIn) return;
    setState(() => _isCheckingIn = true);

    try {
      final reward = await _eventRepository.performCheckin();
      AppSnackbar.showSuccess(context,
          message: tl('checkinSuccessMessage', args: {'reward': reward}));
      final walletRepo = WalletRepository();
      walletNotifier.value = await walletRepo.getMyWallet();
      await _fetchData();
    } catch (e) {
      AppSnackbar.showError(context,
          message: e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line,
              color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tl('eventCenter'),
          style: AppFonts.appBarTitle(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
              color: theme.colorScheme.primary, size: 50))
          : _error != null
          ? Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!),
                ElevatedButton(
                    onPressed: _fetchData, child: Text(tl('retry')))
              ]))
          : _buildContent(context, theme),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    Color cardBgColor = theme.cardColor;
    Color lightTextColor = theme.colorScheme.onSurface.withOpacity(0.7);
    Color primaryTextColor = theme.colorScheme.onSurface;
    Color accentColor = theme.colorScheme.primary; // Warna primer untuk check-in
    Color coinColor = theme.colorScheme.primary;

    List<BoxShadow> cardShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.08),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: EdgeInsets.all(responsiveFontSize(context, 16)),
        children: [
          _buildSaldoSection(
              context, lightTextColor, primaryTextColor, coinColor),
          SizedBox(height: responsiveFontSize(context, 20)),
          if (_checkinStatus != null)
            _buildCheckInSection(context, cardBgColor, lightTextColor,
                primaryTextColor, accentColor, coinColor, cardShadow),
          SizedBox(height: responsiveFontSize(context, 20)),
          _buildMisiHarianSection(context, cardBgColor, lightTextColor,
              primaryTextColor, accentColor, cardShadow),
        ],
      ),
    );
  }

  Widget _buildSaldoSection(BuildContext context, Color lightTextColor,
      Color primaryTextColor, Color coinColor) {
    ThemeData theme = Theme.of(context);
    return ValueListenableBuilder<Wallet?>(
      valueListenable: walletNotifier,
      builder: (context, wallet, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('remainingBalance'),
                    style: AppFonts.bodySmall(color: lightTextColor),
                  ),
                  SizedBox(height: responsiveFontSize(context, 4)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CoinDetailsScreen()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wallet?.totalCoins.toString() ?? '...',
                          style:
                          AppFonts.displayLargeM(color: primaryTextColor),
                        ),
                        Icon(Remix.arrow_right_s_line,
                            color: primaryTextColor,
                            size: responsiveFontSize(context, 30)),
                      ],
                    ),
                  ),
                  SizedBox(height: responsiveFontSize(context, 6)),
                  Text(
                    tl('checkInMotivation'),
                    style: AppFonts.bodySmall(
                        color: lightTextColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            SizedBox(width: responsiveFontSize(context, 10)),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: responsiveFontSize(context, 80),
                  height: responsiveFontSize(context, 80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                ),
                Container(
                  width: responsiveFontSize(context, 55),
                  height: responsiveFontSize(context, 55),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1)
                      ]),
                  child: Icon(Remix.coins_fill,
                      color: coinColor,
                      size: responsiveFontSize(context, 28)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckInSection(
      BuildContext context,
      Color cardBgColor,
      Color lightTextColor,
      Color primaryTextColor,
      Color accentColor,
      Color coinColor,
      List<BoxShadow> cardShadow) {
    ThemeData theme = Theme.of(context);
    final status = _checkinStatus!;
    final dayRewards = {for (var r in status.rewards) r.dayNumber: r};
    final checkedInDays =
    Set.from(status.checkedInDates.map((d) => DateTime.parse(d).day));
    final currentDayOfMonth = DateTime.now().day;
    final totalDays = status.rewards.length;

    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 16)),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
        boxShadow: cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                  tl('dailyCheckInAndRewards'), // Gunakan key baru: "Check-in Harian & Dapatkan Hadiah"
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      ?.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(width: responsiveFontSize(context, 4)),
              Icon(Remix.question_line,
                  color: lightTextColor,
                  size: responsiveFontSize(context, 16)),
            ],
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
              crossAxisSpacing: responsiveFontSize(context, 6),
              mainAxisSpacing: responsiveFontSize(context, 6),
            ),
            itemCount: totalDays,
            itemBuilder: (context, index) {
              int dayNumber = index + 1;
              final reward = dayRewards[dayNumber];
              bool isCheckedIn = checkedInDays.contains(dayNumber);
              bool isToday = (dayNumber == currentDayOfMonth);
              bool isPastDay = (dayNumber < currentDayOfMonth);

              Widget iconWidget;

              if (isCheckedIn) {
                iconWidget = Icon(Remix.checkbox_circle_fill,
                    color: accentColor,
                    size: responsiveFontSize(context, 22));
              } else if (isToday && !status.todayCheckedIn) {
                iconWidget = Icon(Remix.circle_line,
                    color: coinColor, size: responsiveFontSize(context, 22));
              } else if (isPastDay) {
                iconWidget = Icon(Remix.close_circle_line,
                    color: lightTextColor.withOpacity(0.5),
                    size: responsiveFontSize(context, 22));
              } else if (reward != null) {
                // ✨ PERBAIKAN: Tampilkan reward koin dalam lingkaran warna primer
                iconWidget = Container(
                  width: responsiveFontSize(context, 22),
                  height: responsiveFontSize(context, 22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      "+${reward.rewardAmount}",
                      style: AppFonts.labelTiny(color: Colors.white)
                          ?.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              } else {
                // Fallback untuk hari selanjutnya tanpa reward (seharusnya tidak terjadi jika data lengkap)
                iconWidget = Icon(Remix.checkbox_blank_circle_fill,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                    size: responsiveFontSize(context, 22));
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  SizedBox(height: responsiveFontSize(context, 4)),
                  Text("${tl('day')} $dayNumber",
                      style: AppFonts.bodySmall(
                        color: lightTextColor.withOpacity(
                            isToday && !isCheckedIn || isCheckedIn ? 1.0 : 0.6),
                      )?.copyWith(
                        fontWeight: isToday && !isCheckedIn
                            ? FontWeight.bold
                            : FontWeight.normal,
                      )),
                ],
              );
            },
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          ElevatedButton(
            onPressed: status.todayCheckedIn || _isCheckingIn
                ? null
                : _performCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              disabledBackgroundColor:
              theme.colorScheme.onSurface.withOpacity(0.12),
              foregroundColor: theme.colorScheme.onPrimary,
              disabledForegroundColor: lightTextColor,
              minimumSize:
              Size(double.infinity, responsiveFontSize(context, 48)),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(responsiveFontSize(context, 8)),
              ),
            ),
            child: _isCheckingIn
                ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : Text(
              status.todayCheckedIn
                  ? tl('alreadyCheckInToday')
                  : tl('checkInNow'),
              style: AppFonts.titleSmall()
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisiHarianSection(
      BuildContext context,
      Color cardBgColor,
      Color lightTextColor,
      Color primaryTextColor,
      Color accentColor,
      List<BoxShadow> cardShadow) {
    ThemeData theme = Theme.of(context);

    if (_missions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 16)),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tl('dailyMission'),
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      ?.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(width: responsiveFontSize(context, 4)),
              Icon(Remix.question_line,
                  color: lightTextColor,
                  size: responsiveFontSize(context, 16)),
            ],
          ),
          SizedBox(height: responsiveFontSize(context, 8)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _missions.length,
            itemBuilder: (context, index) {
              final mission = _missions[index];
              return _buildMisiItem(
                context: context,
                mission: mission,
                theme: theme,
                accentColor: accentColor,
                cardBgColor: cardBgColor,
                lightTextColor: lightTextColor,
              );
            },
            separatorBuilder: (context, index) => Divider(
                color: theme.dividerColor.withOpacity(0.5),
                height: responsiveFontSize(context, 24)),
          ),
        ],
      ),
    );
  }

  Widget _buildMisiItem({
    required BuildContext context,
    required MissionStatus mission,
    required ThemeData theme,
    required Color accentColor,
    required Color cardBgColor,
    required Color lightTextColor,
  }) {
    IconData icon;
    String missionType =
    mission.missionInfo.title.toLowerCase();
    if (missionType.contains('rating')) {
      icon = Remix.shining_2_line;
    } else if (missionType.contains('komentar')) {
      icon = Remix.chat_3_line;
    } else {
      icon = Remix.book_open_line;
    }

    final tiers = mission.tiers;
    tiers.sort((a, b) => a.tierOrder.compareTo(b.tierOrder));
    final maxThreshold = tiers.isNotEmpty ? tiers.last.threshold : 1;
    final progress = (mission.currentProgress / maxThreshold).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                color: lightTextColor,
                size: responsiveFontSize(context, 20)),
            SizedBox(width: responsiveFontSize(context, 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.missionInfo.title,
                      style: AppFonts.titleSmall(
                          color: theme.colorScheme.onSurface)
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  SizedBox(height: responsiveFontSize(context, 2)),
                  Text(mission.missionInfo.description,
                      style: AppFonts.bodySmall(color: lightTextColor)),
                ],
              ),
            ),
            SizedBox(width: responsiveFontSize(context, 8)),
            ElevatedButton(
              onPressed: () {
                /* TODO: Navigasi ke halaman membaca */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(
                    horizontal: responsiveFontSize(context, 18),
                    vertical: responsiveFontSize(context, 8)),
                textStyle:
                AppFonts.bodySmall()?.copyWith(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        responsiveFontSize(context, 20))),
                elevation: 0,
              ),
              child: Text(tl('read')),
            )
          ],
        ),
        if (tiers.isNotEmpty) ...[
          SizedBox(height: responsiveFontSize(context, 16)),
          LayoutBuilder(builder: (context, constraints) {
            double progressBarWidth = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: responsiveFontSize(context, 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(responsiveFontSize(context, 4)),
                  ),
                ),
                Container(
                  height: responsiveFontSize(context, 8),
                  width: progressBarWidth * progress,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius:
                    BorderRadius.circular(responsiveFontSize(context, 4)),
                  ),
                ),
                ...tiers.map((tier) {
                  final milestoneProgress =
                  (tier.threshold / maxThreshold).clamp(0.0, 1.0);
                  bool isClaimed = tier.tierOrder <= mission.lastClaimedTier;
                  bool canClaim =
                      !isClaimed && mission.currentProgress >= tier.threshold;

                  return Positioned(
                    left: progressBarWidth * milestoneProgress -
                        responsiveFontSize(context, 11),
                    child: GestureDetector(
                      onTap: canClaim
                          ? () {
                        /* TODO: Panggil API klaim hadiah */
                      }
                          : null,
                      child: Column(
                        children: [
                          Container(
                            width: responsiveFontSize(context, 22),
                            height: responsiveFontSize(context, 22),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isClaimed
                                    ? accentColor
                                    : (canClaim
                                    ? Colors.amber.shade600
                                    : theme.colorScheme.onSurface
                                    .withOpacity(0.2)),
                                border:
                                Border.all(color: cardBgColor, width: 2)),
                            child: Center(
                              child: isClaimed
                                  ? Icon(Remix.check_line,
                                  color: Colors.white,
                                  size: responsiveFontSize(context, 12))
                                  : Text(
                                "+${tier.rewardAmount}",
                                style: AppFonts.labelTiny(
                                    color: Colors.white)
                                    ?.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: responsiveFontSize(context, 2)),
                          Text(
                            "${tier.threshold} mnt",
                            style: AppFonts.labelTiny(
                                color: lightTextColor.withOpacity(0.8))
                                ?.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }),
          SizedBox(height: responsiveFontSize(context, 22)),
        ]
      ],
    );
  }
}