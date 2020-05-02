import 'package:flutter/cupertino.dart';
import 'package:timetracker/common_widgets/custom_raised_button.dart';

class SignInButton extends CustomRaisedButton{
  SignInButton({
    @required String text,
    Color color,
    Color textcolor,
    VoidCallback onPressed,
}): assert(text!=null),
        super(
    child:Text(text,style: TextStyle(color: textcolor,fontSize: 15.0),),
    color:color,
    onPressed:onPressed,
  );
}