import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/screens/chat_module_screens/single_chat_tile.dart';
import 'package:flutter/material.dart';

typedef MyCallBack = Function(Connection connection);

class ChatsList extends StatelessWidget {
  final List<Connection> connections;
  final MyCallBack onTap;
  const ChatsList({
    super.key,
    required this.connections,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (connections.isEmpty) {
      return const Center(
        child: Text("no users!"),
      );
    } else {
      return ListView.builder(
        itemCount: connections.length,
        itemBuilder: (context, index) {
          final connection = connections.elementAt(index);
          return ChatTile(
            connection: connection,
            onTap: onTap,
          );
        },
      );
    }
  }
}
