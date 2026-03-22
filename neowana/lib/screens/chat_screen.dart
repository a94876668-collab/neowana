import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neowana/screens/home_screen.dart';
import 'package:neowana/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;

  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _partnerLeft = false;
  bool _partnerTyping = false;
  Timer? _typingDebounce;
  Timer? _partnerTypingHide;
  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _msgSub = widget.chatService.messageStream.listen((msg) {
      if (!mounted) return;
      switch (msg['type']) {
        case 'chat_message':
          setState(() {
            _messages.add(ChatMessage(
              text: msg['message']?.toString() ?? '',
              isMe: false,
            ));
          });
          _scrollToBottom();
          break;
        case 'partner_left':
          setState(() {
            _partnerLeft = true;
            _partnerTyping = false;
            _messages.add(ChatMessage(
              text: msg['message']?.toString() ?? '상대방이 나갔습니다.',
              isMe: false,
              isSystem: true,
            ));
          });
          _scrollToBottom();
          break;
        case 'typing':
          _partnerTypingHide?.cancel();
          setState(() => _partnerTyping = true);
          _partnerTypingHide = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _partnerTyping = false);
          });
          break;
        case 'stopped_typing':
          _partnerTypingHide?.cancel();
          setState(() => _partnerTyping = false);
          break;
        case 'message_blocked':
          setState(() {
            final idx = _messages.lastIndexWhere((m) => m.isMe);
            if (idx >= 0) _messages.removeAt(idx);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('해당 메시지는 전송할 수 없습니다.'),
              backgroundColor: Colors.orange.shade700,
            ),
          );
          break;
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged(String text) {
    _typingDebounce?.cancel();
    if (text.isNotEmpty) {
      widget.chatService.sendTyping();
      _typingDebounce = Timer(const Duration(milliseconds: 1500), () {
        widget.chatService.sendStoppedTyping();
      });
    } else {
      widget.chatService.sendStoppedTyping();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _typingDebounce?.cancel();
    widget.chatService.sendStoppedTyping();
    widget.chatService.sendMessage(text);
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });
    _messageController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  void _leaveChat() {
    _msgSub?.cancel();
    widget.chatService.disconnect();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(chatService: widget.chatService),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingDebounce?.cancel();
    _partnerTypingHide?.cancel();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '채팅 중',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'report') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('상대방 신고'),
                    content: const Text(
                      '이 사용자를 신고하시겠습니까?\n신고 후 채팅이 종료됩니다.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('신고'),
                      ),
                    ],
                  ),
                );
                if (ok == true && mounted) {
                  widget.chatService.reportUser();
                  _msgSub?.cancel();
                  widget.chatService.disconnect();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('신고해 주셔서 감사합니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(chatService: widget.chatService),
                      ),
                      (route) => false,
                    );
                  }
                }
              } else if (value == 'exit') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('채팅 종료'),
                    content: const Text('채팅을 종료하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _leaveChat();
                        },
                        child: const Text('종료'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'block') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('상대방 차단'),
                    content: const Text(
                      '이 사용자를 차단하시겠습니까?\n채팅이 종료됩니다.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('차단'),
                      ),
                    ],
                  ),
                );
                if (ok == true && mounted) {
                  _msgSub?.cancel();
                  widget.chatService.disconnect();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(chatService: widget.chatService),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('신고')),
              const PopupMenuItem(value: 'block', child: Text('차단')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'exit', child: Text('채팅 종료')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('채팅 종료'),
                  content: const Text('채팅을 종료하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _leaveChat();
                      },
                      child: const Text('종료'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_partnerLeft)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '상대방이 나갔습니다. 다시 매칭할까요?',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _leaveChat,
                    child: const Text('다시 매칭'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isSystem) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? Colors.deepPurple.shade400
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(msg.isMe ? 20 : 4),
                        bottomRight: Radius.circular(msg.isMe ? 4 : 20),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isMe ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_partnerTyping && !_partnerLeft)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상대가 입력 중...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      autofocus: true,
                      enabled: !_partnerLeft,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _onTextChanged,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade400,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _partnerLeft ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isSystem;

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isSystem = false,
  });
}
