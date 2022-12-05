class HerbalJsonModel {
  int? herbId;
  String? plantName;
  String? scienName;
  String? location;
  String? description;
  String? uses;
  String? imageURL;

  HerbalJsonModel(
      {this.herbId,
      this.plantName,
      this.location,
      this.imageURL,
      this.scienName,
      this.description,
      this.uses});

  HerbalJsonModel.fromJson(Map<String, dynamic> json) {
    herbId = json['id'];
    plantName = json['plantName'];
    scienName = json['scienName'];
    location = json['location'];
    description = json['description'];
    uses = json['uses'];
    imageURL = json['imageUrl'];
  }
}
