/// A mixin that provides cloning functionality for objects.
///
/// Classes that mix in [CloneableMixin] must implement the [clone] method,
/// which is expected to return a new instance of the object with identical
/// properties. This allows for the creation of deep copies of objects,
/// ensuring that the cloned object is independent of the original and
/// can be modified without affecting it.
///
/// By using this mixin, you can add cloning capabilities to classes
/// that already extend other classes, as Dart does not support multiple
/// inheritance.
///
/// Example usage:
/// ```dart
/// class BaseClass {
///   String id;
///   BaseClass(this.id);
/// }
///
/// class Staff extends BaseClass with CloneableMixin<Staff> {
///   String name;
///   List<int> ratings;
///
///   Staff(String id, this.name, this.ratings) : super(id);
///
///   @override
///   Staff clone() {
///     return Staff(
///       id,
///       name,
///       List.from(ratings),
///     );
///   }
/// }
///
/// void main() {
///   final staff1 = Staff('1', 'Alice', [5, 4, 3]);
///   final staff2 = staff1.clone();
///
///   staff2.name = 'Bob'; // Modify the clone without affecting the original.
///   staff2.ratings.add(2);
///
///   print(staff1.name); // Outputs: Alice
///   print(staff1.ratings); // Outputs: [5, 4, 3]
///   print(staff2.name); // Outputs: Bob
///   print(staff2.ratings); // Outputs: [5, 4, 3, 2]
/// }
/// ```
mixin CloneableMixin<T> {
  /// Creates a clone of the object.
  ///
  /// This method should return a new instance of type [T] with the same
  /// properties as the original object. The cloned object must be a deep copy,
  /// meaning any nested objects, lists, or collections are also newly
  /// instantiated and not merely references to the original.
  ///
  /// The cloned object should be entirely independent of the original,
  /// allowing both to be modified without impacting each other.
  ///
  /// Returns:
  /// - A new instance of type [T] that is a deep copy of the current object.
  T clone();
}
