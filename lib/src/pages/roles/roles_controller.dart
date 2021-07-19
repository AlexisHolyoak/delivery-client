import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
class RolesController{
  BuildContext context;
  User user;
  SharedPref sharedPref= new SharedPref();
  Function refresh;
  Future init(BuildContext context, refresh) async{
    this.context= context;
    this.refresh=refresh;
    //getting user from session
    user=User.fromJson(await sharedPref.read('user'));
    refresh();
  }
  void goToPage(String route){
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}