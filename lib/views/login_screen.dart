import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/services/auth.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/root_app.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.grey.shade400.withOpacity(0.1),
        child: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Welcome to the",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                    color: Colors.black)),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text("Music listening platform",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: Colors.black)),
                          ),
                          SizedBox(height: 30),
                          textFieldWidgets(
                            controller: _emailController,
                            hintText: "E-mail",
                            icon: Icons.mail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          textFieldWidgets(
                            controller: _passwordController,
                            hintText: "Password",
                            icon: Icons.lock,
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                          ),
                          SizedBox(
                            height: size.height * 0.08,
                          ),
                          InkWell(
                            onTap: () async {
                              User? user = await _authService.signIn(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (user != null) {
                                context.pushAndRemoveUntil(RootApp());
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.black),
                              ),
                              InkWell(
                                onTap: () {
                                  context.pushAndRemoveUntil(RegisterScreen());
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyDivider(),
                              Text(
                                "Or",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              MyDivider(),
                            ],
                          ),
                          TextButton(
                            child: Text(
                              "Sign in with Google",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              User? user = await _authService.signIn(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (user != null) {
                                context.pushAndRemoveUntil(RootApp());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Material textFieldWidgets({
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? icon,
    String? hintText,
    bool obscureText = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: TextField(
        cursorWidth: 1,
        obscureText: obscureText,
        obscuringCharacter: "•",

        controller: controller,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 18),
          suffixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          hintText: hintText,
          prefixText: '     ',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget MyDivider() {
    return Container(
      height: 2,
      margin: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      width: 30,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
