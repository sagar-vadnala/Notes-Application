import 'package:flutter/material.dart';
import 'package:notes_app/components/drawer.dart';
import 'package:notes_app/components/note_title.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/note_database.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  //text controller to access the user input
  final textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readNotes();
  }

  //create a note
  void createNote() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
              content: TextField(
                controller: textController,
              ),
              actions: [
                //create button
                MaterialButton(
                  onPressed: () {
                    //add to db
                    context.read<NoteDatabase>().addNote(textController.text);

                    //clear controller
                    textController.clear();

                    //pop the dialog
                    Navigator.pop(context);
                  },
                  child: const Text("create"),
                )
              ],
            ));
  }

  //read notes
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  //update a note
  void updateNote(Note note) {
    //prefill the current note text
    textController.text = note.text;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
              title: const Text("Update Note"),
              content: TextField(controller: textController),
              actions: [
                //update button
                MaterialButton(onPressed: () {
                  //update note in db
                  context
                      .read<NoteDatabase>()
                      .updateNote(note.id, textController.text);
                  //clear controller
                     textController.clear();
                  // pop dialog box
                    Navigator.pop(context);
                },
                child: const Text("Update"),
                )
              ],
            ));
  }

  //delete a note
  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    //note database
    final noteDatabase = context.watch<NoteDatabase>();

    //current notes
    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
          ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // heading 
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 5),
          child: Text("Notes",
          style: TextStyle(
            fontSize: 48,
            color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),

        // List of Notes
          Expanded(
            child: ListView.builder(
                itemCount: currentNotes.length,
                itemBuilder: (context, index) {
                  //get individual notes
                  final note = currentNotes[index];
            
                  //list title ui
                  // return ListTile(
                  //   title: Text(note.text),
                  //   trailing: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       //edit button
                  //       IconButton(
                  //         onPressed: () => updateNote(note),
                  //         icon: const Icon(Icons.edit),
                  //         ),
                  //       //delete button
                  //       IconButton(
                  //         onPressed: () => deleteNote(note.id),
                  //         icon: const Icon(Icons.delete),
                  //         ),
                  //     ],
                  //   ),
                  // );
                  return NoteTitle(
                    text: note.text,
                    onDeletePressed: () => deleteNote(note.id),
                    onEditPressed: () => updateNote(note),);
                }),
          ),
        ],
      ),
    );
  }
}
