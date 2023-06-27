import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:uuid/uuid.dart';

class CreateGroupPage extends StatefulWidget {
  static const routeName = '/app/create/create_group';
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _groupNameController = TextEditingController();
  List<Map<String, dynamic>> _addedFriends = [];
  List<Map<String, dynamic>> _allFriends = [];
  final FirestoreManager _firestoreManager = FirestoreManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null){
      fetchFriends();
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("SANGU"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_groupNameController.text.isNotEmpty && _addedFriends.isNotEmpty) {
            _firestoreManager.getInstance().doc('users/${_auth.currentUser!.uid}').get().then((value) {
              _addedFriends.add(value.data() as Map<String, dynamic>);
              _firestoreManager.updateGroup(uuid.v4(),
                name: _groupNameController.text,
                members: _addedFriends,
                owner: value.data() as Map<String, dynamic>,
                created_at: DateTime.now(),
              );
              Navigator.pop(context, true);
            });
          }
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
                      setState(() {
                        if (_addedFriends.any((friend) => friend['email'] == (allFriends['to']['email'] == _auth.currentUser!.email ? allFriends['from']['email'] : allFriends['to']['email']))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contact already added'),
                            ),
                          );
                          return;
                        }
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
  }
}
