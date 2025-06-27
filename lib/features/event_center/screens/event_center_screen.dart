// lib/features/event_center/screens/event_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nover/src/utils/translation.dart';
import 'package:nover/src/utils/ui_helpers.dart';
import 'package:nover/features/profile/screens/coin_details_screen.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_translate/flutter_translate.dart';

class EventCenterScreen extends StatefulWidget {
  const EventCenterScreen({super.key});

  @override
  State<EventCenterScreen> createState() => _EventCenterScreenState();
}

class _EventCenterScreenState extends State<EventCenterScreen> {
  // _isCheckInSectionExpanded dihapus karena fitur expand/collapse dihilangkan
  late int _daysInCurrentMonth;
  late List<int> _dailyCheckInStatus; // 0: belum, 1: sudah, 2: hadiah Senin (tidak terpakai lagi), 3: hari ini belum
  late int _currentDayOfMonth;
  late DateTime _today;

  double _readingProgress = 15.0 / 60.0;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentDayOfMonth = _today.day;
    _daysInCurrentMonth = DateUtils.getDaysInMonth(_today.year, _today.month);
    _initializeCheckInStatus();
  }

  void _initializeCheckInStatus() {
    _dailyCheckInStatus = List.generate(_daysInCurrentMonth, (index) {
      int day = index + 1;
      if (day < _currentDayOfMonth) {
        return 1; // Sudah check-in
      } else if (day == _currentDayOfMonth) {
        return 3; // Hari ini, belum check-in
      }
      return 0; // Belum check-in (hari mendatang)
    });
  }

  void _performCheckIn() {
    setState(() {
      if (_currentDayOfMonth > 0 && _currentDayOfMonth <= _daysInCurrentMonth) {
        int todayIndex = _currentDayOfMonth - 1;
        if (_dailyCheckInStatus[todayIndex] == 3) {
          _dailyCheckInStatus[todayIndex] = 1;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Berhasil Check-in untuk hari ke-$_currentDayOfMonth!")),
          );
        }
      }
    });
  }

  bool get _isTodayCheckedIn {
    if (_currentDayOfMonth > 0 && _currentDayOfMonth <= _daysInCurrentMonth) {
      return _dailyCheckInStatus[_currentDayOfMonth - 1] == 1;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color scaffoldBgColor = theme.colorScheme.background;
    // Menggunakan theme.cardColor atau theme.colorScheme.surface untuk card.
    // theme.cardColor lebih umum untuk card di Material 2,
    // theme.colorScheme.surface atau surfaceContainerLow untuk Material 3.
    // Mari kita gunakan theme.cardColor agar konsisten jika ProfileScreen juga menggunakannya.
    // Jika ingin lebih ke M3, bisa ganti ke theme.colorScheme.surfaceContainerLow
    Color cardBgColor = theme.cardColor;
    Color lightTextColor = theme.colorScheme.onSurface.withOpacity(0.7);
    Color primaryTextColor = theme.colorScheme.onSurface;
    Color accentColor = theme.colorScheme.primary; // Tetap hijau untuk status check-in
    Color coinColor = theme.colorScheme.primary;  // Tetap kuning untuk ikon koin
    Color giftColor = Colors.pinkAccent.shade200; // Tetap pink untuk ikon gift (Senin)

    // Shadow yang konsisten dengan ProfileScreen
    List<BoxShadow> cardShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.08), // theme.shadowColor lebih adaptif
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tl('eventCenter'),
          style: GoogleFonts.montserrat(
              color: primaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: responsiveFontSize(context, 18)),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(responsiveFontSize(context, 16)),
        children: [
          _buildSaldoSection(context, lightTextColor, primaryTextColor, coinColor),
          SizedBox(height: responsiveFontSize(context, 20)),
          _buildCheckInSection(context, cardBgColor, lightTextColor, primaryTextColor, accentColor, coinColor, giftColor, cardShadow),
          SizedBox(height: responsiveFontSize(context, 20)),
          _buildMisiHarianSection(context, cardBgColor, lightTextColor, primaryTextColor, accentColor, cardShadow),
        ],
      ),
    );
  }

  Widget _buildSaldoSection(BuildContext context, Color lightTextColor, Color primaryTextColor, Color coinColor) {
    ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate('profile.balance.remainingBalance'),
                style: GoogleFonts.montserrat(
                    color: lightTextColor,
                    fontSize: responsiveFontSize(context, 13)),
              ),
              SizedBox(height: responsiveFontSize(context, 4)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoinDetailsScreen()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "4",
                      style: GoogleFonts.montserrat(
                          color: primaryTextColor,
                          fontSize: responsiveFontSize(context, 32),
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(Remix.arrow_right_s_line,
                        color: primaryTextColor,
                        size: responsiveFontSize(context, 30)),
                  ],
                ),
              ),
              SizedBox(height: responsiveFontSize(context, 6)),
              Text(
                "Check-in terus untuk mendapatkan koin bonus semakin banyak~",
                style: GoogleFonts.montserrat(
                    color: lightTextColor.withOpacity(0.8),
                    fontSize: responsiveFontSize(context, 11)),
              ),
            ],
          ),
        ),
        SizedBox(width: responsiveFontSize(context, 10)),
        Stack(
          alignment: Alignment.center,
          children: [
            Container( // Lingkaran abu-abu besar di belakang
              width: responsiveFontSize(context, 80),
              height: responsiveFontSize(context, 80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onSurface.withOpacity(0.08), // Warna lebih netral
              ),
            ),
            Container( // Lingkaran putih/terang di depan
              width: responsiveFontSize(context, 55),
              height: responsiveFontSize(context, 55),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1
                    )
                  ]
              ),
              child: Icon(Remix.coins_fill, color: coinColor, size: responsiveFontSize(context, 28)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInSection(BuildContext context, Color cardBgColor, Color lightTextColor, Color primaryTextColor, Color accentColor, Color coinColor, Color giftColor, List<BoxShadow> cardShadow) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 16)),
      decoration: BoxDecoration(
        color: cardBgColor, // Menggunakan warna card dari argumen
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
        boxShadow: cardShadow, // Menambahkan shadow
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Check-in hari ke $_currentDayOfMonth",
                  style: GoogleFonts.montserrat(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: responsiveFontSize(context, 15))),
              SizedBox(width: responsiveFontSize(context, 4)),
              Icon(Remix.question_line,
                  color: lightTextColor, size: responsiveFontSize(context, 16)),
            ],
          ),
          // Konten kalender tidak lagi dibungkus if _isCheckInSectionExpanded
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
            itemCount: _daysInCurrentMonth,
            itemBuilder: (context, index) {
              int day = index + 1;
              DateTime dateForDay = DateTime(_today.year, _today.month, day);
              int status = _dailyCheckInStatus[index];

              IconData iconData;
              Color iconColorToUse;
              bool isTodayCurrent = (day == _currentDayOfMonth);

              if (status == 1) {
                iconData = Remix.checkbox_circle_fill; // Lebih jelas kalau sudah di-check
                iconColorToUse = accentColor;
              } else if (isTodayCurrent && status == 3) { // Hari ini dan belum check-in
                iconData = Remix.circle_line; // Menggunakan Remix.circle_line
                iconColorToUse = coinColor; // Warna koin untuk menandakan bisa di-check-in
              }
              else if (dateForDay.weekday == DateTime.monday && status != 1) {
                iconData = Remix.gift_2_fill; // gift_2_fill agar ada isi
                iconColorToUse = giftColor;
              } else {
                iconData = Remix.copper_coin_line;
                iconColorToUse = coinColor.withOpacity(0.8);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: iconColorToUse, size: responsiveFontSize(context, 22)), // Ukuran ikon sedikit disesuaikan
                  SizedBox(height: responsiveFontSize(context, 4)),
                  Text("${translate('label.day')} $day",
                      style: GoogleFonts.montserrat(
                        color: lightTextColor.withOpacity(isTodayCurrent && status !=1 || status == 1 ? 1.0 : 0.6),
                        fontSize: responsiveFontSize(context, 9),
                        fontWeight: isTodayCurrent && status != 1 ? FontWeight.bold : FontWeight.normal,
                      )),
                ],
              );
            },
          ),
          // Tombol Tutup/Expand dihapus
          SizedBox(height: responsiveFontSize(context, 16)), // Memberi jarak ke tombol Check-in
          ElevatedButton(
            onPressed: _isTodayCheckedIn ? null : _performCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTodayCheckedIn ? theme.colorScheme.onSurface.withOpacity(0.12) : theme.colorScheme.primary,
              disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
              foregroundColor: _isTodayCheckedIn ? lightTextColor : theme.colorScheme.onPrimary,
              minimumSize: Size(double.infinity, responsiveFontSize(context, 48)),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(responsiveFontSize(context, 8)),
              ),
            ),
            child: Text(
              _isTodayCheckedIn ? translate('label.alreadyCheckInToday') : translate('label.checkInNow'),
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: responsiveFontSize(context, 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisiHarianSection(BuildContext context, Color cardBgColor, Color lightTextColor, Color primaryTextColor, Color accentColor, List<BoxShadow> cardShadow) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(responsiveFontSize(context, 16)),
      decoration: BoxDecoration(
        color: cardBgColor, // Menggunakan warna card dari argumen
        borderRadius: BorderRadius.circular(responsiveFontSize(context, 12)),
        boxShadow: cardShadow, // Menambahkan shadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(translate('label.dailyMission'),
                  style: GoogleFonts.montserrat(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: responsiveFontSize(context, 15))),
              SizedBox(width: responsiveFontSize(context, 4)),
              Icon(Remix.question_line,
                  color: lightTextColor, size: responsiveFontSize(context, 16)),
            ],
          ),
          SizedBox(height: responsiveFontSize(context, 16)),
          _buildMisiItem(
              context: context,
              icon: Remix.book_open_line,
              title: "Membaca Karya",
              reward: "+9 Koin Bonus | 0/40 menit",
              buttonText: translate('label.read'),
              onPressed: () {},
              progress: _readingProgress,
              milestones: { 0.33: "+3", 0.66: "+6" },
              milestoneLabels: { 0.33: "Baca 20 mnt", 0.66: "Baca 40 mnt" },
              theme: theme, accentColor: accentColor, cardBgColor: cardBgColor, lightTextColor: lightTextColor
          ),
          Divider(color: theme.dividerColor.withOpacity(0.5), height: responsiveFontSize(context, 24)), // Menggunakan theme.dividerColor
          _buildMisiItem(
              context: context,
              icon: Remix.time_line,
              title: "Baca karya tertentu 10 menit",
              reward: "2 Koin Bonus",
              buttonText: translate('label.read'),
              onPressed: () {},
              theme: theme, accentColor: accentColor, cardBgColor: cardBgColor, lightTextColor: lightTextColor
          ),
          Divider(color: theme.dividerColor.withOpacity(0.5), height: responsiveFontSize(context, 24)),
          _buildMisiItem(
              context: context,
              icon: Remix.user_settings_line,
              title: "Melengkapi Informasi",
              reward: "+2 Koin",
              buttonText: translate('label.fill'),
              onPressed: () {},
              theme: theme, accentColor: accentColor, cardBgColor: cardBgColor, lightTextColor: lightTextColor
          ),
        ],
      ),
    );
  }

  Widget _buildMisiItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String reward,
    required String buttonText,
    required VoidCallback onPressed,
    double? progress,
    Map<double, String>? milestones,
    Map<double, String>? milestoneLabels,
    required ThemeData theme,
    required Color accentColor,
    required Color cardBgColor,
    required Color lightTextColor
  }) {
    // ... (Implementasi _buildMisiItem tetap sama seperti sebelumnya, pastikan warna di dalamnya juga adaptif jika perlu)
    // Untuk singkatnya, saya tidak copy ulang di sini, tapi pastikan ia menggunakan warna tema dengan benar
    // Contoh penyesuaian warna di ElevatedButton di dalam _buildMisiItem:
    // backgroundColor: theme.colorScheme.onSurface.withOpacity(0.10),
    // foregroundColor: theme.colorScheme.onSurface,
    // Untuk progress bar, color: theme.colorScheme.onSurface.withOpacity(0.1) untuk background,
    // dan accentColor (atau theme.colorScheme.primary) untuk foreground.
    // Untuk teks milestone, color: progress >= milestoneProgress ? Colors.white : lightTextColor, dll.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: lightTextColor, size: responsiveFontSize(context, 20)),
            SizedBox(width: responsiveFontSize(context, 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface, fontSize: responsiveFontSize(context, 13.5), fontWeight: FontWeight.w500)),
                  SizedBox(height: responsiveFontSize(context, 2)),
                  Text(reward, style: GoogleFonts.montserrat(color: lightTextColor, fontSize: responsiveFontSize(context, 11))),
                ],
              ),
            ),
            SizedBox(width: responsiveFontSize(context, 8)),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15), // Warna tombol lebih terang
                foregroundColor: theme.colorScheme.primary, // Teks tombol
                padding: EdgeInsets.symmetric(horizontal: responsiveFontSize(context, 18), vertical: responsiveFontSize(context, 8)),
                textStyle: GoogleFonts.montserrat(fontSize: responsiveFontSize(context, 12), fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveFontSize(context, 20))),
                elevation: 0,
              ),
              child: Text(buttonText),
            )
          ],
        ),
        if (progress != null && milestones != null && milestoneLabels != null) ...[
          SizedBox(height: responsiveFontSize(context, 12)),
          LayoutBuilder(
              builder: (context, constraints) {
                double progressBarWidth = constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: responsiveFontSize(context, 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(responsiveFontSize(context, 4)),
                      ),
                    ),
                    Container(
                      height: responsiveFontSize(context, 8),
                      width: progressBarWidth * progress,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(responsiveFontSize(context, 4)),
                      ),
                    ),
                    ...milestones.entries.map((entry) {
                      double milestoneProgress = entry.key;
                      String milestoneReward = entry.value;
                      String milestoneLabel = milestoneLabels[milestoneProgress] ?? "";

                      return Positioned(
                        left: progressBarWidth * milestoneProgress - responsiveFontSize(context, 8),
                        top: responsiveFontSize(context, -3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: responsiveFontSize(context, 13),
                              height: responsiveFontSize(context, 13),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: progress >= milestoneProgress ? accentColor : theme.colorScheme.onSurface.withOpacity(0.2),
                                  border: Border.all(color: cardBgColor, width: 1.5)
                              ),
                              child: Center(
                                child: Text(
                                  milestoneReward,
                                  style: GoogleFonts.montserrat(
                                      color: progress >= milestoneProgress ? (accentColor.computeLuminance() > 0.5 ? Colors.black: Colors.white) : lightTextColor,
                                      fontSize: responsiveFontSize(context, 7.5),
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                            if(milestoneLabel.isNotEmpty) ...[
                              SizedBox(height: responsiveFontSize(context, 16)),
                              Text(
                                milestoneLabel,
                                style: GoogleFonts.montserrat(
                                  color: lightTextColor.withOpacity(0.8),
                                  fontSize: responsiveFontSize(context, 8.5),
                                ),
                              ),
                            ]
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }
          ),
          SizedBox(height: responsiveFontSize(context, 8)),
        ]
      ],
    );
  }
}