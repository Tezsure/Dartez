import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartez/chain/tezos/tezos_message_utils.dart';

void main() {
  group("Tezos message utils", () {
    test("Read address function test", () {
      var result = TezosMessageUtils.readAddressWithHint(
          Uint8List.fromList(
              hex.decode("42b419240509ddacd12839700b7f720b4aa55e4e")),
          "kt1");
      expect(result, "KT1EfTusMLoeCAAGd9MZJn5yKzFr6kJU5U91");

      result = TezosMessageUtils.readAddressWithHint(
          Uint8List.fromList(
              hex.decode("83846eddd5d3c5ed96e962506253958649c84a74")),
          "tz1");
      expect(result, "tz1XdRrrqrMfsFKA8iuw53xHzug9ipr6MuHq");

      // 2fcb1d9307f0b1f94c048ff586c09f46614c7e90 tz2
      result = TezosMessageUtils.readAddressWithHint(
          Uint8List.fromList(
              hex.decode("2fcb1d9307f0b1f94c048ff586c09f46614c7e90")),
          "tz2");
      expect(result, "tz2Cfwk4ortcaqAGcVJKSxLiAdcFxXBLBoyY");

      result = TezosMessageUtils.readAddressWithHint(
          Uint8List.fromList(
              hex.decode("193b2b3f6b8f8e1e6b39b4d442fc2b432f6427a8")),
          "tz3");
      expect(result, "tz3NdTPb3Ax2rVW2Kq9QEdzfYFkRwhrQRPhX");
    });
  });
}
