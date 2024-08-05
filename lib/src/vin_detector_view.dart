import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ha_vin_scanner/src/text_detector_painter.dart';

import 'camera_view.dart';

class HAVINScannerView extends StatefulWidget {
  final Function(String) vinDetected;
  const HAVINScannerView({required this.vinDetected});

  show(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: ((context) => this)));
  }

  @override
  _HAVINScannerViewState createState() => _HAVINScannerViewState();
}

class _HAVINScannerViewState extends State<HAVINScannerView> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'VIN Scanner',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    // setState(() {
    //   _text = '';
    // });

    final recognizedText = await _textRecognizer.processImage(inputImage);

    // List<TextBlock> textBlocks = recognizedText.blocks
    //     .takeWhile((element) => element.boundingBox.overlaps(Rect.fromLTWH(
    //         10,
    //         MediaQuery.of(context).size.width / 2 - 120,
    //         MediaQuery.of(context).size.height - 20,
    //         260)))
    //     .toList();

    // print(
    //     "has overlaped:${textBlocks.isNotEmpty} with box:${textBlocks.map((e) => e.boundingBox.toString()).join("\n")}");
    print(recognizedText.text);
    RegExp regExp = RegExp("^(?=.*[0-9])(?=.*[A-z])[0-9A-z-]{17}\$");
    List<TextBlock> textBlocks = recognizedText.blocks
        .takeWhile((block) => block.text.contains(regExp))
        .toList();

      
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        textBlocks.isNotEmpty) {
      final painter = TextRecognizerPainter(
          RecognizedText(text: "", blocks: textBlocks),
          inputImage.metadata!.size,
          inputImage.metadata!.rotation);
      _customPaint = CustomPaint(painter: painter);
      widget.vinDetected(textBlocks.map((e) => e.text).join(";"));
      Navigator.pop(context);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    // if (mounted) {
    //   setState(() {});
    // }
  }
}
