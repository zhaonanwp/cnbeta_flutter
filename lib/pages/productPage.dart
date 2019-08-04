import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../model/product.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    productList.add(new Product(
        "加厚鼠标垫超大键盘垫学生电脑垫办公桌垫大鼠标垫电竞书桌垫定制",
        "https://img.alicdn.com/i1/1765223902/O1CN01X1VqvH1eh9wHmgGDO_!!1765223902.jpg",
        "8.80 元",
        "5.80元",
        "https://s.click.taobao.com/JBtn64w"));
    return Center(child: Text("Product"));
  }

  var productList = new List<Product>();
}
