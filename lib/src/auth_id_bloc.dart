library bloc_auth_id;

import 'dart:async';
import 'dart:convert';

import 'package:auth_id/auth_id.dart';
import 'package:encrypted_auth_id/encrypted_auth_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'auth_id_model.dart';
import 'wallet_request.dart';


const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';


class AuthIdBloc extends Cubit<AuthIdState> {
  final EncryptedAuthIdRepo encryptedAuthIdRepo;
  final AuthIdRepo authIdRepo;
  final String password;

  late final StreamSubscription encryptedAuthIdSubscription;
  late final StreamSubscription authIdSubscription;


  AuthIdBloc({required this.encryptedAuthIdRepo, required this.authIdRepo, required this.password}) : super(const AuthIdState.none()){
    subscribe();
  }

  @override
  Future<void> close() {
    encryptedAuthIdSubscription.cancel();
    authIdSubscription.cancel();
    return super.close();
  }

  void subscribe() {
    encryptedAuthIdSubscription = encryptedAuthIdRepo.items.listen(
          (items) {
            print("beauty90");

            items.map(
            none: (none){},
            loading: (loading){},
            some: (some){
              if (some.encryptedAuthId == null){
                authIdRepo.makeNew();
              } else {
                authIdRepo.restore(some.encryptedAuthId!, password);
              }
            });
      },
      onError: (error) => print("STREAM ERROR: $error"),
    );
    authIdSubscription = authIdRepo.items.listen((event) {
      event.map(
          none: (none) => emit(const AuthIdState.none()),
          some: (some) => emit(AuthIdState.some(some.authId))
      );
    },
      onError: (error) => print("STREAM ERROR: $error"),
    );
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
          print("AuthIdBloc sign Error: unreachable");
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
