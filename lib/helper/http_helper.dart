import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpHelper {
  static Future<dynamic> performPostRequest(server, command, payload,
      {Map<String, String> headers = const {}}) async {
    _warnIfHttp(server);
    var response = await http.post(
      command.isEmpty ? Uri.parse(server) : Uri.parse('$server/$command'),
      headers: {
        'content-type': 'application/json',
        ...headers,
      },
      encoding: Encoding.getByName('utf8'),
      body: utf8.encode(json.encode(payload)),
    );

    // check for the status code 200 or throw an exception
    if (response.statusCode != 200) {
      throw HttpException(
        "Error: ${response.statusCode} ${response.reasonPhrase} ${response.body}",
        uri:
            command.isEmpty ? Uri.parse(server) : Uri.parse('$server/$command'),
      );
    }

    return response.body.isNotEmpty ? response.body : null;
  }

  static Future<dynamic> performGetRequest(server, command) async {
    _warnIfHttp(server);
    final response = await http.get(Uri.parse('$server/$command'));

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    }

    throw HttpException(
      "Error: ${response.statusCode} ${response.reasonPhrase} ${response.body}",
      uri: command.isEmpty ? Uri.parse(server) : Uri.parse('$server/$command'),
    );
  }

  static _warnIfHttp(String server) {
    if (server.startsWith('http://')) {
      print(
          'WARNING: You are using an insecure connection. Please consider using HTTPS.');
    }
  }
}
