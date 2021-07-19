
import 'dart:convert';

import 'package:delivery/src/api/environment.dart';
import 'package:delivery/src/models/address.dart';
import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
class OrdersProvider{
  String _url = Environment.API_DELIVERY;
  String _api='/api/orders';
  BuildContext context;
  User userSession;
  Future init (BuildContext context, User userSession){
    this.userSession = userSession;
    this.context=context;
  }
  Future<List<Order>> getByClient(String idClient,String status) async{
    try{
      Uri url= Uri.http(_url, '$_api/findByClient/$idClient/$status');
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
      Order order = Order.fromJsonList(data);
      return order.toList;
    }catch(ex){
      print('Error on find by status orders: $ex');
      return [];
    }
  }
  Future<List<Order>> getByDelivery(String idDelivery,String status) async{
    try{
      Uri url= Uri.http(_url, '$_api/findByDelivery/$idDelivery/$status');
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
      Order order = Order.fromJsonList(data);
      return order.toList;
    }catch(ex){
      print('Error on find by status orders: $ex');
      return [];
    }
  }
  Future<List<Order>> getByStatus(String status) async{
    try{
      Uri url= Uri.http(_url, '$_api/findByStatus/$status');
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
      Order order = Order.fromJsonList(data);
      return order.toList;
    }catch(ex){
      print('Error on find by status orders: $ex');
      return [];
    }
  }
  Future<ResponseApi> updateToDelivered(Order order) async{
    try{
      Uri url= Uri.http(_url, '$_api/updateToDelivered');
      String bodyParams = json.encode(order);
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': userSession.sessionToken
      };
      final res = await http.put(url, headers: headers, body: bodyParams);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, userSession.id);
      }
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on updateToDispatch: $ex');
      return null;
    }
  }
  Future<ResponseApi> updateToOnTheWay(Order order) async{
    try{
      Uri url= Uri.http(_url, '$_api/updateToOnTheWay');
      String bodyParams = json.encode(order);
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': userSession.sessionToken
      };
      final res = await http.put(url, headers: headers, body: bodyParams);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, userSession.id);
      }
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on updateToDispatch: $ex');
      return null;
    }
  }
  Future<ResponseApi> updateToDispatch(Order order) async{
    try{
      Uri url= Uri.http(_url, '$_api/updateToDispatch');
      String bodyParams = json.encode(order);
      Map<String,String> headers = {
        'Content-type': 'application/json',
        'Authorization': userSession.sessionToken
      };
      final res = await http.put(url, headers: headers, body: bodyParams);
      if(res.statusCode==401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, userSession.id);
      }
      final data=json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    }catch(ex){
      print('Error on updateToDispatch: $ex');
      return null;
    }
  }
  Future<ResponseApi> create(Order order) async{
    try{
      Uri url= Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(order);
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