// GENERATED CODE - DO NOT MODIFY BY HAND

part of model_auth_id;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthId _$AuthIdFromJson(Map<String, dynamic> json) => AuthId(
      publicKey: json['public_key'] as String,
      privateKey:
          (json['private_key'] as List<dynamic>).map((e) => e as int).toList(),
      password:
          (json['password'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$AuthIdToJson(AuthId instance) => <String, dynamic>{
      'public_key': instance.publicKey,
      'private_key': instance.privateKey,
      'password': instance.password,
    };
