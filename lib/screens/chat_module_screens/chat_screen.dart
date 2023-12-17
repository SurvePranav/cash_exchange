import 'dart:developer';

import 'package:cashxchange/constants/constant_values.dart';
import 'package:cashxchange/model/connection_model.dart';
import 'package:cashxchange/model/user_model.dart';
import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/provider/messaging_provider.dart';
import 'package:cashxchange/screens/chat_module_screens/chat_list.dart';
import 'package:cashxchange/screens/chat_module_screens/message_screen.dart';
import 'package:cashxchange/utils/location_services.dart';
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
  List<Connection> _connections = [];
  final List<Connection> _searchList = [];
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
      setState(() {
        isSearching = true;
      });
    } else {
      setState(() {
        isSearching = false;
        _searchTextController.text = "";
        _searchList.clear();
        _searchList.addAll(_connections);
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
          title: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        for (var i in _connections) {
                          if (i.name
                              .toLowerCase()
                              .contains(value.trim().toLowerCase())) {
                            _searchList.add(i);
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Your Connections'),
              Tab(
                text: 'Nearby Users',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  isSearching
                      ? Expanded(
                          child: ChatsList(
                            connections: _searchList,
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
                          ),
                        )
                      : Expanded(
                          child: StreamBuilder(
                          stream:
                              Provider.of<AuthProvider>(context, listen: false)
                                  .getUserById(UserModel.instance.uid),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.docs;
                            List<String> userIds = [];
                            if (data != null) {
                              userIds = (data.first.data()['connections']
                                      as List<dynamic>)
                                  .map((e) => e.toString())
                                  .toList();
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.active:
                              case ConnectionState.done:
                                return StreamBuilder(
                                  stream: Provider.of<AuthProvider>(context)
                                      .getMyConnections(userIds),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      if (snapshot.hasData) {
                                        final data = snapshot.data?.docs;
                                        _connections = data!.map((e) {
                                          return Connection.fromJson(e.data());
                                        }).toList();
                                        _searchList.clear();
                                        _searchList.addAll(_connections);
                                        return ChatsList(
                                          connections: _connections,
                                          onTap: (connection) {
                                            Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    MessageScreen(
                                                        connection: connection),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return const Center(
                                          child: Text(
                                              'you are not connected to any users'),
                                        );
                                      }
                                    }
                                  },
                                );
                            }
                          },
                        )),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  isSearching
                      ? Expanded(
                          child: ChatsList(
                            connections: _searchList,
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
                          ),
                        )
                      : Expanded(
                          child: StreamBuilder(
                            stream: Provider.of<AuthProvider>(context)
                                .getMySecondaryConnections(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                if (snapshot.hasData) {
                                  final data = snapshot.data?.docs;
                                  _connections = data!.map((e) {
                                    return Connection.fromJson(e.data());
                                  }).toList();
                                  _searchList.clear();
                                  _searchList.addAll(_connections);
                                  return ChatsList(
                                    connections: _connections,
                                    onTap: (connection) {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => MessageScreen(
                                              connection: connection),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Text(
                                        'you are not connected to any users'),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
