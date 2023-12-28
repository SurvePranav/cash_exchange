import 'package:cashxchange/model/request_model.dart';
import 'package:cashxchange/provider/request_provider.dart';
import 'package:cashxchange/utils/date_util.dart';
import 'package:cashxchange/widgets/walking_distance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestMetaData extends StatelessWidget {
  final RequestModel request;
  final bool showDistance;
  final String fromId;
  const RequestMetaData({
    super.key,
    required this.request,
    this.showDistance = false,
    required this.fromId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<RequestProvider>(context, listen: false)
          .getRequestMetaData(reqId: request.reqId, uid: fromId),
      builder: (context, requestMetaDataSnapshot) {
        if (requestMetaDataSnapshot.connectionState == ConnectionState.done &&
            requestMetaDataSnapshot.hasData) {
          final requestMetaData = requestMetaDataSnapshot.data?.data() ?? {};
          String msg = 'I accept your request';
          if (requestMetaData['msg'].toString().isNotEmpty) {
            msg = requestMetaData['msg'];
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(MyDateUtil.getTimeStamp(
                context: context,
                time: requestMetaData['date'].toString(),
              )),
              const SizedBox(
                height: 3,
              ),
              if (showDistance)
                WalkingDistance(
                  originLat: request.locationLat,
                  originLng: request.locationLon,
                  destinationLat: requestMetaData['lat'],
                  destinationLng: requestMetaData['lng'],
                ),
              Text(msg),
            ],
          );
        } else {
          return const SizedBox(
            height: 45,
          );
        }
      },
    );
  }
}
