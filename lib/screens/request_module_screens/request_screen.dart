import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/register_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_success_screen.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_geocoder/geocoder.dart';

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({super.key});

  @override
  _RaiseRequestScreenState createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _requestType = 'Cash';
  bool isFirst = true;
  String warningText = '';

  final amountController = TextEditingController();
  final infoController = TextEditingController();
  final bioController = TextEditingController();
  String lat = UserModel.instance.locationLat;
  String lon = UserModel.instance.locationLon;
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ), // Adjust the value for roundness
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'New Request ',
                      style: TextStyle(
                          fontSize: 26.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Request Type:',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _requestType,
                      onChanged: (value) {
                        setState(() {
                          _requestType = value!;
                        });
                      },
                      decoration: InputDecoration(
                        // Customize the container surrounding the dropdown
                        filled: true,
                        fillColor: blue_2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: blue_4,
                          ),
                        ),
                      ),
                      items: ['Cash', 'Online Money']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Amount',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          // name field
                          textFeld(
                            hintText: "eg.Rs.200",
                            icon: Icons.money,
                            inputType: TextInputType.number,
                            maxLines: 1,
                            controller: amountController,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Location',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isFirst ? blue_6 : blue_2,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isFirst = true;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text("My Location"),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Consumer<RequestProvider>(
                                  builder: (context, value, child) {
                                    return value.isLoading
                                        ? const CircularProgressIndicator()
                                        : const SizedBox();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Consumer<LocationProvider>(
                                      builder: (context, value, child) {
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isFirst ? blue_2 : blue_6,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              isFirst = false;
                                            });
                                            var position = await value
                                                .getCurrentLocation();
                                            lat = position.latitude.toString();
                                            lon = position.longitude.toString();
                                          },
                                          child: value.myWidget,
                                        );
                                      },
                                    ),
                                    const Text("Current Location"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'More Info',
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          // more info
                          textFeld(
                            hintText: "provide info about request...",
                            icon: Icons.info,
                            inputType: TextInputType.name,
                            maxLines: 3,
                            controller: infoController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: CustomButton(
                        text: "Raise Request",
                        onPressed: () async {
                          if (amountController.text.isNotEmpty &&
                              infoController.text.isNotEmpty) {
                            final requestProvider =
                                Provider.of<RequestProvider>(context,
                                    listen: false);
                            RequestModel.instance.initializeRequest(
                              reqId: '',
                              uid: Provider.of<AuthProvider>(context,
                                      listen: false)
                                  .uid,
                              createdAt: DateTime.now(),
                              amount: amountController.text.trim(),
                              type: _requestType,
                              info: infoController.text.trim(),
                              locationLat: lat,
                              locationLon: lon,
                              views: 0,
                              isAccepted: false,
                            );
                            await requestProvider
                                .uploadRequestToDatabase(context: context)
                                .then((success) {
                              if (success) {
                                amountController.text = 'request uploaded';
                                amountController.text = '';
                                infoController.text = '';
                                _requestType = 'Cash';
                                isFirst = true;
                                warningText = '';
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RequestSuccessScreen()),
                                );
                              } else {
                                warningText = 'something went wrong on server';
                              }
                            });
                          } else {
                            warningText = 'Fill all the details';
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      warningText,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: blue_10,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: blue_10,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: blue_4,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: blue_2,
          filled: true,
        ),
      ),
    );
  }
}
