# Special class to describe the HTTP response that should be sent back.  Gateway
# searches the message string of a JS Error Class, so we're bundling all
# statuses in an error package, givng end users the ability to select a response
# overriding the default for a Lambda / Gateway handler.

StandardError = require "standard-error"

create = (name, message, code) ->
  errorConstructor = (reason) ->
    StandardError.call(this, message, {reason: reason, code: code})

  errorConstructor.prototype = Object.create StandardError.prototype,
    {constructor: {value: errorConstructor, configurable: true, writable: true}}

  errorConstructor.prototype.name = name
  return errorConstructor

module.exports =
  Continue: create "Continue", "continue", 100
  SwitchingProtocols: create "SwitchingProtocols", "switching protocols", 101
  Processing: create "Processing", "processing", 102

  OK: create "OK", "ok", 200
  Created: create "Created", "created", 201
  Accepted: create "Accepted", "accepted", 202
  NonAuthoritativeInformation: : create "NonAuthoritativeInformation", "non-authoritative information", 203
  NoContent: create "NoContent", "no content", 204
  ResetContent: create "ResetContent", "reset content", 205
  PartialContent: create "PartialContent", "partial content", 206
  MultiStatus: create "MultiStatus", "multi-status", 207
  AlreadyReported: create "AlreadyReported", "already reported", 208
  IMUsed: create "IMUsed", "IM used", 226

  MultipleChoices: create "MultipleChoices", "multiple choices", 300
  MovedPermanently: create "MovedPermanently", "moved permanently", 301
  Found: create "Found", "found", 302
  SeeOther: create "SeeOther", "see other", 303
  NotModified: create "NotModified", "not modified", 304
  UseProxy: create "UseProxy", "use proxy", 305
  TemporaryRedirect: create "TemporaryRedirect", "temporary redirect", 307
  PermanentRedirect: create "PermanentRedirect", "permanent redirect", 308

  BadRequest: create "BadRequest", "bad request", 400
  Unauthorized: create "Unauthorized", "unauthorized", 401
  PaymentRequired: create "PaymentRequired", "payment required", 402
  Forbidden: create "Forbidden", "forbidden", 403
  NotFound: create "NotFound", "not found", 404
  MethodNotAllowed: create "MethodNotAllowed", "method not allowed", 405
  MethodNotAcceptable: create "MethodNotAcceptable", "method not acceptable", 406
  ProxyAuthenticationRequired: create "ProxyAuthenticationRequired", "proxy authentication required", 407
  RequestTimeout: create "RequestTimeout", "request timeout", 408
  Conflict: create "Conflict", "conflict", 409
  Gone: create "Gone", "gone", 410
  LengthRequired: create "LengthRequired", "length required", 411
  PreconditionFailed: create "PreconditionFailed", "precondition failed", 412
  TooLarge: create "TooLarge", "request entity too large", 413
  URITooLong: create "URITooLong", "URI too long", 414
  UnsupportedMediaType: create "UnsupportedMediaType", "unsupported media type", 415
  RangeNotSatisfiable: create "RangeNotSatisfiable", "range not satisfiable", 416
  ExpectationFailed: create "ExpectationFailed", "expectation failed", 417
  IMATeapot: create "IMATeapot", "I'm a teapot", 418
  EnhanceYourCalm: create "EnhanceYourCalm:", "enhance your calm", 420
  MisdirectedRequest: create "MisdirectedRequest ", "misdirected request ", 421
  UnprocessableEntity: create "UnprocessableEntity", "unprocessable entity", 422
  Locked: create "Locked", "locked", 423
  FailedDependency: create "FailedDependency", "failed dependency", 424
  UpgradeRequired: create "UpgradeRequired", "upgrade required", 426
  PreconditionRequired: create "PreconditionRequired", "precondition required", 428
  TooManyRequests: create "TooManyRequests", "too many requests", 429
  RequestHeaderFieldsTooLarge: create "RequestHeaderFieldsTooLarge", "request header fields too large", 431
  UnavailableForLegalReasons: create "UnavailableForLegalReasons", "unavailable for legal reasons", 451

  Internal: create "Internal", "internal server error", 500
  NotImplemented: create "NotImplemented", "not implemented", 501
  BadGateway: create "BadGateway", "bad gateway", 502
  ServiceUnavailable: create "ServiceUnavailable", "service unavailable", 503
  GatewayTimeout: create "GatewayTimeout", "gateway time-out", 504
  HTTPVersionNotSupported: create "HTTPVersionNotSupported", "HTTP version not supported", 505
  VariantAlsoNegotiates: create "VariantAlsoNegotiates", "variant also negotiates", 506
  InsufficientStorage: create "InsufficientStorage", "insufficient storage", 507
  LoopDetected: create "LoopDetected", "loop detected", 508
  NotExtended: create "Not Extended", "not extended", 510
  NetworkAuthenticationRequired: create "NetworkAuthenticationRequired", "network authentication required", 511
