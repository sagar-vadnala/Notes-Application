import 'package:isar/isar.dart';

//to generate the file
part 'note.g.dart';


@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String text;
}