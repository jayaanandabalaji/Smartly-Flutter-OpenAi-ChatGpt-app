import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/open_ai_api.dart';
import '../utils/constants.dart';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({super.key});

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration> {
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
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text("Image generation")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          const Text("Image Details", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: Get.width * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: TextField(
                  controller: imageDet,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "a white siamese cat	"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          generateImageButton(),
          if (isLoading)
            const SizedBox(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ))),
          if (!isLoading && imageUrl != "")
            Container(
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      IconButton(
                        onPressed: () async {
                          var response = await Dio().get(imageUrl,
                              options:
                                  Options(responseType: ResponseType.bytes));
                          sendAlert(
                              "Image downloaded to gallery successfully!");
                          await ImageGallerySaver.saveImage(
                              Uint8List.fromList(response.data),
                              quality: 100,
                              name: imageDet.text);
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async {
                          final url = Uri.parse(imageUrl);
                          final response = await http.get(url);
                          Directory tempDir = await getTemporaryDirectory();
                          String imagePath = "${tempDir.path}/tmp.png";
                          await File(imagePath)
                              .writeAsBytes(response.bodyBytes);

                          await Share.shareXFiles([XFile(imagePath)],
                              text: 'Image Shared from chatGPT app');
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
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
    if (imageDet.text != "") {
      isLoading = true;
      setState(() {});
      isLoading = false;
      String response = await ChatGptApi().getImageFromChatGpt(imageDet.text);

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
              color: Constants.primaryColor,
              borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () async {
              generateImage();
            },
            child: Container(
                width: Get.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
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
}
