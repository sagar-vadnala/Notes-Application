import 'package:flutter/material.dart';
import 'package:notes_app/models/note_database.dart';
import 'package:notes_app/tracker/bar_graph/bar_graph.dart';
import 'package:notes_app/tracker/components/my_list_title.dart';
import 'package:notes_app/tracker/helper/helper_functions.dart';
import 'package:notes_app/tracker/models/expense.dart';
import 'package:provider/provider.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  // text controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load grap data
  Future<Map<int, double>>? _monthlyTotalsFuture;

  @override
  void initState() {
    //read db on initial startup
    Provider.of<NoteDatabase>(context, listen: false).readExpense();

    // load futures
    refreshGraphData();
    super.initState();
  }

  // refreash grap data
  void refreshGraphData () {
    _monthlyTotalsFuture = Provider.of<NoteDatabase>(context, listen: false).calculateMonthlyTotals();
  }

  //open new expense box
  void openNewExpense() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Name"),
                  ),

                  // user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(hintText: "Amount"),
                  ),
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                // save button
                _createNewExpanseButton()
              ],
            ));
  }

  // open edit box
  void openEditBox(Expense expense) {
    // pre-fill existing values
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Edit Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),

                  // user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  ),
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),

                // save button
                _editExpenseButton(expense)
              ],
            ));
  }

  // open delete box
  void openDeleteBox (Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Expense"),
              actions: [
                //cancel button
                _cancelButton(),

                // save button
                _deleteExpenseButton(expense.id)
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteDatabase>(
      builder: ((context, value, child) {
        // get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        // calculate the number of months since the first month
        int monthCount = calculateMonthCount(
          startYear, startMonth, currentYear, currentMonth);

        // only display the expense for the curremt month


        //return UI
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
            floatingActionButton: FloatingActionButton(
              onPressed: openNewExpense,
              child: const Icon(Icons.add),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // GRAPH UI
                  SizedBox(
                    height: 250,
                    child: FutureBuilder(
                      future: _monthlyTotalsFuture,
                      builder: (context, snapshot) {
                        //data is loaded
                        if (snapshot.connectionState == ConnectionState.done) {
                          final monthlyTotals = snapshot.data ?? {};
                    
                          // create the list of monthly summary
                          List<double> monthlySummary = List.generate(
                            monthCount,
                            (index) => monthlyTotals[startMonth + index] ?? 0.0);
                    
                            return MyBarGraph(monthlySummary: monthlySummary, startMonth: startMonth);
                        }
                    
                        // loading ...
                        else {
                          return const Center(child: Text("loading..."),);
                        }
                      } 
                      ),
                  ),
              
                  // EXPENSE LIST UI
                  Expanded(
                    child: ListView.builder(
                    itemCount: value.allExpense.length,
                    itemBuilder: (context, index) {
                      //get individual expense
                      Expense individualExpense = value.allExpense[index];
                    
                      //return list tile ui
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) => openEditBox(individualExpense),
                        onDeletePressed: (context) => openDeleteBox(individualExpense),
                      );
                    }),
                  ),
                ],
              ),
            )
          );
      }
          ),
    );
  }

  // cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controller
        nameController.clear();
        amountController.clear();
      },
      child: const Text("cancel"),
    );
  }

  // Save button -> Create new expense
  Widget _createNewExpanseButton() {
    return MaterialButton(
      onPressed: () async {
        // only save if has some content
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());

          //save to the db
          await context.read<NoteDatabase>().createNewExpense(newExpense);

          // refresh graph
          refreshGraphData();

          //clear controller
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // Save Button -> Edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(onPressed: () async {
      // save as long as at least one textfield has been changed
      if (nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
        // pop box
        Navigator.pop(context);

        //create a new updated expense
        Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now());

        // old expense id
        int existingId = expense.id;

        // save in db
        await context.read<NoteDatabase>().updateExpense(existingId, updatedExpense); 

        // refresh bar graph
        refreshGraphData();  
      }
    },
    child: const Text("Save"),
    );
  }

  // Delete Button
  Widget _deleteExpenseButton (int id) {
    return MaterialButton(
      onPressed: () async {
        // pop box
        Navigator.pop(context);

        // delete expense from db
        await context.read<NoteDatabase>().deleteExpense(id);

        // refresh bar graph
        refreshGraphData();
      },
      child: const Text("Delete"),
      );
  }

}
