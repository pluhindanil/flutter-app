import 'package:flutter/cupertino.dart';
import 'package:untitled2/pages/login_page.dart';
import 'package:untitled2/pages/sign_up_page.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
  }

  class _LoginAndSignUpState extends State<LoginAndSignUp>{

  bool islogin = true;

  void togglePage(){
    setState(() {
      islogin=!islogin;
    });
  }

  @override
    Widget build(BuildContext context){
    if(islogin){
      return LoginPage(
        onPressed: togglePage,
      );
    }else{
      return SignUp(
        onPressed: togglePage,
      );
    }
  }
  }