import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DioRequest with DioMixin {
  ///缓存配置
  late CacheOptions? cacheOptions;

  ///Cookie 配置
  CookieJar? cookieJar;

  ///构造方法
  ///如果baseUrl不等于空，options中的baseUrl属性会被这个参数覆盖
  DioRequest(
      {String? baseUrl,
      BaseOptions? op,
      LogInterceptor? log,
      CacheOptions? cache,
      String? cookiePath,
      List<Interceptor>? interceptorList}) {
    options = op ?? DefaultOption(baseUrl: baseUrl);
    if (baseUrl != null && baseUrl.isNotEmpty) {
      options.baseUrl = baseUrl;
    }
    if (kDebugMode && log != null) {
      interceptors.add(log);
    }
    if (cache != null) {
      cacheOptions = cache;
      interceptors.add(DioCacheInterceptor(options: cache));
    }
    if (cookiePath != null && cookiePath.isNotEmpty) {
      cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
      interceptors.add(CookieManager(cookieJar!));
    }
    if (interceptorList != null && interceptorList.isNotEmpty) {
      interceptors.addAll(interceptorList);
    }
  }

  ///创建默认的DioRequest实例
  static Future<DioRequest> getInstance(
      {String? baseUrl,
      BaseOptions? op,
      List<Interceptor>? interceptorList}) async {
    final logInterceptor = LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
        request: false,
        requestBody: true);

    final cacheOptions = CacheOptions(
        store: MemCacheStore(),
        hitCacheOnErrorExcept: [401, 403, 404],
        maxStale: const Duration(days: 7));

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String cookiePath = appDocDir.path + "/.cookies/";

    return DioRequest(
        baseUrl: baseUrl,
        op: op,
        log: logInterceptor,
        cache: cacheOptions,
        cookiePath: cookiePath,
        interceptorList: interceptorList);
  }

  ///判断指定key的缓存是否存在
  Future<bool> cacheExists(String key) async {
    return await cacheOptions?.store?.exists(key) ?? false;
  }

  ///获取指定Key的缓存
  Future<CacheResponse?> getCache(String key) async {
    return await cacheOptions?.store?.get(key);
  }

  ///设置缓存
  Future<void> setCache(CacheResponse response) async {
    await cacheOptions?.store?.set(response);
  }

  ///删除缓存
  Future<void> deleteCache(String key, {bool staleOnly = false}) async {
    await cacheOptions?.store?.delete(key, staleOnly: staleOnly);
  }

  ///清除所有key的缓存
  Future<void> cleanCache(
      {CachePriority priorityOrBelow = CachePriority.high,
      bool staleOnly = false}) async {
    await cacheOptions?.store
        ?.clean(priorityOrBelow: priorityOrBelow, staleOnly: staleOnly);
  }

  ///释放底层资源
  Future<void> closeCache() async {
    await cacheOptions?.store?.close();
  }

  ///保存指定 uri 的 cookie。
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {
    await cookieJar?.saveFromResponse(uri, cookies);
  }

  ///获取指定 uri 的 cookie。
  Future<List<Cookie>?> loadForRequest(Uri uri) async {
    return await cookieJar?.loadForRequest(uri);
  }

  ///删除所以cookie
  Future deleteAllCookie() async {
    await cookieJar?.deleteAll();
  }

  ///删除指定Uri的Cookie
  Future<void> deleteCookie(Uri uri,
      [bool withDomainSharedCookie = false]) async {
    await cookieJar?.delete(uri, withDomainSharedCookie);
  }
}

///默认的BaseOptions配置
class DefaultOption extends BaseOptions {
  DefaultOption({String? baseUrl})
      : super(
          baseUrl: baseUrl ?? '',
          connectTimeout: 5000,
          sendTimeout: 5000,
          receiveTimeout: 5000,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        );
}
