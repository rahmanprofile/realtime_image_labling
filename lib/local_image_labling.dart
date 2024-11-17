import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'controller.dart';

class LocalImageLableing extends StatefulWidget {
  const LocalImageLableing({super.key});

  @override
  State<LocalImageLableing> createState() => _LocalImageLableingState();
}

class _LocalImageLableingState extends State<LocalImageLableing> {
  late ImageLabeler imageLabeler;
  final MachineController _machineController = MachineController.instance;
  File? imageUrl;
  String result = '';

  @override
  void initState() {
    ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
    super.initState();
  }

  Future<void> parseImage() async {
    if (imageUrl != null) {
      final InputImage inputImage = InputImage.fromFile(imageUrl!);
      final List<ImageLabel> lable = await imageLabeler.processImage(inputImage);
      for (ImageLabel data in lable) {
        final text = data.label;
        final index = data.index;
        final confidence = data.confidence;
        result += "$text -- ${confidence.toStringAsFixed(2)}\n";
        log("$text -- $confidence\n");
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Machine Learning",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.file(imageUrl!, height: MediaQuery.of(context).size.width / 1.5),
            const SizedBox(width: 10),
            if (result != null)
              Expanded(child: Text(result, style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          result = "";
          imageUrl = null;
          final img = await _machineController.pickImage(ImageSource.gallery);
          if (img != null) {
            setState(() {
              imageUrl = img;
              parseImage();
            });
          }
        },
        child: const Icon(CupertinoIcons.photo),
      ),
    );
  }
}
