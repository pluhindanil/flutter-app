import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MenuTab extends StatefulWidget {
  @override
  _MenuTabState createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String avatarURL = '';
  User? user;
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  File? _projectImage;
  List<String> criteria = [];
  List<String> categories = [];
  String imageUrl = '';
  List<ProjectWidget> projects = [];

  // Sample values for Требуется and Категории
  List<String> sampleCriteria = ['Критерий 1', 'Критерий 2', 'Критерий 3'];
  List<String> sampleCategories = ['Категория 1', 'Категория 2', 'Категория 3'];

  List<ProjectWidget> myProjects = [];

  List<ProjectWidget> otherProjects = [];

  String username = ''; // Используйте значение по умолчанию

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    loadUserData().then((loadedUsername) async {
      if (loadedUsername != null) {
        setState(() {
          username = loadedUsername;
        });

        otherProjects.add(createSampleProject());

        // Загрузите "Мои проекты"
        await loadMyProjects();

        // Загрузите "Другие проекты"
        await loadOtherProjects();


      }
    });
  }

  Future<String?> loadUserData() async {
    final currentUserEmail = user?.email;

    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final userUsername = userData['username'];
      return userUsername;
    }
    return null; // Возвращаем null, если не удалось получить username.
  }

  ProjectWidget createSampleProject() {
    final projectName = 'Проект';
    final projectDescription = 'Описание проекта';
    final imageUrl = 'https://t3.ftcdn.net/jpg/05/16/27/58/240_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg'; // Установите URL изображения
    final criteria = ['Критерий 1', 'Критерий 2'];
    final categories = ['Категория 1', 'Категория 2'];
    final creator = 'Гений';
    ProjectWidget newProject;
    newProject = ProjectWidget(
      projectName: projectName,
      projectAvatarUrl: imageUrl,
      projectDescription: projectDescription,
      criteria: criteria,
      categories: categories,
      creator: creator,
      onDelete: () {},
    );
    return newProject;
  }



  Future<void> loadMyProjects() async {
    await loadUserData();

    final myProjectsSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('creator', isEqualTo: username)
        .get();

    if (mounted) { // Проверка, что виджет все еще существует
      for (var projectDoc in myProjectsSnapshot.docs) {
        final data = projectDoc.data();
        final projectWidget = ProjectWidget.fromData(data);
        setState(() {
          myProjects.add(projectWidget);
        });
      }
    }
  }

  Future<void> loadOtherProjects() async {
    await loadUserData();

    final otherProjectsSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('creator', isNotEqualTo: username)
        .get();

    for (var projectDoc in otherProjectsSnapshot.docs) {
      final data = projectDoc.data();
      final projectWidget = ProjectWidget.fromData(data);
      setState(() {
        otherProjects.add(projectWidget);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(avatarURL),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(width: 10.0),
                Text(
                  'Добро пожаловать, $username!',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'Ваши проекты',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Column(
            children: myProjects,
          ),
          ElevatedButton(
            onPressed: () {
              _showCreateProjectDialog();
            },
            child: Text('+'),
          ),
          SizedBox(height: 20.0),
          Text(
            'Другие проекты',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Column(
            children: otherProjects,
          ),
        ],
      ),
    );
  }


  Future<void> _showCreateProjectDialog() async {
    List<String> selectedCriteria = [];
    List<String> selectedCategories = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Создать проект'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                      if (pickedImage != null) {
                        setState(() {
                          _projectImage = File(pickedImage.path);
                        });
                      }
                    },
                    child: Text('Выбрать изображение'),
                  ),

                  TextField(
                    controller: _projectNameController,
                    decoration: InputDecoration(labelText: 'Название проекта'),
                  ),
                  TextField(
                    controller: _projectDescriptionController,
                    decoration: InputDecoration(labelText: 'Описание проекта'),
                  ),
                  Row(
                    children: [
                      Text('Требуется: '),
                      for (var criterion in selectedCriteria)
                        Chip(
                          label: Text(criterion),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          _showCriteriaCategoryDialog(
                            'Требуется',
                            selectedCriteria,
                            sampleCriteria,
                                (selectedValues) {
                              setState(() {
                                selectedCriteria = selectedValues;
                              });
                            },
                          );
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Категории: '),
                      for (var category in selectedCategories)
                        Chip(
                          label: Text(category),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          _showCriteriaCategoryDialog(
                            'Категории',
                            selectedCategories,
                            sampleCategories,
                                (selectedValues) {
                              setState(() {
                                selectedCategories = selectedValues;
                              });
                            },
                          );
                        },
                        child: Text('+'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      criteria = selectedCriteria;
                      categories = selectedCategories;
                      if (_projectImage != null) {
                        final storageRef = FirebaseStorage.instance.ref().child('project_avatar/${DateTime.now()}.jpg');
                        await storageRef.putFile(_projectImage!);

                        // Получите URL загруженного изображения
                        imageUrl = await storageRef.getDownloadURL();
                      }
                      createProject(_projectNameController.text, _projectDescriptionController.text, imageUrl, criteria, categories);
                      Navigator.of(context).pop();
                    },
                    child: Text('Создать проект'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCriteriaCategoryDialog(
      String title,
      List<String> selectedValues,
      List<String> allValues,
      Function(List<String>) onSelected,
      ) async {
    List<String> tempSelectedValues = List.from(selectedValues);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var value in allValues)
                Row(
                  children: [
                    Text(value),
                    Spacer(),
                    Checkbox(
                      value: tempSelectedValues.contains(value),
                      onChanged: (bool? newValue) {
                        if (newValue != null && newValue) {
                          tempSelectedValues.add(value);
                        } else {
                          tempSelectedValues.remove(value);
                        }
                        onSelected(tempSelectedValues);
                      },
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  onSelected(tempSelectedValues);
                  Navigator.of(context).pop();
                },
                child: Text('Готово'),
              ),
            ],
          ),
        );
      },
    );
  }


  void createProject(String projectName, String projectDescription, String imageUrl, List<String> criteria, List<String> categories) {
    // Add the created project to the list and display it
    ProjectWidget? newProject;
    newProject = ProjectWidget(
        projectName: projectName,
        projectAvatarUrl: imageUrl,
        projectDescription: projectDescription,
        criteria: criteria,
        categories: categories,
        creator: username,
        onDelete: () {
          // Удаление проекта из списка и Firestore по имени
          deleteProjectByName(projectName);
          setState(() {
            projects.remove(newProject);
            myProjects.remove(newProject); // Удалите из myProjects
          });
        });
    setState(() {
      projects.add(newProject!);
      myProjects.add(newProject); // Добавьте в myProjects
    });

    FirebaseFirestore.instance.collection('projects').add({
      'name': projectName,
      'description': projectDescription,
      'criteria': criteria,
      'avatarUrl': imageUrl,
      'categories': categories,
      'creator': username,
    });
  }

  void deleteProjectByName(String projectName) {
    // Удаление проекта из Firestore по имени
    FirebaseFirestore.instance.collection('projects').where('name', isEqualTo: projectName).get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference.delete();
      });

    });
  }




}

