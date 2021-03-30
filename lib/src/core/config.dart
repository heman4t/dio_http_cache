import 'package:dio_http_cache/src/store/store_impl.dart';

typedef Future<List<int>> Encrypt(List<int> str);
typedef Future<List<int>> Decrypt(List<int> str);

class CacheConfig {
  final Duration defaultMaxAge;
  final Duration defaultMaxStale;
  final String databasePath;
  final String databaseName;
  final String baseUrl;
  final String defaultRequestMethod;

  final bool skipMemoryCache;
  final bool skipDiskCache;

  final int maxMemoryCacheCount;

  final Encrypt encrypt;
  final Decrypt decrypt;
  final ICacheStore? diskStore;

  CacheConfig(
      {this.defaultMaxAge = const Duration(days: 7),
      required this.defaultMaxStale,
      this.defaultRequestMethod = "POST",
      required this.databasePath,
      this.databaseName = "DioCache",
      required this.baseUrl,
      this.skipDiskCache = false,
      this.skipMemoryCache = false,
      this.maxMemoryCacheCount = 100,
      required this.encrypt,
      required this.decrypt,
      required this.diskStore});
}
