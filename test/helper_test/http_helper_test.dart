import 'dart:io';

import 'package:dartez/helper/http_helper.dart' as http_helper;
import 'package:test/test.dart';

void main() {
  var rpc = "https://rpc.tzkt.io/ghostnet";

  group("performGetRequest", () {
    test("200 check", () async {
      var response = await http_helper.HttpHelper.performGetRequest(
          rpc, "chains/main/blocks/head");
      expect(response, isNotNull);
    });

    test("404 check", () async {
      try {
        await http_helper.HttpHelper.performGetRequest(
            rpc, "chains/main/blocks/head/invalid");
      } catch (e) {
        expect(e, isA<HttpException>());
      }
    });
  });

  group("performPostRequest", () {
    test("404 check", () async {
      try {
        await http_helper.HttpHelper.performPostRequest(
            rpc, "chains/main/blocks/head/invalid", []);
      } catch (e) {
        expect(e, isA<HttpException>());
      }
    });
  });
}
