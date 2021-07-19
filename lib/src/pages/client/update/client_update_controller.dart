import 'dart:convert';
import 'dart:io';

import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/provider/users_provider.dart';
import 'package:delivery/src/utils/my_snackbar.dart';
import 'package:delivery/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
class ClientUpdateController{
  BuildContext context;
  TextEditingController nombresController=new TextEditingController();
  TextEditingController apellidosController=new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  PickedFile pickedFile;
  File imageFile;
  Function refresh;
  UsersProvider usersProvider =  new UsersProvider();
  ProgressDialog _progressDialog;
  bool isEnable= true;
  User user;
  SharedPref _sharedPref= new SharedPref();

  Future init(BuildContext context, Function refresh) async{
    this.context=context;
    this.refresh = refresh;
    _progressDialog = ProgressDialog(context: context);

    // init user
    user=User.fromJson(await _sharedPref.read('user'));
    usersProvider.init(context, sessionUser: user);

    // setting pre data
    nombresController.text = user.name;
    apellidosController.text = user.lastname;
    phoneController.text= user.phone;
    refresh();
  }
  // register a user
  void update() async{
    String nombres= nombresController.text;
    String apellidos= apellidosController.text;
    String phone = phoneController.text.trim();
    if(nombres.isEmpty || apellidos.isEmpty || phone.isEmpty){
      MySnackbar.show(context, 'Debes ingresar todos los campos');
      return;
    }
    // opening dialog
    _progressDialog.show(max: 100, msg: "Espere un momento...");
    // disable register button
    isEnable= false;
    // init user
    User myUser= new User(
      id: user.id,
      name: nombres,
      lastname: apellidos,
      phone: phone,
      image: user.image
    );
    // create a user with an image
    Stream stream = await usersProvider.update(myUser, imageFile);
    stream.listen((res) async{
      // closing dialog
      _progressDialog.close();
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      Fluttertoast.showToast(msg: responseApi.message);
      if(responseApi.success){
        // get the new user once updated
        user= await usersProvider.getById(myUser.id);
        // update shared preferences
        _sharedPref.save('user', user.toJson());
        Navigator.pushNamedAndRemoveUntil(context, 'client/products/list', (route) => false);
      }else{
        // enable register button after failure
        isEnable = true;
      }
    });
  }
  // select an image
  Future selectImage(ImageSource imageSource) async{
    pickedFile=await ImagePicker().getImage(source: imageSource);
    if(pickedFile!=null){
      imageFile = File(pickedFile.path);
    }
    Navigator.pop(context);
    refresh();
  }
  // show an alert dialog
  void showAlertDialog(){
    Widget galleryButton = ElevatedButton(
        onPressed: (){
          selectImage(ImageSource.gallery);
        },
        child: Text('GALERIA'));
    Widget cameraButton = ElevatedButton(
        onPressed: (){
          selectImage(ImageSource.camera);
        },
        child: Text('CAMARA'));
    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imágen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );
    showDialog(context: context, builder: (BuildContext context){
      return alertDialog;
    });
  }
}