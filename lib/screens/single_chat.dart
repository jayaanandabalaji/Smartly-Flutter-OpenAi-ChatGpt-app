import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chat});
  final List chat;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String name = "";

  @override
  void initState() {
    super.initState();
    initMessagedFromSharedPrefsValue();
    name = widget.chat[0];
    if (Constants.showAds) {
      _createInterstitialAd();
    }
    setState(() {});
  }

  initMessagedFromSharedPrefsValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(widget.chat[1].toString()) != null) {
      messages = jsonDecode(prefs.getString(widget.chat[1].toString())!);
    }
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
    if (messages.isNotEmpty) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;
  bool adloaded = false;

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Constants.interstitialUnitId,
        request: const AdRequest(
          nonPersonalizedAds: false,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            if (!adloaded) {
              _showInterstitialAd();
              adloaded = true;
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => {},
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  List<dynamic> messages = [];
  bool isSending = false;
  final ScrollController _controller = ScrollController();
  String longPressedMessage = "";

  sendAlert(String message) async {
    Get.snackbar("Successful", message,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM);
  }

  FocusNode fn = FocusNode();
  void editNameDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
                height: Get.height * 0.25,
                width: Get.width * 0.8,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Constants.secondaryColor),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const Text("Rename chat",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: renameController,
                        focusNode: fn,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        await rename();
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: const Text(
                          "Rename",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                )),
          );
        });
  }

  TextEditingController renameController = TextEditingController();

  rename() async {
    if (renameController.text != "") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<dynamic> categories = jsonDecode(prefs.getString("cat")!);
      for (int i = 0; i < categories.length; i++) {
        if (categories[i][1] == widget.chat[1]) {
          categories[i][0] = renameController.text;
        }
      }
      prefs.setString("cat", jsonEncode(categories));
      name = renameController.text;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text(name),
            const SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: () {
                  editNameDialog();
                  fn.requestFocus();
                  renameController.text = name;
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ))
          ],
        ),
        actions: longPressedMessage == ""
            ? null
            : [
                IconButton(
                    onPressed: () {
                      Share.share(longPressedMessage);
                      longPressedMessage = "";
                      setState(() {});
                    },
                    icon: const Icon(Icons.share)),
                IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: longPressedMessage));
                      sendAlert("Message copied successfully!");
                      longPressedMessage = "";
                      setState(() {});
                    },
                    icon: const Icon(Icons.copy)),
                IconButton(
                    onPressed: () {
                      longPressedMessage = "";
                      setState(() {});
                    },
                    icon: const Icon(Icons.close))
              ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Constants.backgroundColor,
      body: (messages.isEmpty)
          ? SizedBox(
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Get.height * 0.35),
                  const Text("No Messages Found",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey))
                ],
              ),
            )
          : ListView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                Column(
                  children: [
                    for (List message in messages)
                      GestureDetector(
                        onTap: () {
                          if (longPressedMessage != "") {
                            if (longPressedMessage == message[1]) {
                              longPressedMessage = "";
                            } else {
                              longPressedMessage = message[1];
                            }
                            setState(() {});
                          }
                        },
                        onLongPress: () {
                          longPressedMessage = message[1];
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: (longPressedMessage != "" &&
                                      longPressedMessage == message[1])
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.transparent),
                          padding: const EdgeInsets.only(
                              bottom: 8, left: 15, right: 15, top: 8),
                          child: (message[0] == 1)
                              ? receivedBotMessage(message[1])
                              : sentMessage(message[1]),
                        ),
                      )
                  ],
                ),
                if (isSending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: gettingMessageAnimation(),
                  ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
      bottomSheet: bottomSendMessage(),
    );
  }

  TextEditingController messageController = TextEditingController();

  Widget bottomSendMessage() {
    return Container(
      color: Constants.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: Get.width * 0.6,
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                controller: messageController,
                decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    hintText: "Ask Me Something",
                    border: InputBorder.none),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                if (!isSending) {
                  sendMessage();
                }
              },
              child: Container(
                height: 45,
                width: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: isSending ? Colors.grey : Constants.primaryColor,
                    shape: BoxShape.circle),
                padding: const EdgeInsets.all(10),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sentMessage(String message) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20))),
          child: Text(
            message,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),
          )),
    );
  }

  Widget gettingMessageAnimation() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Container(
            child: LoadingAnimationWidget.waveDots(
              color: Colors.white,
              size: 30,
            ),
          )),
    );
  }

  Widget receivedBotMessage(String message) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
              color: Constants.secondaryColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Linkify(
            onOpen: (link) async {
              if (!await launchUrl(Uri.parse(link.url))) {
                throw Exception('Could not launch $link.url');
              }
            },
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w400),
            text: message,
          )),
    );
  }

  storeCurrentSharedPreferencesValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.chat[1].toString(), jsonEncode(messages));
  }

  void sendMessage() async {
    if (messageController.text != "") {
      isSending = true;
      String messageText = messageController.text.trim();
      messages.add([2, messageController.text]);
      messageController.text = "";
      if (messages.isNotEmpty) {
        jumpToMaxScroll();
      }
      storeCurrentSharedPreferencesValue();

      setState(() {});
      String response = await getMessageFromChatGPT(messageText);

      messages.add([1, response]);
      isSending = false;
      setState(() {});
      jumpToMaxScroll();
      storeCurrentSharedPreferencesValue();
    }
  }

  jumpToMaxScroll() async {
    await Future.delayed(const Duration(seconds: 1));

    _controller.jumpTo(
      _controller.position.maxScrollExtent,
    );
  }

  Future<String> getMessageFromChatGPT(String message1) async {
    try {
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
      return (jsonDecode(response.body)["choices"][0]["text"] as String)
          .replaceFirst("\n", "")
          .replaceFirst("\n", "");
    } catch (e) {
      return "";
    }
  }
}
