import '../utility/httpClient.dart';
import '../utility/parseDom.dart';
import '../model/article.dart';
import 'package:flutter/foundation.dart';
import 'heroDetailPage.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  NewsPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with AutomaticKeepAliveClientMixin {
  var _futureBuilderFuture;
  List<Article> articleList = new List<Article>();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = getIndexData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text('主頁'),
            ),
            SliverPadding(
                padding: EdgeInsets.only(bottom: 5),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    height: 180,
                    child: Swiper(
                        // pagination: new SwiperPagination(
                        //   alignment: Alignment.topRight,
                        //     builder: DotSwiperPaginationBuilder(
                        //   color: Colors.black54,
                        //   activeColor: Colors.white,
                        // )),
                        //control: new SwiperControl(),
                        scrollDirection: Axis.horizontal,
                        autoplay: true,
                        itemCount: snapshot.data["home"].length,
                        itemBuilder: (BuildContext context, int index) {
                          return renderHome(snapshot.data["home"][index]);
                        }),
                  ),
                )),
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

  Widget renderHome(Article article) {
    return renderHomeArticle(article);
  }

  Builder renderHomeArticle(Article article) {
    return Builder(
      builder: (BuildContext context) {
        return Hero(
            tag: article.tag,
            transitionOnUserGestures: true,
            flightShuttleBuilder:
                (flightContext, animation, direction, fromContext, toContext) {
              return Image.network(article.thumb);
            },
            child: Container(
              height: 180,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeroDetailPage(article)),
                  );
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Image.network(
                      article.thumb,
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      width: 400,
                    ),
                    Container(
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.all(2),
                      height: 40,
                      width: 400,
                      color: Colors.black38,
                      child: Text(article.title,
                          maxLines: 2, style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget renderArticle(Article article) {
    return Container(
        child: Stack(
      children: <Widget>[
        Hero(
          tag: article.tag,
          child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))), //设置圆角
              margin: EdgeInsets.all(10),
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HeroDetailPage(article)),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Image.network(article.thumb,
                              width: 100, height: 100),
                        ),
                        new Flexible(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              Text(article.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: new TextStyle(
                                      color: Colors.black, fontSize: 16)),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0)),
                              Text(
                                ParseDom.getInnerText(article.hometext),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: new TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              )
                            ]))
                      ]),
                ),
              )),
        ),
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
