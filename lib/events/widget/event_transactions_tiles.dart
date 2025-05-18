import 'package:flutter/material.dart';

class TransactionTiles extends StatelessWidget {
  final String title;
  dynamic body;
  final Color bgcolor;
  TransactionTiles(
      {super.key,
      required this.title,
      required this.body,
      required this.bgcolor});

  @override
  Widget build(BuildContext context) {
    double scrwidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.all(scrwidth > 600 ? 15 : scrwidth * 0.03),
      width: scrwidth > 600 ? 300 : scrwidth * 0.4,
      height: scrHeight * 0.1,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(7), color: bgcolor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: scrwidth > 600 ? 14 : scrwidth * 0.03,
                fontWeight: FontWeight.w600,
                fontFamily: "PublicSans"),
          ),
          Text(body.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: scrwidth > 600 ? 14 : scrwidth * 0.03,
                  fontWeight: FontWeight.w500,
                  fontFamily: "PublicSans"))
        ],
      ),
    );
  }
}
