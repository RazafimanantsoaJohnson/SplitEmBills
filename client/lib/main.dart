import 'package:client/features/Camera.dart';
import 'package:client/features/CoPayerPaymentProcess.dart';
import 'package:client/features/MainPayment.dart';
import 'package:flutter/material.dart';
import 'package:client/features/MainPage.dart';
import 'package:client/features/QrScanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.instance.requestPermission();
  final fcmToken= await FirebaseMessaging.instance.getToken();
  print(fcmToken);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey.shade800),
        ),
      initialRoute: '/',
      routes: {
          '/': (context) => const MainPage(),
        '/camera': (context) => const ScanABillPage(),
        '/mainPayment': (context) => const MainPaymentPage(),
        '/copayerPayment': (context) => const CopayerPaymentPage(),
        '/scanqr': (context) => const QrScannerPage(),
      }
    );
  }
} // MainPaymentPage()

