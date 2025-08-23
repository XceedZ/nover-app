// Model untuk konfigurasi hadiah check-in per hari
class DailyCheckinReward {
  final int dayNumber;
  final int rewardAmount;

  DailyCheckinReward({required this.dayNumber, required this.rewardAmount});

  factory DailyCheckinReward.fromJson(Map<String, dynamic> json) {
    return DailyCheckinReward(
      dayNumber: json['dayNumber'],
      rewardAmount: json['rewardAmount'],
    );
  }
}

// Model untuk status check-in keseluruhan dari user
class CheckinStatus {
  final int totalCheckinsThisMonth;
  final bool todayCheckedIn;
  final List<DailyCheckinReward> rewards;
  final List<String> checkedInDates; // Format "YYYY-MM-DD"

  CheckinStatus({
    required this.totalCheckinsThisMonth,
    required this.todayCheckedIn,
    required this.rewards,
    required this.checkedInDates,
  });

  factory CheckinStatus.fromJson(Map<String, dynamic> json) {
    var rewardsList = (json['rewards'] as List<dynamic>?)
        ?.map((e) => DailyCheckinReward.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];
    var datesList = (json['checkedInDates'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ??
        [];

    return CheckinStatus(
      totalCheckinsThisMonth: json['totalCheckinsThisMonth'] ?? 0,
      todayCheckedIn: json['todayCheckedIn'] ?? false,
      rewards: rewardsList,
      checkedInDates: datesList,
    );
  }
}

class MissionInfo {
  final int missionId;
  final String title;
  final String description;

  MissionInfo({required this.missionId, required this.title, required this.description});

  factory MissionInfo.fromJson(Map<String, dynamic> json) {
    return MissionInfo(
      missionId: json['missionId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class MissionTier {
  final int tierId;
  final int threshold;
  final int rewardAmount;
  final int tierOrder;

  MissionTier({required this.tierId, required this.threshold, required this.rewardAmount, required this.tierOrder});

  factory MissionTier.fromJson(Map<String, dynamic> json) {
    return MissionTier(
      tierId: json['tierId'] ?? 0,
      threshold: json['threshold'] ?? 0,
      rewardAmount: json['rewardAmount'] ?? 0,
      tierOrder: json['tierOrder'] ?? 0,
    );
  }
}

class MissionStatus {
  final MissionInfo missionInfo;
  final List<MissionTier> tiers;
  final int currentProgress;
  final int lastClaimedTier;

  MissionStatus({
    required this.missionInfo,
    required this.tiers,
    required this.currentProgress,
    required this.lastClaimedTier,
  });

  factory MissionStatus.fromJson(Map<String, dynamic> json) {
    var tiersList = (json['tiers'] as List<dynamic>?)
        ?.map((e) => MissionTier.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return MissionStatus(
      missionInfo: MissionInfo.fromJson(json['missionInfo']),
      tiers: tiersList,
      currentProgress: json['currentProgress'] ?? 0,
      lastClaimedTier: json['lastClaimedTier'] ?? 0,
    );
  }
}

// Model gabungan untuk seluruh data di halaman Event Center
class EventCenterData {
  final CheckinStatus checkinStatus;
  final List<MissionStatus> missions;

  EventCenterData({required this.checkinStatus, required this.missions});
}