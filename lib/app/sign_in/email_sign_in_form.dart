import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timetracker/app/sign_in/validators.dart';
import 'package:timetracker/common_widgets/form_submit_button.dart';
import 'package:timetracker/common_widgets/platform_exception_alert_dialouge.dart';
import 'package:timetracker/services/auth.dart';

enum EmailSignInFormType{signIn,register}

class EmailSignInForm extends StatefulWidget with EmailAndPasswordValidators {

  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final FocusNode _emailFocusNode=FocusNode();
final FocusNode _passwordFocusNode =FocusNode();

String get _email=>_emailController.text;
String get _password=>_passwordController.text;
EmailSignInFormType _formType=EmailSignInFormType.signIn;
bool _submitted=false; //to not show error on Mobile initialy
bool _isLoading=false;

@override
  void dispose() { //dispose objects when page removed from widget tree
    // TODO: implement dispose
  _emailFocusNode.dispose();
  _emailController.dispose();
  _passwordFocusNode.dispose();
  _passwordController.dispose();
    super.dispose();

  }
  void _submit() async{
    setState(() {
      _submitted=true;
      _isLoading=true;
    });
    try {
      final auth=Provider.of<AuthBase>(context);
      await Future.delayed(Duration(seconds: 3));
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailAndPassword(_email, _password);
      }
      Navigator.of(context).pop();
    }on PlatformException catch(e){
      PlatformExceptionAlertDialog(
        title: 'Sign in failed',
        exception: e,
      ).show(context);

    }finally{
      setState(() {
        _isLoading=false;
      });
    }

  }

  void _emailEditingComplete(){
    final newFocus = widget.emailValidator.isValid(_email)?
    _passwordFocusNode: _emailFocusNode; //if email is not valid then focus will not change

    FocusScope.of(context).requestFocus(newFocus); //change focus of node ex. email-node to password-node
  }

  void _toggleFormType(){
    setState(() {
      _submitted=false; //to not show error Message on mobile when we toggle form
      _formType= _formType==EmailSignInFormType.signIn?
          EmailSignInFormType.register:
          EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren(){
    final primaryText = _formType == EmailSignInFormType.signIn ?
        'Sign in': 'Create an acount';
    final secondaryText = _formType == EmailSignInFormType.signIn ?
        'Need an account? Register' : 'Have an account? Sign in';
    bool submitEnabled= widget.emailValidator.isValid(_email) &&
            widget.passwordValidator.isValid(_password) && !_isLoading; //created different validators class to direct check different validations
    return [
      _buildEmailTextField(),
      SizedBox(height: 8,),
      _buildPasswordTextField(),
      SizedBox(height: 8,),
     FormSubmitButton(
        text:primaryText,
        onPressed: submitEnabled ? _submit : null,
      ),
      SizedBox(height: 8,),
      FlatButton(
        child: Text(secondaryText),
        onPressed: !_isLoading?_toggleFormType:null, //disable button when we try to connect with firebase
      )
    ];
  }

  TextField _buildPasswordTextField() {
    bool showErrorText= _submitted && !widget.passwordValidator.isValid(_password);
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        enabled: _isLoading == false, //enable or disable textfield
        errorText: showErrorText? widget.invalidPasswordErrorText : null,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (password)=>_updateState(), //to Refresh Page to Enable button
      onEditingComplete: _submit, //called when we press next or done button onkeyboard
    );
  }

  TextField _buildEmailTextField() {
    bool showErrorText=_submitted && !widget.emailValidator.isValid(_email);
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: 'Email',
        enabled: _isLoading == false, //disable text field when we try to connect with firebase
        hintText: 'test@test.com',
        errorText: showErrorText?widget.invalidEmailErrorText:null,
      ),
      autocorrect:false,
      keyboardType:TextInputType.emailAddress, //type of different keyboard
      textInputAction: TextInputAction.next,
      onChanged: (email)=>_updateState(), //to Refresh Page to Enable button
      onEditingComplete: _emailEditingComplete, //called when we press next or done button onkeyboard
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: _buildChildren(),
      ),
    );
  }
  _updateState(){
    setState(() {});
  }
}
