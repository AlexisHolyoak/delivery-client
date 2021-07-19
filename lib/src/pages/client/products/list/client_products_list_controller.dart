import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:delivery/src/provider/categories_provider.dart';
import 'package:delivery/src/provider/products_provider.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
class ClientProductsListController{
  BuildContext context;
  SharedPref _sharedPref= new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  User user;
  Function refresh;
  List<Category> categories =[];
  CategoriesProvider _categoriesProvider= new CategoriesProvider();
  ProductsProvider _productsProvider = new ProductsProvider();
  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh = refresh;
    user=User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, user);
    _productsProvider.init(context, user);
    getCategories();
    refresh();
  }
  Future<List<Product>> getProducts(String idCategory) async{
    return await _productsProvider.getByCategory(idCategory);
  }
  void getCategories() async{
  categories=await _categoriesProvider.getAll();
  refresh();
  }
  void openBottomSheet(Product product){
    showMaterialModalBottomSheet(
        context: context,
        builder: (context)=> ClientProductsDetailPage(product: product)
    );
  }
  void logout(){
    _sharedPref.logout(context, user.id);
  }
  void openDrawer(){
    key.currentState.openDrawer();
  }
  void goToUpdatePage(){
    Navigator.pushNamed(context, 'client/update');
  }
  void goToOrderCreatePage(){
    Navigator.pushNamed(context, 'client/orders/create');
  }
  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }
}