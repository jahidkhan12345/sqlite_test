import 'package:flutter/material.dart';

import 'SqliteHelper.dart';

class HomePageProvider with ChangeNotifier{
  List<Map<String, dynamic>> dataList = [];

  Future<void> fetchData() async {
    List<Map<String, dynamic>> data = await SqliteHelper().getData();
    dataList = data;
    notifyListeners();
  }
  Future<void> deleteData(int id) async {
    await SqliteHelper().deleteData(id);
    await fetchData();
      dataList.removeAt(id);

      notifyListeners();
  }

  Future<void> insertData(String name ,String age) async{
    await SqliteHelper().getDatabase();
     await SqliteHelper().insertData(name,age);
     await fetchData();
     // notifyListeners();
  }

}