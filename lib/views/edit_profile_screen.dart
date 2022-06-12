import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onlinemusic/models/usermodel.dart';
import 'package:onlinemusic/services/storage_bloc.dart';
import 'package:onlinemusic/services/user_status_service.dart';

class EditProfile extends StatefulWidget {
  final UserModel userModel;
  const EditProfile({Key? key, required this.userModel}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final ImagePicker _pickerImage = ImagePicker();
  XFile? profileImage;
  final StorageBloc storageService = StorageBloc();
  final UserStatusService statusService = UserStatusService();
  dynamic _pickImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userModel.userName ?? "";
    _bio.text = widget.userModel.bio ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profili düzenle"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  color: Colors.black,
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  hintText: 'Kullanıcı adı',
                  prefixText: ' ',
                  hintStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                initialValue: widget.userModel.email,
                readOnly: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Colors.black,
                  ),
                  hintText: 'E-Mail',
                  prefixText: ' ',
                  hintStyle: TextStyle(color: Colors.black),
                  focusColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                  maxLines: 5,
                  controller: _bio,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'Biografi',
                      prefixText: ' ',
                      hintStyle: TextStyle(color: Colors.black),
                      focusColor: Colors.black,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),),)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    UserModel userModel = widget.userModel;
                    if (profileImage != null) {
                      var mediaUrl = await storageService.uploadImage(
                        profileImage!.path,
                        _auth.currentUser!.uid,
                      );
                      userModel = userModel..image = mediaUrl;
                    }
                    userModel = userModel
                      ..userName = _nameController.text
                      ..bio = _bio.text;
                    statusService.updateProfile(userModel);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: Text(
                      "Bilgileri güncelle",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                          child: Text(
                        "Vazgeç",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  void _onImageButtonPressed(ImageSource source,
      {required BuildContext context}) async {
    try {
      final pickedFile = await _pickerImage.pickImage(source: source);
      setState(() {
        profileImage = pickedFile!;
        print("dosyaya geldim: $profileImage");
        if (profileImage != null) {}
      });
      print('aaa');
    } catch (e) {
      setState(() {
        _pickImage = e;
        print("Image Error: " + _pickImage);
      });
    }
  }
}
