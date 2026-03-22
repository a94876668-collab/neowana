import 'package:flutter/material.dart';
import 'package:neowana/config.dart';
import 'package:neowana/screens/home_screen.dart';
import 'package:neowana/services/chat_service.dart';

void main() {
  runApp(const NeowanaApp());
}

class NeowanaApp extends StatefulWidget {
  const NeowanaApp({super.key});

  @override
  State<NeowanaApp> createState() => _NeowanaAppState();
}

class _NeowanaAppState extends State<NeowanaApp> {
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(serverUrl: serverUrl);
  }

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '너와나',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(chatService: _chatService),
    );
  }
}
