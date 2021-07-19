
import 'dart:convert';

import 'package:delivery/src/models/role.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  //constructor
  User({
    this.id,
    this.email,
    this.name,
    this.lastname,
    this.phone,
    this.image,
    this.sessionToken,
    this.password,
    this.roles
  });
  //declaration
  String id;
  String email;
  String name;
  String lastname;
  String phone;
  String image;
  String sessionToken;
  String password;

  List<Role> roles =[];
  List<User> toList =[];
  //receive json and convert to user
  factory User.fromJson(Map<String, dynamic> json) => User(
    //convert always to string if its int
    id: json["id"] is int? json["id"].toString(): json["id"],
    email: json["email"],
    name: json["name"],
    lastname: json["lastname"],
    phone: json["phone"],
    image: json["image"],
    sessionToken: json["session_token"],
    password: json["password"],
    //In case role is null then return empty array, otherwise: create list role. If it comes empty then return null
    roles: json["roles"] == null ? [] : List<Role>.from(json['roles'].map(
        (model)=>Role.fromJson(model)
    )) ?? [],
  );
  //get user and convert to json
  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "lastname": lastname,
    "phone": phone,
    "image": image,
    "session_token": sessionToken,
    "password": password,
    "roles": roles
  };
  User.fromJsonList(List<dynamic> jsonList){
    if(jsonList == null) return;
    jsonList.forEach((item) {
      User user = User.fromJson(item);
      toList.add(user);
    });
  }
}
