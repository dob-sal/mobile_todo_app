import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbhelper.dart';

DbHelper helper = DbHelper();
final List<String> detailViewPopupChoices = const <String>[
  'Save Todo & Back',
  'Delete Todo',
  'Back to List',
];

const mnuSave = 'Save Todo & Back';
const mnuDelete = 'Delete Todo';
const mnuBack = 'Back to List';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  TodoDetail(this.todo);

  @override
  State<StatefulWidget> createState() => TodoDetailState(todo);
}

class TodoDetailState extends State {
  Todo todo;
  TodoDetailState(this.todo);
  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleEditingController.text = todo.title;
    descriptionEditingController.text = todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(todo.title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: select,
              itemBuilder: (BuildContext context) {
                return detailViewPopupChoices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  TextField(
                    controller: titleEditingController,
                    style: textStyle,
                    onChanged: (value) => updateTitle(),
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: descriptionEditingController,
                      style: textStyle,
                      onChanged: (value) => updateDescription(),
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: DropdownButton<String>(
                      items: _priorities.map((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                      style: textStyle,
                      value: retrievePriority(todo.priority),
                      onChanged: (value) => updatePriority(value),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  void select(String value) async {
    int result;
    switch (value) {
      case mnuSave:
        save();
        break;
      case mnuDelete:
        Navigator.pop(context, true);
        if (todo.id == null) {
          return;
        }
        result = await helper.deleteTodo(todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
              title: Text("Delete Todo"),
              content: Text("The Todo has been deleted!"));
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  void save() async {
    todo.date = DateFormat.yMd().format(DateTime.now());
    if (todo.id != null) {
      helper.updateTodo(todo);
    } else {
      helper.insertTodo(todo);
    }
    Navigator.pop(context, true);
  }

  void updatePriority(String value) {
    switch (value) {
      case "High":
        todo.prioriry = 1;
        break;
      case "Medium":
        todo.prioriry = 2;
        break;
      case "Low":
        todo.prioriry = 3;
        break;
      default:
        todo.prioriry = 3;
    }

    setState(() {
      _priority = value;
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle(){
    todo.title = titleEditingController.text;
  }

  void updateDescription(){
    todo.description = descriptionEditingController.text;
  }
}
