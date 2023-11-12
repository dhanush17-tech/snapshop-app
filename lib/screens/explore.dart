import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:hack_princeton/model/chatModel.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Explore extends StatelessWidget {
  Explore({Key? key}) : super(key: key);
  List<String> imageUrls = [];
  List<String> productUrls = [];
  Future<List<String>> getImages() async {
    try {
      var response = await http.get(Uri.parse(
          "https://hackprinceton-dhravya.up.railway.app/featured_page"));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);

        for (var item in list) {
          AiChatModel aiChatModel = AiChatModel.fromJson(item);
          imageUrls.addAll(
              aiChatModel.fashionItemsAsKeywords.map((product) => product.img));
          productUrls.addAll(aiChatModel.fashionItemsAsKeywords
              .map((product) => product.link));
        }
        return imageUrls;
      } else {
        // Handle the case when the server does not respond with a 200 OK
        return [];
      }
    } catch (e) {
      // Handle any exceptions
      print("An error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 100,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 140,
            ),
            FutureBuilder<List<String>>(
              future: getImages(), // Corrected method name
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}")); // Handle errors
                } else if (snapshot.hasData) {
                  print(snapshot.data); // Display
                  return SingleChildScrollView(
                    child: MasonryView(
                      listOfItem: snapshot.data!,
                      numberOfColumn: 2,
                      itemBuilder: (c) {
                        return GestureDetector(
                          onTap: () async {
                            await launchUrl(
                                Uri.parse(productUrls[imageUrls.indexOf(c)]));
                          },
                          child: Image.network(c),
                        ); // Use the data to build your UI
                      },
                    ),
                  );
                } else {
                  return Center(
                      child: Text(
                          "No data available")); // Handle the case when no data is returned
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
