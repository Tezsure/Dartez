import 'package:convert/convert.dart';
import 'package:dartez/chain/tezos/tezos_message_utils.dart';
import 'package:dartez/dartez.dart';
import 'package:dartez/helper/generateKeys.dart';
import 'package:dartez/src/soft-signer/soft_signer.dart';
import 'package:dartez/utils/sodium/platform_impl/sodium_utils_base.dart';
import 'package:flutter/foundation.dart';
import 'package:secp256k1/secp256k1.dart';

class WalletUtils {
  KeyStoreModel getKeysFromMnemonic(
      Uint8List seedLength32, SignerCurve signerCurve) {
    if (signerCurve == SignerCurve.ED25519) {
      KeyPair keyPair = Dartez.sodiumUtils.cryptoSignSeedKeypair(seedLength32);
      String skKey = GenerateKeys.readKeysWithHint(
          keyPair.sk, GenerateKeys.keyPrefixes[PrefixEnum.edsk]!);
      return getKeysFromPrivateKey(skKey, signerCurve);
    } else if (signerCurve == SignerCurve.SECP256K1) {
      PrivateKey secpPk = PrivateKey.fromHex(hex.encode(seedLength32));
      var pk = GenerateKeys.readKeysWithHint(
          Uint8List.fromList(hex.decode(secpPk.toHex())),
          GenerateKeys.keyPrefixes[PrefixEnum.spsk]!);
      return getKeysFromPrivateKey(pk, signerCurve);
    }
    throw new Exception("SECP256R1 is not supported");
  }

  KeyStoreModel getKeysFromPrivateKey(
      String privateKey, SignerCurve signerCurve) {
    if (signerCurve == SignerCurve.ED25519) {
      Uint8List secretKeyBytes =
          GenerateKeys.writeKeyWithHint(privateKey, 'edsk');
      KeyPair keys = Dartez.sodiumUtils.publicKey(secretKeyBytes);
      String pkKey = TezosMessageUtils.readKeyWithHint(keys.pk, 'edpk');
      String pk = TezosMessageUtils.readKeyWithHint(keys.sk, 'edsk');
      String pkKeyHash = GenerateKeys.computeKeyHash(
          keys.pk, GenerateKeys.keyPrefixes[PrefixEnum.tz1]!);

      // private key length is 32 bytes then pk = privateKey
      if (secretKeyBytes.length == 32) {
        pk = privateKey;
      }

      return KeyStoreModel(
          publicKeyHash: pkKeyHash, publicKey: pkKey, secretKey: pk);
    } else if (signerCurve == SignerCurve.SECP256K1) {
      PrivateKey secpPk = PrivateKey.fromHex(
          hex.encode(GenerateKeys.writeKeyWithHint(privateKey, "spsk")));
      String pubHex = secpPk.publicKey.toCompressedHex();
      Uint8List pubBytes = Uint8List.fromList(hex.decode(pubHex));
      String publicKey = GenerateKeys.readKeysWithHint(
          pubBytes, GenerateKeys.keyPrefixes[PrefixEnum.sppk]!);
      String pkH = GenerateKeys.computeKeyHash(
          GenerateKeys.writeKeyWithHint(publicKey, "sppk"),
          GenerateKeys.keyPrefixes[PrefixEnum.tz2]!);
      return KeyStoreModel(
          publicKeyHash: pkH, publicKey: publicKey, secretKey: privateKey);
    }
    throw new Exception("SECP256R1 is not supported");
  }
}
