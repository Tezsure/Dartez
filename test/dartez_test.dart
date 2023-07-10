import 'package:dartez/chain/tezos/tezos_node_reader.dart';
import 'package:dartez/chain/tezos/tezos_node_writer.dart';
import 'package:dartez/dartez.dart';
import 'package:dartez/models/operation_model.dart';
import 'package:dartez/src/soft-signer/soft_signer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var rpc = "https://rpc.tzkt.io/ghostnet";
  setUpAll(() async => await Dartez().init());

  group("Genrate mnemonic", () {
    test("should generate 12 words", () {
      var mnemonic = Dartez.generateMnemonic(strength: 128);
      expect(mnemonic.split(" ").length, 12);
    });

    test("should generate 24 words", () {
      var mnemonic = Dartez.generateMnemonic(strength: 256);
      expect(mnemonic.split(" ").length, 24);
    });
  });

  test("Derive keys from derivationPath, password and mnemonic", () async {
    var mnemonic =
        'alcohol woman abuse must during monitor noble actual mixed trade anger aisle';

    var mnemonicKeys = Dartez.getKeysFromMnemonic(
      mnemonic: mnemonic,
      passphrase: "hIm*548j^faI",
    );

    expect(mnemonicKeys.secretKey,
        "edskRxjeWuNxTu47qAY4dUpSHaWMCYDppzo13xbv5qvj64QTNMASWPuRgQghEQSPBFSPr9G2GSCmXBzMYpPxSv5KKJoBYytqK3");
    expect(mnemonicKeys.publicKey,
        "edpkvaP2nfa3w1QRMNxac1uZquK1x8eAMi5QCAL47PBibmU1zkCo8R");
    expect(mnemonicKeys.publicKeyHash, "tz1MKE3ExnECuyAah8u9cSPWr522fzzjobGs");

    var path = "m/44'/1729'/0'";

    var keysEd25519 = await Dartez.restoreIdentityFromDerivationPath(
        path, mnemonic,
        signerCurve: SignerCurve.ED25519);

    expect(keysEd25519.secretKey,
        "edskS9KHcddTS3AEfUvBTg9EsTWzwJoGvKnchyZYxNKZY8hWv6mm7FLENMCHNeL8bYJWgj6poWTCn3ugEhCUdZxZsegT3aknyt");
    expect(keysEd25519.publicKey,
        "edpkuxZ5W8c2jmcaGuCFZxRDSWxS7hp98zcwj2YpUZkJWs5F7UMuF6");
    expect(keysEd25519.publicKeyHash, "tz1ckrgqGGGBt4jGDmwFhtXc1LNpZJUnA9F2");

    var keysSecp256k1 = await Dartez.restoreIdentityFromDerivationPath(
        path, mnemonic,
        signerCurve: SignerCurve.SECP256K1);

    expect(keysSecp256k1.secretKey,
        "spsk2mtg7dAiDGMFm6V7auE7uBk6tP8SLQT4EQWQ4kodNfRA4pafkq");
    expect(keysSecp256k1.publicKey,
        "sppk7cFJKErZRibewPzqaPoT7ZQ2brdCVgLxkN75bHYbYoeeMActGPa");
    expect(keysSecp256k1.publicKeyHash, "tz2X522oXW7gpQ53r8UrKapk9jBuT1d7hBwJ");
  });

  test("octez-client keys", () {
    var keys = Dartez.getKeysFromSecretKey(
      "edsk3zWxfW3vFqJNxe3rxtTWuTY5FgqJfYfaWuKobFFPRHs99yVi2f",
    );

    expect(keys.publicKey,
        "edpkvRXYDHZqni4p1uN8T3XCxH9jBDWbbjV3egSkxNgEXun3MTPadG");
    expect(keys.publicKeyHash, "tz1gvf4aHw7SWs62irF98kdmDCpgJQ6n1QT1");
    expect(keys.secretKey,
        "edsk3zWxfW3vFqJNxe3rxtTWuTY5FgqJfYfaWuKobFFPRHs99yVi2f");
  });

  test("signOperationGroup", () async {
    var branch = "BL6BZvC3NUbbiHMJ9r4x3mV8aBsNrrxkTbobdUEgoqmmGypSMWS";

    var privateKey =
        "edskRkMkFH66e2gF3arUAffhxwE6NnczJWm2xTQm98kicXqhbVJt1re4HZELJGRkA4Ki5DkqKy3N8kytn3jh1QWpTazY51dYMR";

    expect(
        Dartez.signOperationGroup(
            privateKey: privateKey,
            forgedOperation: await TezosNodeWriter.forgeOperations(
                rpc, branch, <OperationModel>[
              OperationModel(
                amount: "1",
                destination: "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx",
                source: "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx",
                counter: (await TezosNodeReader.getCounterForAccount(
                        rpc, "tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx")) +
                    1,
                kind: "transaction",
                gasLimit: 10000,
                storageLimit: 257,
                fee: "0",
              )
            ])),
        [
          "edsigu4Y1pGk6GtyUrxUwCJJzFBayZjMig1NtgZhjFWGBWc56UU5mK7K1SAsSzF8zQ3gsTJotDkHc89aq6M2psUnMcpwup3kPjJ",
          "31ba585fe3dd28dcdfd14453cfed9500f477709b679bfd4b079b658c020781566c0002298c03ed7d454a101eb7022bc95f7e5f41ac7800b466904e810201000002298c03ed7d454a101eb7022bc95f7e5f41ac7800eae04c012956e377654c97344253bd8cb99697390790b9f72bceda8c6e2f2d2dac2a0b45b832b62ece7ab5591840d2799a3049a19e8b051dd77e0ab93440ac0d"
        ]);
  });
}
