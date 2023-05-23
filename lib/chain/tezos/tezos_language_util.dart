import 'package:dartez/michelson_parser/parser.dart';

class TezosLanguageUtil {
  static var primitiveRecordOrder = ["prim", "args", "annots"];

  static String? translateMichelsonScriptToMicheline(String code) {
    var result = Parser.parseMichelsonScript(code);
    return result;
  }

  static String? translateMichelsonExpressionToMicheline(String code) {
    var result = Parser.parseMichelsonExpression(code);
    return result;
  }

  static dynamic normalizePrimitiveRecordOrder(data) {
    if (data is List) return data.map(normalizePrimitiveRecordOrder).toList();

    if (data is Map) {
      dynamic keys = data.keys.toList();
      keys.sort((k1, k2) =>
          TezosLanguageUtil.primitiveRecordOrder.indexOf(k1) -
          TezosLanguageUtil.primitiveRecordOrder.indexOf(k2));

      data = keys.fold({}, (obj, value) {
        return {
          ...obj,
          value: normalizePrimitiveRecordOrder(
              data[value] is int ? data[value].toString() : data[value])
        };
      });
    }
    return data;
  }
}
