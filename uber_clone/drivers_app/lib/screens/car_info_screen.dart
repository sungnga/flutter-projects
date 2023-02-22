import 'package:flutter/material.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carPlateNumberTextEditingController =
      TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  List<String> carTypesList = ['uber-x', 'uber-go', 'bike'];
  String? selectedCarType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('asset/logos/logo1.png'),
                ),
                SizedBox(height: 10),
                Text(
                  'Provide Car Details',
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.grey[100],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: carModelTextEditingController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Car Model',
                    // hintText: 'Car Model',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                TextField(
                  controller: carPlateNumberTextEditingController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Car Plate Number',
                    // hintText: 'Car Plate Number',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                TextField(
                  controller: carColorTextEditingController,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Car Color',
                    // hintText: 'Car Color',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                DropdownButton(
                  dropdownColor: Colors.black87,
                  iconSize: 36.0,
                  value: selectedCarType,
                  items: carTypesList.map((car) {
                    return DropdownMenuItem(
                      value: car,
                      child: Text(
                        car,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCarType = newValue.toString();
                    });
                  },
                  hint: const Text(
                    'Choose a car type',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarInfoScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff00AA80)),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
