import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'constants.dart';

class imageGeneration extends StatefulWidget {
  const imageGeneration({super.key});

  @override
  State<imageGeneration> createState() => _imageGenerationState();
}

class _imageGenerationState extends State<imageGeneration> {
  TextEditingController imageDet = TextEditingController();
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
          title: Text("Image generation")),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Text("Image Details", style: TextStyle(color: Colors.white)),
          SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: imageDet,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "a white siamese cat	"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          generateImageButton(),
          if (isLoading)
            Container(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ))),
          if (!isLoading && imageUrl != "")
            Container(
                margin: EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      IconButton(
                        onPressed: () async {
                          try {
                            var response = await Dio().get(imageUrl,
                                options:
                                    Options(responseType: ResponseType.bytes));
                            sendAlert(
                                "Image downloaded to gallery successfully!");
                            final result = await ImageGallerySaver.saveImage(
                                Uint8List.fromList(response.data),
                                quality: 100,
                                name: imageDet.text);
                          } catch (e) {
                            log("error occured " + e.toString());
                          }
                        },
                        icon: Icon(Icons.download, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async {
                          try {
                            final url = Uri.parse(imageUrl);
                            final response = await http.get(url);
                            Directory tempDir = await getTemporaryDirectory();
                            String imagePath = tempDir.path + "/" + "tmp.png";
                            await File(imagePath)
                                .writeAsBytes(response.bodyBytes);

                            await Share.shareFiles([imagePath],
                                text: 'Image Shared from chatGPT app');
                          } catch (e) {
                            log("error occ " + e.toString());
                          }
                        },
                        icon: Icon(Icons.share, color: Colors.white),
                      )
                    ]),
                    ExtendedImage.network(imageUrl)
                  ],
                ))
        ],
      ),
    );
  }

  bool isLoading = false;

  generateImage() async {
    if (imageDet.text != null && imageDet.text != "") {
      isLoading = true;
      setState(() {});
      String response = await getImageFromChatGpt("${imageDet.text}");
      log('got response ' + response.toString());
      isLoading = false;
      imageUrl = response;
      setState(() {});
    }
  }

  String imageUrl = "";

  Widget generateImageButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              color: primaryColor, borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () async {
              generateImage();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Generate Image",
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

  Future<String> getImageFromChatGpt(String message1) async {
    try {
      http.Response response = await http.post(
          Uri.parse("https://api.openai.com/v1/images/generations"),
          headers: {
            "Authorization":
                "Bearer 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",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"prompt": message1, "n": 1}));
      return (jsonDecode(response.body)["data"][0]["url"] as String);
    } catch (e) {
      log("err $e");
      return "";
    }
  }
}
