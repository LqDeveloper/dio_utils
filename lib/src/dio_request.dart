import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'retry_interceptor.dart';

class DioRequest with DioMixin {
  static final DioRequest _instance = DioRequest._internal();

  static DioRequest get instance => _instance;

  late CacheOptions cacheOptions;
  late CookieJar cookieJar;

  DioRequest._internal() {
    options = DefaultOption();
    if (kDebugMode) {
      interceptors.add(LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
          request: false,
          requestBody: true));
    }
    cacheOptions = CacheOptions(
      store: MemCacheStore(),
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
    );
    interceptors.add(DioCacheInterceptor(options: cacheOptions));
    cookieJar = PersistCookieJar(ignoreExpires: true);
    interceptors.add(CookieManager(cookieJar));
  }

  DioRequest(
      {BaseOptions? op,
      LogInterceptor? log,
      CacheOptions? cache,
      CookieJar? cookie,
      RetryInterceptor? retry}) {
    options = op ?? DefaultOption();
    if (kDebugMode) {
      final logInterceptor = log ??
          LogInterceptor(
              responseBody: true,
              error: true,
              requestHeader: false,
              responseHeader: false,
              request: false,
              requestBody: true);
      interceptors.add(logInterceptor);
    }
    cacheOptions = cache ??
        CacheOptions(
          store: MemCacheStore(),
          hitCacheOnErrorExcept: [401, 403, 404],
          maxStale: const Duration(days: 7),
        );
    interceptors.add(DioCacheInterceptor(options: cacheOptions));
    cookieJar = cookie ?? PersistCookieJar(ignoreExpires: true);
    interceptors.add(CookieManager(cookieJar));
  }

  ///判断指定key的缓存是否存在
  Future<bool> cacheExists(String key) async {
    return await cacheOptions.store?.exists(key) ?? false;
  }

  ///获取指定Key的缓存
  Future<CacheResponse?> getCache(String key) async {
    return await cacheOptions.store?.get(key);
  }

  ///设置缓存
  Future<void> setCache(CacheResponse response) async {
    await cacheOptions.store?.set(response);
  }

  ///删除缓存
  Future<void> deleteCache(String key, {bool staleOnly = false}) async {
    await cacheOptions.store?.delete(key, staleOnly: staleOnly);
  }

  ///清除所有key的缓存
  Future<void> cleanCache(
      {CachePriority priorityOrBelow = CachePriority.high,
      bool staleOnly = false}) async {
    await cacheOptions.store
        ?.clean(priorityOrBelow: priorityOrBelow, staleOnly: staleOnly);
  }

  ///释放底层资源
  Future<void> closeCache() async {
    await cacheOptions.store?.close();
  }

  ///保存指定 uri 的 cookie。
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    await cookieJar.saveFromResponse(uri, cookies);
  }

  ///获取指定 uri 的 cookie。
  Future<List<Cookie>> loadForRequest(Uri uri) async {
    return await cookieJar.loadForRequest(uri);
  }

  ///删除所以cookie
  Future deleteAllCookie() async {
    await cookieJar.deleteAll();
  }

  ///删除指定Uri的Cookie
  Future<void> deleteCookie(Uri uri,
      [bool withDomainSharedCookie = false]) async {
    await cookieJar.delete(uri, withDomainSharedCookie);
  }
}

class DefaultOption extends BaseOptions {
  DefaultOption()
      : super(
          connectTimeout: 5000,
          sendTimeout: 5000,
          receiveTimeout: 5000,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        );
}