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
      title:"TO_DO Application",
      home: todo(),
    );
  }
}
class todo extends StatefulWidget {
  @override
  _todoState createState() => _todoState();
}

class Todo{
  int id;
  String task;

  Todo({this.id,this.task});

  Map<String,dynamic> toMap(){
    return {
      'id':id,'task':task,
    };
  }
}
class _todoState extends State<todo> {

  List<Todo> tasklist=new List();

  @override
  void initState() {

    super.initState();

    DataBaseHelper.instance.viewquery().then((value){
      setState(() {
        value.forEach((element){
          tasklist.add(Todo(id:element['col_id'],task:element['list']));
        });
      });
    });

  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController=new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextField(
              onChanged: (value) {

              },
              controller: _textFieldController,
              decoration: InputDecoration(
                  hintText: "Text Field in Dialog"),
            ),
            actions: [
              new Row(

                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Container(
                    margin:EdgeInsets.only(left:5.0,right: 20.0),
                    child:CupertinoButton(

                      color: Colors.blue,
                      child: Text('Cancel'),
                      onPressed: (){
                        setState(() {
                          Navigator.pop(context);
                        });
                      },

                      padding: EdgeInsets.all(10),
                    ),
                  ),
                  Container(

                    margin:EdgeInsets.only(right:5.0,left: 30.0),
                    child:CupertinoButton(

                        color: Colors.blue,
                        child: Text('Add Items'),
                        onPressed: (){

                          setState(() async {
                            var text=_textFieldController.text;
                            var id=await DataBaseHelper.instance.insert({DataBaseHelper.coloum : text});
                            setState(() {
                              tasklist.insert(0, Todo(id:id,task: text));
                            });
                            Navigator.pop(context);
                          });
                        },padding: EdgeInsets.all(10)
                    ),
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
        actions: <Widget> [
          IconButton(icon:Icon(Icons.add),onPressed: () {
            _displayTextInputDialog(context);
          },
      ),],
      ),
      body: ListView.builder(
        itemCount: tasklist.length,
        itemBuilder: (context,index){
          return ListTile(
            title:Text(tasklist[index].task),

            leading: Text(tasklist[index].id.toString()),
            trailing: CupertinoButton(child: Text('Done'),padding: EdgeInsets.only(left:30,right: 30),
            onPressed: (){
              _deleteTask(tasklist[index].id);
            },),



          );
        }
      ),
    );
  }

  void _deleteTask(int id) async{
    await DataBaseHelper.instance.delete(id);
    setState(() {
      tasklist.removeWhere((element) => element.id==id);
    });
  }


}

