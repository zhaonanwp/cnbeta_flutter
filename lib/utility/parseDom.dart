import 'package:html/dom.dart';
import 'package:html/parser.dart';

class ParseDom {
  static Document doParse(String dom) {
    var doc = parse(dom);
    return doc;
  }

  static String getInnerText(String dom) {
    var doc = parse(dom);
    return doc.body.text;
  }
}
