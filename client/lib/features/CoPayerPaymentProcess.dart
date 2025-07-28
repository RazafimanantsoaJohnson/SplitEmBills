import 'package:client/features/MainPayment.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class CopayerPaymentPage extends StatefulWidget {
  const CopayerPaymentPage({super.key});

  @override
  State<CopayerPaymentPage> createState() => _CopayerPaymentPageState();
}

class _CopayerPaymentPageState extends State<CopayerPaymentPage> {
  final userId= "38b5854e-0841-477a-981d-7e8fff70dc2b"; //TODO: need to remove hardcoding
  bool isNewMessageReceived= false;
  List<Widget> assignedPayments= [
    Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        elevation: 2.0,
        child: Row(
            children: [
              ListTile(
                title: Text("ITEM 1"),
                subtitle: Text("50.0\$"),
              )
            ]
        )
    )
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void handleNewAssignment(RemoteMessage message){
    assignedPayments.add(
        Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: Colors.orange.shade200,
            elevation: 2.0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              child: Row(
                  children: [
                    Expanded(
                        child:Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children:[
                              Text("First Item", style:TextStyle(fontSize: 16.0)),
                              Text("\$50.00")
                            ]
                        )
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade200,
                      ),
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical:6.0),
                          child: Text(
                              "Reject"
                          )
                      ),
                      onPressed: (){},
                    )
                  ]
              ),
            )
        )
    );

  }

  @override
  Widget build(BuildContext context) {
    final args= ModalRoute.of(context)!.settings.arguments as MainPaymentPageArgs;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Processsing payments",
          style: TextStyle(
            color: Colors.blueGrey.shade800,

          )
        )
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width:double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16.0,
                children: [
                  SizedBox(height: 16.0),
                  Stack(
                    children: [
                      SizedBox(
                          width: 176,
                          height: 176,
                          child: CircularProgressIndicator(
                            color: Colors.blueGrey.shade800,
                            backgroundColor: Colors.blueGrey.shade50,
                            strokeWidth: 8.0,
                            value: 0,
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
            ),

            DraggableScrollableSheet(
                initialChildSize: 0.6,
                maxChildSize: 0.6,
                minChildSize: 0.6,
                builder: (context, scrollController){
        
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Expanded(
                                child: ListView( // Utilise un ListView ou SingleChildScrollView pour le contenu défilant
                                    controller: scrollController, // Très important: lie ce contrôleur de défilement à ton ListView
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 0.0),
                                        child:Center(
                                          child: Text(
                                              "Process",
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
        
                                              )
                                          ),
                                        ),
                                        /*
                                            trailing: Text(
                                              "(${copayers.length})",
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )
                                            )
        
                                              */
                                      ),
                                      Container(
                                        height: 240,
                                        width: double.infinity,
                                        child: Column(
                                            children: [

                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 24.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: FloatingActionButton.extended(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0) ),
                                            backgroundColor: Colors.orange.shade500,
                                            onPressed: (){},
                                            label: Text(
                                              "Confirm Payment",
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white
                                              )
                                            )
                                        ),
                                      )
                                    ]
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
            )
          ]
        ),
      ),
    );
  }
}

