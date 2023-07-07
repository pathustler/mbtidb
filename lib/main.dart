import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        secondaryHeaderColor: Colors.purple[900],
      ),
      home: const MyHomePage(title: 'MBTI Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<dynamic>> itemList = [];
  List<List<dynamic>> filteredItemList = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDataFromStorage();
  }

  Future<void> loadDataFromStorage() async {
    final box = GetStorage();
    String? encodedData = box.read('data');
    if (encodedData != null) {
      List<dynamic> data = jsonDecode(encodedData);
      setState(() {
        itemList = List<List<dynamic>>.from(data);
        filteredItemList = itemList;
      });
    }
  }

  void updateDataList(List<dynamic> editedData) async {
  int index = itemList.indexWhere((item) => item[0] == editedData[0]);
  if (index != -1) {
    itemList[index] = editedData;
    filteredItemList = itemList;
    await saveDataToStorage(itemList);
    setState(() {});
  }
}


  Future<void> saveDataToStorage(List<List<dynamic>> data) async {
    final box = GetStorage();
    String encodedData = jsonEncode(data);
    await box.write('data', encodedData);
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

  void navigateToEditPage(List<dynamic> item) async {
  List<dynamic>? editedData = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditPage(item: item, updateData: updateDataList, deleteData: deleteData),
    ),
  );
  if (editedData != null) {
 // Wrap editedData in a list
  }
}

  void navigateToAddPage() async {
    List<List<dynamic>> newDataList = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPage(),
      ),
    );
    if (newDataList != null) {
      updateDataList(newDataList);
    }
  }

  void deleteData(List<dynamic> item) async {
  itemList.remove(item);
  filteredItemList = itemList;
  await saveDataToStorage(itemList);
  setState(() {});
}


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
                  String mbtiType = filteredItemList[index][1];
                  Color containerColor = _getContainerColor(mbtiType);

                  return ListTile(
                    onTap: () => navigateToEditPage(filteredItemList[index]),
                    title: Text(
                      filteredItemList[index][0],
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
                        color: containerColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        filteredItemList[index][1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(150, 0, 0, 0),
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
        backgroundColor: const Color.fromARGB(255, 200, 60, 185),
        onPressed: navigateToAddPage,
        child: const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 200, 60, 185),
          foregroundColor: Colors.black,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Color _getContainerColor(String mbtiType) {
    if (mbtiType == 'ISTJ' ||
        mbtiType == 'ESTJ' ||
        mbtiType == 'ESFJ' ||
        mbtiType == 'ISFJ') {
      return const Color.fromARGB(255, 93, 194, 219);
    } else if (mbtiType == 'INTJ' ||
        mbtiType == 'ENTJ' ||
        mbtiType == 'ENTP' ||
        mbtiType == 'INTP') {
      return const Color.fromARGB(255, 141, 101, 125);
    } else if (mbtiType == 'INFP' ||
        mbtiType == 'ENFP' ||
        mbtiType == 'INFJ' ||
        mbtiType == 'ENFJ') {
      return const Color.fromARGB(255, 104, 174, 139);
    } else if (mbtiType == 'ISTP' ||
        mbtiType == 'ESTP' ||
        mbtiType == 'ESFP' ||
        mbtiType == 'ISFP') {
      return const Color.fromARGB(255, 245, 215, 92);
    }
    return Colors.transparent; // Default color if no matching MBTI type
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

  void addData() {
    String name = nameController.text;
    List<dynamic> newData = [name, selectedMBTI];
    List<List<dynamic>> newDataList = [newData];
    Navigator.pop(context, newDataList);
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
                primary: const Color.fromARGB(255, 200, 60, 185),
                foregroundColor: Colors.black,
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

class EditPage extends StatefulWidget {
  final List<dynamic> item;
  final Function(List<dynamic>) deleteData;
  final Function(List<dynamic>) updateData;

  EditPage({required this.item, required this.updateData, required this.deleteData});

  @override
  _EditPageState createState() => _EditPageState();
}


class _EditPageState extends State<EditPage> {
  String selectedMBTI = '';
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

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item[0];
    selectedMBTI = widget.item[1];
  }

  void editData() {
  String name = nameController.text;
  List<dynamic> editedData = [name, selectedMBTI];
  widget.updateData(editedData); // Update the item
  Navigator.pop(context, editedData);
}


  void deleteData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Return true to indicate delete action
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, null); // Return null to indicate delete action
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 30, 40),
        centerTitle: true,
        title: const Text(
          'Edit Item',
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: editData,
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 200, 60, 185),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.deleteData(widget.item); // Delete the item
                      Navigator.pop(context);
                  },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    child: const Text('Delete'),
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

