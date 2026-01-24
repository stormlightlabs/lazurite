// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnimationPreferences _$AnimationPreferencesFromJson(Map<String, dynamic> json) =>
    _AnimationPreferences(
      mode: $enumDecodeNullable(_$AnimationModeEnumMap, json['mode']) ?? AnimationMode.system,
      speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$AnimationPreferencesToJson(_AnimationPreferences instance) =>
    <String, dynamic>{
      'mode': _$AnimationModeEnumMap[instance.mode]!,
      'speedMultiplier': instance.speedMultiplier,
    };

const _$AnimationModeEnumMap = {
  AnimationMode.full: 'full',
  AnimationMode.reduced: 'reduced',
  AnimationMode.minimal: 'minimal',
  AnimationMode.system: 'system',
};
