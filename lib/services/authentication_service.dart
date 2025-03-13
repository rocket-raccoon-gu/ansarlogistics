abstract class AuthenticationService {
  /// Single point function to handle all webservice request to general sp service
  /// ```dart
  /// generalSPService(request: { ..... });
  /// ```
  /// will return the response object.
  Future<String> generalSPService({required String endpoint});
}
