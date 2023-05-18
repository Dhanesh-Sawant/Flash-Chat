import 'package:flash_chat/login_screen.dart';
import 'package:flash_chat/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'reusable_button.dart';


class WelcomeScreen extends StatefulWidget {

  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}



class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation animation;


  @override
  void initState() {
    super.initState();
    
    controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
    );

    controller.forward();

    // animation  = CurvedAnimation(parent: controller, curve: Curves.decelerate );
    //
    // animation.addStatusListener((status) {
    //   if(status == AnimationStatus.completed){
    //     controller.reverse(from: 1);
    //   }
    //   else if(status == AnimationStatus.dismissed){
    //     controller.forward();
    //   }
    // });

    animation = ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);

    controller.addListener(() {
      setState(() {});
    }
    );

  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    child: Image.asset('images/logo.png'),
                  height: 60,
                ),

                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 43,
                    fontFamily: 'Agne',
                    color: Colors.grey,
                    fontWeight: FontWeight.w900
                  ),
                  child:
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('Flash Chat')
                    ]
                  ),

                ),
              ],
            ),

            SizedBox(
              height: 48.0,
            ),

            ReusableButton(
              colour: Colors.lightBlueAccent,
              buttonText: 'Log in',
              onPressed: (){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(context, LoginScreen.id);
                });

              }
            ),

            ReusableButton(
                colour: Colors.blueAccent,
                buttonText: 'Register',
                onPressed: (){
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  });
                }
            )

          ],
        ),
      ),
    );
  }
}



