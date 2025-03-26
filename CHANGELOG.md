## 0.1.5

This version of the package includes
* Addition of a `history()` method to `UndoRedoManager` to get the state history

## 0.1.4

This version of the package includes
* Addition a `dispose()` method to `UndoRedoManager` to completely discard the state history
* Calling initialize on an already initialized manager disposes the previous state history

## 0.1.3

Made the `CloneableMixin` accessible

## 0.1.2

This version of the package includes
* `CloneableMixin` for classes that already extend a class
* `maxMemory` parameter for `UndoRedoManager` to limit the memory size 

## 0.0.2

Updated descriptions to match pub.dev's guidelines

## 0.0.1

Initial Version of the package.
* Includes the `UndoRedoManager` for simple undo/redo state management
* Includes the `Cloneable` interface to provide a method to create a deep-copy of an object