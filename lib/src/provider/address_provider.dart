
import 'dart:convert';

import 'package:delivery/src/api/environment.dart';
import 'package:delivery/src/models/address.dart';
import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
class AddressProvider{
  String _url = Environment.API_DELIVERY;
  String _api='/api/address';
  BuildContext context;
  User userSession;
  Future init (BuildContext context, User userSession){
    this.userSession = userSession;
    this.context=context;
  }
  Future<List<Address>> getByUser(String  idUser) async{
    try{
      Uri url= Uri.http(_url, '$_api/findByUser/$idUser');
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': userSession.sessionToken
      };
      final res = await http.get(url, headers: headers);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, userSession.id);
      }
      final data=json.decode(res.body);
      Address address = Address.fromJsonList(data);
      return address.toList;
    }catch(ex){
      print('Error on get all address : $ex');
      return [];
    }
  }
  Future<ResponseApi> create(Address address) async{
    try{
      Uri url= Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(address);
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': userSession.sessionToken
      };
      final res = await http.post(url, headers: headers, body: bodyParams);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, userSession.id);
      }
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on create: $ex');
      return null;
    }
  }
}