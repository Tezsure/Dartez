import 'dart:typed_data';

import 'package:dartez/dartez.dart';
import 'package:dartez/src/soft-signer/soft_signer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await Dartez().init();
  });

  group("Soft signer test", () {
    var msg = "simple message to sign";

    test("cruve ed25519", () async {
      var signer = Dartez.createSigner(
          "edskRkMkFH66e2gF3arUAffhxwE6NnczJWm2xTQm98kicXqhbVJt1re4HZELJGRkA4Ki5DkqKy3N8kytn3jh1QWpTazY51dYMR");
      expect(signer.signerCurve, SignerCurve.ED25519);
      expect(
          signer.signOperation(Uint8List.fromList(msg.codeUnits)).length, 64);
    });

    test("cruve secp256k1", () {
      var signer = Dartez.createSigner(
          "spsk1W4D4F7CBiUbbaD7nTp1K2FRfVdQkUDNMgHEtsCyWLmyNHMWy4");
      expect(signer.signerCurve, SignerCurve.SECP256K1);
      expect(
          signer.signOperation(Uint8List.fromList(msg.codeUnits)).length, 64);
    });

    test("Invalid secret key", () {
      try {
        Dartez.createSigner("invalid_key");
        fail("Invalid secret key, should throw an exception");
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), "Exception: Invalid secret key");
      }
    });
  });
}
