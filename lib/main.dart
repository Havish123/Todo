import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TO_DO Application",
      home: todo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class todo extends StatefulWidget {
  @override
  _todoState createState() => _todoState();
}

class Todo {
  int id;
  String task;
  bool boolean;

  Todo({this.id, this.task, this.boolean});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'boolean': boolean,
    };
  }
}

class _todoState extends State<todo> {
  List<Todo> tasklist = new List();

  // void navigateSecondPage() {
  //   Route route = MaterialPageRoute(builder: (context) => todo());
  //   Navigator.push(context, route).then(onGoBack);
  // }

  @override
  void initState() {
    super.initState();

    DataBaseHelper.instance.viewquery().then((value) {
      setState(() {
        value.forEach((element) {
          tasklist.add(Todo(
            id: element['col_id'],
            task: element['list'],
            boolean: true,
          ));
        });
      });
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Todos....'),
            content: TextField(
              onChanged: (value) {},
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter the items..."),
            ),
            actions: [
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5.0, right: 20.0),
                    child: CupertinoButton(
                      color: Colors.blue,
                      child: Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5.0, left: 30.0),
                    child: CupertinoButton(
                        color: Colors.blue,
                        child: Text('Add Items'),
                        onPressed: () {
                          setState(() async {
                            var text = _textFieldController.text;
                            var id = await DataBaseHelper.instance
                                .insert({DataBaseHelper.coloum: text});
                            setState(() {
                              tasklist.insert(
                                  0, Todo(id: id, task: text, boolean: true));
                              Navigator.pop(
                                context,
                              );
                            });

                            // Navigator.pop(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (BuildContext context) =>
                            //             new todo()));
                          });
                        },
                        padding: EdgeInsets.all(10)),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TO-DO Application'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _displayTextInputDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: tasklist.length,
          itemBuilder: (context, index) {
            return buildListTile(index);
          }),
    );
  }

  changeStyle(int index) {
    setState(() {
      tasklist[index].boolean = false;
    });
  }

  bool styleOBJ = true;

  ListTile buildListTile(int index) {
    return ListTile(
      title: Padding(
        padding: EdgeInsets.all(10),
        child: buildText(index),
      ),

      // leading: Text(tasklist[index].id.toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            child: Text('Done'),
            // padding: EdgeInsets.only(left: 30, right: 30),
            onPressed: () {
              changeStyle(index);
            },
          ),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteTask(tasklist[index].id);
              }),
        ],
      ),
    );
  }

  Text buildText(int index) {
    return Text(
      tasklist[index].task,
      style: tasklist[index].boolean
          ? TextStyle(decoration: TextDecoration.none, fontSize: 20)
          : TextStyle(decoration: TextDecoration.lineThrough, fontSize: 20),
    );
  }

  void _deleteTask(int id) async {
    await DataBaseHelper.instance.delete(id);
    setState(() {
      tasklist.removeWhere((element) => element.id == id);
    });
  }
}
