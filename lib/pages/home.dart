import 'package:flutter/material.dart';
import 'package:docufind/utils/navigation.dart';
import 'package:docufind/widgets/app_bar.dart';
import 'package:docufind/utils/constants.dart';
import 'package:docufind/models/history.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import "package:path/path.dart";
// class HomePage extends StatelessWidget {
//
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {return true;},
//         child: Scaffold(
//       appBar: const CustomAppBar(
//         title: Constants.appName,
//       ),
//       body: Container(
//         alignment: Alignment.center,
//         child: ElevatedButton(
//           child: const Text('Open File', style: TextStyle(color:Colors.red,),),
//           onPressed: () async {openFilePage(context);},
//           style: ElevatedButton.styleFrom(
//               alignment: Alignment.centerLeft,
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.black,
//               elevation: 10,
//               shape:  RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   side: BorderSide(color: Colors.red)
//               )
//           ),
//         ),
//         ),
//       backgroundColor: Constants.bodyColor,
//       ));
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePage createState() =>  _HomePage();
}

class _HomePage extends State<HomePage> {
  late DatabaseHelper dbHelper;
  @override
  void initState() {
    dbHelper = DatabaseHelper();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Constants.appName,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              openFilePage(context);
            },
          ),
        ],
      ),
      backgroundColor: Constants.bodyColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent documents',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Constants.textColor,
                ),
              ),
            ),
            FutureBuilder(
              future: dbHelper.getItems(),
              builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> items = snapshot.data!;
                  print(items.length);
                  items = items.reversed.toList();
                  print(items.length);
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      items.length,
                          (index) =>
                              GestureDetector(
                                  onTap: (){
                                    print("Container clicked");
                                    openFilePageFromHistory(
                                        this.context,
                                        items[index]['path'],
                                        items[index]['filename'],
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: Constants.buttonBorderColor,
                                        width: 5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          size: 48.0,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 16.0),
                                        Text(
                                          items[index]['filename'],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              )
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}



//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter App',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('My App'),
//           backgroundColor: Colors.blueAccent,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/flower.png',
//                 height: 200,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Welcome to my App!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Press me',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.blueAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
