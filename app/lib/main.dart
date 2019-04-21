


import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms/contact.dart';
import 'package:async/async.dart';
import 'dart:developer';
import 'dart:async';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// Smart contract goodies, needs to be stored somewhere sane
const String Abi =
    '[{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_from","type":"string"}],"name":"NewTransaction","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_from","type":"string"},{"indexed":false,"name":"_to","type":"string"},{"indexed":false,"name":"_amount","type":"uint256"}],"name":"SuccessfulTransaction","type":"event"},{"constant":true,"inputs":[],"name":"getWalletBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getBrokerStake","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_newBroker","type":"address"}],"name":"getBroker","outputs":[{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_newBroker","type":"address"}],"name":"addBroker","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"addBrokerStake","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"_broker","type":"address"}],"name":"voteBrokerIn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_phoneNumber","type":"string"}],"name":"getUser","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_phoneNumber","type":"string"}],"name":"fundUser","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"string"},{"name":"_to","type":"string"},{"name":"_amount","type":"uint256"}],"name":"sendFundsToPhone","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"string"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"sendFundsToAddr","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"string"}],"name":"voteForTransaction","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}]';

const String privateKey =
    'EAE248BEB35E1A2BCE1C9FE2E648FC3D401733A848096B8BEC61D5EC92ACE6E5';

const String url = 'https://rinkeby.infura.io/v3/07833b57821b47a9aec45dc69a107c17';
const String contractAddress = '0x3676817E8aBd12aAf51f4E43452b163852f70905';
// const String url = 'https://dai.poa.network';
// const String contractAddress = '0x47585672b0284CD3397FC6BA7743F91Bc48068A1';


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
  TextEditingController phoneNumberController = TextEditingController(text: '');
  TextEditingController amountController = TextEditingController(text: '');
  var transactions = new List<String>();




  @override
  void initState() {


//    final getWalletBalanceFN = thingContract.findFunctionsByName('getWalletBalance').first;
//    final getWalletBalanceResult = await Transaction(
//        keys: credentials,
//        maximumGas: 0)
//        .prepareForCall(
//          thingContract,
//          getWalletBalanceFN, null)
//        .call(ethClient);
//
//    final kitty = CryptoKitty.fromResponse(mrsWikiLeaksId, kittenResponse);
//    print(kitty);


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
      if(words[0] != "SEND") {
        // ignore
      } else if(words.length != 4) {
        new SmsSender().sendSms(new SmsMessage(msg.sender, "Funds not sent - Try this format - Send xxx to xxx"));
        messageReceived = msg.sender;
      }else{
        String receipient = words[3];
        String amount = words[1];
        messageReceived = "Sending " + amount + " XDAI to " + receipient;
        var amountToPay = double.parse(amount) - 0.0; //Broker fee
        new SmsSender().sendSms(new SmsMessage(msg.sender, amountToPay.toString() + " XDAI sent to " + receipient));
        new SmsSender().sendSms(new SmsMessage(receipient, amountToPay.toString() + " XDAI received from " + msg.sender));
        
        transactions.add(messageReceived);
      }

    })

    });

  }

  void sendMoney(BuildContext context)  {
    
    // getWal().then((value) { 
    //   print("passed " + value.getInWei.toString());
    // })
    // .catchError((err){print("failed " + err);});
    // String amount 

    fundUser("5556", "10000000000000000");

    // if (phoneNumberController.text.isEmpty) {
    //   print('Enter valid phone number');
    // } else {
    //   var amountToPay = int.parse(amountController.text.toString()) - 0.2; //Broker fee
    //   var message = amountToPay.toString() + " XDAI received from EthCPT.givemethe.eth";
    //   new SmsSender().sendSms(new SmsMessage(phoneNumberController.text.toString(), message));
    // }
  }

  var news = '<gathered news goes here>';
  var oneSecond = Duration(seconds: 1);

// Imagine that this function is more complex and slow. :)
  Future<String> gatherNewsReports() =>
      Future.value(news);

  Future<EtherAmount> getWal() async {
    // smart contracts goodies
    final httpClient = Client();
    final ethClient = Web3Client(url, httpClient);
    final credentials = Credentials.fromPrivateKeyHex(privateKey);
    final thingAbi = ContractABI.parseFromJSON(Abi, 'Thing');
    // final thingContract = DeployedContract(
    //   thingAbi,
    //     EthereumAddress(contractAddress),
    //     ethClient,
    //     credentials);

    return ethClient.getBalance(credentials.address);

  }

  Future<void> fundUser(String to, String amount) async {
    // smart contracts goodies
    final httpClient = Client();
    final ethClient = Web3Client(url, httpClient);
    final credentials = Credentials.fromPrivateKeyHex(privateKey);
    final thingAbi = ContractABI.parseFromJSON(Abi, 'Thing');
    final thingContract = DeployedContract(
      thingAbi,
        EthereumAddress(contractAddress),
        ethClient,
        credentials);
    final getfundUserFN = thingContract.findFunctionsByName('fundUser').first;

    final thingResponse = Transaction(keys: credentials,maximumGas: 100000);

    //thingResponse.forceNonce(100);
    final something = await thingResponse.prepareForPaymentCall(thingContract, getfundUserFN, [to], EtherAmount.fromUnitAndValue(EtherUnit.wei, amount)).send(ethClient, chainId: 4);

    something.forEach((item) {print(item);});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ethcapetown.givemethe.eth'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white,
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
                    autofocus: true,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    // onChanged: (v) => phoneNumberController.text = v,
                    decoration: InputDecoration(
                      labelText: 'Recipient Cellnumber',
                      icon: Icon(Icons.phone_android)
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    // onChanged: (v) => amountController.text = v,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      icon: Icon(Icons.print)
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      onPressed: () => sendMoney(context),
                      color: Colors.lightBlueAccent,
                      child: Text('Send XDAI'),
                    );
                  },
                ),
              ),
              Text(
                '$transactions',
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }

}


