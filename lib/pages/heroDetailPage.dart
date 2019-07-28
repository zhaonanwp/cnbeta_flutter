import 'package:cnbeta/utility/httpClient.dart';
import 'package:flutter/material.dart';
import 'package:cnbeta/model/article.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:cnbeta/utility/parseDom.dart';

class HeroDetailPage extends StatelessWidget {
  final Article article;
  double opacityLevel = 1.0;
  HeroDetailPage(this.article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cnbeta"),
      ),
      body: CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
          child: Hero(
            tag: "home" + this.article.urlshow,
            transitionOnUserGestures: true,
            child: Image.network(this.article.thumb, fit: BoxFit.fitWidth),
          ),
        ),
        SliverToBoxAdapter(
            child: FutureBuilder(
                builder: _futureBuilder, future: getHtml(article.urlshow))),
      ]),
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        return Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Flexible(
                child: Text(article.title, style: TextStyle(fontSize: 20)),
              ),
              Html(data: snapshot.data)
            ],
          ),
        );
      default:
        return Center(
          child: CircularProgressIndicator(),
        );
    }
  }

  Future<String> getHtml(String url) async {
    var response = await HttpClient.get(url);
    var doc = ParseDom.doParse(response.data);
    var eleSumary = doc.getElementsByClassName("article-summary").first;
    var eleContent = doc.getElementsByClassName("article-content").first;
    return eleSumary.outerHtml + eleContent.outerHtml;
  }
}
