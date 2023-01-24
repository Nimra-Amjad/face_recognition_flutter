import 'package:face_detector_eye_blink/painters/face_detector_painter.dart';
import 'package:face_detector_eye_blink/picture_view_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_view.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  // final CameraDescription camera;

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableClassification: true,
      enableLandmarks: false,
      enableTracking: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  String rightEye = "Fit your face in the box";
  String leftEye = "Fit your face in the box";
  String smile = "Fit your face in the box";

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    // _controller.dispose();
    super.dispose();
  }

  // late CameraController _controller;
  // late Future<void> _initializeControllerFuture;

  // @override
  // void initState() {
  //   super.initState();
  // To display the current output from the Camera,
  // create a CameraController.
  // _controller = CameraController(
  // Get a specific camera from the list of available cameras.
  // widget.camera,
  // Define the resolution to use.
  //   ResolutionPreset.medium,
  // );

  // Next, initialize the controller. This returns a Future.
  // _initializeControllerFuture = _controller.initialize();
  //}

  alertdialogbox(String text) {
    return AlertDialog(
      title: Text(text),
      content: Text("Press OK to continue!"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    takepicture();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
        if (kDebugMode) {
          // print(inputImage.toJson());
        }
      },
      initialDirection: CameraLensDirection.front,
      rightEyesStatus: rightEye,
      leftEyesStatus: leftEye,
      smile: smile,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);

      for (final face in faces) {
        await _cameraController!.initialize();
        await _cameraController!.lockCaptureOrientation();
        if (face.rightEyeOpenProbability! >= 0.6 &&
            face.leftEyeOpenProbability! >= 0.10) {
          setState(() {
            leftEye = "Right Eye is open";
          });
          print("Eye Open");
        } else {
          setState(() {
            leftEye = "Right Eye blink";
          });
          print("Eye Close");
        }
        if (face.leftEyeOpenProbability! >= 0.6 &&
            face.rightEyeOpenProbability! >= 0.10) {
          setState(() {
            rightEye = "Left Eye is Open";
          });
        } else {
          setState(() {
            rightEye = "left Eye blink";
          });
          print("Eye Close");
        }

        if (face.smilingProbability! >= 0.5) {
          print(
              "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
          print(
              "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
          setState(() async {
            smile = "Happyyyyy";
            //   final image = await _cameraController!.takePicture();

            //   // if (!mounted) return;

            //   // If the picture was taken, display it on a new screen.
            //   await Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (context) => DisplayPictureScreen(
            //         // Pass the automatically generated path to
            //         // the DisplayPictureScreen widget.
            //         imagePath: image.path,
            //       ),
            //     ),
            //   );
          });
          // takepicture();
          // try {
          // await _cameraController!.initialize();
          // await _cameraController!.lockCaptureOrientation();

          // // Attempt to take a picture and get the file `image`
          // // where it was saved.
          // final image = await _cameraController!.takePicture();

          // // if (!mounted) return;

          // // If the picture was taken, display it on a new screen.
          // await Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => DisplayPictureScreen(
          //       // Pass the automatically generated path to
          //       // the DisplayPictureScreen widget.
          //       imagePath: image.path,
          //     ),
          //   ),
          // );
          // } catch (e) {
          //   print(e);
          // }
        } else {
          print(
              "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
          setState(() {
            smile = "saddddd";
          });
        }
      }
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> takepicture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.

    // Ensure that the camera is initialized.
    await _cameraController!.initialize();
    await _cameraController!.lockCaptureOrientation();

    // Attempt to take a picture and get the file `image`
    // where it was saved.
    final image = await _cameraController!.takePicture();

    // if (!mounted) return;

    // If the picture was taken, display it on a new screen.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
          // Pass the automatically generated path to
          // the DisplayPictureScreen widget.
          imagePath: image.path,
        ),
      ),
    );
  }

  Future<void> blinkeye() async {}
}
