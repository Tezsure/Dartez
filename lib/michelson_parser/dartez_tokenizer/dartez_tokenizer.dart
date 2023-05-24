import 'dart:math';

class DartezTokenizer {
  Map<String, dynamic> delimiters;
  List<Map<String, dynamic>> tokens = [];

  // Map key is the token type and value is the matcher
  late RegExp regexGrouping;
  // global position of the whole buffer
  int columnNumber = 0;
  // the current position of the buffer regex while matching
  int currentPos = 0;
  // the buffer to tokenize
  late var buffer;

  DartezTokenizer(this.delimiters) {
    regexGrouping = RegExp(delimiters
        .map<String, String>((key, value) =>
            MapEntry(key, convertValueToRegExpGroupString(value)))
        .values
        .join('|'));
  }

  // convert the matcher to group based on the runTimeType
  convertValueToRegExpGroupString(dynamic value) {
    if (value is String) {
      return "((?:${reEscape(value)}))";
    } else if (value is RegExp) {
      return "((?:${value.pattern}))";
    } else if (value is List) {
      value.sort((a, b) => b.length.compareTo(a.length));
      return "((?:${value.map<String>((e) => "(?:$e)").toList().join('|')}))";
    } else {
      throw Exception("Invalid delimiters value type");
    }
  }

  String reEscape(String s) {
    return s.replaceAll(RegExp(r"[-\/\\^$*+?.()|\[\]{}]"), '\\$s');
  }

  feed(String text) {
    tokens = [];
    currentPos = 0;
    this.buffer = text;
    tokenize();
    return tokens;
  }

  tokenize() {
    var match = regexGrouping.firstMatch(buffer.substring(currentPos));

    while (match != null) {
      if (match.groupCount == 0) {
        throw Exception(
            "Invalid token type found at ${buffer.substring(currentPos)}");
      }
      for (int i = 1; i <= match.groupCount; i++) {
        var group = match.group(i);
        if (group != null) {
          var tokenType = delimiters.keys.toList()[i - 1];

          if (tokenType == 'string') {
            // range of characters inside the string supposed to be in range of 32 to 126
            // https://tezos.gitlab.io/whitedoc/michelson.html#string
            if (group.codeUnits.any((e) => e < 32 || e > 126)) {
              throw Exception(
                  "Invalid string found at ${buffer.substring(currentPos)}");
            }
          }

          tokens.add({
            "type": tokenType,
            "value": group,
            "text": group,
            "col": columnNumber,
            "offset": currentPos,
            "line": '1',
          });
          break;
        }
      }
      currentPos += match.end;
      columnNumber += match.end;
      if (currentPos >= buffer.length) {
        break;
      }
      match = regexGrouping.firstMatch(buffer.substring(currentPos));
      if (match == null) {
        throw Exception(
            "Invalid token type found at ${buffer.substring(currentPos)}");
      }
    }

    if (tokens.map((e) => e['value']).join('') != buffer) {
      throw Exception("Invalid code");
    }
  }

  has(tokenType) {
    return true;
  }

  formatError(token, message) {
    var value = token['text'];
    int index = token['offset'];
    var start = max(0, index - token['offset']);
    var firstLine = this.buffer.substring(start, index + value.length);
    message += " at line " +
        token['line'] +
        " offset " +
        token['offset'].toString() +
        ":\n\n";
    message += "  " + firstLine + "\n";
    message +=
        "  " + List.generate(token['offset'] + 1, (e) => '').join(" ") + "^";
    return message;
  }
}
