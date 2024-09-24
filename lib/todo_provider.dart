import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/data.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoProvider() {
    // Initialize and fetch todos in real-time
    fetchTodos();
  }

  // Fetch todos from Firestore in real-time and update local state
  void fetchTodos() {
    FirebaseFirestore.instance
        .collection('todos')
        .snapshots()
        .listen((snapshot) {
      _todos.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data();
        _todos.add(Todo(
          title: data['title'],
          isCompleted: data['isCompleted'],
          id: doc.id,
        ));
      }
      notifyListeners(); // Notify listeners about the updated todo list
    });
  }

  // Add a new todo to Firestore
  Future<void> addTodo(String title) async {
    await FirebaseFirestore.instance.collection('todos').add({
      'title': title,
      'isCompleted': false, // New todos are incomplete by default
    });
    // No need to manually add to _todos since the real-time listener will update it
  }

  // Update an existing todo's title and/or completion status in Firestore
  Future<void> updateTodo(String id, String title, bool isCompleted) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).update({
      'title': title,
      'isCompleted': isCompleted,
    });
    // No need to manually update _todos since the real-time listener will update it
  }

  // Remove a todo from Firestore
  Future<void> removeTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
    // No need to manually remove from _todos since the real-time listener will update it
  }

  // Toggle the completion status of a todo
  Future<void> toggleTodoStatus(int index) async {
    final todo = _todos[index];

    // Toggle the completed status locally
    todo.toggleCompleted();

    // Update the Firestore document with the new completion status
    await FirebaseFirestore.instance.collection('todos').doc(todo.id).update({
      'isCompleted': todo.isCompleted,
    });
    // No need to manually update _todos since the real-time listener will update it
  }
}
