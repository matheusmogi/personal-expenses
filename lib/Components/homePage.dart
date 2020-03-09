import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Models/transaction.dart';
import 'chart.dart';
import 'transaction_form.dart';
import 'transaction_list.dart';

class HomePage extends StatefulWidget {
  final userId;
  final auth;
  final logoutCallback;

  HomePage({this.userId, this.auth, this.logoutCallback});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final List<Transaction> _transactions = [];
  Query _transctionsQuery;
  StreamSubscription<Event> _onTransactionAddedSubscription;

  final String _path = 'transactions';

  @override
  void initState() {
    super.initState();
    _transctionsQuery = _database
        .reference()
        .child(_path)
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTransactionAddedSubscription =
        _transctionsQuery.onChildAdded.listen(onEntryAdded);
  }

  onEntryAdded(Event event) {
    setState(() {
      _transactions.add(Transaction.fromSnapshot(event.snapshot));
    });
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return DateTime.parse(tr.date)
          .isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    setState(() {
      if (title.length > 0 && value > 0 && date != null) {
        Transaction transaction = Transaction(
            title: title,
            value: value,
            date: date.toIso8601String(),
            userId: widget.userId);
        _database.reference().child(_path).push().set(transaction.toJson());
      }

      // _transactions.add(Transaction(
      //     title: title,
      //     value: value,
      //     date: date ?? DateTime.now(),
      //     id: Random().nextDouble().toString()));
    });
    Navigator.of(context).pop();
  }

  _deleteTransaction(String id) {
    _database.reference().child(_path).child(id).remove().then((_) {
      print("Delete $id successful");
      setState(() {
        _transactions.removeWhere((tr) => tr.id == id);
      });
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return TransactionForm(_addTransaction);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          new FlatButton(
              child: new Text(
                'Logout',
                style: new TextStyle(fontSize: 17.0, color: Colors.white),
              ),
              onPressed: signOut)
        ],
        title: Text(
          "Minhas Despesas",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Chart(_recentTransactions),
            ),
            Column(
              children: <Widget>[
                TransactionList(_transactions, _deleteTransaction)
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _onTransactionAddedSubscription.cancel();
    super.dispose();
  }
}
