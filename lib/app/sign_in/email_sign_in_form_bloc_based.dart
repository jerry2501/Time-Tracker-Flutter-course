import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timetracker/app/sign_in/emai_sign_in_model.dart';
import 'package:timetracker/app/sign_in/email_sign_in_bloc.dart';
import 'package:timetracker/app/sign_in/validators.dart';
import 'package:timetracker/common_widgets/form_submit_button.dart';
import 'package:timetracker/common_widgets/platform_exception_alert_dialouge.dart';
import 'package:timetracker/services/auth.dart';

//enum EmailSignInFormType{signIn,register}

class EmailSignInFormBlocBased extends StatefulWidget  {
  EmailSignInFormBlocBased({@required this.bloc});
  final EmailSignInBloc bloc;

  static Widget create(BuildContext context){
    final AuthBase auth=Provider.of<AuthBase>(context);
    return Provider<EmailSignInBloc>(
      builder:(context)=>EmailSignInBloc(auth: auth),
      child: Consumer<EmailSignInBloc>(
        builder: (context,bloc,_)=>EmailSignInFormBlocBased(bloc: bloc),
      ),
      dispose: (context,bloc)=>bloc.dispose(),
    );
  }
  @override
  _EmailSignInFormBlocBasedState createState() => _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode=FocusNode();
  final FocusNode _passwordFocusNode =FocusNode();


  @override
  void dispose() { //dispose objects when page removed from widget tree
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordFocusNode.dispose();
    _passwordController.dispose();
    super.dispose();

  }
  Future<void> _submit() async{
    try {
      await widget.bloc.submit();
      Navigator.of(context).pop();
    }on PlatformException catch(e){
      PlatformExceptionAlertDialog(
        title: 'Sign in failed',
        exception: e,
      ).show(context);
    }
  }

  void _emailEditingComplete(EmailSignInModel model){
    final newFocus = model.emailValidator.isValid(model.email)?
    _passwordFocusNode: _emailFocusNode; //if email is not valid then focus will not change

    FocusScope.of(context).requestFocus(newFocus); //change focus of node ex. email-node to password-node
  }

  void _toggleFormType(){
    widget.bloc.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren(EmailSignInModel model){

    return [
      _buildEmailTextField(model),
      SizedBox(height: 8,),
      _buildPasswordTextField(model),
      SizedBox(height: 8,),
      FormSubmitButton(
        text:model.primaryButtonText,
        onPressed: model.canSubmit ? _submit : null,
      ),
      SizedBox(height: 8,),
      FlatButton(
        child: Text(model.secondaryButtonText),
        onPressed: !model.isLoading?()=>_toggleFormType():null, //disable button when we try to connect with firebase
      )
    ];
  }

  TextField _buildPasswordTextField(EmailSignInModel model) {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        enabled: model.isLoading == false, //enable or disable textfield
        errorText:model.passwordErrorText,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged:widget.bloc.updatePassword, //to Refresh Page to Enable button
      onEditingComplete: _submit, //called when we press next or done button onkeyboard
    );
  }

  TextField _buildEmailTextField(EmailSignInModel model) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
        labelText: 'Email',
        enabled: model.isLoading == false, //disable text field when we try to connect with firebase
        hintText: 'test@test.com',
        errorText: model.emailErrorText,
      ),
      autocorrect:false,
      keyboardType:TextInputType.emailAddress, //type of different keyboard
      textInputAction: TextInputAction.next,
      onChanged: widget.bloc.updateEmail, //to Refresh Page to Enable button
      onEditingComplete:()=> _emailEditingComplete(model), //called when we press next or done button onkeyboard
    );
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
      stream: widget.bloc.modelStream,
      initialData: EmailSignInModel(),
      builder:(context,snapshot) {
        final EmailSignInModel model=snapshot.data; //to use and update value of EmailSignInModel
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildren(model),
          ),
        );
      }
    );
  }

}
