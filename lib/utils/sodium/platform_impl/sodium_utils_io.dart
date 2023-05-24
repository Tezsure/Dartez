import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartez/utils/sodium/platform_impl/sodium_utils_base.dart'
    as base;
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:sodium/sodium_sumo.dart' as sumo;

class SodiumUtilsImpl extends base.SodiumUtilsBase {
  @override
  Future<void> init() async {
    if (Platform.isMacOS) {
      // must have libsodium installed on macos
      sodium = await sumo.SodiumSumoInit.init2(() => DynamicLibrary.open(
          "/usr/local/lib/libsodium.dylib")); // "/usr/local/lib/libsodium.dylib"
    } else
      sodium = await SodiumSumoInit.init();
  }

  @override
  Uint8List close(Uint8List message, Uint8List nonce, Uint8List keyBytes) {
    return sodium!.crypto.secretBox.easy(
        message: message,
        nonce: nonce,
        key: SecureKey.fromList(sodium!, keyBytes));
  }

  @override
  Uint8List nonce() {
    return rand(sodium!.crypto.secretBox.nonceBytes);
  }

  @override
  Uint8List open(Uint8List nonceAndCiphertext, Uint8List key) {
    var nonce =
        nonceAndCiphertext.sublist(0, sodium!.crypto.secretBox.nonceBytes);
    var ciphertext =
        nonceAndCiphertext.sublist(sodium!.crypto.secretBox.nonceBytes);

    return sodium!.crypto.secretBox.openEasy(
        cipherText: ciphertext,
        nonce: nonce,
        key: SecureKey.fromList(sodium!, key));
  }

  @override
  base.KeyPair publicKey(Uint8List sk) {
    // only 2 valid lengths for sk are 32 and 64 or throw exception
    if (sk.length != 32 && sk.length != 64) {
      throw Exception("Invalid secret key length");
    }

    // if sk length is 32, it is a seed, not a secret key
    if (sk.length == 32) {
      return cryptoSignSeedKeypair(sk);
    }

    var seed = sodium!.crypto.sign.skToPk(SecureKey.fromList(sodium!, sk));
    var temp =
        sodium!.crypto.sign.seedKeyPair(SecureKey.fromList(sodium!, seed));
    return base.KeyPair(temp.publicKey, temp.secretKey.extractBytes());
  }

  @override
  Uint8List pwhash(String passphrase, Uint8List salt) {
    return sodium!.crypto.pwhash
        .call(
            outLen: sodium!.crypto.box.seedBytes,
            password: Int8List.fromList(passphrase.codeUnits),
            salt: salt,
            opsLimit: 4,
            memLimit: 33554432,
            alg: CryptoPwhashAlgorithm.argon2i13)
        .extractBytes();
  }

  @override
  Uint8List rand(int length) {
    return sodium!.randombytes.buf(length);
  }

  @override
  Uint8List salt() {
    return Uint8List.fromList(rand(sodium!.crypto.pwhash.saltBytes).toList());
  }

  @override
  Uint8List sign(Uint8List simpleHash, Uint8List key) {
    return sodium!.crypto.sign.detached(
        message: simpleHash, secretKey: SecureKey.fromList(sodium!, key));
  }

  @override
  getSodium() {
    return sodium!;
  }

  @override
  base.KeyPair cryptoSignSeedKeypair(Uint8List seed) {
    var temp =
        sodium!.crypto.sign.seedKeyPair(SecureKey.fromList(sodium!, seed));
    return base.KeyPair(temp.publicKey, temp.secretKey.extractBytes());
  }

  @override
  Uint8List cryptoSignDetached(Uint8List message, Uint8List key) {
    return sodium!.crypto.sign.detached(
        message: message, secretKey: SecureKey.fromList(sodium!, key));
  }
}
