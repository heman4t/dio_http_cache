import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio_http_cache/src/core/config.dart';
import 'package:dio_http_cache/src/core/obj.dart';
import 'package:dio_http_cache/src/store/store_disk.dart';
import 'package:dio_http_cache/src/store/store_impl.dart';
import 'package:dio_http_cache/src/store/store_memory.dart';
import 'package:sqflite/utils/utils.dart';

class CacheManager {
  CacheConfig _config;
  ICacheStore? _diskCacheStore;
  ICacheStore? _memoryCacheStore;
  Hash _md5 = md5;
  Utf8Encoder _utf8encoder = const Utf8Encoder();

  CacheManager(this._config) {
    if (!_config.skipDiskCache)
      _diskCacheStore = _config.diskStore ??
          DiskCacheStore(_config.databasePath, _config.databaseName,
              _config.encrypt, _config.decrypt);
    if (!_config.skipMemoryCache)
      _memoryCacheStore = MemoryCacheStore(_config.maxMemoryCacheCount);
  }

  Future<CacheObj?> _pullFromCache(String key, {String subKey = ""}) async {
    key = _convertMd5(key);
    if (subKey.isNotEmpty) subKey = _convertMd5(subKey);
    var obj = await _memoryCacheStore?.getCacheObj(key, subKey: subKey);
    if (null == obj) {
      obj = await _diskCacheStore?.getCacheObj(key, subKey: subKey);
      if (null != obj) await _memoryCacheStore?.setCacheObj(obj);
    }
    if (null != obj) {
      var now = DateTime.now().millisecondsSinceEpoch;
      if ((obj.maxStaleDate ?? 0) > 0) {
        //if maxStaleDate exist, Remove it if maxStaleDate expired.
        if (obj.maxStaleDate! < now) {
          await delete(key, subKey: subKey);
          return null;
        }
      } else {
        //if maxStaleDate NOT exist, Remove it if maxAgeDate expired.
        if ((obj.maxAgeDate ?? 0) < now) {
          await delete(key, subKey: subKey);
          return null;
        }
      }
    }
    return obj;
  }

  Future<CacheObj?> pullFromCacheBeforeMaxAge(String key,
      {String subKey = ""}) async {
    var obj = await _pullFromCache(key, subKey: subKey);
    if ((obj?.maxAgeDate ?? 0) < DateTime.now().millisecondsSinceEpoch) {
      return null;
    }
    return obj;
  }

  Future<CacheObj?> pullFromCacheBeforeMaxStale(String key,
      {String subKey = ""}) async {
    return await _pullFromCache(key, subKey: subKey);
  }

  Future<bool> pushToCache(CacheObj obj) {
    obj.key = _convertMd5(obj.key);
    if (obj.subKey.isNotEmpty) obj.subKey = _convertMd5(obj.subKey);

    if ((obj.maxAgeDate ?? 0) <= 0) {
      obj.maxAge = _config.defaultMaxAge;
    }
    if ((obj.maxAgeDate ?? 0) <= 0) {
      return Future.value(false);
    }
    if (((obj.maxStaleDate ?? 0)  <= 0) &&
        null != _config.defaultMaxStale) {
      obj.maxStale = _config.defaultMaxStale;
    }

    return _getCacheFutureResult(
        _memoryCacheStore,
        _diskCacheStore,
        _memoryCacheStore?.setCacheObj(obj) ?? Future<bool>.value(true),
        _diskCacheStore?.setCacheObj(obj) ?? Future<bool>.value(true));
  }

  Future<bool> delete(String key, {String subKey = ""}) {
    key = _convertMd5(key);
    if (subKey.isNotEmpty) subKey = _convertMd5(subKey);

    return _getCacheFutureResult(
        _memoryCacheStore,
        _diskCacheStore,
        _memoryCacheStore?.delete(key, subKey: subKey) ??
            Future<bool>.value(true),
        _diskCacheStore?.delete(key, subKey: subKey) ??
            Future<bool>.value(true));
  }

  Future<bool> clearExpired() {
    return _getCacheFutureResult(
        _memoryCacheStore,
        _diskCacheStore,
        _memoryCacheStore?.clearExpired() ?? Future<bool>.value(true),
        _diskCacheStore?.clearExpired() ?? Future<bool>.value(true));
  }

  Future<bool> clearAll() {
    return _getCacheFutureResult(
        _memoryCacheStore,
        _diskCacheStore,
        _memoryCacheStore?.clearAll() ?? Future<bool>.value(true),
        _diskCacheStore?.clearAll() ?? Future<bool>.value(true));
  }

  String _convertMd5(String str) {
    return hex(_md5.convert(_utf8encoder.convert(str)).bytes);
  }

  Future<bool> _getCacheFutureResult(
      ICacheStore? memoryCacheStore,
      ICacheStore? diskCacheStore,
      Future<bool> memoryCacheFuture,
      Future<bool> diskCacheFuture) async {
    var result1 = (null == memoryCacheStore) ? true : (await memoryCacheFuture);
    var result2 = (null == diskCacheStore) ? true : (await diskCacheFuture);
    return result1 && result2;
  }
}
