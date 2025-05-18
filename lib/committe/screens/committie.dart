// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommittieScreen extends StatefulWidget {
  const CommittieScreen({super.key});

  @override
  State<CommittieScreen> createState() => _CommittieScreenState();
}

class _CommittieScreenState extends State<CommittieScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0C111D),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('committie')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('');
                }
                final data = snapshot.data!.docs
                    .map((e) => TeamModel.fromJson(e.data()))
                    .toList();
                final List<TeamModel> exicutive = data
                    .where((element) => element.role == "exicutive")
                    .toList();
                final List<TeamModel> otherList = data
                    .where((element) => element.role != "exicutive")
                    .toList();
                final List<TeamModel> filterlist = [...otherList, ...exicutive];
                return SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Our Team",
                          style: TextStyle(
                              fontFamily: 'PublicSans',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 600,
                          //height: 600,
                          child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: filterlist.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisSpacing: 13, crossAxisCount: 2),
                              itemBuilder: (context, index) {
                                return teamCircle(
                                    filterlist[index].name ?? "",
                                    filterlist[index].role ?? "",
                                    filterlist[index].image ?? "");
                              }),
                        )
                      ]),
                );
              }),
        ),
      ),
    );
  }

  Widget teamCircle(String name, String role, String image) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(image),
          radius: 55,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          name.toUpperCase(),
          style: const TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        Text(
          role.toUpperCase(),
          style: const TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        )
      ],
    );
  }
}

class TeamModel {
  String? name;
  String? image;
  String? role;

  TeamModel({this.image, this.name, this.role});

  factory TeamModel.fromJson(Map<String, dynamic> map) {
    return TeamModel(name: map['name'], role: map['role'], image: map['image']);
  }
}
