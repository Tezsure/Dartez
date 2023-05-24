import 'package:dartez/chain/tezos/tezos_node_reader.dart';
import 'package:dartez/models/operation_model.dart';
import 'package:dartez/utils/fee_estimation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var rpc = "https://rpc.tzkt.io/ghostnet";

  group("Fee estimations tests", () {
    test("xtz tx", () async {
      FeeEstimation feeEstimation = FeeEstimation(rpc, [
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
      ]);

      var result = await feeEstimation.estimateFees();

      expect(result['gas'] > 0, true);
      expect(result['storageCost'] == 0, true);
      expect(result['estimatedFee'] > 0, true);
    });
  });
}
