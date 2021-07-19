import 'package:delivery/src/models/address.dart';
import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/provider/address_provider.dart';
import 'package:delivery/src/provider/orders_provider.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ClientAddressListController{
  BuildContext context;
  Function refresh;

  List<Address> address= [];
  AddressProvider _addressProvider = new AddressProvider();
  User user;
  SharedPref _sharedPref = new SharedPref();

  int radioValue=0;
  bool isCreated;
  OrdersProvider _ordersProvider = new OrdersProvider();
  Future init(BuildContext context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;

    user =User.fromJson(await _sharedPref.read('user'));

    _addressProvider.init(context, user);
    _ordersProvider.init(context, user);
    refresh();
  }
  Future<List<Address>> getAddress() async{
    address=await _addressProvider.getByUser(user.id);
    Address a = Address.fromJson( await _sharedPref.read('address') ?? {});
    int index = address.indexWhere((ad) => ad.id ==a.id);
    if(index!=-1){
      radioValue = index;
    }
    print('Nueva dirección: ${a.toJson()}');
    return address;
  }
  void createOrder() async{
    Address a = Address.fromJson( await _sharedPref.read('address') ?? {});
    List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order')).toList;
    Order order = new Order(
      idClient: user.id,
      idAddress: a.id,
      products:selectedProducts
    );
    ResponseApi responseApi= await _ordersProvider.create(order);
    Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
    Navigator.pushNamedAndRemoveUntil(context, 'client/products/list', (route) => false);
  }
  void handleRadioValueChange(int value) async{
    radioValue = value;
    _sharedPref.save('address', address[value]);

    refresh();
    print('seleccionado $radioValue' );
  }
  void goToNewAddress() async{
    var result = await Navigator.pushNamed(context, 'client/address/create');

    if(result!=null){
      if(result){
        refresh();
      }
    }
  }
}