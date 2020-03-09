 
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Transaction {
  String id;
  final String title;
  final double value;
  final String date;
  String userId;

  Transaction(
      {@required this.title,
      @required this.value,
      @required this.date,
      @required this.userId});

  Transaction.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        userId = snapshot.value["userId"],
        title = snapshot.value["title"],
        date =  snapshot.value["date"],
        value = snapshot.value["value"].toDouble();

  toJson() {
    return {
      "userId": userId,
      "title": title,
      "date": date,
      "value": value,
    };
  }
}
