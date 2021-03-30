import 'package:json_annotation/json_annotation.dart';

part 'obj.g.dart';

@JsonSerializable()
class CacheObj {
  String key;
  String subKey;
  @JsonKey(name: "max_age_date")
  int? maxAgeDate;
  @JsonKey(name: "max_stale_date")
  int? maxStaleDate;
  List<int>? content;
  int statusCode;
  List<int> headers;

  CacheObj._(
      this.key, this.subKey, this.content, this.statusCode, this.headers);

  factory CacheObj(String key, List<int>? content,
      {String subKey = "",
      Duration? maxAge,
      Duration? maxStale,
      int statusCode = 200,
      List<int> headers = const []}) {
    return CacheObj._(key, subKey, content, statusCode, headers)
      ..maxAge = maxAge
      ..maxStale = maxStale;
  }

  set maxAge(Duration? duration) =>
      (duration != null) ? this.maxAgeDate = _convertDuration(duration) : null;

  set maxStale(Duration? duration) => (duration != null)
      ? this.maxStaleDate = _convertDuration(duration)
      : null;

  _convertDuration(Duration duration) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;

  factory CacheObj.fromJson(Map<String, dynamic> json) =>
      _$CacheObjFromJson(json);

  toJson() => _$CacheObjToJson(this);
}
