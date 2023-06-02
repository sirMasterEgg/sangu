import 'package:flutter/material.dart';
import 'package:sangu/helpers/currency_formatter.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final int value;
  final Color warna;
  const HomeCard({
    Key? key,
    required this.title,
    required this.value,
    required this.warna,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: warna,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width/2-17,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                child: Text(title, style: TextStyle(fontSize: 16.0)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(CurrencyFormat.convertToIdr(value, 0), style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ),
      ),
    );
  }
}
