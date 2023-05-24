import 'package:dartez/helper/operation_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var rpc = "https://rpc.tzkt.io/ghostnet";

  group("get operation status", () {
    test("Not found check", () async {
      var opHash = "opJkCPQp8YJ6pPephdEz9GsZfDe9uzA8qyukFXo8WhKvG58DdJZ";
      try {
        await OperationHelper().getOperationStatus(rpc, opHash);
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), "Exception: Operation status not found");
      }
    });

    test("error throw check", () async {
      var _server = "https://rpc.tzkt.io/error";
      var opHash = "opJkCPQp8YJ6pPephdEz9GsZfDe9uzA8qyukFXo8WhKvG58DdJZ";
      try {
        await OperationHelper().getOperationStatus(_server, opHash);
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(),
            "Exception: An error occurred while getting operation status: type '_Map<String, dynamic>' is not a subtype of type 'FutureOr<List<dynamic>?>'");
      }
    });

    test("Basic check", () async {
      var opHash = "opJkCPQp8YJ6pPephdEz9GsZfDe9uzA8qyukFXo8WhKvG58DdJZ";
      var blockHash = "BKmpF51rq4YYwEvsV8VNH4w9jzQbBVxfRL5QfqmBBTdbacM3qjk";
      var status = await OperationHelper()
          .getOperationStatus(rpc, opHash, blockHash: blockHash);
      expect(status, isNotNull);
      expect(status, "applied");
    });
  });
}
