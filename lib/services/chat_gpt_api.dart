import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:psychology/utils/constants.dart';

class ChatGptApi {
  Future<String> getMessageFromChatGPT(String message) async {
    try {
      http.Response response =
          await http.post(Uri.parse("https://api.openai.com/v1/completions"),
              headers: {
                "Authorization": "Bearer ${Constants.openAIApiKey}",
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                "model": "text-davinci-003",
                "prompt": message,
                "temperature": 0.9,
                "max_tokens": 4000,
                "top_p": 1,
                "frequency_penalty": 0,
                "presence_penalty": 0.6,
                "stop": [" Human:", " AI:"]
              }));
      return (jsonDecode(response.body)["choices"][0]["text"] as String)
          .replaceFirst("\n", "")
          .replaceFirst("\n", "");
    } catch (e) {
      return "";
    }
  }

  Future<String> getImageFromChatGpt(String message) async {
    try {
      http.Response response = await http.post(
          Uri.parse("https://api.openai.com/v1/images/generations"),
          headers: {
            "Authorization": "Bearer ${Constants.openAIApiKey}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"prompt": message, "n": 1}));
      return (jsonDecode(response.body)["data"][0]["url"] as String);
    } catch (e) {
      return "";
    }
  }
}
