import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/widgets/constant_widget.dart';
import 'package:flutter/material.dart';

typedef MyCallBack = Function(Map<String, dynamic> request);

class NearbyAtmsList extends StatelessWidget {
  final List<Map<String, dynamic>> nearbyAtms;
  final MyCallBack onTap;
  const NearbyAtmsList({
    super.key,
    required this.nearbyAtms,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (nearbyAtms.isEmpty) {
      return MyConstantWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No nearby ATM's"),
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: AppColors.deepGreen),
                  onPressed: () {},
                  child: const Icon(
                    Icons.emoji_emotions,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final atm = nearbyAtms.elementAt(index);
            return Container(
              margin: index == 0
                  ? const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 1)
                  : index == nearbyAtms.length - 1
                      ? const EdgeInsets.only(
                          bottom: 20,
                          left: 20,
                          right: 20,
                        )
                      : const EdgeInsets.only(left: 20, right: 20, bottom: 1),
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: index == 0 && index == nearbyAtms.length - 1
                    ? const BorderRadius.all(
                        Radius.circular(20),
                      )
                    : index == 0
                        ? const BorderRadius.vertical(
                            top: Radius.circular(20),
                          )
                        : index == nearbyAtms.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              )
                            : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: AppColors.mintGreen,
                  radius: 20,
                  backgroundImage:
                      const AssetImage('assets/images/profile_icon.png'),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${atm['name']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      atm['rating'] == null
                          ? "Rating -- "
                          : "Rating ${atm['rating']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(
                      '${atm['lat']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 25,
                ),
                onTap: () {
                  onTap(atm);
                },
              ),
            );
          },
          childCount: nearbyAtms.length,
        ),
      );
    }
  }
}
