class CategoryModel {
  int? id;
  String? name;
  String? imageFullUrl;
  String? slug;

  CategoryModel({this.id, this.name, this.imageFullUrl, this.slug});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['slug'] = slug;
    return data;
  }
}
