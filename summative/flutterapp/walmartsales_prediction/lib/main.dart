import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walmart Sales Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _holidayFlagController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  final TextEditingController _cpiController = TextEditingController();
  final TextEditingController _unemploymentController = TextEditingController();

  String? _prediction;
  bool _loading = false;

Future<void> _predict() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://linear-regression-2.onrender.com/predict'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Store': int.parse(_storeController.text),
          'Holiday_Flag': int.parse(_holidayFlagController.text),
          'Temperature': double.parse(_temperatureController.text),
          'Fuel_Price': double.parse(_fuelPriceController.text),
          'CPI': double.parse(_cpiController.text),
          'Unemployment': double.parse(_unemploymentController.text),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _prediction = jsonDecode(response.body)['Weekly_Sales'].toString();
        });
      } else {
        setState(() {
          _prediction = 'Failed to get prediction. Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Failed to get prediction. Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Walmart Sales Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _buildTextField(
                      controller: _storeController,
                      labelText: 'Store',
                      hintText: 'Enter store number',
                    ),
                    _buildTextField(
                      controller: _holidayFlagController,
                      labelText: 'Holiday Flag',
                      hintText: 'Enter holiday flag',
                    ),
                    _buildTextField(
                      controller: _temperatureController,
                      labelText: 'Temperature',
                      hintText: 'Enter temperature',
                    ),
                    _buildTextField(
                      controller: _fuelPriceController,
                      labelText: 'Fuel Price',
                      hintText: 'Enter fuel price',
                    ),
                    _buildTextField(
                      controller: _cpiController,
                      labelText: 'CPI',
                      hintText: 'Enter CPI',
                    ),
                    _buildTextField(
                      controller: _unemploymentController,
                      labelText: 'Unemployment',
                      hintText: 'Enter unemployment rate',
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _predict,
                        child: Text('Predict'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                Center(
                  child: SpinKitFadingCircle(
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ),
              if (_prediction != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      'Predicted Weekly Sales: $_prediction',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}