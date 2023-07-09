import 'package:flutter/material.dart';
import 'package:flutter_todo/QraphQL/graphql_service.dart';
import 'package:flutter_todo/models/todo_model.dart';

class AddTodoPage extends StatefulWidget {
  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  String title = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                // Create a new Todo object and pass it back to the previous page
                await GraphqlService()
                    .addTodo(title: title, description: description)
                    .then((value) => Navigator.pop(context));
              },
              child: Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
