import 'package:flutter/foundation.dart';

class PickedUserProvider extends ChangeNotifier{
  List<Map<String, dynamic>> _pickedUsers = [];
  List<Map<String, dynamic>> get pickedUsers => _pickedUsers;

  List<List<Map<String, dynamic>>> _foodList = [];
  List<List<Map<String, dynamic>>> get foodList => _foodList;

  List<Map<String, dynamic>> _recommendedList = [];
  List<Map<String, dynamic>> get recommendedList => _recommendedList;

  void addFoodList(List<Map<String, dynamic>> food){
    _foodList.add(food);
    for(var item in food){
      bool found = false;
      for(var rec in _recommendedList){
        if(item["item"]==rec["item"]){
          found = true;
          break;
        }
      }
      if(!found){
        _recommendedList.add(item);
      }
    }
    notifyListeners();
  }

  void setFoodList(List<Map<String, dynamic>> food, int index){
    _foodList[index] = food;
    notifyListeners();
  }

  void refreshAll(){
    _pickedUsers = [];
    _foodList = [];
    _recommendedList = [];
    notifyListeners();
  }
}