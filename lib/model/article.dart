import 'package:uuid/uuid.dart';

class Article {
  final String title;
  final String source;
  final String hometext;
  final String catid;
  final String thumb;
  final String sid;
  final String urlshow;
  final String category;
  String tag = new Uuid().v1();

  Article(this.title, this.source, this.hometext, this.catid, this.thumb,
      this.sid, this.urlshow, this.category);

  Article.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        source = json["source"],
        hometext = json["hometext"],
        urlshow = json["url_show"],
        thumb = json["thumb"],
        sid = json["sid"],
        catid = json["catid"],
        category = json["label"]["name"];

  Map<String, dynamic> toJson() => {
        'title': title,
        'source': source,
        'hometext': hometext,
        'urlshow': urlshow,
        'thumb': thumb,
        'sid': sid,
        'catid': catid,
      };
}
