import 'dart:convert';
import 'dart:io';

import 'package:delivery/src/models/response_api.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/provider/users_provider.dart';
import 'package:delivery/src/utils/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
class RegisterController{
  BuildContext context;
  TextEditingController emailController=new TextEditingController();
  TextEditingController nombresController=new TextEditingController();
  TextEditingController apellidosController=new TextEditingController();
  TextEditingController passwordController=new TextEditingController();
  TextEditingController validatePasswordController=new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  PickedFile pickedFile;
  File imageFile;
  Function refresh;
  UsersProvider usersProvider =  new UsersProvider();
  ProgressDialog _progressDialog;
  bool isEnable= true;

  Future init(BuildContext context, Function refresh){
    this.context=context;
    this.refresh = refresh;
    usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
  }
  // register a user
  void register() async{
    String email= emailController.text.trim();
    String nombres= nombresController.text;
    String apellidos= apellidosController.text;
    String password= passwordController.text.trim();
    String validatePassword = validatePasswordController.text.trim();
    String phone = phoneController.text.trim();

    if(email.isEmpty || nombres.isEmpty || apellidos.isEmpty || password.isEmpty || validatePassword.isEmpty || phone.isEmpty){
      MySnackbar.show(context, 'Debes ingresar todos los campos');
      return;
    }
    if(validatePassword!= password){
      MySnackbar.show(context, 'Las contraseñas no coinciden');
      return;
    }
    if(password.length<6){
      MySnackbar.show(context, 'La contraseña debe tener almenos 6 caracteres');
      return;
    }
    if(imageFile == null){
      MySnackbar.show(context, 'Selecciona una imagen');
      return;
    }
    // opening dialog
    _progressDialog.show(max: 100, msg: "Espere un momento...");
    // disable register button
    isEnable= false;
    // init user
    User user= new User(
      email: email,
      name: nombres,
      lastname: apellidos,
      password: password,
      phone: phone,
    );
    // create a user with an image
    Stream stream = await usersProvider.createWithImage(user, imageFile);
    stream.listen((res) {
      // closing dialog
      _progressDialog.close();

      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      MySnackbar.show(context, responseApi.message);
      if(responseApi.success){
        Future.delayed(Duration(seconds: 3),(){
          Navigator.pushReplacementNamed(context, 'login');
        });
      }else{
        // enable register button after failure
        isEnable = true;
      }
    });
  }
  // back button
  void back(){
    Navigator.pop(context);
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