import 'package:client/features/MainPayment.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ItemsProvider extends ChangeNotifier {
  List<Item> _items=[];
  List<Item> get items => _items;

  void addValue(Item){
    _items.add(Item);
    notifyListeners();
  }

  void initialize(List<Item> items){
    _items= items;
    notifyListeners();
  }

  void updateValue(int index, bool newValue){
    _items[index].isChecked= newValue;
    notifyListeners();
  }

  void removeCheckedValue(){
    _items= _items.where((i)=> !i.isChecked ).toList();
  }
}
