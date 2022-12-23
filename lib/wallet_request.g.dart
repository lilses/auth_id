// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletRequest _$WalletRequestFromJson(Map<String, dynamic> json) =>
    WalletRequest(
      publicKey: json['public_key'] as String,
      signature:
          (json['signature'] as List<dynamic>).map((e) => e as int).toList(),
      message: (json['message'] as List<dynamic>).map((e) => e as int).toList(),
      networkId: json['network_id'] as int,
    );

Map<String, dynamic> _$WalletRequestToJson(WalletRequest instance) =>
    <String, dynamic>{
      'public_key': instance.publicKey,
      'signature': instance.signature,
      'message': instance.message,
      'network_id': instance.networkId,
    };
