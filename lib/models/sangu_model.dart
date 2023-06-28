class SanguModel {
  late String id;
  late String suggestName;

  SanguModel({
    required this.id,
    required this.suggestName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_suggest': suggestName,
    };
  }

  SanguModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    suggestName = map['name_suggest'];
  }
}