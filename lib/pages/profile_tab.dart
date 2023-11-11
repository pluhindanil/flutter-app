import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  User? user;
  String username = '';
  String avatarURL = '';

  TextEditingController aboutMeController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Получить текущего пользователя
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Получить username из Firestore при загрузке страницы
      FirebaseFirestore.instance.collection('users').doc(user!.email).get().then((documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final userUsername = data['username'];
          final userAvatar = data['image'];

          setState(() {
            username = userUsername;
            avatarURL = userAvatar;
          });
        }
      });

      // Запрос данных профиля из Firestore и отображение в текстовых полях
      if (user != null && user?.email != null) {
        _firestore.collection('about_user').doc(user?.email!).get().then((documentSnapshot) {
          if (documentSnapshot.exists) {
            final data = documentSnapshot.data() as Map<String, dynamic>;
            aboutMeController.text = data['aboutMe'];
            skillsController.text = data['skills'];
            experienceController.text = data['experience'];
          }
        });
      } else {
        // Handle the case where 'user' or 'user.email' is null
        print('User or user email is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'No email';

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _showAvatarOptions();
            },
            child: CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage(avatarURL),
              backgroundColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 20.0),
          Text('Email: $email', style: TextStyle(fontSize: 18.0)),
          Text('Username: $username', style: TextStyle(fontSize: 18.0)),
          if (aboutMeController.text.isNotEmpty) Text('О себе: ${aboutMeController.text}',style: TextStyle(fontSize: 18.0)),
          if (skillsController.text.isNotEmpty) Text('Навыки: ${skillsController.text}',style: TextStyle(fontSize: 18.0)),
          if (experienceController.text.isNotEmpty) Text('Опыт: ${experienceController.text}',style: TextStyle(fontSize: 18.0)),
          ElevatedButton(
            onPressed: _showProfileDialog,
            child: Text('Заполнить профиль'),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, () {
                    _showProfileDialog();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, () {
                    _showProfileDialog();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, Function afterImageSelected) async {
    final imageFile = await _imagePicker.pickImage(source: source);

    if (imageFile != null) {
      final storage = FirebaseStorage.instance;
      final user = _auth.currentUser;

      if (user != null) {
        final ref = storage.ref().child('avatars/${user.uid}.jpg');
        await ref.putFile(File(imageFile.path));

        final downloadURL = await ref.getDownloadURL();

        setState(() {
          avatarURL = downloadURL;
        });

        // Сохраните ссылку на аватарку в Firestore в коллекции users
        await _firestore.collection('users').doc(user.email).update({
          'image': downloadURL,
        });

        afterImageSelected();
      }
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF11FFE2), // Цвет фона
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: aboutMeController,
                    decoration: InputDecoration(labelText: 'О себе'),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: skillsController,
                    decoration: InputDecoration(labelText: 'Навыки'),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: experienceController,
                    decoration: InputDecoration(labelText: 'Опыт'),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Отмена',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFBE9DE8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _saveProfileData();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Сохранить',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFBE9DE8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveProfileData() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('about_user').doc(user.email).set({
        'aboutMe': aboutMeController.text,
        'skills': skillsController.text,
        'experience': experienceController.text,
      });
    }
  }
}
