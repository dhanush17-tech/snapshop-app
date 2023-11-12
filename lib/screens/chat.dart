import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hack_princeton/model/chatModel.dart';
import 'package:hack_princeton/utils/shaderMask.dart'; // Ensure this is the correct path
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final List<ChatModel> messages = [];
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late AnimationController _animationController;
  Animation<double>? _latestMessageAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
    );
    _scrollController.addListener(_scrollListener);
  }

  ScrollController _scrollController = ScrollController();
  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isUploading = false;

  Future<void> sendMessage(String text, bool isAi, bool isTextOnly) async {
    setState(() {
      _isUploading = true;
      messages.insert(
          0, ChatModel(file: File(text), isAi: false, isOnlyText: isTextOnly));
      messages.insert(0, LoadingMessage());
      _latestMessageAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _animationController.reset();
      _animationController.forward();

      // Trigger the animation when a new message is received
      _animationController.forward();

      // Update the AnimatedList
      listKey.currentState?.insertItem(0);
    });
    if (isTextOnly == false) {
      messageController.clear();

      var dio = Dio();
      FormData formData = FormData.fromMap({
        'email': FirebaseAuth.instance.currentUser?.email,
        'image': await MultipartFile.fromFile(
          text,
          filename: 'image.jpg', // Change the filename as needed
        ),
      });

      var response = await dio
          .post(
        "https://hackprinceton-dhravya.up.railway.app/fashion_sense",
        data: formData,
      )
          .then((response) {
        print(response.data);
        final aiResponse = AiChatModel.fromJson(response.data);
        messages.removeAt(0); // Remove the loading message at index 0
        messages.insert(
            0,
            ChatModel(
              file: File(""),
              aiResponse: aiResponse,
              isAi: true,
              isOnlyText: false,
              time: DateTime.now().toIso8601String(),
            ));
        setState(() {
          _isUploading = false;

          // Create an animation for the new message
          _latestMessageAnimation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut),
          );

          _animationController.reset();
          _animationController.forward();

          // Trigger the animation when a new message is received
          _animationController.forward();

          // Update the AnimatedList
          listKey.currentState?.insertItem(0);
        });
      }).catchError((error) {
        print(error);
        // Handle error or show a message to the user
      });
    } else {
      print(text);
      http
          .get(Uri.parse(
              "https://hackprinceton-dhravya.up.railway.app/fashion_recommendation?user_prompt=${text}&user_email=${FirebaseAuth.instance.currentUser?.email}"))
          .then((value) {
        print(value.body);
        final aiResponse = AiChatModel.fromJson(jsonDecode(value.body));
        messages.removeAt(0); // Remove the loading message at index 0
        messages.insert(
            0,
            ChatModel(
              file: File(""),
              aiResponse: aiResponse,
              isAi: true,
              isOnlyText: true,
              time: DateTime.now().toIso8601String(),
            ));
        setState(() {
          _isUploading = false;

          // Create an animation for the new message
          _latestMessageAnimation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut),
          );

          _animationController.reset();
          _animationController.forward();

          // Trigger the animation when a new message is received
          _animationController.forward();

          // Update the AnimatedList
          listKey.currentState?.insertItem(0);
        });
      }).catchError((error) {
        print(error);
        // Handle error or show a message to the user
      });
    }
    //}
  }

  Widget chatInputField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.add),
                color: Theme.of(context).iconTheme.color,
                onPressed: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((value) async {
                    if (value != null) {
                      sendMessage(value.path, false, false);
                    }
                  });
                }),
            Expanded(
              child: TextField(
                controller: messageController,
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.poppins(
                    fontSize: Theme.of(context).textTheme.bodyText1?.fontSize,
                    color: Theme.of(context).textTheme.bodyText1?.color,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: GoogleFonts.poppins(
                        fontSize:
                            Theme.of(context).textTheme.bodyText1?.fontSize,
                        color: Theme.of(context).textTheme.bodyText1?.color,
                        fontWeight: FontWeight.w500),
                    border: InputBorder.none),
                onSubmitted: (text) {
                  sendMessage(text, true, false);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {
                sendMessage(messageController.text, true, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  final key = new GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 100,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
        controller: _scrollController, // Attach the ScrollController here

        child: Column(
          children: [
            FadedEdges(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.87,
                    child: AnimatedList(
                        reverse: true,
                        key: listKey,
                        physics: BouncingScrollPhysics(),
                        // Usage inside itemBuilder of AnimatedList
                        itemBuilder: (context, index, animation) {
                          final message = messages[index];
                          final isLatestMessage = index == 0;
                          final messageAnimation =
                              isLatestMessage ? _latestMessageAnimation : null;

                          if (message is LoadingMessage) {
                            // Display a loading indicator
                            return SizeTransition(
                              sizeFactor: messageAnimation!,
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.withOpacity(
                                      0.2), // Change baseColor as needed
                                  highlightColor: Colors.grey.withOpacity(0.1)!,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 5, right: 5, top: 10, bottom: 10),
                                    alignment: Alignment.center,
                                    height: 300,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .highlightColor
                                              .withOpacity(0.19),
                                          offset: Offset(0, 8),
                                          blurRadius: 40,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                      color: Color(4294834683),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          // Apply the animation only to the latest message
                          final messageWidget = isLatestMessage
                              ? SizeTransition(
                                  sizeFactor: messageAnimation!,
                                  child: message.isAi
                                      ? aiMessage(context, message.aiResponse!)
                                      : userMessage(
                                          context,
                                          message.isOnlyText
                                              ? message.aiResponse?.comment ??
                                                  ""
                                              : message.file.path,
                                          message.isOnlyText))
                              : (message.isAi
                                  ? aiMessage(context, message.aiResponse!)
                                  : userMessage(
                                      context,
                                      message.isOnlyText
                                          ? message.aiResponse?.comment ?? ""
                                          : message.file.path,
                                      message.isOnlyText));
                          return messageWidget;
                        }),
                  ),
                ],
              ),
            ),
            chatInputField(context),
          ],
        ),
      ),
    );
  }
}

