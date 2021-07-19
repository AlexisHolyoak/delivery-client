import 'dart:convert';
import 'dart:io';

import 'package:delivery/src/api/environment.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
class UsersProvider{
  String _url=Environment.API_DELIVERY;
  String _api='api/users';

  BuildContext context;
  User sessionUser;
  Future init(BuildContext context, {User sessionUser}){
    this.context= context;
    this.sessionUser= sessionUser;
  }
  Future<ResponseApi> create(User user) async{
    try{
      Uri url= Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(user);
      Map<String,String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on create: $ex');
      return null;
    }
  }
  Future<ResponseApi> logout(String idUser) async{
    try{
      Uri url= Uri.http(_url, '$_api/logout');
      String bodyParams = json.encode({
        'id': idUser
      });
      Map<String,String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on create: $ex');
      return null;
    }
  }
  Future<Stream> createWithImage(User user, File image) async{
    try{
      Uri url= Uri.http(_url, '$_api/create');
      final request = http.MultipartRequest('POST', url);
      if(image !=null){
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(image.openRead().cast()),
          await image.length(),
          filename: basename(image.path)
        ));
      }

      request.fields['user']=json.encode(user);
      final response = await request.send(); //Sending petition

      return response.stream.transform(utf8.decoder);

    }catch(ex){
      print('Error $ex');
      return null;
    }
  }
  Future<Stream> update(User user, File image) async{
    try{
      Uri url= Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization']=sessionUser.sessionToken;
      if(image !=null){
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['user']=json.encode(user);
      final response = await request.send(); //Sending petition
      // handle unauthorize
      if(response.statusCode==401){
        Fluttertoast.showToast(msg: 'Tu sesión ha expirado');
        new SharedPref().logout(context, sessionUser.id);
      }
      return response.stream.transform(utf8.decoder);

    }catch(ex){
      print('Error $ex');
      return null;
    }
  }
  Future<ResponseApi> login(email, password) async{
    try{
      Uri url= Uri.http(_url, '$_api/login');
      String bodyParams = json.encode({
        'email': email,
        'password': password
      });
      Map<String,String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on create: $ex');
      return null;
    }
  }
  Future<List<User>> getDeliveryMen() async{
    try{
      Uri url= Uri.http(_url, '$_api/findDeliveryMen');
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.get(url, headers: headers);
      // handle unauthorize
      if(res.statusCode ==401){
        Fluttertoast.showToast(msg: 'Tu sesión ha expirado');
        new SharedPref().logout(context, sessionUser.id);
      }
      final data= json.decode(res.body);
      User user = User.fromJsonList(data);
      return user.toList;
    }catch(ex){
      print('Error on findDeliveryMen $ex');
    }
  }
  Future<User> getById(String id) async{
    try{
      Uri url= Uri.http(_url, '$_api/findById/$id');
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken
      };
      final res = await http.get(url, headers: headers);
      // handle unauthorize
      if(res.statusCode ==401){
        Fluttertoast.showToast(msg: 'Tu sesión ha expirado');
        new SharedPref().logout(context, sessionUser.id);
      }
      final data= json.decode(res.body);
      User user = User.fromJson(data);
      return user;
    }catch(ex){
      print('Error on getById $ex');
    }
  }
}