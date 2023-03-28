import 'package:flutter/material.dart';
import 'package:docufind/utils/navigation.dart';
import 'package:docufind/widgets/app_bar.dart';
import 'package:docufind/utils/constants.dart';
import 'package:docufind/models/history.dart';

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
                  items = items.reversed.toList();
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      items.length,
                          (index) =>
                              GestureDetector(
                                  onTap: (){
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