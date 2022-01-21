enum HttpStatus {
  unknown,
  ok,
  noContent,
  badRequest,
  unauthorized,
  clientError,
  internalServerError,
  badGateway,
  serverError,
  unhandleError,
}

abstract class HttpResponse {
  const HttpResponse({
    this.status = HttpStatus.unknown,
    this.message = '',
  });
  final HttpStatus status;
  final String message;
  bool isOk() => [HttpStatus.ok, HttpStatus.noContent].contains(status);
}

class HttpResponseOk extends HttpResponse {
  const HttpResponseOk(this.content) : super(status: HttpStatus.ok);
  final dynamic content;
}

class HttpResponseNoContent extends HttpResponse {
  const HttpResponseNoContent() : super(status: HttpStatus.noContent);
}

class HttpResponseBadRequest extends HttpResponse {
  const HttpResponseBadRequest({String message = 'BadRequest'})
      : super(status: HttpStatus.badRequest, message: message);
}

class HttpResponseUnauthorized extends HttpResponse {
  const HttpResponseUnauthorized({String message = 'Authentication required'})
      : super(status: HttpStatus.unauthorized, message: message);
}

class HttpResponseClientError extends HttpResponse {
  const HttpResponseClientError({String message = 'Client Errors'})
      : super(status: HttpStatus.clientError, message: message);
}

class HttpResponseInternalServerError extends HttpResponse {
  const HttpResponseInternalServerError(
      {String message = 'Internal Server Error'})
      : super(status: HttpStatus.internalServerError, message: message);
}

class HttpResponseBadGateway extends HttpResponse {
  const HttpResponseBadGateway({String message = 'BadGateWay'})
      : super(status: HttpStatus.badGateway, message: message);
}

class HttpResponseServerError extends HttpResponse {
  const HttpResponseServerError({String message = 'Server Errors'})
      : super(status: HttpStatus.serverError, message: message);
}

class HttpResponseUnhandleError extends HttpResponse {
  const HttpResponseUnhandleError({String message = 'Unhandle Errors'})
      : super(status: HttpStatus.unhandleError, message: message);
}
