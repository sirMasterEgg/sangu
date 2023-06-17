import 'package:flutter/material.dart';

class AddUserListTile extends StatelessWidget {
  final String name;
  final String username;
  final Function() onClick;
  final Color iconColor;
  final Color tileColor;
  final IconData icon;
  final IconData type;
  const AddUserListTile({
    Key? key,
    required this.name,
    required this.username,
    required this.onClick,
    required this.iconColor,
    required this.icon,
    required this.tileColor,
    required this.type
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(type, color: Theme.of(context).colorScheme.primary,),
      ),
      title: Text(name),
      subtitle: Text(username),
      trailing: CircleAvatar(
        radius: 20,
        backgroundColor: iconColor,
        child: IconButton(
          onPressed: (){
            onClick();
          },
          icon: Icon(icon, color: iconColor==Colors.white?Theme.of(context).colorScheme.primary:Colors.white,),
        ),
      ),
    );
  }
}
