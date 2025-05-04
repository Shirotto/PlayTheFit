import 'package:flutter/material.dart';

import '../Components/Heading.dart';
import '../Components/card_button.dart';
import '../Components/custom_container.dart';
import '../Components/social_media_icons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool signup=true;
  TextEditingController name=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container()),
            Expanded(
                flex: 11,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration:  BoxDecoration(
                      color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30,),
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: Heading(signup: signup),
                      ),
                      const SizedBox(height: 20,),
                      const SocialMediaIcons(),
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          "Qui non so se ci scriviamo qualcosa",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(child: Center(child: CustomContainer(signup: signup,
                        email: email,
                        password: password,
                        name: name,
                      ),)),
                      const SizedBox(height: 20,),
                      signup ? const CardButton(txt: "Registrati") : const CardButton(txt: "Login"),
                      const SizedBox(height: 20,),
                      GestureDetector(
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                signup ? "Hai già un account?" : "Non hai un account?",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                signup ? "Login" : "Registrati",
                                style: const TextStyle(color: Colors.blue),
                              ),
                              // -----------------------------
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,)
                    ],
                  ),
                )
            ),
            Expanded(
                flex: 1,
                child: Container())
          ],
        ),
      ),
    );
  }

void onTap() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupPage()),
  );
}


/*  onTap(){
    signup=!signup;
    setState((){});
  } */

}
