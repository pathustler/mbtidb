import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() async {
  // Load data from SharedPreferences before running the app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      brightness: Brightness.dark, // Set the brightness to dark
      primaryColor: Colors.deepPurple, // Set the primary color
      secondaryHeaderColor: Colors.purple[900]
      
    ),
      home: const MyHomePage(title: 'MBTI Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    AddPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    
    body: Container(
      color: Color.fromARGB(255, 21, 30, 40), // Set the background color to pink
      child: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    ),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 53, 62, 72), // Specify the color of the top border
            width: 3.0, // Specify the width of the top border
          ),
        ),
      ),
      height: 75.0,
      child: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 21, 30, 40), 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 185, 70, 251),
        onTap: _onItemTapped,
      ),
    ),
  );
}

}

Future<void> saveDataToStorage(List<List<dynamic>> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> encodedData = data.map((list) {
    return jsonEncode(list);
  }).toList();
  await prefs.setStringList('data', encodedData);
}


Future<List<List<dynamic>>> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedData = prefs.getStringList('data');
    if (encodedData != null) {
      List<List<dynamic>> data = encodedData.map((jsonString) {
        return List<List<dynamic>>.from(jsonDecode(jsonString).map((list) {
          return List<dynamic>.from(list);
        }));
      }).toList();
      return data;
    } else {
      return [];
    }
  }




class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  List<List> itemList = [
    ['Jeffrey','INTP', Color.fromRGBO(113, 74, 134, 1)],
    ['Johan Shooter','INFP',Color.fromRGBO(86, 176, 126, 1)],
    ['Revan','INTP',Color.fromRGBO(113, 74, 134, 1)],
    ['Yunzu','ISTJ',Color.fromRGBO(107, 196, 222, 1)],
    ['Grace','INFP',Color.fromRGBO(86, 176, 126, 1)],
    ['Patlow','INTJ',Color.fromRGBO(113, 74, 134, 1)],
    ['Kade','ISTP',Color.fromRGBO(230, 201, 41, 1)],
    ['John','INTJ',Color.fromRGBO(113, 74, 134, 1)],
    ['Lucio','ENTP',Color.fromRGBO(113, 74, 134, 1)],
    ['Hitler','INFJ',Color.fromRGBO(86, 176, 126, 1)],
    ['Lenny','ISFJ',Color.fromRGBO(107, 196, 222, 1)],
    ['Rokurama','ENFP',Color.fromRGBO(86, 176, 126, 1)],
    ['Mastuke','INTJ',Color.fromRGBO(113, 74, 134, 1)],
    ['Yuichi','ISTJ',Color.fromRGBO(107, 196, 222, 1)],
    ['Nemoko','ESFJ',Color.fromRGBO(107, 196, 222, 1)],
  ];



  List<List> filteredItemList = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItemList = itemList;
  }

  void filterItems(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        filteredItemList = itemList;
      });
      return;
    }

    List<List> tempList = [];
    for (List item in itemList) {
      if (item[0].toLowerCase().contains(searchTerm.toLowerCase()) || item[1].toLowerCase().contains(searchTerm.toLowerCase())) {
        tempList.add(item);
      }
    }

    setState(() {
      filteredItemList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 21, 30, 40),
      centerTitle: true,
      title: Text(
        "MBTI Database",
        style: const TextStyle(
          fontSize: 22,
        ),
      ),
    ),
     body: Container(
      
      color: Color.fromARGB(255, 21, 30, 40), 
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterItems,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            
            child: ListView.builder(
              itemCount: filteredItemList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  
                  title: Text(
                        filteredItemList[index][0],
                        style: const TextStyle(
                          fontFamily: 'Roboto', // Replace 'Roboto' with your desired font family
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                    ),
                  trailing: Container(
                    width: 80.0,
                  padding: const EdgeInsets.all(13.0),
                  decoration: BoxDecoration(
                    color: filteredItemList[index][2],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    filteredItemList[index][1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
    )
    );
  
  }
}


class AddPage extends StatelessWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 21, 30, 40),
      centerTitle: true,
      title: const Text(
        "Add Data",
        style:  TextStyle(
          fontSize: 22,
        ),
      )
    ),
    body:  Container(
      decoration: const BoxDecoration(color: const Color.fromARGB(255, 21, 30, 40)),
    ),
    );
  }
}
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Page'),
    );
  }
}