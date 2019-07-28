import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utility/httpClient.dart';
import 'utility/parseDom.dart';
import 'model/article.dart';
import 'package:flutter/foundation.dart';
import 'pages/detailPage.dart';
import 'pages/heroDetailPage.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
          ThemeData(primarySwatch: Colors.lime, backgroundColor: Colors.grey),
      home: MyHomePage(),
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
  var _futureBuilderFuture;
  List<Article> articleList = new List<Article>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///用_futureBuilderFuture来保存_gerData()的结果，以避免不必要的ui重绘
    _futureBuilderFuture = getIndexData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
        body:
            FutureBuilder(builder: _buildFuture, future: _futureBuilderFuture));
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: false,
              title: Text('CNBETA'),
            ),
            SliverPadding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              sliver: SliverToBoxAdapter(
                  child: CarouselSlider(
                      enlargeCenterPage: true,
                      aspectRatio: 2.0,
                      height: 220,
                      items: renderHome(snapshot.data["home"]))),
            ),
            SliverPadding(
              padding: EdgeInsets.only(top: 0, bottom: 5),
              sliver: SliverFixedExtentList(
                itemExtent: 150.0,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return renderArticle(snapshot.data["list"][index]);
                }, childCount: snapshot.data["list"].length),
              ),
            ),
          ],
        );

      // return Row(children: <Widget>[
      //   ListView.builder(
      //     itemCount: snapshot.data["list"].length,
      //     itemBuilder: (context, index) {
      //       return renderArticle(snapshot.data["list"][index]);
      //     },
      //   )
      // ]);
      default:
        return Center(
          child: CircularProgressIndicator(),
        );
    }
  }

  List<Widget> renderHome(List<Article> articles) {
    return articles.map((article) {
      return renderHomeArticle(article);
    }).toList();
  }

  Builder renderHomeArticle(Article article) {
    return Builder(
      builder: (BuildContext context) {
        return Hero(
            tag: "home" + article.urlshow,
            transitionOnUserGestures: true,
            flightShuttleBuilder:
                (flightContext, animation, direction, fromContext, toContext) {
              return Image.network(article.thumb);
            },
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeroDetailPage(article)),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.network(article.thumb),
                    Flexible(
                        child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        article.title,
                      ),
                    ))
                  ],
                ),
              ),
              elevation: 10.0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))), //设置圆角
              margin: EdgeInsets.symmetric(horizontal: 5.0),
            ));
      },
    );
  }

  Widget renderArticle(Article article) {
    return Container(
        child: Stack(
      children: <Widget>[
        Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))), //设置圆角
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8),
                      child:
                          Image.network(article.thumb, width: 100, height: 100),
                    ),
                    new Flexible(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Text(article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: new TextStyle(
                                  color: Colors.black, fontSize: 16)),
                          Padding(padding: const EdgeInsets.only(bottom: 5.0)),
                          Text(
                            ParseDom.getInnerText(article.hometext),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style:
                                new TextStyle(color: Colors.grey, fontSize: 14),
                          )
                        ]))
                  ]),
            )),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.grey.withOpacity(0.3),
            highlightColor: Colors.grey.withOpacity(0.1),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage(article)),
              );
            },
          ),
        ))
      ],
    ));
  }

  String getToken(String dom) {
    var doc = ParseDom.doParse(dom);
    var m = doc.getElementsByTagName("meta");
    var t =
        m.firstWhere((e) => e.attributes.values.first.contains("csrf-token"));
    return t.attributes["content"];
  }

  Future<Map<String, List<Article>>> getIndexData() async {
    var response = await HttpClient.get("https://www.cnbeta.com/");
    var token = getToken(response.data);
    var homeData = getHomeData(response.data);
    var rJson = await HttpClient.get(
        "https://www.cnbeta.com/home/more?&type=all&page=1&_csrf=" + token);
    Map<String, dynamic> result = rJson.data;
    List<Article> articles = new List<Article>();

    result["result"]["list"].forEach((item) {
      articles.add(Article.fromJson(item));
    });

    Map<String, List<Article>> resultData = {
      "home": homeData,
      "list": articles
    };

    return resultData;
  }

  List<Article> getHomeData(dom) {
    List<Article> list = new List<Article>();
    var thumb;
    var title;
    var category;
    var urlshow;
    var doc = ParseDom.doParse(dom);
    var hDoc = doc.getElementById("hero_scroll");
    hDoc.children.forEach((e) => {
          e.children.forEach((child) => {
                thumb = child
                    .getElementsByClassName("figure-img")
                    .first
                    .firstChild
                    .attributes["src"],
                title = child
                    .getElementsByClassName("item-title")
                    .first
                    .text
                    .replaceAll(" ", "")
                    .replaceAll("\n", ""),
                category = child
                    .getElementsByClassName("item-title")
                    .first
                    .children[1]
                    .text,
                urlshow = child
                    .getElementsByClassName("link")
                    .first
                    .attributes["href"],
                list.add(new Article(
                    title, "", "", '', thumb, '', urlshow, category)),
              })
        });
    return list;
  }
}
