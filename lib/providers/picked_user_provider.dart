import 'package:flutter/foundation.dart';

class PickedUserProvider extends ChangeNotifier{
  List<Map<String, dynamic>> _pickedUsers = [];
  List<Map<String, dynamic>> get pickedUsers => _pickedUsers;
}