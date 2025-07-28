import 'dart:convert';
import 'dart:ffi';

import 'package:client/features/MainPayment.dart';
import 'package:client/providers/userProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class CopayerPaymentArgs {
  final String roomId;
  CopayerPaymentArgs(this.roomId);
}
class CopayerPaymentPage extends StatefulWidget {
  const CopayerPaymentPage({super.key});

  @override
  State<CopayerPaymentPage> createState() => _CopayerPaymentPageState();
}

class _CopayerPaymentPageState extends State<CopayerPaymentPage> {
  String roomPaymentUri= "https://ce468dd56af2.ngrok-free.app/users";
  String processPayemntUri= "https://ce468dd56af2.ngrok-free.app/payments/process";
  bool isNewMessageReceived= false;
  List<Widget> assignedPayments= [];
  List<dynamic> paymentData= [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPendingPayments();
    FirebaseMessaging.onMessage.listen(handleNewAssignment);
  }

  void handleNewAssignment(RemoteMessage message) {
    print("${message.data}");
    paymentData.add(message.data);
    assignedPayments.add(
        Container(
            color: Colors.blueGrey.shade100,
            child: ListTile(
              leading: Icon(Icons.account_circle_sharp, size: 32.0),
              title: Text(message.data["itemDescription"], style: TextStyle(
                fontSize: 18.0,
              )),
            )
        )
    );
    setState(() {
      isNewMessageReceived= !isNewMessageReceived;
    });
  }

  Future<void> getPendingPayments() async{
    var user= Provider.of<GlobalStateProvider>(context,listen:false).user;
    final args= ModalRoute.of(context)!.settings.arguments as CopayerPaymentArgs;
    var paymentsDue= await post(Uri.parse(roomPaymentUri), headers: {"Content-Type":"application/json"},
        body: json.encode({
          "userId": user["id"],
          "roomId": args.roomId
        })
    );
    List<dynamic> payments= jsonDecode(paymentsDue.body);
    assignedPayments= payments.map((payment)=>Container(
        color: Colors.blueGrey.shade100,
        child: ListTile(
          leading: Icon(Icons.account_circle_sharp, size: 32.0),
          title: Text(payment["description"], style: TextStyle(
            fontSize: 18.0,
          )),
          trailing: Text(payment["amount"]),
        )
    )).toList();

  }


    @override
  Widget build(BuildContext context) {
    final args= ModalRoute.of(context)!.settings.arguments as CopayerPaymentArgs;
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
                  initialChildSize: 1.0,// hide the 'Hero'
                  maxChildSize: 1.0,
                  minChildSize: 1.0,
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
                                          height: 480,
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Column(
                                              children: assignedPayments
                                          ),
                                        ),
                                        SizedBox(height: 24.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: FloatingActionButton.extended(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0) ),
                                              backgroundColor: Colors.orange.shade500,
                                              onPressed: (){
                                                showDialog(
                                                  context:context,
                                                  builder: (_) => AlertDialog(
                                                      title: Text("Confirm"),
                                                      content: Text("Confirming this action will process a transaction on your account"),
                                                      actions:[
                                                        GestureDetector(
                                                            onTap: ()async {
                                                              //TODO: send the request
                                                              //var checkedItems= items.where((i)=> i.isChecked).toList();
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Text("Cancel")
                                                        ),
                                                        SizedBox(width:24),
                                                        GestureDetector(
                                                            onTap: () async{
                                                              //TODO: send the request
                                                              // var checkedItems= items.where((i)=> i.isChecked).toList();
                                                              await processPayments(processPayemntUri);

                                                              Navigator.of(context).pop();
                                                              print("assigned to x");

                                                            },
                                                            child: Text("OK")
                                                        )
                                                      ],
                                                      elevation: 24.0
                                                  ),
                                                  barrierDismissible: false,
                                                );
                                              },
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

  Future<void> processPayments(processPaymentUrl) async{

    for(int i=0; i<paymentData.length; i++){
      await post(Uri.parse("${processPaymentUrl}/${paymentData[i]["id"]}"));
    }
    paymentData=[];
    assignedPayments=[];
    setState(() {
      isNewMessageReceived= !isNewMessageReceived;
    });
  }
}

