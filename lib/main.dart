import 'dart:convert';
import 'dart:ffi';
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
      debugShowCheckedModeBanner: false,
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
        itemList.sort((a, b) => int.parse(b[2]).compareTo(int.parse(a[2])));
        filteredItemList = itemList;
      });
    }
  }

  Future<void> updateDataList(List<dynamic> newData, int index) async {
    itemList[index] = newData;
    filteredItemList = itemList;
    await saveDataToStorage(itemList);
    setState(() {});
  }
void addDataList(List<dynamic> newData) async {
  itemList.add(newData);
  itemList.sort((a, b) => int.parse(b[2]).compareTo(int.parse(a[2])));
  filteredItemList = itemList;
  await saveDataToStorage(itemList);
  setState(() {});
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

   void navigateToEditPage(List<dynamic> item, int index) async {
  List<dynamic>? editedData = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditPage(
        item: item,
        index: index,
        updateData: updateDataList,
        deleteData: deleteData,
      ),
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
      builder: (context) => AddPage(addDataList: addDataList),
    ),
  );
  if (newDataList != null) {
    addDataList(newDataList[0]);
  }
}


  Future<void> deleteData(List<dynamic> item) async {
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
                  String iq =filteredItemList[index][2];
                  Color containerColor = _getContainerColor(mbtiType);
                  Color iqcontainerColor = _getIQColor(iq);
                  String imagePath = '';

                  // Assign image path based on MBTI type
                  imagePath = 'assets/images/$mbtiType.jpeg';
                  // Add more conditions for other MBTI types
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 48, 59, 66),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: ListTile(
                          onTap: () => navigateToEditPage(filteredItemList[index], index),
                          title: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the vertical padding as needed
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  filteredItemList[index][0],
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 80.0,
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: iqcontainerColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    filteredItemList[index][2],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color.fromARGB(139, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          leading: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
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
  Color _getIQColor(String iq){
  if (int.parse(iq)>150){
    return Color.fromARGB(72, 95, 0, 183);
  }
  else if (int.parse(iq)>120){
    return Color.fromARGB(61, 0, 128, 183);
  }
  else if (int.parse(iq)>=100){
    return Color.fromARGB(63, 61, 183, 0);
  }
  else if (int.parse(iq)<100){
    return Color.fromARGB(58, 186, 186, 186);
  }
  return Color.fromARGB(58, 186, 186, 186);
}

}


class AddPage extends StatefulWidget {
  final Function(List<dynamic>) addDataList;

  const AddPage({Key? key, required this.addDataList}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String selectedMBTI = 'ESFP';
  String selectedExtrovertedFunction = 'None Selected';
  String selectedIntrovertedFunction = 'None Selected';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController iqController = TextEditingController(text: "100");

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

  List<String> extrovertedFunctions = [
    'None Selected',
    'te',
    'fe',
    'se',
    'ne',
  ];

  List<String> introvertedFunctions = [
    'None Selected',
    'ti',
    'fi',
    'si',
    'ni',
  ];

  List<String> availableIntrovertedFunctions = [];

  void addData() {
  String name = nameController.text;
  String iq = iqController.text;
  List<dynamic> newData = [name, selectedMBTI,iq];
  widget.addDataList(newData); // Call the updateData callback
  Navigator.pop(context);
}


  @override
Widget build(BuildContext context) {
  availableIntrovertedFunctions = _getAvailableIntrovertedFunctions(selectedExtrovertedFunction);
  var predmbti = _getmbti(selectedExtrovertedFunction, selectedIntrovertedFunction);

  return Scaffold(
    resizeToAvoidBottomInset : false,
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
          
          TextField(
            controller: iqController,
            decoration: const InputDecoration(labelText: "IQ"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly]),
           const SizedBox(height: 20.0),
          const Text(
            'Extroverted Function',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10.0),
          DropdownButton<String>(
            value: selectedExtrovertedFunction,
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
                selectedExtrovertedFunction = newValue!;
                selectedIntrovertedFunction = 'None Selected'; // Reset the selected introverted function
              });
            },
            items: extrovertedFunctions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          const SizedBox(height: 20.0),
          const Text(
            'Introverted Function',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10.0),
          DropdownButton<String>(
            value: selectedIntrovertedFunction,
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
                selectedIntrovertedFunction = newValue!;
              });
            },
            items: availableIntrovertedFunctions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
           
          Text(
            'Predicted MBTI: $predmbti',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 0.0),
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
List<String> _getAvailableIntrovertedFunctions(String extrovertedFunction) {
  switch (extrovertedFunction) {
    case 'te':
    case 'fe':
      return ['None Selected', 'si', 'ni'];
    case 'se':
    case 'ne':
      return ['None Selected', 'ti', 'fi'];
    default:
      return ['None Selected'];
  }
}

String _getmbti(String extrovertedFunction, String introvertedFunction){
  switch(extrovertedFunction){
    case 'te':
      switch(introvertedFunction){
        case 'ni':
          return "XNTJ";
        case 'si':
          return "XSTJ";
      }
    case 'se':
      switch(introvertedFunction){
        case 'ti':
          return "XSTP";
        case 'fi':
          return "XSFP";
      }
    case 'fe':
      switch(introvertedFunction){
        case 'ni':
          return "XNFJ";
        case 'si':
          return "XSFJ";
      }
    case 'ne':
      switch(introvertedFunction){
        case 'ti':
          return "XNTP";
        case 'fi':
          return "XNFP";
      }
  }
  return "None";
}

class EditPage extends StatefulWidget {
  final List<dynamic> item;
  final int index;
  final Future<void> Function(List<dynamic>, int) updateData;
  final Future<void> Function(List<dynamic>) deleteData;
  EditPage({required this.item, required this.index, required this.updateData, required this.deleteData});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String selectedMBTI = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController iqController = TextEditingController(text: "100");

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
    iqController.text = widget.item[2];
    selectedMBTI = widget.item[1];
  }

  void editData() async {
  String name = nameController.text;
  String iq = iqController.text;
  List<dynamic> editedData = [name, selectedMBTI, iq];

  // Update the existing item
  widget.item[0] = name;
  widget.item[1] = selectedMBTI;
  widget.item[2] = iq;
  await widget.updateData(widget.item, widget.index);

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
      backgroundColor: const Color.fromARGB(255, 21, 30, 40),
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
      body: SingleChildScrollView( child:Container(
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
            TextField(
            controller: iqController,
            decoration: const InputDecoration(labelText: "IQ"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly]),
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
                    child: const Text('Save'),
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
                      primary: Color.fromARGB(255, 187, 41, 30),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
      ),),
    );
  }
}