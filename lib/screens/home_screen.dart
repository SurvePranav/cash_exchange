import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/widgets/home_screen_top.dart';
import 'package:cashxchange/widgets/my_dropdown_button.dart';
import 'package:cashxchange/widgets/nearby_atms.dart';
import 'package:cashxchange/widgets/nearby_requests_widget.dart';
import 'package:cashxchange/widgets/view_map.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  String _selectedItem = "Nearby Requests";
  bool _loadMap = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _selectedItem = "Nearby Requests";
        _loadMap = true;
        setState(() {});
      },
      color: AppColors.deepGreen,
      child: CustomScrollView(
        slivers: [
          // SliverList for the list of items fetched from Firestore
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Column(
                  children: [
                    const HomeScreenTopSection(),
                    _loadMap ? ViewMapWidget() : const ViewMapWidget(),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MyDropdown(
                        selectedParameter: _selectedItem,
                        onChange: (String? selectedItem) {
                          _selectedItem = selectedItem ?? "Nearby Requests";
                          _loadMap = false;
                          setState(() {});
                        },
                        parameterItems: const [
                          'Nearby Requests',
                          'Requests Near Home',
                          'Nearby ATM\'s',
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          _selectedItem == 'Nearby Requests'
              ? RequestsWidget(
                  nearMe: true,
                )
              : _selectedItem == 'Requests Near Home'
                  ? RequestsWidget(
                      nearMe: false,
                    )
                  // : RequestsWidget(
                  //     nearMe: false,
                  //   )
                  : NearbyAtmsWidget(),
        ],
      ),
    );
  }
}
