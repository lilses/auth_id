
import 'package:auth_id/auth_id.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:types/types.dart';

part 'auth_id_state.freezed.dart';

@freezed
class AuthIdState with _$AuthIdState {
  const factory AuthIdState.none() = _None;
  const factory AuthIdState.some(AuthId authId, WalletRequest walletRequest) = _Some;
}