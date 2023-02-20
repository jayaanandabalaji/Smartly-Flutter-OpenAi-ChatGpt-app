import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'single_chat.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    initCategoriesList();
  }

  initCategoriesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("cat") != null) {
      categoriesList = jsonDecode(prefs.getString("cat")!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text("Smartly Chat GPT")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              children: [
                for (List category in categoriesList)
                  singleChat(category,
                      isLast: category.indexOf(categoriesList) % 3 == 0
                          ? true
                          : false),
              ]),
          const SizedBox(
            height: 50,
          ),
          addChatButton()
        ],
      ),
    );
  }

  Future<List> addNewChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    categoriesList.insert(0, ["untitled", categoriesList.length]);
    prefs.setString("cat", jsonEncode(categoriesList));
    setState(() {});
    return ["untitled", categoriesList.length - 1];
  }

  List<dynamic> categoriesList = [];

  updatedSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("cat") != null) {
      categoriesList = jsonDecode(prefs.getString("cat")!);
    }
    setState(() {});
  }

  Widget addChatButton() {
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
              List list = await addNewChat();
              await Get.to(ChatPage(
                chat: list,
              ));
              log("updating");
              updatedSharedPreferences();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "New Chat",
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

  Widget singleChat(List category, {bool isLast = false}) {
    return InkWell(
      onTap: () async {
        await Get.to(ChatPage(chat: category));
        updatedSharedPreferences();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: EdgeInsets.only(right: isLast ? 0 : 10, bottom: 10),
        decoration: BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              color: Colors.white,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(category[0],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13))
          ],
        ),
      ),
    );
  }
}
