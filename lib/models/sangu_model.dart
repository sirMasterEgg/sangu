class SanguModel {
  late int id;
  late String image;

  SanguModel({
    required this.id,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
    };
  }

  SanguModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    image = map['image'];
  }
}