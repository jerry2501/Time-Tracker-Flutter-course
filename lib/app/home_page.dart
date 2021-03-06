import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timetracker/common_widgets/platform_alert_dialog.dart';
import 'package:timetracker/services/auth.dart';
class HomePage extends StatelessWidget {

  Future<void> _signOut(BuildContext context) async{
    try {
      final auth=Provider.of<AuthBase>(context);
      await auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async{
   final didRequestSignOut= await PlatformAlertDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    ).show(context);
   if(didRequestSignOut==true){
     _signOut(context);
   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout',style: TextStyle(fontSize: 18,color: Colors.white),),
            onPressed: (){
              _confirmSignOut(context);
            },
          ),
        ],
      ),
    );
  }
}
