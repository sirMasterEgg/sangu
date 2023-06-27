import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/providers/selected_group_provider.dart';
import 'package:sangu/ui/app/create/edit_group.dart';

class AddFriendsOrGroupListTile extends StatefulWidget {
  final String name;
  final String username;
  final bool isGroup;
  final dynamic friendObject;
  final Function callbackRefresh;
  final Function? callbackRefreshGroup;

  const AddFriendsOrGroupListTile({
    Key? key,
    required this.isGroup,
    required this.name,
    required this.username,
    required this.friendObject,
    required this.callbackRefresh,
    this.callbackRefreshGroup,
  }) : super(key: key);

  @override
  State<AddFriendsOrGroupListTile> createState() => _AddFriendsOrGroupListTileState();
}

class _AddFriendsOrGroupListTileState extends State<AddFriendsOrGroupListTile> {
  final double modalBottomSheetItemHeight = 53;

  final FirestoreManager _firestore = FirestoreManager();

  Future<int?> _groupLeaveDialog({required Map<String, dynamic> group, required bool isOwner}) async {
    final text = isOwner ? Text('Would you like to delete ${group['name']} group?') : Text('Do you want to leave ${group['name']} group?');
    final button = isOwner ? [
      TextButton(
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
        onPressed: () {
          Navigator.of(context).pop(2);
        },
      ),
      TextButton(
        child: const Text('Leave', style: TextStyle(color: Colors.orange),),
        onPressed: () {
          Navigator.of(context).pop(1);
        },
      ),
      TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop(0);
        },
      ),
    ] : [
      TextButton(
        child: const Text('Leave', style: TextStyle(color: Colors.red),),
        onPressed: () {
          Navigator.of(context).pop(1);
        },
      ),
      TextButton(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop(0);
        },
      ),
    ];
    return showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                text,
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            ...button
          ],
        );
      },
    );
  }

  Future<bool?> _friendDeleteConfirmationDialog(Map<String, dynamic> friend) async {
    final friendName = friend['display_name'] ?? friend['username'] ?? friend['email'];
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to remove $friendName from your friend list?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
              onPressed: () {
                return Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                return Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> generateListTileGroup ({required BuildContext context}) {
    return [
      Consumer<SelectedGroupProvider>(
        builder: (BuildContext context, SelectedGroupProvider provider, Widget? child) {
          return SizedBox(
            height: modalBottomSheetItemHeight,
            child: ListTile(
              title: const Text('Edit Group'),
              leading: Icon(Icons.edit_outlined , color: Theme.of(context).colorScheme.primary,),
              onTap: () async {
                final navigator = Navigator.of(context);
                final groupId = await _firestore.findGroupIdByElement(widget.friendObject);

                if (groupId == null){
                  return;
                }

                provider.setIdDocument(groupId);
                final editStatus = await navigator.pushNamed(EditGroup.routeName);
                if (editStatus == true){
                  navigator.pop();
                  widget.callbackRefreshGroup!();
                }
              },
            ),
          );
        },
      ),
      SizedBox(
        height: modalBottomSheetItemHeight,
        child: ListTile(
          title: const Text('Leave Group', style: TextStyle(color: Colors.red),),
          leading: const Icon(Icons.logout_outlined , color: Colors.red,),
          onTap: () async {
            final navigator = Navigator.of(context);
            int? dialogResult;
            if (widget.friendObject['owner']['email'] == FirebaseAuth.instance.currentUser!.email) {
              dialogResult = await _groupLeaveDialog(group: widget.friendObject, isOwner: true);
            } else {
              dialogResult = await _groupLeaveDialog(group: widget.friendObject, isOwner: false);
            }

            switch (dialogResult){
              case 1: {
                final docId = await _firestore.findGroupIdByElement(widget.friendObject);
                if (docId != null && FirebaseAuth.instance.currentUser != null){
                  await _firestore.leaveGroup(idDocument: docId, email: FirebaseAuth.instance.currentUser!.email);
                  navigator.pop();
                  widget.callbackRefresh();
                }
                break;
              }
              case 2: {
                final groupId = await _firestore.getInstance().collection('groups')
                    .where('owner.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .get();

                if (groupId.docs.isNotEmpty){
                  await _firestore.deleteGroup(groupId.docs.first.id);
                  navigator.pop();
                  widget.callbackRefresh();
                  return;
                }
                break;
              }
              default: {
                navigator.pop();
                break;
              }
            }
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
          onTap: () async {
            final navigator = Navigator.of(context);
            final dialogResult = await _friendDeleteConfirmationDialog(widget.friendObject);

            if (dialogResult != null){
              if (dialogResult){
                var documentId = await _firestore.getInstance().collection('friends')
                    .where('from.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .where('to.email', isEqualTo: widget.friendObject['email'])
                    .get();

                if(documentId.docs.isNotEmpty){
                  await _firestore.removeFriendFromDatabase(documentId.docs.first.id);
                  navigator.pop();
                  widget.callbackRefresh();
                  return;
                }

                documentId = await _firestore.getInstance().collection('friends')
                    .where('to.email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .where('from.email', isEqualTo: widget.friendObject['email'])
                    .get();

                if(documentId.docs.isNotEmpty){
                  await _firestore.removeFriendFromDatabase(documentId.docs.first.id);
                  navigator.pop();
                  widget.callbackRefresh();
                  return;
                }
              }
              else {
                navigator.pop();
              }
            }
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
