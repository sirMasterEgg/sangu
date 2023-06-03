import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sangu/ui/widgets/add_user_list_tile.dart';

class AddUserPage extends StatefulWidget {
  static const routeName = '/app/create/add_user';
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  List<Map<String, dynamic>> _users = [
    {"name": "victor", "email": "victor@gmail.com", "username": "victor",},
    {"name": "jason", "email": "jason@gmail.com", "username": "jje",},
    {"name": "daniel", "email": "daniel@gmail.com", "username": "kitsunne",},
  ];
  List<Map<String, dynamic>> _picked = [];
  final _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: Icon(
                Icons.navigate_before,
                color: Colors.white,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: "next",
            onPressed: (){

            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.navigate_next,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  animationDuration: 400,
                  percent: 0.3,
                  progressColor: Theme.of(context).colorScheme.secondary,
                  barRadius: Radius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: MaterialTextField(
                  controller: _searchController,
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
                  itemCount: _picked.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AddUserListTile(
                        name: _picked[index]["name"],
                        username: _picked[index]["username"],
                        icon: Icons.remove,
                        iconColor: Colors.red,
                        onClick: (){
                          setState(() {
                            _users.add(_picked[index]);
                            _picked.removeAt(index);
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
                itemCount: _users.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AddUserListTile(
                      name: _users[index]["name"],
                      username: _users[index]["username"],
                      icon: Icons.add,
                      iconColor: Colors.white,
                      onClick: (){
                        setState(() {
                          _picked.add(_users[index]);
                          _users.removeAt(index);
                        });
                      },
                    )
                  );
                }
              )
            ]
          )
        ),
      ),
    );
  }
}
