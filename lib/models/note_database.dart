import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/tracker/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;
  //////////////////
  // static late Isar isar;
  List<Expense> _allExpense = [];

  // INITIALIZE - DATABASE
  static Future<void> initialize() async {
    final dir =  await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema, ExpenseSchema],
      directory: dir.path
      );
  }

  //List of notes
  final List<Note> currentNotes = [];


  //CREATE a note and save in db
  Future<void> addNote (String textFromUser) async {

    //create a new note object
    final newNote = Note()..text = textFromUser;

    //save to db
    await isar.writeTxn(() => isar.notes.put(newNote));

    //re-read from db
    fetchNotes();
  }

  //READ - notes from db
  Future<void> fetchNotes() async {
    List<Note> fetchNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchNotes);
    notifyListeners();
  }

  //UPDATE - a note in db
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.notes.get(id);
    if (existingNote != null) {
      existingNote.text = newText;
      await isar.writeTxn(() => isar.notes.put(existingNote));
      await fetchNotes();
    }
  }

  //DELETE - a note from db
  Future <void> deleteNote (int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }




  //----------------------------------------------------------------------------------------------------------------------
  // G E T T E R S

  List<Expense> get allExpense => _allExpense;

  // O P E R A T I O N S

  // CREATE - add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //re-read from db
    await readExpense();
  }

  //READ - expense from db
  Future<void> readExpense() async {
    //fetch all existing expenses from db
    List<Expense> fetchExpenses = await isar.expenses.where().findAll();

    //give to local expense list
    _allExpense.clear();
    _allExpense.addAll(fetchExpenses);

    //update UI
    notifyListeners();
  }

  //UPDATE - edit an expense in db
  Future<void> updateExpense (int id, Expense updateExpense) async {
    //new expense has same id as existing one
    updateExpense.id = id;

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updateExpense));

    //re-read from db
    await readExpense();
  }

  //DELETE - an expense
  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpense();
  }

  // HELPER FUNCTIONS FOR EXPENSES

  // calculate total expense for each month
  Future<Map<int, double>> calculateMonthlyTotals () async {
    // ensure the expense are read fron the db
    await readExpense();

    //create a map to keep track of tatal expenses per month
    Map<int, double> monthlyTotals = {};
    
    // iterate over all expense
    for (var expense in _allExpense) {
      //extract the month from the data of the expense
      int month = expense.date.month;

      // if the month is not yet in the map, initialize to 0
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      // add the expense amount to the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }

    return monthlyTotals;
  }

  // get start month 
  int getStartMonth () {
    if (_allExpense.isEmpty) {
      return DateTime.now().month;// default to current month is no expense are recorded
    }

    // sort expense by date to find the earlist
    _allExpense.sort(
      ((a, b) => a.date.compareTo(b.date)),
    );
    return _allExpense.first.date.month;
  }

  // get start year
    int getStartYear () {
    if (_allExpense.isEmpty) {
      return DateTime.now().year;// default to current month is no expense are recorded
    }

    // sort expense by date to find the earlist
    _allExpense.sort(
      ((a, b) => a.date.compareTo(b.date)),
    );
    return _allExpense.first.date.year;
  }
}
