import 'package:flutter/material.dart';
import 'package:notes_app/components/note_settings.dart';
import 'package:popover/popover.dart';

class NoteTitle extends StatelessWidget {
  final String text;
  final void Function()?  onEditPressed;
  final  void Function()?  onDeletePressed;
  
  const NoteTitle({super.key, required this.text, required this.onDeletePressed, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8), 
      ),
      margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
      child: ListTile(
        title: Text(text),
        trailing: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => showPopover(
                height: 100,
                width: 100,
                backgroundColor: Theme.of(context).colorScheme.background,
                context: context,
                 bodyBuilder: (context) => NoteSettings(
                  onEditTap: onEditPressed ,
                  onDeleteTap: onDeletePressed ,
                 ),
                 ),
              );
          }
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       onPressed: onEditPressed,
        //       icon: const Icon(Icons.edit),
        //       ),
        //       IconButton(
        //       onPressed: onDeletePressed,
        //       icon: const Icon(Icons.delete),
        //       ),
        //   ],
        // ),
      ),
    );
  }
}