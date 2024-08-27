/// An abstract class that defines a cloneable object.
///
/// Classes that implement [Cloneable] must provide a [clone] method,
/// which returns a new instance of the object with identical properties.
/// This ensures that the cloned object is separate in memory, allowing
/// for safe modifications without affecting the original object.
abstract class Cloneable<T> {
  /// Creates a clone of the object.
  ///
  /// This method should return a new instance of type [T] with the same
  /// properties as the original object. It ensures that the cloned object
  /// is a deep copy, meaning all nested objects, lists, or collections within
  /// the object are also newly instantiated and not merely references to the
  /// original ones.
  ///
  /// The cloned object should be entirely independent of the original,
  /// allowing both objects to be modified without impacting each other.
  ///
  /// Returns:
  /// - A new instance of type [T] that is a deep copy of the current object.
  ///
  /// Example usage:
  /// ```
  ///class Staff extends Cloneable<Staff> {
  ///  String name;
  ///  List<int> ratings;
  ///
  ///  @override
  ///  Staff clone() {
  ///    return Staff(
  ///      name: name,
  ///      ratings: List.from(ratings),
  ///    );
  ///  }
  ///}
  /// ```
  T clone();
}
