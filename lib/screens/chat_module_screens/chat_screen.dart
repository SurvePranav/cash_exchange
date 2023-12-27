import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/screens/chat_module_screens/message_screen.dart';
import 'package:cashxchange/screens/chat_module_screens/single_chat_tile.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchTextController = TextEditingController();
  List<String> _connectionNames = [];
  List<String> _userIds = [];
  final List<String> _searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      if (_searchTextController.text == "") {
        _searchList.clear();
        _searchList.addAll(_userIds);
      }
      setState(() {
        isSearching = true;
      });
    } else {
      setState(() {
        isSearching = false;
        _searchTextController.text = "";
        _searchList.clear();
        _searchList.addAll(_userIds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.blue_4,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.deepGreen,
            ),
            onPressed: () {
              if (isSearching) {
                _focusNode.unfocus();
                _searchTextController.text = "";
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Chats',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: TextField(
                      controller: _searchTextController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        border: InputBorder.none,
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      onChanged: (value) {
                        _searchList.clear();
                        for (int i = 0; i < _connectionNames.length; i++) {
                          if (_connectionNames[i]
                              .toLowerCase()
                              .contains(value.trim().toLowerCase())) {
                            _searchList.add(_userIds[i]);
                          }
                        }
                        setState(() {
                          _searchList;
                        });
                      },
                      focusNode: _focusNode,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.deepGreen,
            labelColor: AppColors.deepGreen,
            tabs: const [
              Tab(
                text: 'Conversations',
              ),
              Tab(
                text: 'Direct',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _tabBarViewItem(primary: true),
            _tabBarViewItem(primary: false),
          ],
        ),
      ),
    );
  }

  Widget _tabBarViewItem({required bool primary}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          isSearching
              ? Expanded(
                  child: Builder(builder: (context) {
                    if (_searchList.isEmpty) {
                      return const Center(
                        child: Text('No Users'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: _searchList.length,
                        itemBuilder: (context, index) {
                          return ChatTile(
                            uid: _searchList[index],
                            onTap: (connection) {
                              setState(() {
                                _focusNode.unfocus();
                                _searchTextController.clear();
                                _searchList.clear();
                                isSearching = false;
                              });
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => MessageScreen(
                                    connection: connection,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  }),
                )
              : Expanded(
                  child: StreamBuilder(
                    stream: Provider.of<AuthProvider>(context, listen: false)
                        .getMyConnections(primary: primary),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.docs ?? [];
                      _userIds = data.map((e) {
                        return e.data()['uid'] as String;
                      }).toList();

                      // adding names to connection names
                      _connectionNames = data.map(
                        (e) {
                          return e.data()['name'] as String;
                        },
                      ).toList();
                      log('fetetched userIds: $_userIds');
                      log('fetetched userNames: $_connectionNames');

                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (_userIds.isEmpty) {
                            return Center(
                              child: Text(primary
                                  ? 'No Conversations Yet!'
                                  : 'No Direct Messages!'),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: _userIds.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ChatTile(
                                  uid: _userIds[index],
                                  onTap: (connection) {
                                    log('marking as read.....');
                                    //updating the message as readed to remove the badge on chats
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .updateHasUnreadMessage(
                                      uid: connection.uid,
                                      updateInMyConnections: true,
                                      hasUnreadMessage: false,
                                    );
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => MessageScreen(
                                            connection: connection),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
