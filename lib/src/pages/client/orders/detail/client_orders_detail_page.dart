import 'package:delivery/src/models/order.dart';
import 'package:delivery/src/models/product.dart';
import 'package:delivery/src/models/user.dart';
import 'package:delivery/src/pages/client/orders/detail/client_orders_detail_controller.dart';
import 'package:delivery/src/pages/delivery/orders/detail/delivery_orders_detail_controller.dart';
import 'package:delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_controller.dart';
import 'package:delivery/src/utils/my_colors.dart';
import 'package:delivery/src/utils/relative_time_util.dart';
import 'package:delivery/src/widgets/no_data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientOrdersDetailPage extends StatefulWidget {
  Order order;
  ClientOrdersDetailPage({Key key, @required this.order}) : super(key: key);

  @override
  _ClientOrdersDetailPageState createState() => _ClientOrdersDetailPageState();
}

class _ClientOrdersDetailPageState extends State<ClientOrdersDetailPage> {
  ClientOrdersDetailController _con=new ClientOrdersDetailController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${_con.order?.id??''}'),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 20, right: 10),
            child: Text('Total: S/.${_con.total}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height *0.45,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30, // margin right
                indent: 30, // margin left
              ),
              SizedBox(height: 10,),
              _textData('Repartidor:', '${ _con.order?.delivery?.name??'Sin asignar'} ${_con.order?.delivery?.lastname??''}'),
              _textData('Entregar en:', '${_con.order?.address?.address??''}'),
              _textData(
                  'Fecha del pedido:', '${RelativeTimeUtil.getRelativeTime(_con.order?.timestamp??0)}'),
              _con.order?.status != 'EN CAMINO'?_buttonShoppingBag(): Container()
            ],
          ),
        ),
      ),
      body:_con.order!=null? _con.order.products.length > 0 ? ListView(
        children: _con.order.products.map((Product product){
          return _cardProduct(product);
        })?.toList(),
      ): NoDataWidget(text: 'Ningun producto agregado',): []
    );
  }

  Widget _textData(String title, String content){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title),
        subtitle: Text(content,maxLines: 2,),
      )
    );
  }
  Widget _buttonShoppingBag(){
    return Container(
      margin:  EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 10),
      child: ElevatedButton(
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 5),
            primary: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                    'SEGUIR PEDIDO',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    )),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 70, top: 6),
                height: 25,
                child: Icon(Icons.directions_car, color: Colors.white,size: 25,),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cardProduct(Product product){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          _imageProduct(product),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?.name??'',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              Text(
                'Cantidad: ${product?.quantity??''}',
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _imageProduct(Product product){
    return    Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey[200]
      ),
      child: FadeInImage(
        image: product.image1!=null?
        NetworkImage(product.image1):
        AssetImage('assets/img/no-image.png'),
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 50),
        placeholder: AssetImage('assets/img/no-image.png'),
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}
