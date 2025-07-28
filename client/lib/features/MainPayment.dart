import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class MainPaymentPageArgs {
  final String roomId;

  MainPaymentPageArgs(this.roomId);
}

class MainPaymentPage extends StatefulWidget {
  const MainPaymentPage({super.key});

  @override
  State<MainPaymentPage> createState() => _MainPaymentPageState();
}

class _MainPaymentPageState extends State<MainPaymentPage> with SingleTickerProviderStateMixin {
  List<Widget> copayers= [];
  bool isANewMessageReceived= false;

  // TODO: at initState -> go fetch the users already in the room.

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(handleNewMessage);
  }

  void handleNewMessage(RemoteMessage message){
    print("${message.data}");
    copayers.add(
      Container(
        color: Colors.blueGrey.shade100,
          child: ListTile(
          leading: Icon(Icons.account_circle_sharp, size: 32.0),
          title: Text(message.data["username"], style:TextStyle(
            fontSize: 18.0,
          )),
          enabled: false,
        )
      )
    );

    setState((){
      isANewMessageReceived= !isANewMessageReceived;
    });
  }


  @override
  Widget build(BuildContext context) {
    final args= ModalRoute.of(context)!.settings.arguments as MainPaymentPageArgs;
    final screenWidth= MediaQuery.of(context).size.width;
    final screenHeight= MediaQuery.of(context).size.height;
    final MenuController menuController= MenuController();
    int pageToShow= 1;  // 1-3 (payment, assignment, choice of items (pre-assignment))

    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Split payments",
              style: TextStyle(
                color: Colors.blueGrey.shade800,
              )
          )
      ),
      body: Container(
          padding: EdgeInsets.only(top: 16.0),
          width: double.infinity,
          child:  Container(
            width: screenWidth,
            height: double.infinity,
            child: Stack(
              children: [
                Column(
                spacing: 40,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    spacing: 8.0,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                    ],
                  ),
                  QrImageView(
                    data: args.roomId,
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                  Container(
                    height: 160.0,
                    width: 240,
                    child: SingleChildScrollView(

                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: copayers
                      ),
                    )
                  ),
                  // DraggableSheet()
                ],
              ),
                DraggableScrollableSheet(
                  initialChildSize: 0.12,
                  maxChildSize: 0.7,
                  minChildSize: 0.1,
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
                              // Le contenu principal de la feuille, qui peut être défilant
                              Expanded(
                                child: ListView( // Utilise un ListView ou SingleChildScrollView pour le contenu défilant
                                  controller: scrollController, // Très important: lie ce contrôleur de défilement à ton ListView
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 0.0),
                                      child:Center(
                                          child: Text(
                                              "Assign",
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
                                    //pageToShow==1? ItemList() :
                                    UsersInRoom(),

                                  ]
                                )
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 16.0,
                          right: 16.0,
                          child:  MenuAnchor(
                              builder: (BuildContext context, MenuController controller, Widget? child) {
                                return FloatingActionButton(
                                    child: Icon(Icons.attach_money),
                                    onPressed: (){
                                      if (controller.isOpen){
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    }
                                );
                              },
                            menuChildren: [
                              MenuItemButton(
                                onPressed: (){

                                },
                                child: Text("Process Payment"),
                              ),
                              MenuItemButton(
                                onPressed: (){
                                  print("go on assignment");
                                  setState((){
                                    pageToShow=2;
                                  });
                                },
                                child: Text("Assign to others"),
                              )
                            ]
                          )
                        )
                      ],
                    );
                  }
                )
              ],
            ),
          )
      ),
    );
  }
}

class Item{
  final String description;
  final double amount;
  bool isChecked;

  Item({required this.description, required this.amount, this.isChecked= false});

  factory Item.fromJson(Map<String,dynamic> json){
    return Item(
      description: json["description"],
      amount: json["amount"]
    );
  }
}

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final List<Item> items= [
    Item(description: "Item 1", amount: 1.2),
    Item(description: "Item 1", amount: 1.2),
    Item(description: "Item 1", amount: 1.2)
  ];
  void showNumberOfChecked(){
    final List<Item> checkedItems= items.where((item)=>item.isChecked).toList();
    print(checkedItems.length);
  }
  @override
  Widget build(BuildContext context) {
    List<Item> _items= items;
    List<Widget> itemWidgets= [];
    for(int i=0; i<_items.length; i++){
      itemWidgets.add(Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          elevation: 2.0,
          child: CheckboxListTile(
            value: _items[i].isChecked,
            onChanged: (bool? newValue){
              setState((){
                _items[i].isChecked= newValue ?? false;
              });
              showNumberOfChecked();
            },
            title: Text(_items[i].description),
            subtitle: Text("${_items[i].amount}"),
            controlAffinity: ListTileControlAffinity.leading,
          )
      )
      );
    }
    return SingleChildScrollView(child: Column( children: itemWidgets));
  }
}

class UsersInRoom extends StatefulWidget {
  const UsersInRoom({super.key});

  @override
  State<UsersInRoom> createState() => _UsersInRoomState();
}

class _UsersInRoomState extends State<UsersInRoom> {
  List<Map<String,dynamic>> allUsersInRoom= [
    {"username": "JOJO legrand"},
    {"username": "le petit baba"}
  ];

  String roomApi= "https://ce468dd56af2.ngrok-free.app/rooms";
  String roomId= "";  // TODO: should change into a state we receive from parents

  @override
  void initState() {
    super.initState();
    getAllUsersInRoom(roomApi, roomId);
  }

  Future<void> getAllUsersInRoom(String roomApi,String roomId) async{
      final response= await http.get(Uri.parse("$roomApi/$roomId"));
      if (response.statusCode>299){
        print("error when trying to fetch the resource");
        return;
      }
      allUsersInRoom= jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: allUsersInRoom.map((user)=>Card(
            color: Colors.orange.shade100,
            margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
              child:ListTile(
                leading: Icon(Icons.account_circle_sharp,size: 40.0),
                title: Text(user["username"]),
                onTap: (){
                  print("We choose: ${user["username"]}");
                  showDialog(
                    context:context,
                    builder: (_) => AlertDialog(
                      title: Text("Confirm"),
                      content: Text("Confirming this action will assign the cost to ${user["username"]}"),
                      actions:[
                        GestureDetector(
                            onTap: (){
                              //TODO: send the request
                              Navigator.of(context).pop();
                              print("assigned to x");
                            },
                            child: Text("Cancel")
                        ),
                        SizedBox(width:24),
                        GestureDetector(
                          onTap: (){
                            //TODO: send the request
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
              ),

          )).toList()
        )
      )
    );
  }
}

