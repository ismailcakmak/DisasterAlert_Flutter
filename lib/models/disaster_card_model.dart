

class DisasterCardModel{

  final String? disasterName;
  final String? disasterDescription;
  final String? disasterType;
  final int? distance;
  final Map? location;

  DisasterCardModel({this.disasterType,this.disasterName, this.distance, this.disasterDescription, this.location});

  DisasterCardModel.fromMap(Map<String, dynamic> m) : this.disasterType = m['disasterType'], this.disasterName = m['disasterName'], this.distance = m['distance'], this.disasterDescription = m['disasterDescription'], this.location = m['location'] {}

  Map<String, dynamic> toMap() {

    Map<String, dynamic> m = {
      'disasterType' : disasterType,
      'disasterName' : disasterName,
      'distance' : distance,
      'disasterDescription' : disasterDescription,
      'location' : location,
    };

    return m;
  }


}