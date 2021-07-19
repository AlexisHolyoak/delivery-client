import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_page.dart';
import 'package:delivery/src/provider/orders_provider.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
class DeliveryOrdersListController{
  BuildContext context;
  SharedPref _sharedPref= new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  User user;
  Function refresh;
  List<String> status=['DESPACHADO','EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  bool isUpdate = false;
  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh = refresh;
    user=User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, user);
    refresh();
  }
  Future<List<Order>> getOrders(String status) async{
    return await _ordersProvider.getByDelivery(user.id,status);
  }
  void openBottomSheet(Order order) async{
    isUpdate = await showMaterialModalBottomSheet(
        context: context,
        builder: (context)=> DeliveryOrdersDetailPage(order: order)
    );
    if(isUpdate){
      refresh();
    }
  }
  void logout(){
    _sharedPref.logout(context, user.id);
  }
  void openDrawer(){
    key.currentState.openDrawer();
  }
  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }
  void goToCategories(){
    Navigator.pushNamed(context, 'restaurant/categories/create');
  }
  void goToProductsCreate(){
    Navigator.pushNamed(context, 'restaurant/products/create');
  }
}