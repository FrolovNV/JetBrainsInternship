//на всякий случай оставлю ссылку на гит:

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ListItems {
  var title = '';
  var tag = '';
  var color = Colors.black;

  ListItems(this.title, this.tag, this.color);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> myCustomList = [
    {"title": "Поступить в JetBrains", "tag": "Срочно", "color": Colors.red, 'done': false},
    {"title": "Поступить в JetBrains", "tag": "Срочно", "color": Colors.red, 'done': false}
  ];

  Future<void> addItemToList() async {
    var temp = await createAlertDialog(context);
    if (temp == null) {
      return;
    }
    setState(() {
      myCustomList.insert(0, temp,);
    });
  }

  //Alert Dialog for creating new todos with tags and color.
  Future<Map<String, dynamic>> createAlertDialog(BuildContext context) {
    //promise to return string
    Color currentColor = Color(0xff443a49);
    TextEditingController tagController =
    TextEditingController();
    TextEditingController titleController =
    TextEditingController(); //new texteditingc object
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter New Task: ",),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: new InputDecoration.collapsed(
                      hintText: 'Title of Task'
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: tagController,
                  decoration: new InputDecoration.collapsed(
                      hintText: 'Tag name of Task'
                  ),
                ),
                SizedBox(height: 10),
                ColorPicker(
                  color: currentColor,
                  onColorChanged: (Color color) =>
                      setState(() => currentColor = color),
                  heading: Text(
                    'Select color',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  subheading: Text(
                    'Select color shade',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ]
            ),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop({
                    'title': titleController.text.toString(),
                    'tag': tagController.text.toString(),
                    'color': currentColor,
                    'done': false,
                  });
                },
                color: Colors.cyan,
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.cyan,
              )
            ],
          );
        });
  }

  Future<void> changeColor(int index) async {
    var temp = await changeColorDialog(context, index);
    if (temp == null) {
      return;
    }
    setState(() {
      myCustomList[index]['color'] = temp;
    });
  }

  Future<Color> changeColorDialog(BuildContext context, int index) {
    Color currentColor = myCustomList[index]['color'];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Change Color: ",),
            content: Column(
                children: <Widget>[
                  ColorPicker(
                    color: currentColor,
                    onColorChanged: (Color color) =>
                        setState(() => currentColor = color),
                  ),
                ]
            ),
            actions: [
              MaterialButton(
                elevation: 5.0,
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(currentColor);
                },
                color: Colors.cyan,
              ),
              MaterialButton(
                elevation: 5.0,
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.cyan,
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: ReorderableListView(
          children:  <Widget>[
            for (var i = 0; i < myCustomList.length; i++)
              Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    child: Align(
                      child: Text("Удалить",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      ),
                      alignment: Alignment.center,
                    ),
                    color: Colors.red,
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      myCustomList.remove(myCustomList[i]);
                    });
                  },
                  child: ListTile(
                    title: Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              myCustomList[i]['title'],
                              style: TextStyle(
                                  fontSize: 16,
                                  decoration: (myCustomList[i]['done']) ? TextDecoration.lineThrough: TextDecoration.none
                              ),
                            ),
                            Text(
                              " "+ myCustomList[i]['tag'],
                              style: TextStyle(
                                  fontSize: 14,
                                  color: myCustomList[i]['color']),
                            )
                          ],
                        ),
                        Spacer(),
                        IconButton(icon: Icon(Icons.edit), onPressed: (){
                          changeColor(i);
                        }),
                        SizedBox(width: 20),
                      ],
                    ),
                    onTap: (){
                      setState(() {
                        myCustomList[i]['done'] = !myCustomList[i]['done'];
                      });
                    },
                  )
              )],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final Map<String, dynamic> newItem = myCustomList.removeAt(oldIndex);
              myCustomList.insert(newIndex, newItem);
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItemToList,
        child: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}