Widget userMessage(BuildContext context, dynamic content, bool isTextOnly) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        vertical: 8.0, horizontal: 16.0), // Adjust padding
    child: Align(
      alignment: isTextOnly ? Alignment.topLeft : Alignment.topRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: 250,
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).primaryColor,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: isTextOnly
                  ? Text(content.toString()) // Display text here
                  : Image.file(
                      File(content ??
                          ""), // Display the image using the file path
                      fit: BoxFit.cover,
                    )),
        ),
      ),
    ),
  );
}

Widget aiMessage(
  BuildContext context,
  AiChatModel message,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        vertical: 8.0, horizontal: 16.0), // Adjust padding
    child: Align(
      alignment: Alignment.center,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message.comment,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: 12,
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Outfit Type  ",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 16),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 217, 212, 214),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${message.styleName[0].toUpperCase()}${message.styleName.substring(1).toLowerCase()}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(4281959396)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color:
                            Theme.of(context).highlightColor.withOpacity(0.19),
                        offset: Offset(0, 8),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    color: Color(4294834683),
                  ),
                  child: Wrap(
                    spacing: 10, // Adjust the spacing between items as needed
                    runSpacing: 10, // Adjust the run spacing as needed
                    crossAxisAlignment: WrapCrossAlignment
                        .start, // Align items to the start of each line
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      ...message.fashionItemsAsKeywords.map((e) {
                        double cardWidth =
                            MediaQuery.of(context).size.width * 0.4;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width:
                                cardWidth, // Adjust the width of each item as needed
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(e.img),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(e.link));
                                  },
                                  child: Container(
                                    width:
                                        cardWidth, // Match the width of the container
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.8),
                                          Colors.black.withOpacity(0.2),
                                        ],
                                        end: Alignment.topCenter,
                                        begin: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall!
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                          ),
                                          Spacer(),
                                          Text(
                                            e.price,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall!
                                                .copyWith(
                                                  fontSize: 12,
                                                ),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5, // Match the width of the container
                                            height: 2,
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              e.link
                                                  .replaceAll(
                                                      "https://www.", "")
                                                  .replaceAll("http://www.", "")
                                                  .split("/")[0],
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(
                                                    fontSize: 10,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
