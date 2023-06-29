import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sangu/helpers/currency_formatter.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/providers/picked_user_provider.dart';
import 'package:sangu/ui/app/app.dart';
import 'package:sangu/ui/widgets/add_user_list_tile.dart';
import 'package:uuid/uuid.dart';

class SummaryPage extends StatefulWidget {
  static const routeName = '/app/create/summary';
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  num getSubtotal(List<Map<String, dynamic>> data){
    num subtotal = 0;
    for(var item in data){
      subtotal += item["price"] * item["quantity"];
    }
    return subtotal;
  }

  final Uuid uuid = Uuid();
  final _firestoreManager = FirestoreManager();

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

              _firestoreManager.createBill(
                  uuid.v4(),
                  pickedUser: Provider.of<PickedUserProvider>(context, listen: false).pickedUsers,
                  pickedItem: Provider.of<PickedUserProvider>(context, listen: false).foodList
              );

              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AppPage.routeName);
            },
            backgroundColor: Colors.green,
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Consumer<PickedUserProvider>(
          builder: (context, PickedUserProvider data, widget){
            return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Lets check the summary !", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearPercentIndicator(
                          animation: true,
                          animateFromLastPercent: true,
                          lineHeight: 8.0,
                          animationDuration: 1000,
                          percent: 1,
                          progressColor: Theme.of(context).colorScheme.secondary,
                          barRadius: Radius.circular(10),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text("You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                                    for(var item in data.foodList[0])
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(item["item"],style: TextStyle(fontSize: 16)),
                                                  Padding(padding: const EdgeInsets.only(left: 24.0), child: Text("${item["quantity"].toString()} pcs",style: TextStyle(fontSize: 16))),
                                                  Padding(padding: const EdgeInsets.only(left: 24.0), child: Text("@${CurrencyFormat.convertToIdr(item["price"], 0)}",style: TextStyle(fontSize: 16))),
                                                ],
                                              ),
                                            ]
                                        ),
                                      ),
                                    Padding(padding: const EdgeInsets.symmetric(vertical: 4.0) ,child: Text("Total: ${CurrencyFormat.convertToIdr(getSubtotal(data.foodList[0]), 0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),)),
                                  ],
                                )
                              ]
                          )
                      ),
                      ListView.builder(
                          itemCount: data.pickedUsers.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index){
                            return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text(data.pickedUsers[index]["display_name"]??data.pickedUsers[index]["email"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                                        for(var item in data.foodList[index+1])
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(item["item"],style: TextStyle(fontSize: 16)),
                                                    Padding(padding: const EdgeInsets.only(left: 24.0), child: Text("${item["quantity"].toString()} pcs",style: TextStyle(fontSize: 16))),
                                                    Padding(padding: const EdgeInsets.only(left: 24.0), child: Text("@${CurrencyFormat.convertToIdr(item["price"], 0)}",style: TextStyle(fontSize: 16))),
                                                  ],
                                                ),
                                              ]
                                            ),
                                          ),
                                        Padding(padding: const EdgeInsets.symmetric(vertical: 4.0) ,child: Text("Total: ${CurrencyFormat.convertToIdr(getSubtotal(data.foodList[index+1]), 0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),)),
                                      ],
                                    )
                                  ]
                                )
                            );
                          }
                      ),
                    ]
                  )
                ),
            );
          }),
    );
  }
}
