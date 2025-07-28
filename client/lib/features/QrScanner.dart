import 'package:client/features/MainPayment.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final backendApi= "https://ce468dd56af2.ngrok-free.app/payments";
  bool isPaymentCreated= false;
  bool isProcessing= false;

  Future<bool> createPayment(String apiUrl,String roomId) async{
    // TODO: remove all hard coding on user_ids
    var client= http.Client();
    Map<String,String> data= {"userId":"4c70caa7-b3ab-45c5-9ae2-f391de428aeb", "roomId": roomId};
    var response= await client.post(Uri.parse(apiUrl),
      headers:{"Content-Type":"application/json"},
      body: jsonEncode(data)
    );
    if (response.statusCode >299){
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (result) async{
        print(result.barcodes.first.rawValue);
        if (isProcessing || isPaymentCreated) return;
        isProcessing= true;
        String? qrData= result.barcodes.first.rawValue;
        if (!isPaymentCreated){
          print(isPaymentCreated);
          if (qrData != null){
            isPaymentCreated= await createPayment( backendApi ,qrData);
            if (!isPaymentCreated) return;
            isProcessing= false;
            Navigator.pushNamed(context, "/copayerPayment",arguments: MainPaymentPageArgs(qrData));
          }
        }
      }
    );
  }
}


