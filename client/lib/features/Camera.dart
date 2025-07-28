import 'dart:io';

import 'package:camera/camera.dart';
import 'package:client/features/MainPayment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';


class ScanABillPage extends StatefulWidget {

  const ScanABillPage({super.key});

  @override
  State<ScanABillPage> createState() => _ScanABillPageState();
}

class _ScanABillPageState extends State<ScanABillPage> {
  late List<CameraDescription> _cameras;
  late CameraController controller;
  String newImage= "";
  final backendApi= "https://ce468dd56af2.ngrok-free.app/rooms";

  @override
  void initState(){ // will be called when the widget is first drawned on the screen
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras= await availableCameras();
    controller= CameraController(_cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_){
      if (!mounted){
        return;
      }
      setState((){});// forcing a rebuild if camera not mounted
    }).catchError((Object e){
      if (e is CameraException){
        switch (e.code) {
          case 'CameraAccessDenied':
            print("we don't have access to the camera");
            break;
          default:
            print(e);
            break;
        }
      }
    });
  }

  Future<void> sendPicture() async {
    var request= http.MultipartRequest("POST", Uri.parse(backendApi));
    request.files.add(await http.MultipartFile.fromPath('bill', newImage, contentType: MediaType('image','png')));
    var response= await request.send();
    if (response.statusCode< 299){
      String responseBody= await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse= jsonDecode(responseBody);
      List<dynamic> data= jsonResponse["Data"];
      print("=====================Response BODYYY: $responseBody");
      Navigator.pushNamed(context, "/mainPayment", arguments: MainPaymentPageArgs.fromJson(jsonResponse["id"], data));
    }else{
      print('File upload unsuccessful: ${response.statusCode}');
    }
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cameraViewer= SizedBox(
        width: 500,
        height: 500,
        child:  CameraPreview(controller)
    );
    if (!controller.value.isInitialized){
      return Container();
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,

          children: [
            newImage == ""? cameraViewer : SizedBox(
                width: 500,
                height: 500,
                child: Image.file(
                  File(newImage),
                  fit: BoxFit.cover,
                )
            ),
            Container(
              height: MediaQuery.of(context).size.height - 600,
              width: double.infinity,
              child: Center(
                child: FloatingActionButton(
                    onPressed: () async {
                      if (newImage==""){
                        final XFile image= await  controller.takePicture();

                        setState((){
                          newImage= image.path;
                        });
                        return;
                      }
                      sendPicture();
                    },
                    child: Icon(
                        newImage=="" ?Icons.circle: Icons.send
                    )
                ),
              )
            )
          ]
        ),
      )
    );
  }
}

