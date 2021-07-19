import 'package:delivery/src/models/role.dart';
import 'package:delivery/src/pages/roles/roles_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RolesPage extends StatefulWidget {
  @override
  _RolesPageState createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {

  RolesController _con = new RolesController();

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
        title: Text('Selecciona un rol'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.14),
        child: ListView(
          children: _con.user!=null? _con.user.roles.map((Role role){
            return _cardRole(role);
          }).toList() : [],
        ),
      ),
    );
  }
  Widget _cardRole(Role role){
    return GestureDetector(
      onTap: (){
        _con.goToPage(role.route);
      },
      child: Column(
         children: [
           Container(
             height: 100,
             child: FadeInImage(
               image: role.image!=null ? NetworkImage(role.image): AssetImage('assets/img/no-image.png'),
               fit: BoxFit.contain,
               fadeInDuration: Duration(milliseconds: 50),
               placeholder: AssetImage('assets/img/no-image.png'),
             ),
           ),
           SizedBox(height: 15,),
           Text(
             role.name?? '',
             style: TextStyle(
               fontSize: 16,
               color: Colors.black
             ),
           ),
           SizedBox(height: 15,),
         ],
      ),
    );
  }
  void refresh(){
    setState(() {

    });
  }
}
