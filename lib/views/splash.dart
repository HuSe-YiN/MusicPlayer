import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onlinemusic/main.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/library_page.dart';
import 'package:onlinemusic/views/state.dart';

import '../util/const.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String message = "İnternet bağlantınız  kontrol ediliyor";
  @override
  void initState() {
    super.initState();
    httpGet();
  }

  void httpGet() async {
    try {
      await HttpClientHelper.httpClient
          .get(Uri.parse("https://www.google.com.tr"));
      isConnectivity = true;
      message = "Bağlantı sağlandı, giriş yapılıyor";
      setState(() {});

      context.pushAndRemoveUntil(StateScreen());
    } on HandshakeException catch (e) {
      isConnectivity = false;
      message = "İnternet bağlantınızı kontrol ediniz!!";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // try {
    //   try {} catch (e) {}

    //   isConnectivity = true;

    //
    // } catch (e) {}

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              radius: 50,
              animating: true,
              color: Const.kPurple,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                color: Const.kPurple,
                
              ),
            ),
            SizedBox(
              height: 50,
            ),
            if (isConnectivity == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      backgroundColor: Const.kPurple.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.pushAndRemoveUntil(StateScreen());
                    },
                    child: Text(
                      "Misafir girişi",
                      style: TextStyle(
                        
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Const.kPurple,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      
                      setState(() {
                        isConnectivity=true;
                        message = "İnternet bağlantınız  kontrol ediliyor";
                        httpGet();
                      });
                    },
                    child: Text(
                      "Tekrar deneyin",
                      style: TextStyle(
                        
                        color: Const.kPurple,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
