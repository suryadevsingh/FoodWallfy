import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foodwallfy/services/connectionStatus.dart';
import 'package:foodwallfy/services/responses.dart';
import 'package:http/http.dart' as http;
import '../constants/frazile.dart';

/*
 * 1. set global data variables
 * 2. fetch data 
 * 3. fetch more data 
 * 4. merge more data to original data 
 */
class FoodWalls with ChangeNotifier {
  FoodWalls();

  // String _jsonResonse = "";
  bool _isFetching = false;
  bool _isLoading = false;
  List<FoodResult> wallsData = List<FoodResult>();

  ConnectionStatus _connection = ConnectionStatus.getInstance();

  bool get isFetching =>
      _isFetching; // It is checking whether data is fetched from the server or not yet.

  bool get isLoading =>
      _isLoading; // It is checking whether more data is fetched from the server or not yet.

  void loadmore() async {
    Frazile.page = Frazile.page + 1;
    List<FoodResult> walls = await fetchData(page: Frazile.page);
    wallsData.addAll(walls);
    notifyListeners();
  }

  void getHomeData() async {
    List<FoodResult> walls = await fetchData(page: 1);
    wallsData.addAll(walls);
    notifyListeners();
  }

  Future<List<FoodResult>> fetchData({int page}) async {
    page == 1 ? _isFetching = true : _isLoading = true;
    String jsonResponse = '';
    notifyListeners();
    await _connection.checkConnection();

    if (_connection.hasConnection) {
      var response = await http.get(Frazile.baseURL +
          '?client_id=' +
          Frazile.clientId +
          '&query=' +
          Frazile.query +
          '&per_page=' +
          Frazile.perPage.toString() +
          '&orientation=' +
          Frazile.orientation +
          '&page=' +
          page.toString() +
          '');

      if (response.statusCode == 200) {
        jsonResponse = response.body;
      }
    } else {
      jsonResponse = 'No';
    }

    page == 1 ? _isFetching = false : _isLoading = false;
    notifyListeners();

    List<FoodResult> walls = List<FoodResult>();
    if (jsonResponse.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(jsonResponse);
      walls = Food.fromJson(json).results;
    }
    return walls;
  }

  // String get getResponseText =>
  //     jsonResponse; // Storing the API response from jsonResponse to a getResponseText

  // List<FoodResult> walls = List<FoodResult>();

  List<FoodResult> getResponseJson() => wallsData;
}
