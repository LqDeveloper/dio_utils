import 'dart:async';
import 'package:dio/dio.dart';
import 'http_status_code.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioError error, int attempt);

///重试拦截器
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
    RetryEvaluator? retryEvaluator,
    this.ignoreRetryEvaluatorExceptions = false,
  }) : _retryEvaluator = retryEvaluator ?? defaultRetryEvaluator;

  /// Dio 对象
  final Dio dio;

  ///打印方法
  final Function(String message)? logPrint;

  ///重新请求次数
  final int retries;

  ///是否忽略异常
  final bool ignoreRetryEvaluatorExceptions;

  ///重试时间间隔
  final List<Duration> retryDelays;

  final RetryEvaluator _retryEvaluator;

  ///默认判断重试的条件
  static FutureOr<bool> defaultRetryEvaluator(DioError error, int attempt) {
    bool shouldRetry;
    if (error.type == DioErrorType.response) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = HttpStatusCode.isRetryable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry =
          error.type != DioErrorType.cancel && error.error is! FormatException;
    }
    return shouldRetry;
  }

  Future<bool> _shouldRetry(DioError error, int attempt) async {
    try {
      return await _retryEvaluator(error, attempt);
    } catch (e) {
      logPrint?.call('There was an exception in _retryEvaluator: $e');
      if (!ignoreRetryEvaluatorExceptions) {
        rethrow;
      }
    }
    return true;
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.disableRetry) {
      return super.onError(err, handler);
    }

    final attempt = err.requestOptions._attempt + 1;
    final shouldRetry = attempt <= retries && await _shouldRetry(err, attempt);

    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt);
    logPrint?.call(
      '[${err.requestOptions.path}] An error occurred during request, '
      'trying again '
      '(attempt: $attempt/$retries, '
      'wait ${delay.inMilliseconds} ms, '
      'error: ${err.error})',
    );

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    try {
      await dio
          .fetch<void>(err.requestOptions)
          .then((value) => handler.resolve(value));
    } on DioError catch (e) {
      super.onError(e, handler);
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }
}

///存储重试次数
extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'ro_attempt';
  static const _kDisableRetryKey = 'ro_disable_retry';

  ///获取重试次数
  int get _attempt => (extra[_kAttemptKey] as int?) ?? 0;

  ///将重试次数保存在RequestOptions中
  set _attempt(int value) => extra[_kAttemptKey] = value;

  ///是否禁用重试
  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  ///设置是否禁用重试
  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;
}
