part of picker_driver_api;

class _DebuggableClient implements http.Client {
  final http.Client _client;

  _DebuggableClient(this._client);

  @override
  void close() => _client.close();

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   print('[HTTP] [$requestId] method=DELETE');
    //   print('[HTTP] [$requestId] url=$url');
    //   print('[HTTP] [$requestId] headers=$headers');
    //   print('[HTTP] [$requestId] body=$body');
    //   print('[HTTP] [$requestId] encoding=$encoding');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.delete(url,
          headers: headers, body: body, encoding: encoding);

      // if (kDebugMode) {
      //   print(
      //       '[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }
      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   print('[HTTP] [$requestId] method=GET');
    //   print('[HTTP] [$requestId] url=$url');
    //   print('[HTTP] [$requestId] headers=$headers');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.get(url, headers: headers);

      // if (kDebugMode) {
      //   print('[HTTP] [$requestId] status=${result.statusCode}');
      //   print('[HTTP] [$requestId] response=${result.body}');
      //   print('[HTTP] [$requestId] headers=${result.headers}');
      //   print(
      //       '[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }

      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   print('[HTTP] [$requestId] method=HEAD');
    //   print('[HTTP] [$requestId] url=$url');
    //   print('[HTTP] [$requestId] headers=$headers');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.head(url, headers: headers);

      // if (kDebugMode) {
      //   print(
      //       '[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }
      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   print('[HTTP] [$requestId] method=PATCH');
    //   print('[HTTP] [$requestId] url=$url');
    //   print('[HTTP] [$requestId] headers=$headers');
    //   print('[HTTP] [$requestId] body=$body');
    //   print('[HTTP] [$requestId] encoding=$encoding');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.patch(url,
          headers: headers, body: body, encoding: encoding);

      // if (kDebugMode) {
      //   print(
      //       '[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }
      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   log('[HTTP] [$requestId] method=POST');
    //   log('[HTTP] [$requestId] url=$url');
    //   log('[HTTP] [$requestId] headers=$headers');
    //   log('[HTTP] [$requestId] body=$body');
    //   log('[HTTP] [$requestId] encoding=$encoding');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.post(url,
          headers: headers, body: body, encoding: encoding);
      // if (kDebugMode) {
      //   log('[HTTP] [$requestId] status=${result.statusCode}');
      //   log('[HTTP] [$requestId] response=${result.body}');
      //   log('[HTTP] [$requestId] headers=${result.headers}');
      //   log('[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }

      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final requestId = const Uuid().v4();
    // if (kDebugMode) {
    //   print('[HTTP] [$requestId] method=PUT');
    //   print('[HTTP] [$requestId] url=$url');
    //   print('[HTTP] [$requestId] headers=$headers');
    //   print('[HTTP] [$requestId] body=$body');
    //   print('[HTTP] [$requestId] encoding=$encoding');
    // }

    Stopwatch stopwatch = Stopwatch()..start();
    try {
      final result = await _client.put(url,
          headers: headers, body: body, encoding: encoding);

      // if (kDebugMode) {
      //   print(
      //       '[HTTP] [$requestId] took=${stopwatch.elapsedMilliseconds} milliseconds to connect to $url');
      // }
      return result;
    } catch (e) {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      _client.read(url, headers: headers);

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      _client.readBytes(url, headers: headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request);
}
