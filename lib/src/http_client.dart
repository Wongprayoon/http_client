import 'dart:convert';

import 'package:http/http.dart';

import 'model/model.dart';

class HttpClient {
  final Client _client = Client();
  TokenSchema? _tokenBuilder;

  /// [onFetch] is a wrapper function around [Http] package.
  ///
  /// This functions produce header depend on token schema
  /// RETURN [HttpResponse]
  Future<HttpResponse> onFetch({
    bool auth = true,
    bool json = true,
    bool decode = true,
    required Future<Response> Function(Client, Map<String, String>? header)
        builder,
  }) async {
    if (auth && _tokenBuilder == null) {
      throw ArgumentError("Require refresh token scheme.");
    }
    try {
      final header = await _generateHeader(auth, json);
      final response = await builder(_client, header);
      return _handleResponse(response, decode);
    } on ClientException catch (e) {
      return HttpResponseClientError(message: e.message);
    } on ArgumentError catch (e) {
      return HttpResponseClientError(message: e.message);
    } catch (e) {
      return HttpResponseUnhandleError(message: '$e');
    }
  }

  Future<Map<String, String>?> _generateHeader(bool auth, bool json) async {
    if (auth) {
      return await _tokenBuilder?.build(json: json);
    }
    if (json) {
      return {'Content-Type': 'application/json'};
    }
    return null;
  }

  HttpResponse _handleResponse(Response response, bool decode) {
    if (response.statusCode == 200) {
      if (decode) return HttpResponseOk(jsonDecode(response.body));
      return HttpResponseOk(response.body);
    } else if (response.statusCode == 204) {
      return const HttpResponseNoContent();
    } else if (response.statusCode == 400) {
      return HttpResponseBadRequest(
          message:
              'statusCode: ${response.statusCode}, message: ${response.body}');
    } else if (response.statusCode == 401) {
      return const HttpResponseUnauthorized();
    } else if (response.statusCode >= 400 || response.statusCode < 500) {
      return HttpResponseClientError(
          message:
              'statusCode: ${response.statusCode}, message: ${response.body}');
    } else if (response.statusCode == 500) {
      return HttpResponseInternalServerError(message: response.body);
    } else if (response.statusCode == 502) {
      return const HttpResponseBadGateway();
    } else if (response.statusCode >= 500) {
      return HttpResponseServerError(
          message:
              'statusCode: ${response.statusCode}, message: ${response.body}');
    } else {
      return HttpResponseUnhandleError(
          message:
              'statusCode: ${response.statusCode}, message: ${response.body}');
    }
  }

  /// [setTokenSchema] is setter function for settting token schema.
  ///
  ///
  void setTokenSchema(TokenSchema tokenSchema) => _tokenBuilder = tokenSchema;

  void dispose() => _client.close();
}

abstract class TokenSchema {
  /// return header
  ///
  /// limitation on json body only
  Future<Map<String, String>> build({required bool json});
}

/// [TokenWithRefreshTokenSchema] is a congrete class.
///
/// Implemented in a traditional ways of api authentication flow.
class TokenWithRefreshTokenSchema implements TokenSchema {
  final HttpClient _http = HttpClient();
  final Uri refreshTokenUri;
  final Uri signInUri;
  final String Function(Map<String, dynamic>) tokenBuilder;
  final String Function(Map<String, dynamic>) refreshBodyBuilder;
  String _refreshBody;
  final String _signInBody;
  DateTime _expire;
  String _token;

  TokenWithRefreshTokenSchema(
    this.refreshTokenUri,
    this.signInUri,
    this.tokenBuilder,
    this.refreshBodyBuilder,
    this._refreshBody,
    this._signInBody,
    this._expire,
    this._token,
  );

  @override
  Future<Map<String, String>> build({required bool json}) async {
    var token = await _lazyGenerater();
    var h = {"Authorization": 'Bearer $token'};
    if (json) h['Content-Type'] = "application/json";
    return h;
  }

  Future<String> _lazyGenerater() async {
    if (_expire.compareTo(DateTime.now()) <= 10) return await _refreshToken();
    return _token;
  }

  Future<String> _refreshToken() async {
    var result = await _http.onFetch(
        auth: false,
        builder: (client, header) {
          return client.post(refreshTokenUri,
              headers: header, body: _refreshBody, encoding: utf8);
        });
    if (result is HttpResponseOk) {
      _token = tokenBuilder(result.content);
      _expire = DateTime.now().add(Duration(seconds: result.content['expire']));
      _refreshBody = refreshBodyBuilder(result.content);
      return _token;
    }
    if (result is HttpResponseUnauthorized) {
      var signInresult = await _http.onFetch(
          auth: false,
          builder: (client, header) {
            return client.post(signInUri,
                headers: header, body: _signInBody, encoding: utf8);
          });
      if (signInresult is HttpResponseOk) {
        _token = tokenBuilder(signInresult.content);
        _expire = DateTime.now()
            .add(Duration(seconds: signInresult.content['expire']));
        _refreshBody = refreshBodyBuilder(signInresult.content);
        return _token;
      }
      throw result;
    }
    throw result;
  }
}
