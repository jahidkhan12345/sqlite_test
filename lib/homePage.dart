
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_test/home_page_provider.dart';
import 'SqliteHelper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<HomePageProvider>(context, listen: false).fetchData();
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                var provider = Provider.of<HomePageProvider>(context, listen: false);
                var dataList = provider.dataList;
                setState(() {
                  provider.deleteData(dataList[id]['id']);
                });
                Navigator.of(context).pop();
              },
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateDialog(int index) async {
    var provider = Provider.of<HomePageProvider>(context, listen: false);
    var dataList = provider.dataList;

    if (index >= 0 && index < dataList.length) {
      String currentName = dataList[index]['name'];
      String currentAge = dataList[index]['age'];
      TextEditingController nameController = TextEditingController(text: currentName);
      TextEditingController ageController = TextEditingController(text: currentAge);

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Update Data"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {
                      dataList[index]['name'] = value;
                    });
                  },
                  decoration: InputDecoration(hintText: "Enter new name"),
                ),
                TextField(
                  controller: ageController,
                  onChanged: (value) {
                    setState(() {
                      dataList[index]['age'] = value;
                    });
                  },
                  decoration: InputDecoration(hintText: "Enter new age"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("CANCEL"),
              ),
              TextButton(
                onPressed: () async {
                  if (index >= 0 && index < dataList.length) {
                    await SqliteHelper().updateData(
                      dataList[index]['id'],
                      nameController.text,
                      ageController.text,
                    );
                    await provider.fetchData();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("UPDATE"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.lightBlue,
      ),
      body: Consumer<HomePageProvider>(
        builder: (context, value, child) {
          if (value.dataList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: value.dataList.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text('Name: ${value.dataList[index]['name']}'),
                  subtitle: Text('Age: ${value.dataList[index]['age']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showUpdateDialog(index),
                  ),
                  onLongPress: () => _showDeleteConfirmationDialog(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Enter your name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.lightBlue),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Enter your age',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.lightBlue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: MaterialButton(
                          color: Colors.lightBlue,
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          minWidth: 200,
                          height: 50,
                          onPressed: () async {
                            if (nameController.text.isEmpty || ageController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              Provider.of<HomePageProvider>(context, listen: false)
                                  .insertData(nameController.text, ageController.text);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Success'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              nameController.clear();
                              ageController.clear();
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
