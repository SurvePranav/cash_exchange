import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/connectivity_provider.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/screens/request_module_screens/active_requests_screen.dart';
import 'package:cashxchange/screens/request_module_screens/request_success_screen.dart';
import 'package:cashxchange/utils/location_services.dart';
import 'package:cashxchange/utils/util.dart';
import 'package:cashxchange/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RaiseRequestScreen extends StatefulWidget {
  final RequestModel? request;
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
  int activeButton = 0;
  bool isPressed = false;
  final amountController = TextEditingController();
  final infoController = TextEditingController();

  @override
  void initState() {
    if (widget.editRequest) {
      amountController.text = widget.request!.amount;
      infoController.text = widget.request!.info;
      _requestType = widget.request!.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.skyBlue,
              AppColors.mintGreen,
              AppColors.lightMintGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      Text(
                        widget.editRequest ? 'Edit Request ' : 'New Request',
                        style: const TextStyle(
                            fontSize: 26.0, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                          color: AppColors.skyBlue,
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
                        widget.editRequest
                            ? const SizedBox()
                            : Column(
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
                                        child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: const Text(
                                            "Using Current Location",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Consumer<RequestProvider>(
                        builder: (context, rp, widget) {
                          if (rp.isLoading) {
                            return const CircularProgressIndicator();
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: CustomButton(
                        text: widget.editRequest
                            ? "Edit Request"
                            : "Raise Request",
                        onPressed: () async {
                          if (!isPressed) {
                            await raiseRequest();
                          }
                        }),
                  ),
                ],
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
              color: AppColors.skyBlue,
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
    if (Provider.of<ConnectivityProvider>(context, listen: false).isConnected) {
      if (amountController.text.isNotEmpty && infoController.text.isNotEmpty) {
        if (int.parse(amountController.text) <= 2000) {
          final requestProvider =
              Provider.of<RequestProvider>(context, listen: false);
          requestProvider.setLoading(true);
          isPressed = true;
          if (widget.editRequest) {
            await requestProvider
                .updateRequestById(
                    reqId: widget.request!.reqId,
                    type: _requestType,
                    amount: amountController.text,
                    info: infoController.text)
                .then((success) {
              requestProvider.setLoading(false);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const RequestStatusScreen(),
                ),
              );
            });
          } else {
            await LocationServices.getCurrentLocation().then((coordinates) {
              final request = RequestModel(
                reqId: DateTime.now().millisecondsSinceEpoch.toString(),
                uid: UserModel.instance.uid,
                createdAt: DateTime.now(),
                amount: amountController.text.trim(),
                type: _requestType,
                info: infoController.text.trim(),
                locationLat: coordinates[0],
                locationLon: coordinates[1],
                views: 0,
                isAccepted: false,
              );
              requestProvider
                  .uploadRequestToDatabase(
                context: context,
                request: request,
              )
                  .then((success) {
                if (success) {
                  amountController.text = '';
                  infoController.text = '';
                  _requestType = 'Cash';
                  activeButton = 0;
                  isPressed = false;
                  requestProvider.setLoading(false);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RequestSuccessScreen(
                        request: request,
                      ),
                    ),
                  );
                } else {
                  MyAppServices.showSlackBar(
                      context, "something went wrong on server");
                }
              });
            });
          }
        } else {
          MyAppServices.showSlackBar(
            context,
            "Amount Should be less than Rs.2000",
          );
        }
      } else {
        MyAppServices.showSlackBar(context, "fill all the details");
      }
    } else {
      MyAppServices.showSlackBar(context, "No internet Connection");
    }
  }
}
