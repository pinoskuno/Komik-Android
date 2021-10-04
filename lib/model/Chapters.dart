class Chapters {
  List<String> links;
  String name;

  Chapters({this.links, this.name});

  Chapters.fromJson(Map<String, dynamic> json) {
    if (json['Links'] != null) links = json['Links'].cast<String>();
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Links'] = this.links;
    data['Name'] = this.name;
    return data;
  }
}
