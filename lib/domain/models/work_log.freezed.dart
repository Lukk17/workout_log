// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkLog {

 String get id; Exercise get exercise; DateTime get created; Map<String, String> get series; Map<String, String> get load; double get bodyWeight;
/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkLogCopyWith<WorkLog> get copyWith => _$WorkLogCopyWithImpl<WorkLog>(this as WorkLog, _$identity);

  /// Serializes this WorkLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkLog&&(identical(other.id, id) || other.id == id)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.created, created) || other.created == created)&&const DeepCollectionEquality().equals(other.series, series)&&const DeepCollectionEquality().equals(other.load, load)&&(identical(other.bodyWeight, bodyWeight) || other.bodyWeight == bodyWeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exercise,created,const DeepCollectionEquality().hash(series),const DeepCollectionEquality().hash(load),bodyWeight);

@override
String toString() {
  return 'WorkLog(id: $id, exercise: $exercise, created: $created, series: $series, load: $load, bodyWeight: $bodyWeight)';
}


}

/// @nodoc
abstract mixin class $WorkLogCopyWith<$Res>  {
  factory $WorkLogCopyWith(WorkLog value, $Res Function(WorkLog) _then) = _$WorkLogCopyWithImpl;
@useResult
$Res call({
 String id, Exercise exercise, DateTime created, Map<String, String> series, Map<String, String> load, double bodyWeight
});


$ExerciseCopyWith<$Res> get exercise;

}
/// @nodoc
class _$WorkLogCopyWithImpl<$Res>
    implements $WorkLogCopyWith<$Res> {
  _$WorkLogCopyWithImpl(this._self, this._then);

  final WorkLog _self;
  final $Res Function(WorkLog) _then;

/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exercise = null,Object? created = null,Object? series = null,Object? load = null,Object? bodyWeight = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as Map<String, String>,load: null == load ? _self.load : load // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bodyWeight: null == bodyWeight ? _self.bodyWeight : bodyWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res> get exercise {
  
  return $ExerciseCopyWith<$Res>(_self.exercise, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkLog].
extension WorkLogPatterns on WorkLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkLog value)  $default,){
final _that = this;
switch (_that) {
case _WorkLog():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkLog value)?  $default,){
final _that = this;
switch (_that) {
case _WorkLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Exercise exercise,  DateTime created,  Map<String, String> series,  Map<String, String> load,  double bodyWeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkLog() when $default != null:
return $default(_that.id,_that.exercise,_that.created,_that.series,_that.load,_that.bodyWeight);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Exercise exercise,  DateTime created,  Map<String, String> series,  Map<String, String> load,  double bodyWeight)  $default,) {final _that = this;
switch (_that) {
case _WorkLog():
return $default(_that.id,_that.exercise,_that.created,_that.series,_that.load,_that.bodyWeight);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Exercise exercise,  DateTime created,  Map<String, String> series,  Map<String, String> load,  double bodyWeight)?  $default,) {final _that = this;
switch (_that) {
case _WorkLog() when $default != null:
return $default(_that.id,_that.exercise,_that.created,_that.series,_that.load,_that.bodyWeight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkLog extends WorkLog {
   _WorkLog({required this.id, required this.exercise, required this.created, final  Map<String, String> series = const <String, String>{}, final  Map<String, String> load = const <String, String>{}, this.bodyWeight = 0.0}): _series = series,_load = load,super._();
  factory _WorkLog.fromJson(Map<String, dynamic> json) => _$WorkLogFromJson(json);

@override final  String id;
@override final  Exercise exercise;
@override final  DateTime created;
 final  Map<String, String> _series;
@override@JsonKey() Map<String, String> get series {
  if (_series is EqualUnmodifiableMapView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_series);
}

 final  Map<String, String> _load;
@override@JsonKey() Map<String, String> get load {
  if (_load is EqualUnmodifiableMapView) return _load;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_load);
}

@override@JsonKey() final  double bodyWeight;

/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkLogCopyWith<_WorkLog> get copyWith => __$WorkLogCopyWithImpl<_WorkLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkLog&&(identical(other.id, id) || other.id == id)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&(identical(other.created, created) || other.created == created)&&const DeepCollectionEquality().equals(other._series, _series)&&const DeepCollectionEquality().equals(other._load, _load)&&(identical(other.bodyWeight, bodyWeight) || other.bodyWeight == bodyWeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,exercise,created,const DeepCollectionEquality().hash(_series),const DeepCollectionEquality().hash(_load),bodyWeight);

@override
String toString() {
  return 'WorkLog(id: $id, exercise: $exercise, created: $created, series: $series, load: $load, bodyWeight: $bodyWeight)';
}


}

/// @nodoc
abstract mixin class _$WorkLogCopyWith<$Res> implements $WorkLogCopyWith<$Res> {
  factory _$WorkLogCopyWith(_WorkLog value, $Res Function(_WorkLog) _then) = __$WorkLogCopyWithImpl;
@override @useResult
$Res call({
 String id, Exercise exercise, DateTime created, Map<String, String> series, Map<String, String> load, double bodyWeight
});


@override $ExerciseCopyWith<$Res> get exercise;

}
/// @nodoc
class __$WorkLogCopyWithImpl<$Res>
    implements _$WorkLogCopyWith<$Res> {
  __$WorkLogCopyWithImpl(this._self, this._then);

  final _WorkLog _self;
  final $Res Function(_WorkLog) _then;

/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exercise = null,Object? created = null,Object? series = null,Object? load = null,Object? bodyWeight = null,}) {
  return _then(_WorkLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exercise: null == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise,created: null == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as DateTime,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as Map<String, String>,load: null == load ? _self._load : load // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bodyWeight: null == bodyWeight ? _self.bodyWeight : bodyWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of WorkLog
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res> get exercise {
  
  return $ExerciseCopyWith<$Res>(_self.exercise, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}

// dart format on
