import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/ui/widgets/home_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestoreManager = FirestoreManager();
  List<Map<String, dynamic>> costBills = [];
  List<Map<String, dynamic>> owedBills = [];
  num owed = 0;
  num cost = 0;
  int _selectedIndex = 0;

  Future<void> _loadUserData() async {
    costBills = [];
    owedBills = [];
    final results = await _firestoreManager.getInstance().collection('bills')
        .get();
    num tempOwned = 0;
    num tempCost = 0;
    for (var temp in results.docs) {
      var data = temp.data();
      bool owned = data["owner"]==_auth.currentUser!.email?true:false;
      for(var temp2 in data['detail']){
        if(temp2['email'] == _auth.currentUser!.email && !owned && temp2['status'] == "pending"){
          num total = 0;
          List<Map<String, dynamic>> items = [];
          for(var temp3 in temp2['items']){
            tempCost += temp3['price'];
            total += temp3['price'];
            items.add(temp3);
          }
          costBills.add({
            "to" : temp2['email'],
            "total" : total,
            "date": data['created_at'],
            "id": temp.id,
            "items": items,
          });
        }else if(temp2['email'] != _auth.currentUser!.email && owned && temp2['status'] == "pending"){
          num total = 0;
          for(var temp3 in temp2['items']){
            tempOwned += temp3['price'];
            total += temp3['price'];
          }
          owedBills.add({
            "from" : temp2['email'],
            "total" : total,
            "date": data['created_at'],
            "id": temp.id,
          });
        }
      }
    }

    setState(() {
      owed = tempOwned;
      cost = tempCost;
    });

  }

  Future<void> completePayment(String id, List<Map<String, dynamic>> items) async{
    await _firestoreManager.getInstance().collection('bills').doc(id).update({
      "detail": FieldValue.arrayRemove([
        {
          "email": _auth.currentUser!.email,
          "items": items,
          "status": "pending",
        }
      ])
    });
    await _firestoreManager.getInstance().collection('bills').doc(id).update({
      "detail": FieldValue.arrayUnion([
        {
          "email": _auth.currentUser!.email,
          "items": items,
          "status": "paid",
        }
      ])
    });
    _loadUserData();
  }

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeCard(
              title: "I'm owed!",
              value: int.parse(owed.toString()),
              warna: Theme.of(context).colorScheme.secondary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                HomeCard(
                  title: "My costs",
                  value: int.parse(cost.toString()),
                  warna: Theme.of(context).colorScheme.onSecondary,
                ),
                HomeCard(
                  title: "Total costs",
                  value: int.parse((owed-cost).toString()),
                  warna: Colors.white,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width/2-20,
                      onPressed: (){
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      color: _selectedIndex==0?Theme.of(context).colorScheme.secondary:Theme.of(context).colorScheme.onSecondary,
                      textColor: _selectedIndex==0?Colors.black:Colors.white,
                      child: const Text("Cost Bill", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    ),
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width/2-20,
                    onPressed: (){
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    color: _selectedIndex==1?Theme.of(context).colorScheme.secondary:Theme.of(context).colorScheme.onSecondary,
                    textColor: _selectedIndex==1?Colors.black:Colors.white,
                    child: const Text("Owed Bill", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  )
                ],
              ),
            ),
            _selectedIndex==0?
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: costBills.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.primary,),
                        ),
                        title: Text(costBills[index]['date'].toDate().toString().substring(0, 10) + " | Total: "+costBills[index]['total'].toString()),
                        subtitle: Text("To: "+costBills[index]['to']),
                        trailing: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            onPressed: (){
                              completePayment(costBills[index]['id'], costBills[index]['items']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Items Payed"),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      )
                  );
                }
              )
              :
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: owedBills.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.primary,),
                        ),
                        title: Text(owedBills[index]['date'].toDate().toString().substring(0, 10) + " | Total: "+owedBills[index]['total'].toString()),
                        subtitle: Text("From: "+owedBills[index]['from']),
                      )
                  );
                }
            )
          ],
        ),
      )
    );
  }
}


