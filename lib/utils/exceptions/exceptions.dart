class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No Internet Connection']);
}
