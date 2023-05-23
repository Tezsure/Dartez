import 'dart:async';

import 'package:dartez/helper/http_helper.dart';

class OperationHelper {
  /// Get operation status
  Future<String?> getOperationStatus(String server, String operationHash,
      {int numberOfRetries = 5,
      String blockHash = "head",
      int waitSec = 2}) async {
    for (var i = 0; i < numberOfRetries; i++) {
      try {
        var status = await _getStatus(server, operationHash, blockHash);
        if (status != "Pending") {
          return status;
        }
      } catch (e) {
        throw Exception("An error occurred while getting operation status: $e");
      }

      await Future.delayed(Duration(seconds: waitSec));
    }

    throw Exception("Operation status not found");
  }

  /// Get operation status
  Future<String?> _getStatus(
      String server, String opHash, String blockHash) async {
    var operations = await (getOperations(server, blockHash));
    var operation =
        operations!.where((element) => element['hash'] == opHash).toList();
    if (operation.isEmpty) {
      return "Pending";
    } else {
      var status =
          operation[0]['contents'][0]['metadata']['operation_result']['status'];
      return status;
    }
  }

  /// Get operations from block
  Future<List<dynamic>?> getOperations(String server, String block) async {
    var response = await HttpHelper.performGetRequest(
        server, "chains/main/blocks/$block/operations/3");
    return response;
  }

  /// Get block
  Future<String> getBlock(String server) async {
    var response =
        await HttpHelper.performGetRequest(server, "chains/main/blocks");
    return response[0][0].toString();
  }
}
