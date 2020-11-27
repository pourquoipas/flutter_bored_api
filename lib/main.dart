import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this line
import 'package:http/http.dart' as http;
import 'package:percent_indicator/linear_percent_indicator.dart';

void main() {
  runApp(BoredApiApp());
}

class BoredApiApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English
        const Locale('it', 'IT'), // Italian
        // ... other locales the app supports
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode ||
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).boredApi,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: ""),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) {}

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<BoredActivity> _activity;

  @override
  void initState() {
    super.initState();
    _activity = fetchActivity();
  }

  void refresh() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values.
      _activity = fetchActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).boredApi /* widget.title */),
      ),
      body: Center(
        child: FutureBuilder<BoredActivity>(
          future: _activity,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _MyLabel(
                      label: AppLocalizations.of(context).activity,
                      text: snapshot.data.activity),
                  Divider(
                    color: Colors.black,
                  ),
                  _MyLabel(
                      label: AppLocalizations.of(context).type,
                      text: snapshot.data.type),
                  Divider(
                    color: Colors.black,
                  ),
                  _MyLabel(
                      label: AppLocalizations.of(context).participants,
                      text: snapshot.data.participants.toString()),
                  Divider(
                    color: Colors.black,
                  ),
                  _MyPercent(
                    label: AppLocalizations.of(context).accessibility,
                    percent: snapshot.data.accessibility,
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  _MyPercent(
                    label: AppLocalizations.of(context).price,
                    percent: snapshot.data.price,
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        tooltip: 'Increment',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _MyLabel extends StatelessWidget {
  final String label;
  final String text;

  const _MyLabel({Key key, this.label, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          children: <Widget>[
            Container(
                padding: new EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                ),
                width: double.infinity,
                child: Text(
                  label + ":",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                )),
            Flexible(
                child: new Container(
              padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.justify,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ))
          ],
        )
    );
  }
}

class _MyPercent extends StatelessWidget {
  final String label;
  final double percent;

  const _MyPercent({Key key, this.label, this.percent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
            children: <Widget>[
              Container(
                padding: new EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                ),
                width: double.infinity,
                child: Text(
                  label + ":",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                )
              ),
              Flexible(
                child: new Container(
                  padding: new EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                  child: LinearPercentIndicator(
                    width: 180.0,
                    lineHeight: 14.0,
                    percent: percent,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                    alignment: MainAxisAlignment.center,
                  ),
                )
              )
            ]
        )
    );
  }
}

Future<BoredActivity> fetchActivity() async {
  // Call to http://www.boredapi.com/api/activity/

  final response = await http.get("https://www.boredapi.com/api/activity/");

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return BoredActivity.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load activity');
  }
}

class BoredActivity {
  final String activity;
  final double accessibility; // A factor describing how possible an event is to do with zero being the most accessible [0.0, 1.0]
  final String type; // Type of the activity ["education", "recreational", "social", "diy", "charity", "cooking", "relaxation", "music", "busywork"]

  final int participants; // The number of people that this activity could involve [0, n]

  final double price; // A factor describing the cost of the event with zero being free [0, 1]

  final int key; //

  BoredActivity(
      {this.activity,
      this.accessibility,
      this.type,
      this.participants,
      this.price,
      this.key});

  factory BoredActivity.fromJson(Map<String, dynamic> json) {
    return BoredActivity(
      activity: json['activity'],
      accessibility: json['accessibility'].toDouble(),
      type: json['type'],
      participants: json['participants'],
      price: json['price'].toDouble(),
    );
  }
}
