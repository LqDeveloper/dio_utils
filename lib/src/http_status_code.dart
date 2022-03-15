class HttpStatusCode {
  static const status100Continue = 100;
  static const status101SwitchingProtocols = 101;
  static const status102Processing = 102;

  static const status200OK = 200;
  static const status201Created = 201;
  static const status202Accepted = 202;
  static const status203NonAuthoritative = 203;
  static const status204NoContent = 204;
  static const status205ResetContent = 205;
  static const status206PartialContent = 206;
  static const status207Multistatus = 207;
  static const status208AlreadyReported = 208;
  static const status226IMUsed = 226;

  static const status300MultipleChoices = 300;
  static const status301MovedPermanently = 301;
  static const status302Found = 302;
  static const status303SeeOther = 303;
  static const status304NotModified = 304;
  static const status305UseProxy = 305;
  static const status306SwitchProxy = 306; // RFC 2616, removed
  static const status307TemporaryRedirect = 307;
  static const status308PermanentRedirect = 308;

  static const status400BadRequest = 400;
  static const status401Unauthorized = 401;
  static const status402PaymentRequired = 402;
  static const status403Forbidden = 403;
  static const status404NotFound = 404;
  static const status405MethodNotAllowed = 405;
  static const status406NotAcceptable = 406;
  static const status407ProxyAuthenticationRequired = 407;
  static const status408RequestTimeout = 408;
  static const status409Conflict = 409;
  static const status410Gone = 410;
  static const status411LengthRequired = 411;
  static const status412PreconditionFailed = 412;
  static const status413RequestEntityTooLarge = 413; // RFC 2616, renamed
  static const status413PayloadTooLarge = 413; // RFC 7231
  static const status414RequestUriTooLong = 414; // RFC 2616, renamed
  static const status414UriTooLong = 414; // RFC 7231
  static const status415UnsupportedMediaType = 415;
  static const status416RequestedRangeNotSatisfiable = 416; // RFC 2616, renamed
  static const status416RangeNotSatisfiable = 416; // RFC 7233
  static const status417ExpectationFailed = 417;
  static const status418ImATeapot = 418;
  static const status419AuthenticationTimeout = 419; // Not defined in any RFC
  static const status421MisdirectedRequest = 421;
  static const status422UnprocessableEntity = 422;
  static const status423Locked = 423;
  static const status424FailedDependency = 424;
  static const status426UpgradeRequired = 426;
  static const status428PreconditionRequired = 428;
  static const status429TooManyRequests = 429;
  static const status431RequestHeaderFieldsTooLarge = 431;
  static const status451UnavailableForLegalReasons = 451;

  static const status500InternalServerError = 500;
  static const status501NotImplemented = 501;
  static const status502BadGateway = 502;
  static const status503ServiceUnavailable = 503;
  static const status504GatewayTimeout = 504;
  static const status505HttpVersionNotSupported = 505;
  static const status506VariantAlsoNegotiates = 506;
  static const status507InsufficientStorage = 507;
  static const status508LoopDetected = 508;
  static const status510NotExtended = 510;
  static const status511NetworkAuthenticationRequired = 511;

// Cloudflare Statuses
  static const status520WebServerReturnedUnknownError = 520;
  static const status521WebServerIsDown = 521;
  static const status522ConnectionTimedOut = 522;
  static const status523OriginIsUnreachable = 523;
  static const status524TimeoutOccurred = 524;
  static const status525SSLHandshakeFailed = 525;
  static const status526InvalidSSLCertificate = 526;
  static const status527RailgunError = 527;

// Not in RFC:
  static const status598NetworkReadTimeoutError = 598;
  static const status599NetworkConnectTimeoutError = 599;

  /// From IIS
  static const status440LoginTimeout = 440;

  /// From ngnix
  static const status499ClientClosedRequest = 499;

  /// From AWS Elastic Load Balancer
  static const status460ClientClosedRequest = 460;

  static const retryableStatuses = <int>{
    status408RequestTimeout,
    status429TooManyRequests,
    status500InternalServerError,
    status502BadGateway,
    status503ServiceUnavailable,
    status504GatewayTimeout,
    status440LoginTimeout,
    status499ClientClosedRequest,
    status460ClientClosedRequest,
    status598NetworkReadTimeoutError,
    status599NetworkConnectTimeoutError,
    status520WebServerReturnedUnknownError,
    status521WebServerIsDown,
    status522ConnectionTimedOut,
    status523OriginIsUnreachable,
    status524TimeoutOccurred,
    status525SSLHandshakeFailed,
    status527RailgunError,
  };

  static bool isRetryable(int statusCode) =>
      retryableStatuses.contains(statusCode);
}
