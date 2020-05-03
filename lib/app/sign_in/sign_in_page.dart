import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timetracker/app/sign_in/email_sign_in_page.dart';
import 'package:timetracker/app/sign_in/sign_in_bloc.dart';
import 'package:timetracker/app/sign_in/sign_in_button.dart';
import 'package:timetracker/app/sign_in/social_sign_in_button.dart';
import 'package:timetracker/common_widgets/platform_exception_alert_dialouge.dart';
import 'package:timetracker/services/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key,@required this.bloc}) : super(key: key);
  final SignInBloc bloc;


   static Widget create(BuildContext context){
     final auth=Provider.of<AuthBase>(context);
     return Provider<SignInBloc>(
       builder: (_)=>SignInBloc(auth: auth),
       dispose: (context,bloc)=>bloc.dispose(), //it is used to dispose bloc when widget removed from widget tree
       child: Consumer<SignInBloc>(builder:(context,bloc,_)=> SignInPage(bloc: bloc,)), //to access bloc and pass it to constructor
     );
   }

void _showSignInError(BuildContext context,PlatformException exception){
  PlatformExceptionAlertDialog(   //Used two dart file Platform_exception_alert_dailog and platform_alert_dailog
    title: 'Sign in failed',
    exception: exception,
  ).show(context);
}

  Future<void> _signInAnonymously(BuildContext context) async{
    try {
      await bloc.SignInAnonymously();
    }on PlatformException catch(e){  // Used to show Manual error when PlatformException Occur
      _showSignInError(context, e);
    }
  }

 Future<void> _signInWithGoogle(BuildContext context) async{
   try {
     await bloc.signInWithGoogle();
   }on PlatformException catch(e){
     if(e.code!='ERROR_ABORTED_BY_USER'){
       _showSignInError(context, e);
     }
   }
 }

 Future<void> _signInWithFacebook(BuildContext context) async{
   try {
     await bloc.signInWithFacebook();
   }on PlatformException catch(e){
     if(e.code!='ERROR_ABORTED_BY_USER'){
       _showSignInError(context, e);
     }
   }
 }

 void _signInWithEmail(BuildContext context){
       Navigator.of(context).push(
         MaterialPageRoute<void>(
           fullscreenDialog: true, //screen comes through bottom
           builder: (context) => EmailSignInPage(),
         )
       );
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: StreamBuilder<bool>(
        stream: bloc.isLoadingStream,
        initialData: false,
        builder: (context,snapshot){ return  _buildContent(context,snapshot.data);},
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context,bool isLoading) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              height: 50,
              child: _buildHeader(isLoading),
          ),
          SizedBox(height: 48,),
          SocialSignInButton(
            assetName: 'images/google-logo.png',
           text: 'Sign in with Google',
            textcolor: Colors.black87,
            color: Colors.white,
            onPressed:isLoading?null:()=> _signInWithGoogle(context),
          ),
          SizedBox(height: 8,),
          SocialSignInButton(
            assetName: 'images/facebook-logo.png',
            text: 'Sign in with Facebook',
            textcolor: Colors.white,
            color: Color(0xFF334D92),
            onPressed:isLoading?null: ()=>_signInWithFacebook(context),
          ),
          SizedBox(height: 8,),
          SignInButton(
            text: 'Sign in with email',
            textcolor: Colors.white,
            color: Colors.teal[700],
            onPressed:isLoading?null:() => _signInWithEmail(context),
          ),
          SizedBox(height: 8,),
          Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8,),
          SignInButton(
            text: 'Go anonymous',
            textcolor: Colors.black,
            color: Colors.lime[300],
            onPressed:isLoading?null:()=> _signInAnonymously(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoading){
  if(isLoading){
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  return Text(
    "Sign in",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
  );
  }
}

