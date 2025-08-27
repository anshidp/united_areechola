import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/asl_admin/screens/add_matches.dart';

class AddNewMatches extends ConsumerStatefulWidget {
  const AddNewMatches({super.key});

  @override
  ConsumerState<AddNewMatches> createState() => _ShowMatchesState();
}

class _ShowMatchesState extends ConsumerState<AddNewMatches> {
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              content: AddMatches(),
                            );
                          });
                    },
                    child: Text('Add match'))),
          ],
        ),
      ),
    );
  }
}
