library ha_vin_scanner;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ha_vin_scanner/src/vin_detector_view.dart';
import 'package:image_size_getter/image_size_getter.dart' as iz;
import 'package:mask_for_camera_view/mask_for_camera_view.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_camera_description.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_result.dart';

// export 'package:ha_vin_scanner/src/vin_detector_view.dart';

class HAVINScanner {
  final bool autoScan;
  final Function(String) didScan;
  const HAVINScanner({required this.didScan, this.autoScan = false});
  show(BuildContext context) {
    if (autoScan) {
      HAVINScannerView(vinDetected: ((p0) {
        // Navigator.pop(context);
        didScan(p0);
      })).show(context);
    } else {
      MaskForCameraView.initialize().then((value) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => MaskForCameraView(
                  cameraDescription: MaskForCameraViewCameraDescription.rear,
                  title: "VIN Scan",
                  visiblePopButton: true,
                  onTake: (MaskForCameraViewResult res) async {
                    final TextRecognizer _textRecognizer = TextRecognizer();

                    String? filePath = await _saveImage(
                        res.croppedImage!,
                        Directory.systemTemp,
                        'temp_${DateTime.now().microsecondsSinceEpoch}.png');

                    InputImage inputImage =
                        InputImage.fromFile(File.fromUri(Uri.file(filePath!)));

                    RecognizedText recognizedText =
                        await _textRecognizer.processImage(inputImage);

                    RegExp regExp = RegExp("^[A-Z0-9]{17}\$");
                    List<TextBlock> textBlocks = recognizedText.blocks
                        .where((b) => regExp.hasMatch(b.text
                            .replaceAll(" ", "")
                            .replaceAll("-", "")
                            .replaceAll("_", "")
                            .replaceAll("*", "")))
                        .toList();
                    String vinNo =
                        textBlocks.isNotEmpty ? textBlocks.first.text : "";
                    print("Recognised Text: ${recognizedText.text}");
                    didScan(textBlocks
                        .map((e) => vinNo
                            .replaceAll(" ", "")
                            .replaceAll("-", "")
                            .replaceAll("_", "")
                            .replaceAll("*", ""))
                        .join(";"));
                    Navigator.pop(context);
                    _textRecognizer.close();
                    // Image imageCropped =
                    //     Image.file(File.fromUri(Uri.file(filePath)));
                    // Navigator.of(context).push(
                    //   MaterialPageRoute<void>(
                    //     builder: (BuildContext context) {
                    //       return Scaffold(
                    //         appBar: AppBar(
                    //           title:
                    //               Text(textBlocks.map((e) => e.text).join(";")),
                    //         ),
                    //         body: Center(
                    //           child: Column(
                    //             children: [
                    //               Text(recognizedText.text),
                    //               SizedBox(
                    //                 height: 8,
                    //               ),
                    //               imageCropped,
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // );
                  })))));
    }
  }

  Future<String?> _saveImage(
      Uint8List uint8List, Directory dir, String fileName,
      {Function? success, Function? fail}) async {
    bool isDirExist = await Directory(dir.path).exists();
    if (!isDirExist) Directory(dir.path).create();
    String tempPath = '${dir.path}$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    await File(tempPath).writeAsBytes(uint8List).then((_) {
      if (success != null) success();
    });
    return tempPath;
  }
}
