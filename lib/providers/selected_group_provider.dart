import 'package:flutter/foundation.dart';

class SelectedGroupProvider extends ChangeNotifier {
  String _documentId = "";
  String get idDocument => _documentId;

  void setIdDocument(String idDocument) {
    _documentId = idDocument;
    notifyListeners();
  }
}