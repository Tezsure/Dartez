import 'package:dartez/michelson_parser/parser/michelson_grammar.dart';
import 'package:dartez/michelson_parser/parser/nearley.dart';

class Parser {
  static String? parseMichelsonExpression(String code) {
    var parser = Nearley();
    parser.parser(Nearley.fromCompiled(MichelsonGrammar().grammar));
    code = code
        .replaceAll(RegExp(r'#.*$', multiLine: true), '')
        .replaceAll('\n', ' ')
        .trim();
    parser.feedExpressionOrScript(code);
    return parser.results[0];
  }

  static String? parseMichelsonScript(String code) {
    code = code
        .replaceAll(RegExp(r'#.*$', multiLine: true), '')
        .replaceAll('\n', ' ')
        .trim();
    var parser = Nearley();
    parser.parser(Nearley.fromCompiled(MichelsonGrammar().grammar));
    parser.feedExpressionOrScript(code, isScript: true);
    return parser.results[0];
  }

  static String normalizeMichelineWhiteSpace(String fragment) {
    return fragment
        .replaceAll(new RegExp(r'\n'), ' ')
        .replaceAll(new RegExp(r' +'), ' ')
        .replaceAll(new RegExp(r'\[{'), '[ {')
        .replaceAll(new RegExp(r'}\]'), '} ]')
        .replaceAll(new RegExp(r'},{'), '}, {')
        .replaceAll(new RegExp(r'\]}'), '] }')
        .replaceAll(new RegExp(r'":"'), '": "')
        .replaceAll(new RegExp(r'":\['), '": [')
        .replaceAll(new RegExp(r'{"'), '{ "')
        .replaceAll(new RegExp(r'"}'), '" }')
        .replaceAll(new RegExp(r',"'), ', "')
        .replaceAll(new RegExp(r'","'), '", "')
        .replaceAll(new RegExp(r'\[\[\['), '[ [ [')
        .replaceAll(new RegExp(r'\[\['), '[ [')
        .replaceAll(new RegExp(r'\]\]\]'), '] ] ]')
        .replaceAll(new RegExp(r'\]\]'), '] ]')
        .replaceAll(new RegExp(r'\["'), '[ "')
        .replaceAll(new RegExp(r'"\]'), '" ]')
        .replaceAll(new RegExp(r'\[ +\]'), '\[\]')
        .trim();
  }
}
