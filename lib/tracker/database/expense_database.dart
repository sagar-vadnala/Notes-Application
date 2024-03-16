// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:notes_app/tracker/models/expense.dart';
// import 'package:path_provider/path_provider.dart';

// class ExpenseDatabase extends ChangeNotifier {
//   static late Isar isar;
//   List<Expense> _allExpense = [];

//   //s E T U P

//   // initialize db
//   static Future<void> initialize() async {
//     final dir = await getApplicationDocumentsDirectory();
//     isar = await Isar.open([ExpenseSchema], directory: dir.path);
//   }

//   // G E T T E R S

//   List<Expense> get allExpense => _allExpense;

//   // O P E R A T I O N S

//   // CREATE - add a new expense
//   Future<void> createNewExpense(Expense newExpense) async {
//     //add to db
//     await isar.writeTxn(() => isar.expenses.put(newExpense));

//     //re-read from db
//     await readExpense();
//   }

//   //READ - expense from db
//   Future<void> readExpense() async {
//     //fetch all existing expenses from db
//     List<Expense> fetchExpenses = await isar.expenses.where().findAll();

//     //give to local expense list
//     _allExpense.clear();
//     _allExpense.addAll(fetchExpenses);

//     //update UI
//     notifyListeners();
//   }

//   //UPDATE - edit an expense in db
//   Future<void> updateExpense (int id, Expense updateExpense) async {
//     //new expense has same id as existing one
//     updateExpense.id = id;

//     //update in db
//     await isar.writeTxn(() => isar.expenses.put(updateExpense));

//     //re-read from db
//     await readExpense();
//   }

//   //DELETE - an expense
//   Future<void> deleteExpense(int id) async {
//     //delete from db
//     await isar.writeTxn(() => isar.expenses.delete(id));

//     //re-read from db
//     await readExpense();
//   }



  
// }