import 'package:flutter/material.dart';
import '../Models/transaction.dart';
import 'package:intl/intl.dart';
import 'chart_bar.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;

  Chart(this.recentTransactions);

  List<Map<String, Object>> get groupedTransactions {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      double totalSum = 0;

      for (var i = 0; i < recentTransactions.length; i++) {
        var date = DateTime.parse(recentTransactions[i].date);
        bool isSameDay = DateTime(date.year, date.month, date.day) ==
            DateTime(weekDay.year, weekDay.month, weekDay.day);
        if (isSameDay) {
          totalSum += recentTransactions[i].value;
        }
      }
      const Locale('pt');

      var map = {
        'Day': DateFormat.E().format(weekDay)[0].toUpperCase(),
        'Value': totalSum
      };

      return map;
    });
  }

  double get _weekTotalValue {
    return groupedTransactions.fold(0, (sum, transaction) {
      return sum + transaction["Value"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactions.reversed.map((tr) {
            return Expanded(
              child: ChartBar(
                day: tr["Day"],
                value: tr["Value"],
                percentage: _weekTotalValue > 0
                    ? (tr["Value"] as double) / _weekTotalValue
                    : 0,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
