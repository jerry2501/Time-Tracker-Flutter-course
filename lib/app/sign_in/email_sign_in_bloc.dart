
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:timetracker/app/sign_in/emai_sign_in_model.dart';
import 'package:timetracker/services/auth.dart';

class EmailSignInBloc{
  EmailSignInBloc({@required this.auth});
  final AuthBase auth;
  final StreamController<EmailSignInModel> _modelController=StreamController<EmailSignInModel>();


  Stream<EmailSignInModel> get modelStream =>_modelController.stream;
   EmailSignInModel _model=EmailSignInModel();

  void dispose(){
    _modelController.close();
  }

  void toggleFormType(){
    updateWith(
      email: '',
      password: '',
      formType: _model.formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn,
      isLoading: false,
      submitted: false,
    );
  }

  void updateEmail(String email)=>updateWith(email: email);

  void updatePassword(String password)=>updateWith(password: password);

  void updateWith({
  String email,
  String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
}){
    //update model
    _model=_model.copywith(
      email: email,
      password: password,
      formType: formType,
      isLoading: isLoading,
      submitted: submitted
    );
    //add updated model to _modelcontroller
      _modelController.add(_model);
  }

  Future<void> submit() async{
    updateWith(submitted: true,isLoading: true);
    try {
      await Future.delayed(Duration(seconds: 3));
      if (_model.formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_model.email, _model.password);
      } else {
        await auth.createUserWithEmailAndPassword(_model.email, _model.password);
      }
    }catch(e){
      updateWith(isLoading: false);
      rethrow;
    }
  }
}