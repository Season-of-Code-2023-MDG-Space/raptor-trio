import 'package:flutter/material.dart';
import 'package:DocuFind/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final List<Widget> actions;
  final leadingIcon;

  const CustomAppBar(
      {
        Key? key,
        this.title = "",
        this.leadingIcon = null,
        this.actions = const []
      }
  ) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leadingIcon,
      title: Text(title, style: Constants.textStyle,),
      actions: actions,
      backgroundColor: Constants.appBarColor,
    );
  }
}