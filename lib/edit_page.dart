import 'package:flutter/material.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key, required this.item}) : super(key: key);

  final List<dynamic> item;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController nameController;
  String selectedMBTI = '';

  List<String> mbtiTypes = [
    'ESFP',
    'ESFJ',
    'ESTP',
    'ESTJ',
    'ENFP',
    'ENFJ',
    'ENTP',
    'ENTJ',
    'ISFP',
    'ISFJ',
    'ISTP',
    'ISTJ',
    'INFP',
    'INFJ',
    'INTP',
    'INTJ',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item[0]);
    selectedMBTI = widget.item[1];
  }

  void editData() {
    String name = nameController.text;
    List<dynamic> editedData = [name, selectedMBTI];
    Navigator.pop(context, editedData);
  }

  void deleteData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context, []); // Return an empty list to indicate deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ...
      ),
      body: Container(
        // ...
      ),
    );
  }
}
