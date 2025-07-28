import "dart:convert";

import "package:client/providers/userProvider.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:provider/provider.dart";


class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  Future<Map<String,dynamic>> sendSigninRequest(String signinUrl,String username) async{
    String? userToken= await FirebaseMessaging.instance.getToken();
    Map<String,String> data= {"username": username, "userToken": userToken!};
    var response= await post(Uri.parse(signinUrl),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(data)
    );
    var resBody= jsonDecode(response.body);
    if (response.statusCode > 299){
      print(response);
      return {"error": "error when trying to signin"};
    }
    return resBody;
  }

  @override
  Widget build(BuildContext context) {
    final globalStateProvider= Provider.of<GlobalStateProvider>(context,listen: false);
    final textFieldController= TextEditingController();
    final signinUrl= "https://ce468dd56af2.ngrok-free.app/users"; // TODO: make this link some kind of global state
    return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16.0,
            children:[
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Input Username',
                  ),
                  controller: textFieldController,
                ),
              ),
              SizedBox(
                width: 280,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.blueGrey.shade800,
                  onPressed: () async{
                    print(textFieldController.text);
                    var response= await sendSigninRequest(signinUrl, textFieldController.text);
                    if (response['error']==null){
                      print(response);
                      globalStateProvider.setUser(response);
                      Navigator.of(context).pushNamed("/mainPage");
                    }
                    },
                  label: Text("Signin",
                  style:TextStyle(color:Colors.white))
                ),
              )
            ]
          ),
        )
    );
  }
}

