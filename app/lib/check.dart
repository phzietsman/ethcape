import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CheckScreen extends StatefulWidget {
  const CheckScreen({Key key}) : super(key: key);
  @override
  CheckScreenState createState() => new CheckScreenState();
}

class CheckScreenState extends State<CheckScreen>
    with TickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ethcapetown.givemethe.eth'),
        backgroundColor: Colors.black,
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
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    return RaisedButton(
                      onPressed: () => "",
                      color: Colors.lightBlueAccent,
                      child: Text('Send Money'),
                    );
                  },
                ),
              ),
              Text(
                'CHECK',
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
