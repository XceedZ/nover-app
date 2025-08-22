class Chapter {
  final int chapterId;
  final String title;
  final int coinCost;
  final int totalViews;
  final String createDatetime;
  final int chapterOrder;
  // FIX: Tambahkan properti content yang opsional
  final String? content;

  Chapter({
    required this.chapterId,
    required this.title,
    required this.coinCost,
    required this.totalViews,
    required this.createDatetime,
    required this.chapterOrder,
    // FIX: Tambahkan di konstruktor
    this.content,
  });

  // FIX: Perbarui factory fromJson
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as int,
      title: json['title'] ?? 'Untitled Chapter',
      coinCost: json['coinCost'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      createDatetime: json['createDatetime'] ?? '',
      chapterOrder: json['chapterOrder'] ?? 0,
      // API detail akan punya 'content', tapi list tidak.
      // Jadi kita ambil jika ada.
      content: json['content'],
    );
  }

  // FIX: Tambahkan metode copyWith untuk imutabilitas
  Chapter copyWith({
    int? chapterId,
    String? title,
    int? coinCost,
    int? totalViews,
    String? createDatetime,
    int? chapterOrder,
    String? content,
  }) {
    return Chapter(
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      coinCost: coinCost ?? this.coinCost,
      totalViews: totalViews ?? this.totalViews,
      createDatetime: createDatetime ?? this.createDatetime,
      chapterOrder: chapterOrder ?? this.chapterOrder,
      content: content ?? this.content,
    );
  }
}