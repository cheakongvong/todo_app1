import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/data.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoProvider() {
    fetchTodos();
  }

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
      notifyListeners();
    });
  }

  Future<void> addTodo(String title) async {
    await FirebaseFirestore.instance.collection('todos').add({
      'title': title,
      'isCompleted': false,
    });
  }

  Future<void> updateTodo(String id, String title, bool isCompleted) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).update({
      'title': title,
      'isCompleted': isCompleted,
    });
  }

  Future<void> removeTodo(String id) async {
    await FirebaseFirestore.instance.collection('todos').doc(id).delete();
  }

  Future<void> toggleTodoStatus(int index) async {
    final todo = _todos[index];
    todo.toggleCompleted();

    await FirebaseFirestore.instance.collection('todos').doc(todo.id).update({
      'isCompleted': todo.isCompleted,
    });
  }
}
