import 'package:dio/dio.dart';
import 'dart:async';

class HttpClient {
  static Future<Response> get(String url) async {
    try {
      Map<String, String> header = {"referer": "https://www.cnbeta.com/"};
      Dio dio = new Dio();
      if (!url.startsWith("http")) {
        url = "https:" + url;
      }
      Response response =
          await dio.request(url, options: new Options(headers: header));
      return response;
    } catch (e) {
      throw e;
    }
  }
}
