library model_auth_id;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypted_auth_id/encrypted_auth_id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'auth_id_model.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class AuthId {
  late String publicKey;
  late List<int> privateKey;
  late List<int> password;

  AuthId(
      {required this.publicKey,
        required this.privateKey,
        required this.password});

  List<int> sign(List<int> data) {
    final secretKey = privateKey.toList();
    List<int> bytes = base58decode(publicKey);
    secretKey.addAll(bytes);
    final signingKey = SigningKey.fromValidBytes(Uint8List.fromList(secretKey));
    var f = signingKey.sign(Uint8List.fromList(data));
    return f.toList();
  }

  static Future<AuthId> create() async {
    final randomKeyPair = await Ed25519HDKeyPair.random();
    final privateKey = (await randomKeyPair.extract()).bytes;
    final publicKey = randomKeyPair.publicKey.toString();
    final password =
    await (await AesGcm.with256bits().newSecretKey()).extractBytes();
    return AuthId(
        publicKey: publicKey, privateKey: privateKey, password: password);
  }

  static Future<AuthId> restore(EncryptedAuthId data, String password) async {
    final decoded = base58decode(data.encryptedAuthId);
    final decryptedAuthId = await decrypt(decoded, password);
    return AuthId.fromJson(jsonDecode(utf8.decode(decryptedAuthId)) as dynamic);
  }

  static Future<List<int>> encrypt(List<int> data, String password) async {
    final algorithm = AesGcm.with256bits();
    final nonce = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    final passwordBytes = utf8.encode(password); // data being hashed
    final digest1 = sha256.convert(passwordBytes);
    final secretKey = await algorithm.newSecretKeyFromBytes(digest1.bytes);
    final secretBox = await algorithm.encrypt(
      data,
      secretKey: SecretKey(await secretKey.extractBytes()),
      nonce: nonce,
    );
    return secretBox.concatenation();
  }

  static Future<List<int>> decrypt(List<int> data, String password) async {
    final algorithm = AesGcm.with256bits();
    final passwordBytes = utf8.encode(password); // data being hashed
    final digest1 = sha256.convert(passwordBytes);
    final secretKey = await algorithm.newSecretKeyFromBytes(digest1.bytes);
    final clearText = await algorithm.decrypt(
      SecretBox.fromConcatenation(data, nonceLength: 12, macLength: 16),
      secretKey: SecretKey(await secretKey.extractBytes()),
    );
    return clearText;
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory AuthId.fromJson(Map<String, dynamic> json) => _$AuthIdFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$AuthIdToJson(this);
}
