import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/screens/chat_module_screens/message_screen.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.blue_4,
            expandedHeight: 80, // Adjust as needed
            floating: false, // The app bar does not float as the user scrolls
            pinned: false, // The app bar remains pinned at the top
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Chats',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          // Add other SliverList or SliverGrid widgets for your scrollable content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Chat $index'),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            const MessageScreen(), // SecondPage is the destination page
                      ),
                    );
                  },
                );
              },
              childCount: 30, // Number of list items
            ),
          ),
        ],
      ),
    );
  }
}