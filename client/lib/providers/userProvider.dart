import 'package:flutter/material.dart';

class GlobalStateProvider extends ChangeNotifier {
  Map<String,dynamic> _user={};
  Map<String, dynamic> get user => _user;

  void setUser(Map<String, dynamic> user){
    _user= user;
    notifyListeners();
  }
}