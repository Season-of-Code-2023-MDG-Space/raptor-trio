import 'package:flutter/material.dart';
import 'package:DocuFind/utils/navigation.dart';
import 'package:DocuFind/widgets/app_bar.dart';
import 'package:DocuFind/utils/constants.dart';

class HomePage extends StatelessWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: Constants.appName,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: const Text('Open File', style: TextStyle(color:Colors.black,),),
          onPressed: () async {openFilePage(context);},
        ),
        ),
      backgroundColor: Constants.bodyColor,
      );
  }
}