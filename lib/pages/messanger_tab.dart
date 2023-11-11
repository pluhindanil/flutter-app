import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessengerTab extends StatefulWidget {
  @override
  _MessengerTabState createState() => _MessengerTabState();
}

class _MessengerTabState extends State<MessengerTab> {
  List<Application> testApplications = [];

  @override
  void initState() {
    super.initState();

    // Создайте тестовую заявку и добавьте ее в список
    final testApplication = Application(
      skills: 'Тута навыки',
      experience: 'А тут опыт работы',
      telegram: 'Типо  Телеграм',
    );


    testApplications.add(testApplication);
  }

  Future<void> fetchApplications() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Applications')
          .get();

      final applications = querySnapshot.docs
          .map((doc) => Application(
          skills: doc['skills'],
          experience: doc['experience'],
          telegram: doc['telegram']))
          .toList();

      setState(() {
        testApplications = applications;
      });
    } catch (e) {
      print('Error fetching applications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApplicationsList(applications: testApplications), // Отображение списка заявок
    );
  }
}

class Application {
  final String skills;
  final String experience;
  final String telegram;

  Application({
    required this.skills,
    required this.experience,
    required this.telegram,
  });
}

class ApplicationsList extends StatelessWidget {
  final List<Application> applications;

  ApplicationsList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(child: Text('Нет заявок.'));
    }

    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];

        return Card(
          margin: EdgeInsets.all(10.0),
          child: ListTile(
            title: Text(
              'Навыки: ${application.skills}',
              style: TextStyle(
                color: Colors.black, // Черный цвет текста
                fontSize: 16.0, // Размер шрифта
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Опыт работы: ${application.experience}',
                  style: TextStyle(
                    color: Colors.black, // Черный цвет текста
                    fontSize: 16.0, // Размер шрифта
                  ),
                ),
                Text(
                  'Телеграмм: ${application.telegram}',
                  style: TextStyle(
                    color: Colors.black, // Черный цвет текста
                    fontSize: 16.0, // Размер шрифта
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );
  }
}
