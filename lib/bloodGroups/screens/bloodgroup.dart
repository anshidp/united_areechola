import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:united_areechola/Models/bloodgroup_model.dart';
import 'package:united_areechola/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodGroups extends StatefulWidget {
  const BloodGroups({super.key});

  @override
  State<BloodGroups> createState() => _BloodGroupsState();
}

class _BloodGroupsState extends State<BloodGroups> {
  makingPhoneCall(String phoneNumber) async {
    try {
      var url = Uri.parse("tel:$phoneNumber");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print(e);
    }
  }

  List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  String? bloodGroup;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primarycolor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.27,
                  height: MediaQuery.of(context).size.width * 0.12,
                  child: DropdownButton(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: bloodGroup,
                      hint: const Text(
                        "Select",
                        style:
                            TextStyle(fontFamily: "PublicSans", fontSize: 12),
                      ),
                      onChanged: (val) {
                        setState(() {
                          bloodGroup = val ?? "";
                        });
                      },
                      items: bloodGroups
                          .map((e) => DropdownMenuItem(
                                value: e.toString(),
                                child: Text(e.toString()),
                              ))
                          .toList()),
                ),
                const SizedBox(
                  width: 10,
                ),
                bloodGroup == null
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          setState(() {
                            bloodGroup = null;
                          });
                        },
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                            color: Color.fromARGB(255, 124, 18, 11),
                            fontFamily: "PublicSans",
                            fontSize: 12,
                          ),
                        ),
                      )
              ],
            ),
            Expanded(
              child: StreamBuilder<List<BloodGroup>>(
                  stream: FirebaseFirestore.instance
                      .collection("bloodGroups")
                      .where("bloodGroup", isEqualTo: bloodGroup)
                      .snapshots()
                      .map((event) => event.docs
                          .map((e) => BloodGroup.fromMap(e.data()))
                          .toList()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || (snapshot.data ?? []).isEmpty) {
                      return const Center(
                        child: Text(
                          "No data found",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data ?? [];
                          return ListTile(
                            trailing: GestureDetector(
                              onTap: () {
                                //launch("tel:${data[index].phoneNumber ?? ""}");
                                makingPhoneCall(data[index].phoneNumber ?? "");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: primarycolor),
                                    borderRadius: BorderRadius.circular(10)),
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.1,
                                child: const Center(child: Text("Call")),
                              ),
                            ),
                            subtitle: Text(
                              data[index].phoneNumber ?? "",
                              style: TextStyle(
                                  fontFamily: "PublicSans",
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: primarycolor,
                                  fontWeight: FontWeight.w500),
                            ),
                            title: Text(
                              data[index].name?.toUpperCase() ?? "",
                              style: TextStyle(
                                  fontFamily: "PublicSans",
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  fontWeight: FontWeight.w500),
                            ),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Text(
                                data[index].bloodGroup ?? "",
                                style: TextStyle(
                                    fontFamily: "PublicSans",
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
