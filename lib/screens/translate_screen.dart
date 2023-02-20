import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/chat_gpt_api.dart';
import '../utils/constants.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({Key? key}) : super(key: key);
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String fromTranslation = "English";
  String toTranslation = "Tamil";
  String? translationStr = "";
  String translatedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Translate"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Constants.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15),
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Constants.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    showTranslationDialog(Constants.fromTranslations, true);
                  },
                  child: Row(
                    children: [
                      Text(fromTranslation,
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(
                        width: 2,
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white)
                    ],
                  ),
                ),
                const Icon(
                  Icons.swap_horiz,
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () {
                    showTranslationDialog(Constants.toTranslations, false);
                  },
                  child: Row(
                    children: [
                      Text(toTranslation,
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(
                        width: 2,
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white)
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: Get.width,
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: TextField(
              onChanged: (String value) {
                translationStr = value;
              },
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(border: InputBorder.none),
              minLines: 1,
              maxLines: 10,
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            children: [
              Container(
                width: Get.width,
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: SelectableText(translatedText),
              ),
              if (isLoading)
                Container(
                    alignment: Alignment.center,
                    height: 200,
                    width: Get.width,
                    child: const CircularProgressIndicator())
            ],
          ),
          const SizedBox(height: 30),
          translateButton()
        ],
      ),
    );
  }

  void showTranslationDialog(
      List<String> languagesList, bool isFromTranslation) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              height: Get.height * 0.35,
              width: Get.width,
              child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Text("Change language",
                        style: TextStyle(
                            fontSize: 18,
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    for (String language in languagesList)
                      buildTranslation(language, isFromTranslation)
                  ]),
            ),
          );
        });
  }

  Widget buildTranslation(String language, bool isFromTranslation) {
    return GestureDetector(
      onTap: () {
        Get.back();
        if (isFromTranslation) {
          fromTranslation = language;
        } else {
          toTranslation = language;
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(language,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 17)),
      ),
    );
  }

  bool isLoading = false;
  void translateText() async {
    if (translationStr != "") {
      isLoading = true;
      setState(() {});
      String message = await ChatGptApi().getMessageFromChatGPT(
          "Translate from $fromTranslation to $toTranslation\n\n$translationStr");
      String decodedString = utf8.decode(message.runes.toList());
      translatedText = decodedString;
      isLoading = false;
      setState(() {});
    }
  }

  Widget translateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () async {
              translateText();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "Translate",
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
