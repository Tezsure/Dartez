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
        "edskSBLCBjt14rsgFndZkgEKdd6NfjwxTthGQ9LG57dJTKLgesFQCFJnZArgXzeCWq7ym27tbeRjd2bZrYD5j8xT5tvUwFe7pz");
    expect(mnemonicKeys.publicKey,
        "edpku8Qzrj5yrZG8DRnErchmu3bBG7WEUtoxSVeJBkg1FCLokdKQn5");
    expect(mnemonicKeys.publicKeyHash, "tz1KrY4LhzqRQdngkhER6d3zvcjgsiXuAwCf");

    var path = "m/44'/1729'/0'";

    var keysEd25519 = await Dartez.restoreIdentityFromDerivationPath(
        path, mnemonic,
        signerCurve: SignerCurve.ED25519);

    expect(keysEd25519.secretKey,
        "edskRdmPw766Dbj3oFYRuCcCn1Pbeuu9LaPRCUkNpE3TTFV25Ej2yHzvYqtAAFKcTmjT2fqEwJdbBzuCv24DH7qcXWHxVXXoQY");
    expect(keysEd25519.publicKey,
        "edpkuUxN5P4LfByoDJnzXRK3pGJaR5YsRMRJEnn2hPq4aCLZAUwLJn");
    expect(keysEd25519.publicKeyHash, "tz1PjZrPEmWfTJpv3jZt2FsQpQa3t6XU2LrP");

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
          "edsigtYKJjx9q7dU9GQKPdePhiWcQzp4SnxZtESFdi9GKeackEAjhCueuox4KPVBBuHtmhHZC32g81QYzEHmCEnbotK9pqehgym",
          "31ba585fe3dd28dcdfd14453cfed9500f477709b679bfd4b079b658c020781566c0002298c03ed7d454a101eb7022bc95f7e5f41ac7800b266904e810201000002298c03ed7d454a101eb7022bc95f7e5f41ac780003e4bd5095f84541f478d88f777b15da89d7c27ed89622fa64da040ef5ae57b0a69b2d8ea5051b289f5893736077f3f3307f763c47577df0ba5b2e42b76c4800"
        ]);
  });
}
