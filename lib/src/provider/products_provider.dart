

import 'dart:convert';
import 'dart:io';

import 'package:delivery/src/api/environment.dart';
import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
class ProductsProvider{
  String _url = Environment.API_DELIVERY;
  String _api='/api/products';
  BuildContext context;
  User userSession;
  Future init (BuildContext context, User userSession){
    this.userSession = userSession;
    this.context=context;
  }
  Future<List<Product>> getByCategory(String idCategory) async{
    try{
      Uri url= Uri.http(_url, '$_api/findByCategory/$idCategory');
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
      Product product = Product.fromJsonList(data);
      return product.toList;
    }catch(ex){
      print('Error on getAll categories: $ex');
      return [];
    }
  }
  Future<Stream> create(Product product, List<File> images) async{
    try{
      Uri url= Uri.http(_url, '$_api/create');
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = userSession.sessionToken;
      for(int i=0; i<images.length; i++){
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(images[i].openRead().cast()),
            await images[i].length(),
            filename: basename(images[i].path)
        ));
      }
      // TODO: fix this error
      request.fields['product']=json.encode(product);
      final response = await request.send(); //Sending petition

      return response.stream.transform(utf8.decoder);

    }catch(ex){
      print('Error $ex');
      return null;
    }
  }
}