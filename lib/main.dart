import 'package:flutter/material.dart';
//http helper
import 'dart:convert'; //jsonEncode and jsonDecode
import 'dart:async'; //Future
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HttpHelper API = HttpHelper();

  List users = []; //we will populate this with the API call

  void failToGetMyData() async {
    try {
      List data = await API.failGetData();
      setState(() {
        //we got some data put it into the state variable to trigger build
        users = data;
      });
    } catch (err) {
      //IF failed to get the data
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(err.toString()),
      ));
    }
  }

  void getMyData() async {
    try {
      List data = await API.succeedGetData();
      // print(data);
      setState(() {
        //we got some data
        users = data;
      });
    } catch (err) {
      //IF failed to get the data
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(err.toString()),
      ));
    }
  }

  void postData() async {
    try {
      var data = await API.postData(name: 'Mr Magoo', email: 'magoo@home.org');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.lightBlue,
        content: Text(data.toString()),
      ));
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handling Http Requests'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            child: const Text('Get Good Data'),
            onPressed: () {
              getMyData();
            },
          ),
          TextButton(
            child: const Text(
              'Get Bad Data',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onPressed: () {
              failToGetMyData();
            },
          ),
          TextButton(
            child: const Text(
              'Do a Data POST',
              style: TextStyle(
                color: Colors.purple,
              ),
            ),
            onPressed: () {
              postData();
            },
          ),
          Divider(color: Colors.black54),
          Expanded(
            flex: 1,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  key: ValueKey(users[index]['name']),
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Text(users[index]['name']
                        .toString()
                        .substring(0, 1)
                        .toUpperCase()),
                  ),
                  title: Text(users[index]['name']),
                );
              },
              itemCount: users.length,
            ),
          ),
        ],
      ),
    );
  }
}

class HttpHelper {
  Future<List> succeedGetData() async {
    //this always works
    Uri uri =
        Uri.https('jsonplaceholder.typicode.com', 'users'); //Uri in dart:core
    Map<String, String> headers = {
      'x-my-header': 'My name',
    };

    var resp = await http.get(uri, headers: headers);
    //resp could work or fail
    switch (resp.statusCode) {
      case 200:
      case 201:
        //maybe other codes too
        //got some data
        print(resp.body);
        return jsonDecode(resp.body);
      case 404:
        Map<String, dynamic> msg = {
          'code': 404,
          'message': 'No such route.',
        };
        throw Exception(msg);
      case 403:
        Map<String, dynamic> msg = {
          'code': resp.statusCode,
          'message': 'No soup for you.',
        };
        throw Exception(msg);
      default:
        //something else
        Map<String, dynamic> msg = {
          'code': resp.statusCode,
          'message': 'Something bad happened somewhere.',
        };
        throw Exception(msg);
    }
  }

  Future<List> failGetData() async {
    //this never works
    Uri uri = Uri.https(
        'jsonplaceholder.typicode.com', 'bad/endpoint'); //Uri in dart:core
    Map<String, String> headers = {
      'x-my-header': 'My name',
    };

    var resp = await http.get(uri, headers: headers);
    //resp could work or fail
    switch (resp.statusCode) {
      case 200:
      case 201:
        //maybe other codes too
        //got some data
        return jsonDecode(resp.body);
      case 404:
        Map<String, dynamic> msg = {
          'code': 404,
          'message': 'No such route.',
        };
        throw Exception(msg);
      case 403:
        Map<String, dynamic> msg = {
          'code': resp.statusCode,
          'message': 'No soup for you.',
        };
        throw Exception(msg);
      default:
        //something else
        Map<String, dynamic> msg = {
          'code': resp.statusCode,
          'message': 'Something bad happened somewhere.',
        };
        throw Exception(msg);
    }
  }

  Future<Map> postData({required String name, required String email}) async {
    Uri uri =
        Uri.https('jsonplaceholder.typicode.com', 'users'); //Uri in dart:core
    Map<String, String> headers = {
      'x-my-header': 'My name',
      'content-type': 'application/json', //because we want to send JSON
    };
    Map<String, dynamic> user = {
      'name': name,
      'email': email,
    };
    String body = jsonEncode(user);

    var resp = await http.post(uri, headers: headers, body: body);
    //resp could work or fail
    switch (resp.statusCode) {
      case 200:
      case 201:
        //maybe other codes too
        //got some data
        return jsonDecode(resp.body);
      default:
        Map<String, dynamic> msg = {
          'code': resp.statusCode,
          'message': 'Bad things happening. Failed to add user.',
        };
        throw Exception(msg);
    }
  }
}
