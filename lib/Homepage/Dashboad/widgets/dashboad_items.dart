// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class DashboadItems extends StatelessWidget {
  final String title;
  final num count;
  final int index;
  final Icon icon;
  const DashboadItems(
      {super.key,
      required this.title,
      required this.count,
      required this.index,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                icon,
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: scrWidth * 0.1),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: "Inter",
                        color: const Color(0xff4B5053),
                        fontSize: scrWidth >= 600
                            ? scrWidth * 0.009
                            : scrWidth * 0.025,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Text(index == 2 ? "₹$count" : count.toString(),
                style: TextStyle(
                    fontFamily: "PublicSans",
                    color: const Color(0xff191B1C),
                    fontSize:
                        scrWidth >= 600 ? scrWidth * 0.015 : scrWidth * 0.04,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
