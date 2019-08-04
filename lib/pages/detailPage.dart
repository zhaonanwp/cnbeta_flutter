import 'package:cnbeta/utility/httpClient.dart';
import 'package:flutter/material.dart';
import 'package:cnbeta/model/article.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:cnbeta/utility/parseDom.dart';

class DetailPage extends StatelessWidget {
  final Article article;
  double opacityLevel = 1.0;
  DetailPage(this.article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cnbeta"),
      ),
      body: Container(
        child: Hero(
            tag: "index" + this.article.urlshow,
            child: FutureBuilder(
                builder: _futureBuilder, future: getHtml(article.urlshow))),
      ),
    );
  }

  Widget _futureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.done:
        return new AnimatedOpacity(
            opacity: opacityLevel,
            duration: new Duration(seconds: 10),
            child: SingleChildScrollView(
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
            ));
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
