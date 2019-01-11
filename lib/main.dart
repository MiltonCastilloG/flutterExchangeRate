import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



void main() => runApp(MyApp());


Future<Post> fetchPost() async {
  final response =
      await http.get('https://free.currencyconverterapi.com/api/v6/convert?q=USD_EUR&compact=y');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final double cRate;

  Post({this.cRate});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      cRate: json['USD_EUR']["val"],
    );
  }
}

class ConvertedMoney extends StatefulWidget {
  @override
  _ConvertedMoney createState() => _ConvertedMoney();
}

class _ConvertedMoney extends State<ConvertedMoney> {
  double i = 1;
  TextEditingController textController = TextEditingController(); 
  void convertMoney() {
    setState(() {
      i = double.tryParse(textController.text);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textController.text = "1";
    return Column(
      children: [
         Container(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'USD',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        TextField(
          decoration: new InputDecoration.collapsed(
            hintText: '1'
          ),
          controller: textController
        ),
        Container(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            'EU',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          child: FutureBuilder<Post>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double rate = snapshot.data.cRate;
                String finaltext = (rate*i).toString();
                return Text(finaltext);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          )
        ),
        RaisedButton(
          onPressed: convertMoney,
          child: new Text(
            "Convert",
          ),
        ),
      ]
    );
  }
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertion app',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Convertion app'),
        ),
        body: ConvertedMoney()
      ),
    );
  }
}