import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:developer';
import 'dart:async';

SmsReceiver receiver = new SmsReceiver();

void main() => runApp(MyApp());







class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }


}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {

  String messageReceived = '';
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    receiver.onSmsReceived.listen((SmsMessage msg) =>
    {

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      var words = msg.body.split(' ');
      if(words.length != 4) {
        messageReceived = msg.sender;
      }else{
        messageReceived = "Sending " + words[1] + " XDAI to " + words[3];
      }

    })

    });

  }

  void sendMoney(BuildContext context) {
    // First make sure there is some information in the form.
    // A dog needs a name, but may be location independent,
    // so we'll only abandon the save if there's no name.
    if (phoneNumberController.text.isEmpty) {
      print('');
    } else {
      new SmsSender().sendSms(new SmsMessage(phoneNumberController.text.toString(), amountController.text.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EthGlobal'),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  // Tell your textfield which controller it owns
                    controller: phoneNumberController,
                    // Every single time the text changes in a
                    // TextField, this onChanged callback is called
                    // and it passes in the value.
                    //
                    // Set the text of your controller to
                    // to the next value.
                    onChanged: (v) => phoneNumberController.text = v,
                    decoration: InputDecoration(
                      labelText: 'Recipient Cellnumber',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                    controller: amountController,
                    onChanged: (v) => amountController.text = v,
                    decoration: InputDecoration(
                      labelText: "Amount",
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      onPressed: () => sendMoney(context),
                      color: Colors.lightBlueAccent,
                      child: Text('Send Money'),
                    );
                  },
                ),
              ),
              Text(
                '$messageReceived',
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }

}


