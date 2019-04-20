import 'package:flutter/material.dart';
import 'package:ethcapetown/Pages/check.dart';
import 'package:ethcapetown/main.dart';

class Routes {
  Routes() {
    runApp(new MaterialApp(
      title: "EthCPT.givemethe.eth",
      debugShowCheckedModeBanner: false,
      home: new CheckScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {

          case '/home':
            return new MyCustomRoute(
              builder: (_) => new MyHomePage(),
              settings: settings,
            );
          case '/check':
            return new MyCustomRoute(
              builder: (_) => new CheckScreen(),
              settings: settings,
            );
        }
      },
    ));
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    return new FadeTransition(opacity: animation, child: child);
  }
}
