import "dart:convert";

import "package:client/features/MainPayment.dart";
import "package:flutter/material.dart";

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
          child:  Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 24.0,
                    children: [
                      Container(
                          width: 320,
                          child: FloatingActionButton.extended(

                            onPressed: (){
                              Navigator.pushNamed(context,'/camera');
                              print("we want to scan a bill");
                            },
                            label: Text("Scan a bill"),
                            icon: Image.asset("assets/icons/document_scanner.png"),
                          )
                      ),
                      Container(
                        width: 320,
                        child: FloatingActionButton.extended(
                          onPressed: (){
                            Navigator.pushNamed(context, '/scanqr');
                            },
                          label: Text("Scan a Qr"),
                          icon: Image.asset("assets/icons/qr_code_scanner.png"),
                        ),
                      ),

                    ]
                )
              ]
          )
      ),
    );
  }
}
