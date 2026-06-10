class UserProfile {
  final String userId;
  final String name;
  final DateTime date;
  final String username;
  final String phone;
  final String country;
  final String city;
  final String job;
  final double weight;
  final double height;
  final String gender;
  final String maritalStatus;
  final bool hasInsurance;

  UserProfile({
    required this.userId,
    required this.name,
    required this.date,
    required this.username,
    required this.phone,
    required this.country,
    required this.city,
    required this.job,
    required this.weight,
    required this.height,
    required this.gender,
    required this.maritalStatus,
    required this.hasInsurance,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name,
    "date": date.toIso8601String(),
    "username": username,
    "phone": phone,
    "country": country,
    "city": city,
    "job": job,
    "weight": weight,
    "height": height,
    "gender": gender,
    "maritalStatus": maritalStatus,
    "hasInsurance": hasInsurance,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json["userId"],
    name: json["name"],
    date: DateTime.parse(json["date"]),
    username: json["username"],
    phone: json["phone"],
    country: json["country"],
    city: json["city"],
    job: json["job"],
    weight: json["weight"],
    height: json["height"],
    gender: json["gender"],
    maritalStatus: json["maritalStatus"],
    hasInsurance: json["hasInsurance"],
  );
}
