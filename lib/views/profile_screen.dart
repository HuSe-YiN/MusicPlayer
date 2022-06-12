import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinemusic/util/const.dart';
import 'package:onlinemusic/util/extensions.dart';
import 'package:onlinemusic/views/edit_profile_screen.dart';
import '../models/usermodel.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  

  
 
  XFile? profileImage;
  dynamic _pickImage;

  
  Widget imagePlace() {
    if (widget.userModel.image != null) {
      setState(() {
        _pickImage = widget.userModel.image;
      });
    }
    if (profileImage != null) {
      print("resim : " + profileImage!.path);
      return CircleAvatar(
          backgroundImage: FileImage(File(profileImage!.path)), radius: 80);
    } else {
      if (_pickImage != null) {
        return CircleAvatar(
          backgroundImage: NetworkImage(_pickImage),
          radius: 80,
        );
      } else
        return CircleAvatar(
          maxRadius: 80,
          child: Icon(Icons.supervised_user_circle_outlined),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
        iconTheme: IconThemeData(
          color: Const.kPurple,
        ),
        actions: [
          IconButton(onPressed: () async{
           await context.push(EditProfile(userModel: widget.userModel));
           setState(() {
             
           });
          }, icon: Icon(Icons.mode_edit_outlined))
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Const.kPurple.withOpacity(0.25),
                    offset: Offset(0, 7),
                    blurRadius: 12,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                )),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  imagePlace(),
                  SizedBox(height: 30),
                  Text(
                    widget.userModel.userName ?? "",
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      "    " +
                          (widget.userModel.bio ??
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    widget.userModel.email ?? "",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Const.kPurple.withOpacity(0.4),
            endIndent: 30,
            indent: 30,
          ),
          listTileWidget(
            title: "Arkadaşlarınız",
            leadingIcon: Icons.groups_outlined,
          ),
          listTileWidget(
            title: "Yüklenen müzikler",
            leadingIcon: Icons.music_note_rounded,
          ),
          listTileWidget(
            title: "Bildirimler",
            leadingIcon: Icons.notifications_none_rounded,
          ),
          listTileWidget(
            title: "Engellenen kullanıcılar",
            leadingIcon: Icons.person_off_outlined,
          ),
          listTileWidget(
            title: "Güvenlik",
            leadingIcon: Icons.security_rounded,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 28),
            leading: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-pi),
                child: Icon(
                  Icons.logout_rounded,
                  size: 30,
                  color: Colors.redAccent,
                )),
            title: Text(
              "Çıkış yap",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  ListTile listTileWidget({
    required String title,
    required IconData leadingIcon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 28),
      leading: Icon(leadingIcon, color: Const.kPurple.withOpacity(0.4)),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Const.kPurple),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Const.kPurple.withOpacity(0.4),
      ),
    );
  }
}



