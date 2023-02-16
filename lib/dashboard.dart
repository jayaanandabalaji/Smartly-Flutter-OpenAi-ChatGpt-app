import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:psychology/singleChat.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text("Smartly Chat GPT")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                for (List category in categoriesList)
                  singleChat(category,
                      isLast: category.indexOf(categoriesList) % 3 == 0
                          ? true
                          : false),
              ],
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3)),
          SizedBox(
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
    log(jsonEncode(categoriesList));
    setState(() {});
    return ["untitled", categoriesList.length - 1];
  }

  List<dynamic> categoriesList = [];

  updatedSharedPreferences() async {
    log("updating shared prefs value");
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
              color: primaryColor, borderRadius: BorderRadius.circular(10)),
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
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await Get.to(ChatPage(chat: category));
        updatedSharedPreferences();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: EdgeInsets.only(right: isLast ? 0 : 10, bottom: 10),
        decoration: BoxDecoration(
            color: secondaryColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            Text(category[0],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13))
          ],
        ),
      ),
    );
  }
}
