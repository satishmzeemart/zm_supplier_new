class CategoryResponse {
  CategoryResponse({
    this.data,
  });
  List<Categories> data;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        data: List<Categories>.from(
            json["data"].map((x) => Categories.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Categories {
  String categoryId;
  String name;
  String imageURL;

  Categories(this.categoryId, this.name, this.imageURL);

  Categories.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    name = json['name'];
    imageURL = json['imageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    data['imageURL'] = this.imageURL;
  }
}

class SubCategoryBaseResponse {
  int status;
  String message;
  List<SubCategoryData> data;

  SubCategoryBaseResponse(this.data, this.status, this.message);

  SubCategoryBaseResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = List<SubCategoryData>.from(
        json["data"].map((x) => SubCategoryData.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['message'] = this.message;
    data['status'] = this.status;
    data['data'] = this.data;
  }
}

class SubCategoryData {
  String categoryId;
  String name;
  List<SubCategory> children;

  SubCategoryData(this.name, this.categoryId, this.children);

  SubCategoryData.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    name = json['name'];
    children = List<SubCategory>.from(
        json["children"].map((x) => SubCategory.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
    // data['children'] = List<dynamic>.from(data.map((x) => x.toJson())),
  }
}

class SubCategory {
  String categoryId;
  String name;

  SubCategory(this.categoryId, this.name);

  SubCategory.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['categoryId'] = this.categoryId;
    data['name'] = this.name;
  }
}
