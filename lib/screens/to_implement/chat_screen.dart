import 'package:cashxchange/constants/color_constants.dart';
import 'package:cashxchange/screens/to_implement/message_screen.dart';
import 'package:flutter/cupertino.dart';
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
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ), // Adjust the value for roundness
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: blue_10,
            expandedHeight: 80, // Adjust as needed
            floating: false, // The app bar does not float as the user scrolls
            pinned: false, // The app bar remains pinned at the top
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Chats'),
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
