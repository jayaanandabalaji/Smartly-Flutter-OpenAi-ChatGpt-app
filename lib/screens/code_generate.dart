import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/open_ai_api.dart';
import '../utils/constants.dart';
import 'package:share_plus/share_plus.dart';

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key});
  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
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
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text("Code generation")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          const Text("Code Language", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: language,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Python"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text("Problem", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.9,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: problem,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Check if given string is palindrome or not"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          generateCodeButton(),
          const SizedBox(
            height: 20,
          ),
          if (isLoading)
            const SizedBox(
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
                        icon: const Icon(Icons.copy, color: Colors.white)),
                    IconButton(
                        onPressed: () {
                          Share.share(codeText);
                        },
                        icon: const Icon(Icons.share, color: Colors.white))
                  ],
                ),
                HighlightView(
                  codeText,
                  theme: githubTheme,
                  language: language.text,
                  padding: const EdgeInsets.all(12),
                  textStyle: const TextStyle(
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
    if (language.text != "" && problem.text != "") {
      isLoading = true;
      setState(() {});
      String response = await ChatGptApi()
          .getMessageFromChatGPT("${problem.text} in ${language.text}");
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
              color: Constants.primaryColor,
              borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () async {
              generateCode();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
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
}
