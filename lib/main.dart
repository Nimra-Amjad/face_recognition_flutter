import 'package:camera/camera.dart';
import 'package:face_detector_eye_blink/face_detector_view.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras=[];

Future<void> main() async {
  try{
    WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  } on CameraException catch(e){
    debugPrint('CameraError: ${e.description}');
  }
  runApp(MaterialApp(
      title: "Face Detection App",
      theme: ThemeData(primarySwatch: Colors.amber),
      home: FaceDetectorView(),
    ));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Face Detection App",
//       theme: ThemeData(primarySwatch: Colors.amber),
//       home: FaceDetectorView(),
//     );
//   }
// }