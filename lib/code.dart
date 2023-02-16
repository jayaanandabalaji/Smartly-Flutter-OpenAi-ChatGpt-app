import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:psychology/constants.dart';
import 'package:share_plus/share_plus.dart';

class codeScreen extends StatefulWidget {
  const codeScreen({super.key});

  @override
  State<codeScreen> createState() => _codeScreenState();
}

class _codeScreenState extends State<codeScreen> {
  TextEditingController language = TextEditingController();
  TextEditingController problem = TextEditingController();

  sendAlert(String message) async {
    Get.snackbar("Successful", message,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text("Code generation")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text("Code Language", style: TextStyle(color: Colors.white)),
          SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: language,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Python"),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text("Problem", style: TextStyle(color: Colors.white)),
          SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.9,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: problem,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Check if given string is palindrome or not"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          generateCodeButton(),
          SizedBox(
            height: 20,
          ),
          if (isLoading)
            Container(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ))),
          if (!isLoading && codeText != "")
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: codeText));
                          sendAlert("Message copied successfully!");
                        },
                        icon: Icon(Icons.copy, color: Colors.white)),
                    IconButton(
                        onPressed: () {
                          Share.share(codeText);
                        },
                        icon: Icon(Icons.share, color: Colors.white))
                  ],
                ),
                HighlightView(
                  codeText,
                  theme: githubTheme,
                  language: language.text,
                  padding: EdgeInsets.all(12),
                  textStyle: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  bool isLoading = false;

  String codeText = "";

  generateCode() async {
    if (language.text != "" &&
        problem.text != "" &&
        language.text != null &&
        language.text != null) {
      isLoading = true;
      setState(() {});
      String response =
          await getMessageFromChatGPT("${problem.text} in ${language.text}");
      log("code ${response}");
      codeText = response;
      isLoading = false;
      setState(() {});
    }
  }

  Widget generateCodeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              color: primaryColor, borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () async {
              generateCode();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Generate Code",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Future<String> getMessageFromChatGPT(String message1) async {
    try {
      log("getting message from chatgpt $message1");
      http.Response response =
          await http.post(Uri.parse("https://api.openai.com/v1/completions"),
              headers: {
                "Authorization":
                    "Bearer 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",
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                "model": "text-davinci-003",
                "prompt": message1,
                "temperature": 0.9,
                "max_tokens": 4000,
                "top_p": 1,
                "frequency_penalty": 0,
                "presence_penalty": 0.6,
                "stop": [" Human:", " AI:"]
              }));
      log("got response");
      return (jsonDecode(response.body)["choices"][0]["text"] as String)
          .replaceFirst("\n", "")
          .replaceFirst("\n", "");
    } catch (e) {
      log("err $e");
      return "";
    }
  }
}
