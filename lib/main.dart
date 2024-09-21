import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app1/screens/todo_list_screen.dart';

import 'components/colors.dart';
import 'todo_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: Colors.white, width: 2),
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.green;
            }
            return Colors.transparent;
          }),
          checkColor:
              MaterialStateProperty.all(Colors.white), // Check mark color
        ),
        colorSchemeSeed: AppColors.primaryColor,
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}
