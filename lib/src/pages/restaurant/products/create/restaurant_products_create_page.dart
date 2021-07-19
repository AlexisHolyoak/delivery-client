import 'dart:io';

import 'package:delivery/src/models/category.dart';
import 'package:delivery/src/pages/restaurant/categories/create/restaurant_categories_create_controller.dart';
import 'package:delivery/src/pages/restaurant/products/create/restaurant_products_create_controller.dart';
import 'package:delivery/src/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RestaurantProductsCreatePage extends StatefulWidget {
  @override
  _RestaurantProductsCreatePageState createState() => _RestaurantProductsCreatePageState();
}

class _RestaurantProductsCreatePageState extends State<RestaurantProductsCreatePage> {
  RestaurantProductsCreateController _con = new RestaurantProductsCreateController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo producto'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30,),
              _textFieldName(),
              _textFieldDescription(),
              _textFieldPrice(),
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardImage(_con.imageFile1, 1),
                    _cardImage(_con.imageFile2, 2),
                    _cardImage(_con.imageFile3, 3)
                  ],
                ),
              ),
              _dropDownCategories(_con.categories)
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buttonCreateProduct(),
    );
  }
  Widget _textFieldName(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOppacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.nameController,
        decoration: InputDecoration(
            hintText: 'Nombre del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.local_pizza,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }

  Widget _textFieldPrice(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOppacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        controller: _con.priceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            hintText: 'Precio del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.monetization_on,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }
  Widget _textFieldDescription(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: MyColors.primaryOppacityColor,
          borderRadius: BorderRadius.circular(30)
      ),
      child: TextField(
        maxLines:  3,
        maxLength: 255,
        controller: _con.descriptionController,
        decoration: InputDecoration(
            hintText: 'Descripción del producto',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(
                color: MyColors.primaryColorDark
            ),
            suffixIcon: Icon(
                Icons.description,
                color: MyColors.primaryColor
            )
        ),
      ),
    );
  }
  Widget _buttonCreateProduct(){
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: ElevatedButton(
        onPressed: _con.createProduct,
        child: Text('REGISTRAR'),
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
            ),
            padding: EdgeInsets.symmetric(vertical: 15)
        ),
      ),
    );
  }
  Widget _cardImage(File imageFile, int numberFile){
    return GestureDetector(
      onTap: (){
        _con.showAlertDialog(numberFile);
      },
      child: imageFile != null ? Card(
        elevation: 3.0,
        child: Container(
          height: 140,
          width: MediaQuery.of(context).size.width*0.26,
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
          ),
        ),
      ):Card(
        elevation: 3.0,
        child: Container(
          height: 140,
          width: MediaQuery.of(context).size.width*0.26,
          child: Image(
          image: AssetImage('assets/img/add_image.png'),
        )
        ),
      ),
    );
  }
  Widget _dropDownCategories(List<Category> categories){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 33),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                      Icons.search,
                      color:MyColors.primaryColor
                  ),
                  SizedBox(width: 15,),
                  Text('Categorias',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14
                  )),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton(
                  underline: Container(
                      alignment:  Alignment.centerRight,
                      child:Icon(
                        Icons.arrow_drop_down_circle,
                        color:MyColors.primaryColor)
                  ),
                  elevation: 3,
                  isExpanded: true,
                  items: _dropDownItems(categories),
                  hint: Text('Selecciona categoria',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16
                    ),
                  ),

                  value: _con.idCategory,
                  onChanged: (option){
                    setState((){
                      _con.idCategory=option; // setting id category
                    });
                  }
                )
              )
            ],
          ),
        ),
      ),
    );
  }
  List<DropdownMenuItem<String>> _dropDownItems(List<Category> categories){
    List<DropdownMenuItem<String>> list =[];
    categories.forEach((category){
      list.add(DropdownMenuItem(
        child: Text(category.name),
        value: category.id,
      ));
    });
    return list;
  }
  void refresh(){
    setState(() {
    });
  }
}
