#import "DioHttpCachePlugin.h"
#if __has_include(<dio_http_cache/dio_http_cache-Swift.h>)
#import <dio_http_cache/dio_http_cache-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dio_http_cache-Swift.h"
#endif

@implementation DioHttpCachePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDioHttpCachePlugin registerWithRegistrar:registrar];
}
@end
