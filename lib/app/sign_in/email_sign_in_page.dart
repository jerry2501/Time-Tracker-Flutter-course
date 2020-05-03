import 'package:flutter/material.dart';
import 'package:timetracker/app/sign_in/email_sign_in_form_bloc_based.dart';
class EmailSignInPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SingleChildScrollView( //it will not show bottom pixels overflow error
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
              child: EmailSignInFormBlocBased.create(context),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

}
