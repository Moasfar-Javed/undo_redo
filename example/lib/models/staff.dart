import 'package:undo_redo/undo_redo.dart';

class Staff extends Cloneable<Staff> {
  String name;
  List<int> ratings;

  Staff({
    required this.name,
    required this.ratings,
  });

  @override
  Staff clone() {
    return Staff(
      name: name,
      ratings: List.from(ratings),
    );
  }
}
