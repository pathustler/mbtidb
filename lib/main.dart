import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<List<dynamic>> itemList = [];
  List<List<dynamic>> filteredItemList = [];

  @override
  void initState() {
    super.initState();
    loadDataFromStorage();
  }

  Future<void> loadDataFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedData = prefs.getStringList('data');
    if (encodedData != null) {
      List<List<dynamic>> data = encodedData.map((jsonString) {
        return List<dynamic>.from(jsonDecode(jsonString));
      }).toList();
      setState(() {
        itemList = data;
        filteredItemList = itemList;
      });
    } else {
      setState(() {
        itemList = [];
        filteredItemList = [];
      });
    }
  }

  void updateDataList(List<List<dynamic>> newDataList) {
    setState(() {
      itemList.addAll(newDataList);
      filteredItemList = itemList;
      saveDataToStorage(itemList);
    });
  }

  Future<void> saveDataToStorage(List<List<dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedData = data.map((list) {
      return jsonEncode(list);
    }).toList();
    await prefs.setStringList('data', encodedData);
  }

  void filterItems(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        filteredItemList = itemList;
      });
      return;
    }

    List<List<dynamic>> tempList = [];
    for (List<dynamic> item in itemList) {
      if (item[0].toLowerCase().contains(searchTerm.toLowerCase()) ||
          item[1].toLowerCase().contains(searchTerm.toLowerCase())) {
        tempList.add(item);
      }
    }

    setState(() {
      filteredItemList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        secondaryHeaderColor: Colors.purple[900],
      ),
      home: MyHomePage(
        title: 'MBTI Database',
        itemList: filteredItemList,
        updateDataList: updateDataList,
        filterItems: filterItems,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.itemList,
    required this.updateDataList,
    required this.filterItems,
  }) : super(key: key);

  final String title;
  final List<List<dynamic>> itemList;
  final Function(List<List<dynamic>>) updateDataList;
  final Function(String) filterItems;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 30, 40),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 21, 30, 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: widget.filterItems,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.itemList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      widget.itemList[index][0],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    trailing: Container(
                      width: 80.0,
                      padding: const EdgeInsets.all(13.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 63, 170, 10),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        widget.itemList[index][1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<List<dynamic>> newDataList = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPage(),
            ),
          );
          if (newDataList != null) {
            widget.updateDataList(newDataList);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String selectedMBTI = 'ESFP';
  final TextEditingController nameController = TextEditingController();

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

  void addData() async {
    String name = nameController.text;
    List<dynamic> newData = [name, selectedMBTI];
    List<List<dynamic>> newDataList = [newData];
    await saveDataToStorage(newDataList);
    Navigator.pop(context, newDataList);
  }

  Future<void> saveDataToStorage(List<List<dynamic>> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedData = data.map((list) {
      return jsonEncode(list);
    }).toList();
    await prefs.setStringList('data', encodedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 30, 40),
        centerTitle: true,
        title: const Text(
          'Add MBTI',
          style: TextStyle(
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 21, 30, 40),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Name',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: nameController,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'MBTI Type',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10.0),
            DropdownButton<String>(
              value: selectedMBTI,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              dropdownColor: Colors.grey[900],
              onChanged: (String? newValue) {
                setState(() {
                  selectedMBTI = newValue!;
                });
              },
              items: mbtiTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: addData,
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
