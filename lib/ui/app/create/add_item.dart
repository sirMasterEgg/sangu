import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sangu/helpers/currency_formatter.dart';
import 'package:sangu/providers/picked_user_provider.dart';
import 'package:sangu/ui/widgets/add_user_list_tile.dart';

class AddItemPage extends StatefulWidget {
  static const routeName = '/app/create/add_food';
  final int userIndex;
  const AddItemPage({Key? key, required this.userIndex}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  int get userIndex => widget.userIndex;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  List<Map<String, dynamic>> _pickedItem = [];
  num subtotal = 0;

  void sumSubtotal(){
    subtotal = 0;
    for(var item in _pickedItem){
      subtotal += (item["price"] * item["quantity"]);
    }
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
              if(_pickedItem.length == 0){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please add at least one item"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }else{
                if(Provider.of<PickedUserProvider>(context, listen: false).foodList.length == userIndex+1){
                  Provider.of<PickedUserProvider>(context, listen: false).addFoodList(_pickedItem);
                }else{
                  Provider.of<PickedUserProvider>(context, listen: false).setFoodList(_pickedItem, userIndex+1);
                }
                Navigator.pushNamed(context, AddItemPage.routeName, arguments: userIndex+1);
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
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("What did ${userIndex==-1?"you":data.pickedUsers[userIndex]["display_name"]} buy ?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearPercentIndicator(
                    animation: true,
                    animateFromLastPercent: true,
                    lineHeight: 8.0,
                    animationDuration: 1000,
                    percent: (0.2 + ((userIndex+2)/(data.pickedUsers.length+1))-0.3),
                    progressColor: Theme.of(context).colorScheme.secondary,
                    barRadius: Radius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: MaterialTextField(
                    onChanged: (value){
                      setState(() {

                      });
                    },
                    controller: _itemNameController,
                    keyboardType: TextInputType.text,
                    hint: 'Item Name',
                    labelText: 'Item Name',
                    textInputAction: TextInputAction.next,
                    enabled: true,
                    prefixIcon: const Icon(Icons.shopping_bag),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: MaterialTextField(
                            onChanged: (value){
                              setState(() {

                              });
                            },
                            controller: _itemQuantityController,
                            keyboardType: TextInputType.number,
                            hint: 'Quantity',
                            labelText: 'Quantity',
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            prefixIcon: const Icon(Icons.add_circle),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: MaterialTextField(
                            onChanged: (value){
                              setState(() {

                              });
                            },
                            controller: _itemPriceController,
                            keyboardType: TextInputType.number,
                            hint: 'Price',
                            labelText: 'Price',
                            textInputAction: TextInputAction.next,
                            enabled: true,
                            prefixIcon: const Icon(Icons.monetization_on),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: (){
                    if(_itemNameController.text == "" || _itemPriceController.text == "" || _itemQuantityController.text == ""){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All Field Must Be Filled!"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }else{
                      if (int.tryParse(_itemQuantityController.text.toString()) == null || int.tryParse(_itemPriceController.text.toString()) == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Quantity & Price Must Be A Number !"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }else{
                        if(int.parse(_itemQuantityController.text.toString()) <= 0 || int.parse(_itemPriceController.text.toString()) <= 0){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Quantity & Price Must Be Greater Than 0 !"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }else{
                          bool found = false;
                          for(var item in _pickedItem){
                            if(item["item"].toString().toLowerCase() == _itemNameController.text.toString().toLowerCase()){
                              found = true;
                            }
                          }
                          if(!found){
                            final Map<String, dynamic> _temp = {
                              "item": _itemNameController.text.toString(),
                              "quantity": int.parse(_itemQuantityController.text.toString()),
                              "price": int.parse(_itemPriceController.text.toString()),
                            };
                            setState(() {
                              _pickedItem.add(_temp);
                              sumSubtotal();
                              _itemNameController.text = "";
                              _itemQuantityController.text = "";
                              _itemPriceController.text = "";
                            });
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Item Already Added, To Override Please Delete Item Bought First!"),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  child: const Text("Add Item", style: TextStyle(fontSize: 16),),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bought', style: TextStyle(fontSize: 16)),
                        Text("Subtotal: ${CurrencyFormat.convertToIdr(subtotal, 0)}", style: const TextStyle(fontSize: 16))
                      ]
                  ),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pickedItem.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: AddUserListTile(
                            name: _pickedItem[index]["item"],
                            username: "Quantity: ${_pickedItem[index]["quantity"]}, Price: ${CurrencyFormat.convertToIdr(_pickedItem[index]["price"], 0)}",
                            icon: Icons.remove,
                            iconColor: Colors.red,
                            tileColor: Theme.of(context).colorScheme.secondary,
                            type: Icons.shopping_bag,
                            onClick: (){
                              setState(() {
                                _pickedItem.removeAt(index);
                                sumSubtotal();
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
                  child: Text('Recommended', style: TextStyle(fontSize: 16),),
                ),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recommendedList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: AddUserListTile(
                            name: data.recommendedList[index]["item"],
                            username: "Price: ${CurrencyFormat.convertToIdr(data.recommendedList[index]["price"], 0)}",
                            icon: Icons.add,
                            iconColor: Theme.of(context).colorScheme.primary,
                            tileColor: Theme.of(context).colorScheme.onSecondary,
                            type: Icons.shopping_bag,
                            onClick: (){
                              setState(() {
                                _itemNameController.text = data.recommendedList[index]["item"].toString();
                                _itemPriceController.text = data.recommendedList[index]["price"].toString();
                              });
                            },
                          )
                      );
                    }
                ),
              ],
            ),
          )
        );
      }),
    );
  }
}
