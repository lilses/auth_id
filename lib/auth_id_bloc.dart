library bloc_auth_id;

import 'dart:convert';

import 'package:auth_id/auth_id_state.dart';
import 'package:encrypted_auth_id/encrypted_auth_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'auth_id_model.dart';
import 'wallet_request.dart';


const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';


class BlocAuthId extends Cubit<AuthIdState> {
  BlocAuthId() : super(const AuthIdState.none());

  Future<AuthId> makeNew() async {
    final authId = await AuthId.create();
    emit(AuthIdState.some(authId));
    return authId;
  }

  restore(EncryptedAuthId encryptedAuthId, String password) async {
    final authId = await AuthId.restore(encryptedAuthId, password);
    emit(AuthIdState.some(authId));
  }

  AuthId? get(){
    return state.map(none: (none){
      return null;
    }, some: (some){
      return some.authId;
    });
  }

  Future<WalletRequest?> sign() async {
    return state.map(
        none: (none){
          print("BlocAuthId sign Error: unreachable");
          return null;
        },
        some: (some){
          final authId = some.authId;
          final r = Random();
          final message = utf8.encode(List.generate(10, (index) => chars[r.nextInt(chars.length)]).join());
          final signature  = authId.sign(message);

          return WalletRequest(
              message: message,
              publicKey: authId.publicKey,
              signature: signature,
              networkId: 1
          );
        }
    );
  }
}
