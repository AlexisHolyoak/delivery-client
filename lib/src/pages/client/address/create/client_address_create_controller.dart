import 'package:delivery/src/models/address.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/pages/client/address/map/client_address_map_page.dart';
import 'package:delivery/src/provider/address_provider.dart';
import 'package:delivery/src/utils/my_snackbar.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
class ClientAddressCreateController{
  BuildContext context;
  Function refresh;
  TextEditingController referenceController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController neighborhoodController = new TextEditingController();
  Map<String, dynamic> referencePoint;
  AddressProvider _addressProvider = new AddressProvider();
  SharedPref _sharedPref = new SharedPref();
  User user;
  Future init(BuildContext context, Function refresh) async{
    this.context = context;
    this.refresh = refresh;
    user=User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, user);
    refresh();
  }
  void createAddress() async{
    String address=addressController.text;
    String neighborhood = neighborhoodController.text;
    double lat = referencePoint['lat'] ?? 0;
    double lng = referencePoint['lng'] ?? 0;
    if(address.isEmpty || neighborhood.isEmpty || lat==0 || lng ==0){
      MySnackbar.show(context, 'Completa todos los campos');
      return;
    }
    Address myAddress = new Address(
      address: address,
      neighborhood: neighborhood,
      lat: lat,
      lng: lng,
      idUser: user.id
    );

    ResponseApi responseApi = await _addressProvider.create(myAddress);
    if(responseApi.success){
      myAddress.id = responseApi.data;
      _sharedPref.save('address',myAddress);
      Fluttertoast.showToast(msg: responseApi.message);
      Navigator.pop(context, true);
    }
  }
  void openMap() async{
    referencePoint= await showMaterialModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context)=>ClientAddressMapPage()
    );
    if(referencePoint!=null){
      referenceController.text = referencePoint['address'];
      refresh();
    }
  }
}