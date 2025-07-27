import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainPaymentPageArgs {
  final String roomId;

  MainPaymentPageArgs(this.roomId);
}

class MainPaymentPage extends StatefulWidget {
  const MainPaymentPage({super.key});

  @override
  State<MainPaymentPage> createState() => _MainPaymentPageState();
}

class _MainPaymentPageState extends State<MainPaymentPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen(handleNewMessage);
  }

  void handleNewMessage(RemoteMessage message){
    print("${message.data}");
  }

  @override
  Widget build(BuildContext context) {
    final args= ModalRoute.of(context)!.settings.arguments as MainPaymentPageArgs;
    return Scaffold(
      body: Container(
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
                  // DraggableSheet()
                ],
              ),
              QrImageView(
                data: args.roomId,
                version: QrVersions.auto,
                size: 160.0,
              )
              // DraggableSheet()
            ],
          )
      ),
    );
  }
}



class DraggableSheet extends StatefulWidget {
  const DraggableSheet({super.key});

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme= Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (BuildContext context,ScrollController scrollController){
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(color: Colors.blueAccent),
          );
          // return SingleChildScrollView(
          //     controller: scrollController,
          //     child: Text("Assign")
          // );
        }
    );
  }
}