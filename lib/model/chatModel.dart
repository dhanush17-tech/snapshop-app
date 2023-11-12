import 'dart:io';

import 'package:flutter/material.dart';

class ChatModel {
  bool isAi;
  bool isOnlyText;
  bool isLoading;
  File file;
  AiChatModel? aiResponse;
  String time;

  ChatModel(
      {this.isAi = false,
      this.aiResponse,
      this.isLoading = false,
      this.time = "",
      required this.isOnlyText,
      required this.file});

  // Optionally add a method to convert JSON data to a ChatModel instance
  factory ChatModel.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> aiResponse) {
    return ChatModel(
      isAi: json['isAi'] ?? false,
      isOnlyText: false,
      aiResponse:
          json['isAi'] == true ? AiChatModel.fromJson(aiResponse) : null,
      // Assuming AiChatModel.fromJson is a method that properly parses a JSON object into an AiChatModel instanc
      file: File(""),
      time: json['time'] ?? "",
    );
  }
}

class AiChatModel {
  String comment;
  String styleName;
  List<Product> fashionItemsAsKeywords;
  String image;

  AiChatModel({
    required this.comment,
    required this.styleName,
    required this.fashionItemsAsKeywords,
    required this.image,
  });

  factory AiChatModel.fromJson(Map<String, dynamic> json) {
    var fashionItemsList = json['fashion_items_as_keywords'] as List;
    List<Product> fashionItems =
        fashionItemsList.map((item) => Product.fromJson(item)).toList();

    return AiChatModel(
      comment: json['comment'] ?? '',
      styleName: json['style_name'] ?? '',
      fashionItemsAsKeywords: fashionItems,
      image: json['image'] ?? '',
    );
  }
}

class Product {
  final String link;
  final String name;
  final String price;
  final String img;

  Product({
    required this.link,
    required this.name,
    required this.price,
    required this.img,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      link: json['link'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      img: json['img'] ?? '',
    );
  }
}

class LoadingMessage extends ChatModel {
  LoadingMessage()
      : super(
        isOnlyText: false, // This is not a text message
          isAi: false, // This is not an AI message
          file: File(""), // No file associated with the loading message
          aiResponse: null, // No AI response for loading message
          time: DateTime.now().toIso8601String(),
        );
}
