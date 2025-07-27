import "package:flutter/material.dart";

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child:  Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Container(
                        width: 48.0,
                        height: 48.0,
                        child: CircleAvatar(
                            child: Icon(Icons.man)
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        child: FloatingActionButton(onPressed: (){},
                            child: Icon(Icons.menu)
                        ) ,
                      ),
                    ]
                ),
                SizedBox(
                    height: 300
                ),
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
                            print("we want to scan a qr");
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
