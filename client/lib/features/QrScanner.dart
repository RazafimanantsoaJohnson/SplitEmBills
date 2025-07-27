import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (result){
        print(result.barcodes.first.rawValue);
        Navigator.pushNamed(context, '/mainPayment');
      }
    );
  }
}


