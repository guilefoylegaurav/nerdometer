import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nerdometer/quiz.dart';

Quiz quiz;
List<Results> results;

void main() => runApp(MaterialApp(
  home: MyScreen(),
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primaryColor: Colors.white),

));


class MyScreen extends StatefulWidget {

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {

  Future<void> fetchQuestions() async
  {
    var response = await http.get('https://opentdb.com/api.php?amount=10');
    var decResp = jsonDecode(response.body);
    quiz = Quiz.fromJson(decResp);
    results = quiz.results;
    print(results);


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
         appBar: AppBar(title: Text('Nerdometer'),elevation: 0.0,centerTitle: true,),
         body: RefreshIndicator(
           onRefresh: fetchQuestions,
           child: FutureBuilder(
             future: fetchQuestions(),
             builder: (BuildContext context, AsyncSnapshot snapshot) {
               switch(snapshot.connectionState) {
                 case ConnectionState.none:
                   return Center(
                     child: Text('No net'),
                   );
                 case ConnectionState.waiting:
                   return Center(
                     child: CircularProgressIndicator(),
                   );
                 case ConnectionState.active:
                 case ConnectionState.done:
                   if (snapshot.hasError)
                   {
                     return Center(child: Text('No net'));
                   }
                   return questionList();




               }
               return null;
             },
           ),
         ),

      );
  }
}

ListView questionList()
{
  return ListView.builder(itemCount:results.length,itemBuilder: (context, index) =>
  Card(
    color: Colors.white,
    child: ExpansionTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(results[index].question.replaceAll("&quot;", '\"').replaceAll("&#039;", '\'').replaceAll('&eacute;', 'e'),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold
            ) ,),
          FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FilterChip(

                  onSelected: (b) {},
                  label: Text(results[index].category, style: TextStyle(color: Colors.white, fontSize: 15.0),),
                  backgroundColor: Colors.brown[200],
                ),
               /* FilterChip(
                  backgroundColor: Colors.black,

                  onSelected: (b){},
                  label: Text(results[index].difficulty, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                ),*/
              ],
            ),
          ),
        ],
      ),
      children: results[index].allAnswer.map((m) {
        return AnswerWidget(results, index, m);
      }).toList(),

    ),
  ));
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;
  AnswerWidget(this.results, this.index, this.m);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.brown;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer){
               c = Colors.green;
          }
          else
            {
              c = Colors.red;
            }
        });
      },
      title: Text(widget.m.replaceAll("&quot;", '\"').replaceAll("&#039;", '\'').replaceAll('&eacute;', 'e'), textAlign: TextAlign.center,style: TextStyle(
        color : c,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
      ),),
    );
  }
}

