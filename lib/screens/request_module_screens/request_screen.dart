import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/location_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_success_screen.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_geocoder/geocoder.dart';

class RaiseRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? request;
  final bool editRequest;
  const RaiseRequestScreen({
    super.key,
    this.request,
    this.editRequest = false,
  });

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  String _requestType = 'Cash';
  bool isFirst = true;
  String warningText = '';

  final amountController = TextEditingController();
  final infoController = TextEditingController();
  double lat = double.parse(UserModel.instance.locationLat);
  double lon = double.parse(UserModel.instance.locationLon);
  int i = 0;

  @override
  void initState() {
    if (widget.editRequest) {
      amountController.text = widget.request!['amount'];
      infoController.text = widget.request!['info'];
      _requestType = widget.request!['type'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.blue_4,
            AppColors.mintGreen,
            AppColors.blue_2,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(
                  widget.editRequest ? 'Edit Request ' : 'New Request',
                  style: const TextStyle(
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
                    fillColor: Colors.white,
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
                        color: AppColors.blue_4,
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
                      Visibility(
                          visible: !widget.editRequest,
                          child: Column(
                            children: [
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
                                            backgroundColor: isFirst
                                                ? AppColors.blue_6
                                                : Colors.white,
                                          ),
                                          onPressed: () {
                                            lat = double.parse(
                                                UserModel.instance.locationLat);
                                            lon = double.parse(
                                                UserModel.instance.locationLon);
                                            print(
                                                "my pos: lat: $lat, lon:$lon");
                                            setState(() {
                                              isFirst = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.location_pin,
                                            color: isFirst
                                                ? Colors.white
                                                : AppColors.deepGreen,
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
                                            ? SizedBox(
                                                height: 30,
                                                width: 30,
                                                child:
                                                    CupertinoActivityIndicator(
                                                  color: AppColors.deepGreen,
                                                ),
                                              )
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
                                                backgroundColor: isFirst
                                                    ? Colors.white
                                                    : AppColors.blue_6,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  isFirst = false;
                                                });
                                                value.setLoading(true);
                                                await value
                                                    .getCurrentLocation()
                                                    .then((pos) {
                                                  lat = pos[0];
                                                  lon = pos[1];
                                                  print(
                                                    "current pos: lat: $lat, lon:$lon",
                                                  );
                                                });
                                                value.setLoading(false);
                                              },
                                              child: value.isLoading
                                                  ? const SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.location_searching,
                                                      color: isFirst
                                                          ? AppColors.deepGreen
                                                          : Colors.white,
                                                    ),
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
                            ],
                          )),
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
                      text:
                          widget.editRequest ? "Edit Request" : "Raise Request",
                      onPressed: () async {
                        await raiseRequest();
                      }),
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
        cursorColor: AppColors.deepGreen,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.deepGreen,
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
              color: AppColors.blue_4,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Future<void> raiseRequest() async {
    if (amountController.text.isNotEmpty && infoController.text.isNotEmpty) {
      final requestProvider =
          Provider.of<RequestProvider>(context, listen: false);

      if (widget.editRequest) {
        await requestProvider
            .updateRequestById(
                reqId: widget.request!['reqId'],
                type: _requestType,
                amount: amountController.text,
                info: infoController.text)
            .then((success) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RequestStatusScreen(),
            ),
          );
        });
      } else {
        print('lat: $lat, lon: $lon');
        RequestModel.instance.initializeRequest(
          reqId: '',
          uid: Provider.of<AuthProvider>(context, listen: false).uid,
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
            amountController.text = '';
            infoController.text = '';
            _requestType = 'Cash';
            isFirst = true;
            warningText = '';
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const RequestSuccessScreen()),
            );
          } else {
            warningText = 'something went wrong on server';
          }
        });
      }
    } else {
      warningText = 'Fill all the details';
    }
    setState(() {});
  }
}
