import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class BitcoinTracker extends StatefulWidget {
  @override
  _BitcoinTrackerState createState() => _BitcoinTrackerState();
}

class _BitcoinTrackerState extends State<BitcoinTracker> {
  Map<String, dynamic>? bitcoinData;
  String? rate;
  late Timer _timer;

  Future<void> fetchBitcoinData() async {
    var response = await http.get(Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'));
    if (response.statusCode == 200) {
      setState(() {
        bitcoinData = json.decode(response.body);
        updateRate();
      });
    }
  }

  void updateRate() {
    var currency = bitcoinData!['bpi'].keys.first;
    rate = bitcoinData!['bpi'][currency]['rate'];
  }

  @override
  void initState() {
    super.initState();
    fetchBitcoinData();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchBitcoinData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 99, 197, 194),
        body: Center(
          child: bitcoinData == null
              ? CircularProgressIndicator()

              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/bitcoin.png"),
                    Text(
                      '${rate ?? 'Price'}',
                      style: TextStyle(fontSize: 22,color: Colors.yellow),
                    ),
                   SizedBox(
  height: 200,
  child: CupertinoPicker(
    itemExtent: 30,
    onSelectedItemChanged: (int index) {
      var currency = bitcoinData!['bpi'].keys.elementAt(index);
      setState(() {
        rate = bitcoinData!['bpi'][currency]['rate'];
      });
    },
    children: bitcoinData!['bpi'].keys.map<Widget>((currency) {
      return Text('$currency');
    }).toList(),
  ),
),
                  ],
                ),
        ),
      ),
    );
  }
}
