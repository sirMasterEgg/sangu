import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/providers/picked_user_provider.dart';
import 'package:sangu/ui/app/create/add_item.dart';
import 'package:sangu/ui/widgets/add_user_list_tile.dart';
import 'package:provider/provider.dart';

class AddUserPage extends StatefulWidget {
  static const routeName = '/app/create/add_user';
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _foundUsers = [];
  List<Map<String, dynamic>> _allGroups = [];
  bool _isLoading = true;
  final _firestoreManager = FirestoreManager();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    wrapper();
  }

  Future wrapper () async {
    final provider = Provider.of<PickedUserProvider>(context, listen: false);
    await fetchFriend();
    await fetchGroups();
    provider.refreshAll();
  }

  Future fetchFriend() async {
    final toResult = await _firestoreManager.getInstance().collection('friends')
        .where('to.email', isEqualTo: _auth.currentUser?.email)
        .where('status', isEqualTo: 1)
        .get();
    final fromResult = await _firestoreManager.getInstance().collection('friends')
        .where('from.email', isEqualTo: _auth.currentUser?.email)
        .where('status', isEqualTo: 1)
        .get();
    final result = toResult.docs + fromResult.docs;

    if (result.isEmpty) {
      return;
    }

    for (var doc in result) {
      final data = doc.data();
      var temp = parseUserWithoutName(data, _auth.currentUser!.email!);
      _allUsers.add(temp);
    }

    setState(() {
      _foundUsers = _allUsers;
    });
  }

  Future fetchGroups () async {
    final myUser = await _firestoreManager.getInstance().collection('users').doc(_auth.currentUser?.uid).get();

    final result = await _firestoreManager.getInstance().collection('groups')
        .where('members', arrayContains: myUser.data())
        .get();

    if (result.docs.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> tempGroups = [];
    for (var doc in result.docs) {
      final data = parseGroup(doc.data(), _auth.currentUser!.email!);
      tempGroups.add(data);
    }

    setState(() {
      _allGroups = tempGroups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SANGU"),
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FloatingActionButton(
              heroTag: "back",
              onPressed: (){
                Navigator.pop(context);
              },
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.navigate_before,
                color: Colors.white,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "next",
            onPressed: (){
              if(Provider.of<PickedUserProvider>(context, listen: false).pickedUsers.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please pick at least one user"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }else{
                Navigator.pushNamed(context, AddItemPage.routeName, arguments: -1);
              }
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.navigate_next,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Consumer<PickedUserProvider>(
        builder: (context, PickedUserProvider data, widget){
          return _isLoading ? Center(
            child: SpinKitCircle(
            size: 125,
            duration: const Duration(seconds: 2),
            itemBuilder: (BuildContext context, int index){
              final colors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.onSecondary];
              final color = colors[index % colors.length];

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        ) :
        SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Who we split among", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LinearPercentIndicator(
                  animation: true,
                  lineHeight: 8.0,
                  animationDuration: 1000,
                  percent: 0.2,
                  progressColor: Theme.of(context).colorScheme.secondary,
                  barRadius: Radius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MaterialTextField(
                  onChanged: (value){
                    setState(() {
                      _foundUsers = _allUsers.where((element) => element["display_name"].toString().toLowerCase().contains(value.toLowerCase())).toList();
                      _foundUsers += _allUsers.where((element) => element["username"].toString().toLowerCase().contains(value.toLowerCase())).toList();
                      _foundUsers += _allUsers.where((element) => element["email"].toString().toLowerCase().contains(value.toLowerCase())).toList();
                      _foundUsers = _foundUsers.toSet().toList();
                      _foundUsers.removeWhere((element) => data.pickedUsers.contains(element));
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  hint: 'Search',
                  labelText: 'Search',
                  textInputAction: TextInputAction.search,
                  enabled: true,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Picked', style: TextStyle(fontSize: 16),),
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.pickedUsers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AddUserListTile(
                        name: data.pickedUsers[index]["display_name"]??data.pickedUsers[index]["email"],
                        username: data.pickedUsers[index]["username"]??"",
                        icon: Icons.remove,
                        iconColor: Colors.red,
                        tileColor: Theme.of(context).colorScheme.secondary,
                        type: Icons.person,
                        onClick: (){
                          setState(() {
                            bool found = false;
                            for (var user in _foundUsers) {
                              if(user["email"] == data.pickedUsers[index]["email"]){
                                found = true;
                                break;
                              }
                            }
                            if(!found){
                              _foundUsers.add(data.pickedUsers[index]);
                            }
                            data.pickedUsers.removeWhere((element) => element["email"] == data.pickedUsers[index]["email"]);
                          });
                        },
                      )
                    );
                  }
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 1.0,
                  thickness: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Group', style: TextStyle(fontSize: 16),),
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allGroups.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: AddUserListTile(
                          name: _allGroups[index]["name"],
                          username: "Group",
                          icon: Icons.add,
                          iconColor: Colors.white,
                          tileColor: Theme.of(context).colorScheme.onSecondary,
                          type: Icons.group,
                          onClick: (){
                            setState(() {
                              final members = _allGroups[index]["members"];
                              for (var member in members) {
                                final temp = _allUsers.firstWhere((element) => element["email"] == member["email"]);
                                data.pickedUsers.removeWhere((element) => element["email"] == member["email"]);
                                data.pickedUsers.add(temp);
                                _foundUsers.removeWhere((element) => element["email"] == member["email"]);
                              }
                            });
                          },
                        )
                    );
                  }
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 1.0,
                  thickness: 1.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Friend List', style: TextStyle(fontSize: 16),),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foundUsers.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AddUserListTile(
                      name: _foundUsers[index]["display_name"]??data.pickedUsers[index]["email"],
                      username: _foundUsers[index]["username"]??"",
                      icon: Icons.add,
                      iconColor: Colors.white,
                      tileColor: Theme.of(context).colorScheme.onSecondary,
                      type: Icons.person,
                      onClick: (){
                        setState(() {
                          //check if user is already added
                          bool isAdded = false;
                          for (var user in data.pickedUsers) {
                            if (user["email"] == _foundUsers[index]["email"]){
                              isAdded = true;
                              _foundUsers.removeWhere((element) => element["email"] == user["email"]);
                              break;
                            }
                          }
                          if (isAdded){
                            SnackBar snackBar = const SnackBar(content: Text("User already added"));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }else{
                            data.pickedUsers.add(_foundUsers[index]);
                            _foundUsers.removeWhere((element) => data.pickedUsers.contains(element));
                          }
                        });
                      },
                    )
                  );
                }
              )
            ]
          )
        ),
      );
    })
    );
  }

  Map<String, dynamic> parseUserWithoutName(Map<String, dynamic> user, String emailCurrentUser){
    if (user['to']['email'] == emailCurrentUser){
      return {
        'display_name': user['from']['display_name'] ?? user['from']['username'] ?? user['from']['email'],
        'username' : user['from']['username'],
        'email' : user['from']['email'],
      };
    }
    else {
      return {
        'display_name': user['to']['display_name'] ?? user['to']['username'] ?? user['to']['email'],
        'username' : user['to']['username'],
        'email' : user['to']['email'],
      };
    }
  }

  Map<String, dynamic> parseGroup(Map<String, dynamic> group, String emailCurrentUser) {
    final members = group['members'].where((element) => element['email'] != emailCurrentUser).toList();
    List<Map<String, dynamic>> member = [];

    for (var i = 0; i < members.length; i++) {
      member.add({
        'display_name': members[i]['display_name'] ?? members[i]['username'] ?? members[i]['email'],
        'username' : members[i]['username'],
        'email' : members[i]['email'],
      });
    }

    return {
      'name': group['name'],
      'members': member,
    };
  }
}