class ProjectWidget extends StatefulWidget {
  final String projectName;
  final String projectDescription;
  final String projectAvatarUrl;
  final List<String> criteria;
  final List<String> categories;
  final String creator;
  final VoidCallback onDelete;

  ProjectWidget({
    required this.projectName,
    required this.projectDescription,
    required this.criteria,
    required this.categories,
    required this.projectAvatarUrl,
    required this.creator,
    required this.onDelete,
  });

  static ProjectWidget fromData(Map<String, dynamic> data) {
    return ProjectWidget(
      projectName: data['name'],
      projectDescription: data['description'],
      projectAvatarUrl: data['avatarUrl'],
      criteria: List<String>.from(data['criteria']),
      categories: List<String>.from(data['categories']),
      creator: data['creator'],
      onDelete: () {},
    );
  }

  @override
  _ProjectWidgetState createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  bool isCurrentUserProject = false; // Флаг, указывающий, является ли пользователь создателем проекта
  String? username;

  @override
  void initState() {
    super.initState();

    loadUserData().then((loadedUsername) {
      if (loadedUsername != null && widget.creator == loadedUsername) {
        setState(() {
          isCurrentUserProject = true;
          username = loadedUsername;
        });
      }
    });
  }

  Future<String?> loadUserData() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserEmail).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final userUsername = userData['username'];
        return userUsername;
      }
    }

    return null; // Возвращаем null, если не удалось получить username.
  }

  Future<void> _submitApplication(String projectName, String skills, String experience, String telegram) async {

    final currentUserEmail = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('applications').add({
      'projectName': projectName,
      'applicantEmail': currentUserEmail,
      'skills': skills,
      'experience': experience,
      'telegram': telegram,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  Future<void> _showCreateApplicationDialog(String projectName) async {
    String skills = '';
    String experience = '';
    String telegram = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подать заявку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  skills = value;
                },
                decoration: InputDecoration(labelText: 'Навыки'),
              ),
              TextField(
                onChanged: (value) {
                  experience = value;
                },
                decoration: InputDecoration(labelText: 'Опыт работы'),
              ),
              TextField(
                onChanged: (value) {
                  telegram = value;
                },
                decoration: InputDecoration(labelText: 'Телеграмм'),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitApplication(projectName, skills, experience, telegram);
                  Navigator.of(context).pop();
                },
                child: Text('Отправить заявку'),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage: NetworkImage(widget.projectAvatarUrl),
            backgroundColor: Colors.transparent,
          ),
          Text('Creator: ${widget.creator}'),
          ListTile(
            title: Text(widget.projectName),
            subtitle: Text(widget.projectDescription),
          ),
          Row(
            children: [
              Text('Требуется: '),
              for (var criterion in widget.criteria)
                Chip(
                  label: Text(criterion),
                ),
            ],
          ),
          Row(
            children: [
              Text('Категории: '),
              for (var category in widget.categories)
                Chip(
                  label: Text(category),
                ),
            ],
          ),
          if (!isCurrentUserProject)
            ElevatedButton(
              onPressed: () {
                _showCreateApplicationDialog(widget.projectName);
              },
              child: Text('Подать заявку'),
            ),
          if (isCurrentUserProject)
            ElevatedButton(
              onPressed: widget.onDelete,
              child: Text('Удалить'),
            ),
        ],
      ),
    );
  }
}
