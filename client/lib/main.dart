import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:client/features/MainPage.dart';

late List<CameraDescription> _cameras;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  _cameras= await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: SafeArea(
          child:  MainPaymentPage()
          ) // CameraPage()
        )
    );
  }
}

class MainPaymentPage extends StatelessWidget {
  const MainPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.0),
      width: double.infinity,
      child:  Column(
        spacing: 80,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            spacing: 16.0,
            children: [
              Text(
                "Payment Completion",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              Stack(
                  children: [
                    SizedBox(
                        width: 176,
                        height: 176,
                        child: CircularProgressIndicator(
                          color: Colors.blueGrey.shade800,
                          backgroundColor: Colors.blueGrey.shade50,
                          strokeWidth: 8.0,
                          value: 0.3,
                        )
                    ),
                    SizedBox(
                        width: 176,
                        height: 176,
                        child: Center(
                            child: Text(
                              "30 %",
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        )
                    )

                  ]
              ),
              Text(
                "Total Amount:\t 500\$",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800
                ),
              ),
            ]
          ),
          Stack(
            children: [
              SizedBox(
                  height: 160,
                  width: 160,
                  child: Image.asset("assets/images/QR_Code_Example.svg.png")
              ),
              // DraggableScrollableSheet(
              //     builder: (context, scrollController){
              //       return SingleChildScrollView(
              //         controller: scrollController,
              //         child: Text("Assign")
              //       );
              //     }
              // )
            ],
          )
        ],
      )
    );
  }
}


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

