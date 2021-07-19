import 'dart:convert';

ResponseApi responseApiFromJson(String str) => ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  ResponseApi({
    this.message,
    this.error,
    this.success,
  });

  String message;
  String error;
  bool success;
  //variable of any type
  dynamic data;

  ResponseApi.fromJson(Map<String, dynamic> json) {
    message= json["message"];
    error= json["error"];
    success= json["success"];
    try{
     data=json["data"];
    }catch(e){
      print('Exception data: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "error": error,
    "success": success,
    "data": data
  };
}
