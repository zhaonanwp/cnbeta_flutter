import 'package:cnbeta/pages/productPage.dart';

import '../model/article.dart';
import '../pages/newsPage.dart';
import 'package:flutter/foundation.dart';
import 'heroDetailPage.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  var _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
        vsync: this, //动画效果的异步处理，默认格式，背下来即可
        length: 2 //需要控制的Tab页数量
        );
  }

  //当整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new TabBarView(controller: _tabController, children: <Widget>[
        new NewsPage(),
        new ProductPage(),
      ]),
      bottomNavigationBar: new Material(
        color: Colors.lime,
        
        textStyle: new TextStyle(
          color: Colors.white
        ),
        child: new TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          
          tabs: <Tab>[
            new Tab(text: "首页", icon: new Icon(Icons.home)),
            new Tab(text: "列表", icon: new Icon(Icons.list)),
          ],
          indicatorWeight: 0.1,
        ),
      ),
    );
  }
}
