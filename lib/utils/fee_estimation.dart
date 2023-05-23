import 'dart:convert';

import 'package:dartez/chain/tezos/tezos_node_writer.dart';
import 'package:dartez/dartez.dart';
import 'package:dartez/helper/constants.dart';
import 'package:dartez/helper/http_helper.dart';
import 'package:dartez/models/operation_model.dart';

class FeeEstimation {
  String server;
  String chainId;
  List<OperationModel> operations;
  // ignore: non_constant_identifier_names
  int GAS_BUFFER = 100;

  FeeEstimation(this.server, this.operations, {this.chainId = 'main'});

  Future<Map<String, dynamic>> estimateFees() async {
    var opResults = await dryRunOperation(
        server,
        chainId,
        this.operations.map((e) {
          e.gasLimit = TezosConstants.OperationGasCap ~/ operations.length;
          e.storageLimit =
              TezosConstants.OperationStorageCap ~/ operations.length;
          return e;
        }).toList());

    var estimatedResources =
        await estimateOperation(server, chainId, opResults);

    return estimatedResources;
  }

  estimateOperation(String server, String chainId, opResults) async {
    var gas = 0;
    var storageCost = 0;
    var staticFee = 0;
    for (var ele in opResults['contents']) {
      try {
        gas += (int.parse(ele['metadata']['operation_result']
                        ['consumed_milligas']
                    .toString()) ~/
                1000) +
            GAS_BUFFER;
        storageCost += int.parse((ele['metadata']['operation_result']
                    ['paid_storage_size_diff'] ??
                '0')
            .toString());

        if (ele['kind'] == 'origination' ||
            ele['metadata']['operation_result']
                    ['allocated_destination_contract'] !=
                null) {
          storageCost += TezosConstants.EmptyAccountStorageBurn;
        } else if (ele['kind'] == 'reveal') {
          staticFee += 1270;
        }
      } catch (e) {
        throw "Error while estimating operation: $e";
      }

      var internalOperations = ele['metadata']['internal_operation_results'];
      if (internalOperations == null) {
        continue;
      }

      for (var internalOperation in internalOperations) {
        var result = internalOperation['result'];
        gas += (int.parse(result['consumed_milligas'] ?? '0') ~/ 1000) +
            GAS_BUFFER;
        storageCost += int.parse(result['paid_storage_size_diff'] ?? '0');
        if (internalOperation['kind'] == 'origination') {
          storageCost += TezosConstants.EmptyAccountStorageBurn;
        }
      }
    }

    var validBranch = 'BMLxA4tQjiu1PT2x3dMiijgvMTQo8AVxkPBPpdtM8hCfiyiC1jz';
    var forgedOperationGroup =
        await TezosNodeWriter.forgeOperations(server, validBranch, operations);
    var operationSize = forgedOperationGroup.length / 2 + 64;
    var estimatedFee = staticFee +
        (gas / 10).ceil() +
        TezosConstants.BaseOperationFee +
        operationSize +
        TezosConstants.DefaultBakerVig;
    var estimatedStorageBurn =
        (storageCost * TezosConstants.StorageRate).ceil();

    return {
      'gas': gas,
      'storageCost': storageCost,
      'estimatedFee': estimatedFee.toInt(),
      'estimatedStorageBurn': estimatedStorageBurn
    };
  }

  dryRunOperation(String server, String chainId,
      List<OperationModel> localOperations) async {
    const fake_signature =
        'edsigtkpiSSschcaCt9pUVrpNPf7TTcgvgDEDD6NCEHMy8NNQJCGnMfLZzYoQj74yLjo9wx6MPVV29CvVzgi7qEcEUok3k7AuMg';
    var fakeBranch = await Dartez.getBlock(server);
    var payload = {
      'operation': {
        'branch': fakeBranch,
        'contents': localOperations,
        'signature': fake_signature
      }
    };
    var response = await HttpHelper.performPostRequest(
        server, 'chains/$chainId/blocks/head/helpers/scripts/run_operation', {
      'chain_id': 'NetXdQprcVkpaWU',
      ...payload,
    });

    return jsonDecode(response.toString());
  }
}
