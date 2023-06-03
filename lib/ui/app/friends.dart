import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:sangu/ui/widgets/add_friends_or_group_list_tile.dart';
import 'package:uuid/uuid.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _allFriends = [];
  final uuid = const Uuid();
  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundFriends = [];
  Map<String, dynamic> _user = {};

  @override
  initState() {
    getUserDetail();
    fetchFriend();

    super.initState();
  }

  Future fetchFriend() async {
    final toResult = await _db.collection('friends')
        .where('to_email', isEqualTo: _auth.currentUser?.email)
        .where('status', isEqualTo: 1)
        .get();
    final fromResult = await _db.collection('friends')
        .where('from_email', isEqualTo: _auth.currentUser?.email)
        .where('status', isEqualTo: 1)
        .get();
    final result = toResult.docs + fromResult.docs;

    if (result.isEmpty) {
      return;
    }

    for (var doc in result) {
      final data = doc.data();
      _allFriends.add(data);
    }

    setState(() {
      _foundFriends = _allFriends;
    });
  }

  Future getUserDetail() async {
    final results = await _db.collection('users')
        .where('email', isEqualTo: _auth.currentUser!.email!)
        .limit(1)
        .get();

    if (results.docs.isEmpty) {
      return;
    }

    final doc = results.docs.first;
    final data = doc.data();
    setState(() {
      _user = data;
    });
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFriends;
    } else {
      results = _allFriends
          .where((user) {
              return user['email'].toLowerCase().contains(enteredKeyword.toLowerCase());
            }
          )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundFriends = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_foundFriends);
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            MaterialTextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              keyboardType: TextInputType.text,
              labelText: 'Search a Friend',
              hint: 'Search or Add',
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                  foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    ),
                  ),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final focus = FocusScope.of(context);

                  showDialog(
                      context: context,
                      builder: (context) {
                        return Center(
                          child: SpinKitCircle(
                            size: 125,
                            duration: const Duration(seconds: 2),
                            itemBuilder: (BuildContext context, int index){
                              final colors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary, Colors.white];
                              final color = colors[index % colors.length];

                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        );
                      }
                  );

                  if (_searchController.text == _auth.currentUser?.email || _searchController.text == _user['username']) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('You cannot add yourself'),
                      ),
                    );
                    navigator.pop();
                    return;
                  }

                  if (EmailValidator.validate(_searchController.text)) {
                    await addFriendByEmail(focus: focus, messenger: messenger, navigator: navigator, email: _searchController.text);
                  }
                  else {
                    await addFriendByUsername(focus: focus, messenger: messenger, navigator: navigator, username: _searchController.text);
                  }

                  navigator.pop();
                  _searchController.clear();
                  focus.unfocus();

                },
                child: const Text('Add'),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text('* To add friend input username or email'),
            const SizedBox(
              height: 20,
            ),
            /*const Text('Groups'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Theme.of(context).colorScheme.onSecondary,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  // todo: create a group
                },
                child: ListTile(
                  title: const Text('Create a group'),
                  leading: Icon(Icons.group_add_outlined, color: Theme.of(context).colorScheme.primary,),
                ),
              ),
            ),
            Expanded(
                child:_foundFriends.isNotEmpty ? ListView.builder(
                  itemCount: _foundFriends.length,
                  itemBuilder: (context, index) {
                    var user = _foundFriends[index];
                    return AddFriendsOrGroupListTile(
                        isGroup: true,
                        name: user['name'],
                        username: user['name'],
                        onClick: () {

                        },
                    );
                  },
                ) : const Text( 'No results found', style: TextStyle(fontSize: 18)),
            ),
            Divider(height: 5, thickness: 2, color: Theme.of(context).colorScheme.primary,),
            const SizedBox(height: 10),*/
            const Text('Friends'),
            const SizedBox(height: 10),
            Expanded(
                child:_foundFriends.isNotEmpty ? ListView.builder(
                  itemCount: _foundFriends.length,
                  itemBuilder: (context, index) => Card(
                    // key: ValueKey(_foundFriends[index]["id"]),
                    color: Theme.of(context).colorScheme.secondary,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Text(
                        _foundFriends[index]['to_username'].toString(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(_foundFriends[index]['to_username']),
                    ),
                  ),
                ) : const Text( 'No results found', style: TextStyle(fontSize: 18)),
            ),

            /*const Text('Groups'),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Theme.of(context).colorScheme.onSecondary,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  print('kontol');
                },
                child: ListTile(
                  title: const Text('Create a group'),
                  leading: Icon(Icons.group_add_outlined, color: Theme.of(context).colorScheme.primary,),
                ),
              ),
            ),
            Divider(height: 5, thickness: 2, color: Theme.of(context).colorScheme.primary,),
            const SizedBox(height: 10),
            const Text('Friends'),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top - 300,
              child: _foundUsers.isNotEmpty ? ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => Card(
                  key: ValueKey(_foundUsers[index]["id"]),
                  color: Colors.amberAccent,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Text(
                      _foundUsers[index]["id"].toString(),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(_foundUsers[index]['name']),
                    subtitle: Text(
                        '${_foundUsers[index]["age"].toString()} years old'),
                  ),
                ),
              ) : const Text( 'No results found', style: TextStyle(fontSize: 18)),
            ),*/
          ],
        ),
    );
  }

  Future addFriendByEmail({messenger = ScaffoldMessengerState, navigator = NavigatorState, focus = FocusScopeNode, email = String}) async {
    final getUserByEmail = await _db.collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (getUserByEmail.docs.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    final userSearched = getUserByEmail.docs.first.data();
    final getAddedBackUser = await _db.collection('friends')
        .where('to_email', isEqualTo: _auth.currentUser?.email)
        .get();

    // add friend
    if (getAddedBackUser.docs.isEmpty) {
      final getFriendRequest = await _db.collection('friends')
          .where('from_email', isEqualTo: _auth.currentUser?.email)
          .where('to_email', isEqualTo: userSearched['email'])
          .get();

      if (getFriendRequest.docs.isNotEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Friend request already sent'),
          ),
        );
        return;
      }

      await _db.collection('friends').doc(uuid.v4()).set({
        'to_email': userSearched['email'],
        'to_username': userSearched['username'],
        'from_email': _auth.currentUser?.email,
        'from_username': _user['username'],
        'status': 0,
      }, SetOptions(merge: true));

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Friend request sent'),
        ),
      );
    }
    // accept friend
    else {
      for (var doc in getAddedBackUser.docs) {
        final data = doc.data();
        if (data['from_email'] == userSearched['email'] && data['status'] == 0){
          await _db.collection('friends').doc(doc.id).set({
            'to_email': _auth.currentUser?.email,
            'to_username': _user['username'],
            'from_email': userSearched['email'],
            'from_username': userSearched['username'],
            'status': 1,
          }, SetOptions(merge: true));
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You are now friends'),
            ),
          );
          setState(() {
            _allFriends.add(data);
          });
          return;
        }
        else if (data['from_email'] == userSearched['email'] && data['status'] == 1){
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You are already friends'),
            ),
          );
          return;
        }
      }
    }
  }

  Future addFriendByUsername({messenger = ScaffoldMessengerState, navigator = NavigatorState, focus = FocusScopeNode, username = String}) async {
    final getUserByUsername = await _db.collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (getUserByUsername.docs.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    final userSearched = getUserByUsername.docs.first.data();
    final getAddedBackUser = await _db.collection('friends')
        .where('to_email', isEqualTo: _auth.currentUser?.email)
        .get();

    // add friend
    if (getAddedBackUser.docs.isEmpty) {
      final getFriendRequest = await _db.collection('friends')
          .where('from_email', isEqualTo: _auth.currentUser?.email)
          .where('to_email', isEqualTo: userSearched['email'])
          .get();

      if (getFriendRequest.docs.isNotEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Friend request already sent'),
          ),
        );
        return;
      }

      await _db.collection('friends').doc(uuid.v4()).set({
        'to_email': userSearched['email'],
        'to_username': userSearched['username'],
        'from_email': _auth.currentUser?.email,
        'from_username': _user['username'],
        'status': 0,
      }, SetOptions(merge: true));

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Friend request sent'),
        ),
      );
    }
    // accept friend
    else {
      for (var doc in getAddedBackUser.docs) {
        final data = doc.data();
        if (data['from_email'] == userSearched['email'] && data['status'] == 0){
          await _db.collection('friends').doc(doc.id).set({
            'to_email': _auth.currentUser?.email,
            'to_username': _user['username'],
            'from_email': userSearched['email'],
            'from_username': userSearched['username'],
            'status': 1,
          }, SetOptions(merge: true));
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You are now friends'),
            ),
          );
          setState(() {
            _allFriends.add(data);
          });
          return;
        }
        else if (data['from_email'] == userSearched['email'] && data['status'] == 1){
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You are already friends'),
            ),
          );
          return;
        }
      }
    }
  }


}
