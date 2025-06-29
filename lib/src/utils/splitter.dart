List<String> splitGenres(String? genresString) {
  if (genresString == null || genresString.isEmpty) return [];
  return genresString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
