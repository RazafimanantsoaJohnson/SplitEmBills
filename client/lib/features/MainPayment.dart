import 'dart:convert';

import 'package:client/providers/itemsProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MainPaymentPageArgs {
  final String roomId;
  final List<Item> items;

  MainPaymentPageArgs(this.roomId, this.items);
  factory MainPaymentPageArgs.fromJson(String roomId,List<dynamic> json){

    return MainPaymentPageArgs(
      roomId,
      json.map((e)=>Item(description: e["description"], amount: e["amount"].toDouble())).toList()
    );
  }
}



class MainPaymentPage extends StatefulWidget {
  const MainPaymentPage({super.key});

  @override
  State<MainPaymentPage> createState() => _MainPaymentPageState();
}

class _MainPaymentPageState extends State<MainPaymentPage> with SingleTickerProviderStateMixin {
  List<Widget> copayers= [];
  List<dynamic> copayersData=[];
  bool isANewMessageReceived= false;
  int pageToShow= 1;  // 1-3 (payment, assignment, choice of items (pre-assignment))

  // TODO: at initState -> go fetch the users already in the room.

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen(handleNewMessage);
  }

  void handleNewMessage(RemoteMessage message){
    print("${message.data}");
    copayersData.add({
      "username": message.data["username"],
      "userId": message.data["userId"]
    });
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

  Widget showMainWidget( String roomId,List<Item> items, List<dynamic> copayersData){
    if(pageToShow== 2){
      return UsersInRoom(roomId: roomId ,users: copayersData);
    }
    return ItemList(items: items);
  }

  @override
  Widget build(BuildContext context) {
    final args= ModalRoute.of(context)!.settings.arguments as MainPaymentPageArgs;
    final screenWidth= MediaQuery.of(context).size.width;
    final screenHeight= MediaQuery.of(context).size.height;
    final MenuController menuController= MenuController();
    double totalAmount= 0.0;
    for (int i=0; i<args.items.length; i++){
      totalAmount+= args.items[i].amount;
    }

    return ChangeNotifierProvider(
      create: (context)=>ItemsProvider(),
        child:Scaffold(
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
                Padding(
                  padding:EdgeInsets.symmetric(horizontal: 80.0),
                  child: Column(
                  spacing: 40,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 16.0,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /*
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
                         */
                        Text(
                          "Total Amount:\t ${totalAmount}\$",
                          style: TextStyle(
                              fontSize: 24.0,
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
                      height: 240.0,
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
                                    showMainWidget(args.roomId ,args.items, copayersData),
                                    // UsersInRoom(),
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
                                    if(pageToShow==1){
                                      pageToShow=2;
                                    }else{
                                      pageToShow=1;
                                    }
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
    ));
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
  final List<Item> items;

  const ItemList({super.key, required this.items});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {

  void showNumberOfChecked(List<Item> items){
    final List<Item> checkedItems= items.where((item)=>item.isChecked).toList();
    print(checkedItems.length);
  }

  void showItems(List<Item> items){
    print("=============================ITEMS:::${items}");
  }
  @override
  Widget build(BuildContext context) {
    final itemProvider= Provider.of<ItemsProvider>(context, listen: false);
    if (itemProvider.items.length==0){
      itemProvider.initialize(widget.items);
    }

    showItems(itemProvider.items);
    List<Widget> itemWidgets= [];
    for(int i=0; i<itemProvider.items.length; i++){
      itemWidgets.add(Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          elevation: 2.0,
          child: CheckboxListTile(
            value: itemProvider.items[i].isChecked,
            onChanged: (bool? newValue){
              setState((){
                itemProvider.items[i].isChecked= newValue ?? false;
                itemProvider.updateValue(i, newValue ?? false);
              });
              showNumberOfChecked(itemProvider.items);
            },
            title: Text(itemProvider.items[i].description),
            subtitle: Text("${itemProvider.items[i].amount}"),
            controlAffinity: ListTileControlAffinity.leading,
          )
      )
      );
    }
    return SingleChildScrollView(child: Column( children: itemWidgets));
  }
}

class UsersInRoom extends StatefulWidget {
  final List<dynamic> users;
  final String roomId;
  const UsersInRoom({super.key, required this.users,required this.roomId });

  @override
  State<UsersInRoom> createState() => _UsersInRoomState();
}

class _UsersInRoomState extends State<UsersInRoom> {

  String roomApi= "https://ce468dd56af2.ngrok-free.app/rooms";
  String assignmentApi= "https://ce468dd56af2.ngrok-free.app/payments";

  @override
  void initState() {
    super.initState();
    // getAllUsersInRoom(roomApi, roomId);
  }

  // Future<void> getAllUsersInRoom(String roomApi,String roomId) async{
  //     final response= await http.get(Uri.parse("$roomApi/$roomId"));
  //     if (response.statusCode>299){
  //       print("error when trying to fetch the resource");
  //       return;
  //     }
  //     allUsersInRoom= jsonDecode(response.body);
  // }

  Future<bool> assignToUsers(String assignmentUrl, String roomId ,String userId ,List<Item> items) async{
    bool result= true;
    print(items);
    for(int i=0;i<items.length;i++){
      print("sending:  ${items[i]}");
      var data= {
        "userId": userId, "roomId": roomId, "itemDescription":items[i].description, "amount":items[i].amount
      };
      var response= await http.post(Uri.parse(assignmentUrl), headers: {"Content-Type":"application/json"},
          body: jsonEncode(data));
      result= response.statusCode<299 && result;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final allUsersInRoom= widget.users;
    final items= context.watch<ItemsProvider>().items;
    final itemProvider= Provider.of<ItemsProvider>(context,listen: false);
    final roomId= widget.roomId;

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
                            onTap: ()async {
                              //TODO: send the request
                              //var checkedItems= items.where((i)=> i.isChecked).toList();
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel")
                        ),
                        SizedBox(width:24),
                        GestureDetector(
                          onTap: ()async{
                            //TODO: send the request
                            var checkedItems= items.where((i)=> i.isChecked).toList();
                            await assignToUsers(assignmentApi, roomId, user["userId"], checkedItems);
                            itemProvider.removeCheckedValue();

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

