import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sangu/helpers/firestore_manager.dart';

class AddFriendsOrGroupListTile extends StatefulWidget {
  final String name;
  final String username;
  final bool isGroup;

  const AddFriendsOrGroupListTile({
    Key? key,
    required this.isGroup,
    required this.name,
    required this.username,
  }) : super(key: key);

  @override
  State<AddFriendsOrGroupListTile> createState() => _AddFriendsOrGroupListTileState();
}

class _AddFriendsOrGroupListTileState extends State<AddFriendsOrGroupListTile> {
  final double modalBottomSheetItemHeight = 53;

  final FirestoreManager firestore = FirestoreManager();

  List<Widget> generateListTileGroup ({required BuildContext context}) {
    return [
      SizedBox(
        height: modalBottomSheetItemHeight,
        child: ListTile(
          title: const Text('Edit Group'),
          leading: Icon(Icons.edit_outlined , color: Theme.of(context).colorScheme.primary,),
          onTap: (){
            // todo edit group
          },
        ),
      ),
      SizedBox(
        height: modalBottomSheetItemHeight,
        child: ListTile(
          title: const Text('Leave Group', style: TextStyle(color: Colors.red),),
          leading: const Icon(Icons.logout_outlined , color: Colors.red,),
          onTap: () {
            // todo leave group
            print('Leaving group with ID: tes');
          },
        ),
      ),
    ];
  }

  List<Widget> generateListTilePerson ({required BuildContext context}) {
    return [
      SizedBox(
        height: modalBottomSheetItemHeight,
        child: ListTile(
          title: const Text('Remove Friend', style: TextStyle(color: Colors.red),),
          leading: const Icon(Icons.remove_circle_outline , color: Colors.red,),
          onTap: () {
            // todo remove friends provide idDocument
            // firestore.removeFriendFromDatabase(idDocument)
          },
        ),
      ),
    ];
  }

  List<Widget> generateListTile ({required BuildContext context}) {
    return widget.isGroup
        ? generateListTileGroup(context: context)
        : generateListTilePerson(context: context);
  }

  @override
  Widget build(BuildContext context) {
    int totalListTile = widget.isGroup
        ? generateListTileGroup(context: context).length
        : generateListTilePerson(context: context).length;

    double modalBottomSheetContainerHeight =
        modalBottomSheetItemHeight * totalListTile + 22.5;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: widget.isGroup ? Colors.grey.shade200 : Theme.of(context).colorScheme.secondary,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: (){
          showModalBottomSheet(
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))
              ),
              context: context,
              isScrollControlled: true,
              builder: (context) => SizedBox(
                height: modalBottomSheetContainerHeight,
                child: Column(
                  children: [
                    Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: const BoxDecoration(
                            color: Color(0xFF1F2128),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        margin: const EdgeInsets.only(bottom: 10, top: 2)
                    ),
                    ...generateListTile(context: context)
                  ],
                ),
              )

          );
        },
        child: ListTile(
          title: Text(widget.name),
          leading: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              child: Icon(widget.isGroup ? Icons.group_outlined : Icons.person_outline , color: Theme.of(context).colorScheme.primary,),
          ),
          subtitle: Text(widget.username),
        ),
      ),
    );
  }
}
