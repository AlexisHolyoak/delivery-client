import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/provider/categories_provider.dart';
import 'package:delivery/src/utils/my_snackbar.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
class RestaurantCategoriesCreateController{
  BuildContext context;
  Function refresh;

  TextEditingController categoryNameController= new TextEditingController();
  TextEditingController descriptionController= new TextEditingController();
  CategoriesProvider _categoriesProvider= new CategoriesProvider();
  User user;
  SharedPref _sharedPref= new SharedPref();
  Future init(BuildContext context, Function refresh) async{
    this.context= context;
    this.refresh= refresh;
    user= User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, user);
  }
  void createCategory() async{
    String name = categoryNameController.text;
    String description = descriptionController.text;
    if(name.isEmpty || description.isEmpty){
      MySnackbar.show(context, 'Debe ingresar todos los campos');
      return;
    }
    Category category= new Category(
      name: name,
      description: description
    );

    ResponseApi responseApi = await _categoriesProvider.create(category);
    MySnackbar.show(context, responseApi.message);
    if(responseApi.success){
      categoryNameController.text='';
      descriptionController.text='';
    }
  }
}