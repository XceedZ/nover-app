// lib/src/constants/api_constants.dart

class ApiConstants {
  // Kunci untuk mengambil base URL dari file .env
  static const String baseUrlKey = 'BASE_URL';

  // Endpoint untuk Autentikasi (tanpa /v1)
  static const String loginEndpoint = 'auth/login';
  static const String registerEndpoint = 'auth/register';

  // Endpoint untuk fitur v1
  static const String getBanksEndpoint = 'v1/bank/get';
  static const String requestAuthorEndpoint = '/v1/user/request-author';
  static const String getAuthorStatusEndpoint = '/v1/user/author-status';
  static const String getMyBooksEndpoint = '/v1/books/my-books';
  static const String createBookEndpoint = '/v1/books/create';
  static const String getGenresEndpoint = '/v1/genres';
  static String updateBookStatus(int bookId, String action) {
    // action bisa berupa: 'complete', 'hold', 'publish', 'unpublish'
    return '/v1/books/$bookId/$action';
  }
  static String createChapter(int bookId) => '/v1/books/$bookId/chapters';
  static String getBookDetail(int bookId) => '/v1/books/$bookId/detail';
  static const String getBooksEndpoint = '/v1/books';
  static String getBookDetailPublic(int bookId) => '/v1/books/$bookId';
  static String getChapterDetail(int chapterId) => '/v1/chapters/$chapterId';

}