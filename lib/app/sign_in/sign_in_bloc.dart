import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:timetracker/services/auth.dart';

class SignInBloc{
  SignInBloc({@required this.auth});

  final AuthBase auth;
  final StreamController<bool> _isLoadingController=StreamController<bool>();


  Stream<bool> get isLoadingStream => _isLoadingController.stream; //getter method to take value from stream controller

  void dispose(){
    _isLoadingController.close();
  }

  void _setIsLoading(bool isLoading)=> _isLoadingController.add(isLoading);

  Future<User> _signIn(Future<User> Function() signInMethod) async{
    try{
      _setIsLoading(true);
      return await signInMethod();
    }catch(e){
      _setIsLoading(false);
      rethrow;
    }
  }

  Future<User> SignInAnonymously() async=>await _signIn(auth.SignInAnonymously);
  Future<User> signInWithGoogle() async =>await _signIn(auth.signInWithGoogle);
  Future<User> signInWithFacebook() async=>await _signIn(auth.signInWithFacebook);
}