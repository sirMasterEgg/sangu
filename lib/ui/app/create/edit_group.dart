import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:provider/provider.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/providers/selected_group_provider.dart';

class EditGroup extends StatefulWidget {
  static const routeName = '/app/create/edit_group';
  const EditGroup({super.key});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final _groupNameController = TextEditingController();
  List<Map<String, dynamic>> _addedFriends = [];
  List<Map<String, dynamic>> _allFriends = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null){
      fetchFriends();
      fetchGroupData();
    }
  }

  Future fetchGroupData() async {
    final idDocument = Provider.of<SelectedGroupProvider>(context, listen: false).idDocument;
    final getGroupData = await _firestoreManager.getInstance().collection('groups').doc(idDocument).get();

    final groupName = getGroupData.get('name');
    final groupMembers = getGroupData.get('members') as List<dynamic>;

    final List<Map<String, dynamic>> tempGroupMembers = groupMembers.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else {
        // Convert other dynamic values to Map<String, dynamic> format
        return { 'value' : item };
      }
    }).toList();

    tempGroupMembers.removeWhere((element) => element['email'] == _auth.currentUser!.email);

    setState(() {
      _groupNameController.text = groupName;
      _addedFriends = tempGroupMembers;
    });
  }

  Future fetchFriends() async {
    final getAllFriends = await _firestoreManager.getInstance().collection('friends').where('status', isEqualTo: 1).get();

    List<Map<String, dynamic>> tempFriends = [];
    for (DocumentSnapshot documentSnapshot in getAllFriends.docs) {
      String toEmail = documentSnapshot.get('to.email');
      String fromEmail = documentSnapshot.get('from.email');

      if (toEmail == _auth.currentUser!.email || fromEmail == _auth.currentUser!.email) {
        tempFriends.add(documentSnapshot.data() as Map<String, dynamic>);
      }
    }

    setState(() {
      _allFriends = tempFriends;
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedGroupProvider>(
      builder: (BuildContext context, SelectedGroupProvider provider, Widget? child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("SANGU"),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final groupName = _groupNameController.text;
                if (groupName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group name cannot be empty'),
                    ),
                  );
                  return;
                }

                if (_addedFriends.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add at least one friend'),
                    ),
                  );
                  return;
                }

                _firestoreManager.getInstance().doc('users/${_auth.currentUser!.uid}').get().then((value) {
                  _addedFriends.add(value.data() as Map<String, dynamic>);
                  _firestoreManager.updateGroup(provider.idDocument,
                    name: _groupNameController.text,
                    members: _addedFriends,
                    updated_at: DateTime.now(),
                  );
                  Navigator.pop(context, true);
                });

                // provider.updateGroup(groupName, tempAddedFriends);
                // Navigator.of(context).pop();
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 5,
              child: const Icon(Icons.check),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MaterialTextField(
                    controller: _groupNameController,
                    keyboardType: TextInputType.text,
                    hint: 'Group Name',
                    labelText: 'Group Name',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.groups_outlined),
                  ),
                  const SizedBox(height: 10.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 5,
                      alignment: WrapAlignment.start,
                      children: _addedFriends.map((user) {
                        final currUserDisplayName = user['display_name'] ?? user['username'] ?? user['email'];
                        return Chip(
                          label: Text(currUserDisplayName),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          onDeleted: () {
                            setState(() {
                              _addedFriends.remove(user);
                            });
                          },
                          elevation: 5,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allFriends.length,
                      itemBuilder: (context, index) {
                        final allFriends = _allFriends[index];
                        return ListTile(
                          title: Text("${allFriends['to']['email'] == _auth.currentUser!.email ? (allFriends['from']['display_name'] ?? allFriends['from']['username'] ?? allFriends['from']['email']) : (allFriends['to']['display_name'] ?? allFriends['to']['username'] ?? allFriends['to']['email'])}"),
                          onTap: () {
                            if (_addedFriends.any((friend) => friend['email'] == (allFriends['to']['email'] == _auth.currentUser!.email ? allFriends['from']['email'] : allFriends['to']['email']))) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact already added'),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _addedFriends.add(allFriends['to']['email'] == _auth.currentUser!.email ? allFriends['from'] : allFriends['to']);
                            });
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            )
        );
      },
    );
  }
}
