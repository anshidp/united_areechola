import 'package:flutter/material.dart';
import 'package:united_areechola/constants.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: TextField(
        
          decoration: InputDecoration(
              fillColor: cardbgColor,
              filled: true,
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              hintText: "Search",hintStyle: TextStyle(color: Colors.white),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 21,
              ))),
    );
  }
}
