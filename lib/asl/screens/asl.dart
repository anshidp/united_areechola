import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:united_areechola/asl/screens/season_tile.dart';
import 'package:united_areechola/asl/screens/team_details.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';

class Asl extends StatefulWidget {
  const Asl({super.key});

  @override
  State<Asl> createState() => _AslState();
}

class _AslState extends State<Asl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<List<SeasonModel>>(
              stream: FirebaseFirestore.instance
                  .collection("seasons")
                  .where('delete', isEqualTo: false)
                  .orderBy('createdDate', descending: true)
                  .snapshots()
                  .map(
                    (event) => event.docs
                        .map(
                          (e) => SeasonModel.fromMap(e.data()),
                        )
                        .toList(),
                  ),
              builder: (context, snapshot) {
                print(snapshot.error);
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("No data found"),
                  );
                }
                final season = snapshot.data ?? [];
                return LayoutBuilder(builder: (context, constrains) {
                  int crossAxisCount;
                  if (constrains.maxWidth < 600) {
                    crossAxisCount = 1; // Mobile
                  } else {
                    crossAxisCount = 3; // Web/Desktop
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: season.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.7,
                            //crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            crossAxisCount: crossAxisCount),
                        itemBuilder: (context, index) {
                          final data = season[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TeamDetails(
                                            seasonModel: data,
                                          )));
                            },
                            child: SeasonTile(
                              seasonModel: data,
                            ),
                          );
                        }),
                  );
                });
              })
        ],
      ),
    );
  }
}
