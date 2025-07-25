import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

class CameraPage extends StatefulWidget{
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>{
  late CameraController controller;

  @override
  void initState(){
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_){
      if (!mounted){
        return;
      }
    }).catchError((Object e){
      if (e is CameraException){
        switch (e.code){
          case 'CameraAccessDenied':
          //TODO: add a message for the user to ask him for permission
            print("the app did not have access to camera");
            break;
          default:
            print("print $e");
            break;
        }
      }
    });
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    if (!controller.value.isInitialized){
      return Container();
    }
    return CameraPreview(controller);
  }
}
