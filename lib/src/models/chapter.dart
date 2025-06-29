class Chapter {
  final int chapterId;
  final String title;
  final int coinCost;
  final int totalViews;
  final String createDatetime;
  final int chapterOrder;
  // Tambahkan properti lain jika diperlukan

  Chapter({
    required this.chapterId,
    required this.title,
    required this.coinCost,
    required this.totalViews,
    required this.createDatetime,
    required this.chapterOrder,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as int,
      title: json['title'] ?? 'Untitled Chapter',
      coinCost: json['coinCost'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      createDatetime: json['createDatetime'] ?? '',
      chapterOrder: json['chapterOrder'] ?? 0,
    );
  }
}