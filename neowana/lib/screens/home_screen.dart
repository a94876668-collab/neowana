import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neowana/screens/chat_screen.dart';
import 'package:neowana/screens/privacy_screen.dart';
import 'package:neowana/screens/terms_screen.dart';
import 'package:neowana/services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  final ChatService chatService;

  const HomeScreen({super.key, required this.chatService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnecting = false;
  bool _isWaiting = false;
  String? _errorMessage;
  StreamSubscription? _msgSub;

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  void _connectAndFindMatch() {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    widget.chatService.connect(
      onConnected: () {
        if (!mounted) return;
        setState(() => _isConnecting = false);

        // 연결 안정화를 위해 짧은 대기 후 매칭
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted || !widget.chatService.isConnected) return;

          _msgSub = widget.chatService.messageStream.listen((msg) {
            if (!mounted) return;
            switch (msg['type']) {
              case 'waiting':
                setState(() => _isWaiting = true);
                break;
              case 'matched':
                _msgSub?.cancel();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(chatService: widget.chatService),
                  ),
                );
                break;
              case 'status':
                setState(() => _errorMessage = msg['message']?.toString());
                break;
              case 'error':
                setState(() => _errorMessage = msg['message']?.toString());
                break;
            }
          });

          widget.chatService.findMatch();
        });
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  void _cancelMatch() {
    _msgSub?.cancel();
    widget.chatService.cancelMatch();
    widget.chatService.disconnect();
    setState(() => _isWaiting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Spacer(),
                Text(
                    '너와나',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                    '랜덤 채팅',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                const SizedBox(height: 80),
                if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
                if (_isConnecting)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '서버 연결 중...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )
                else if (_isWaiting)
                    Column(
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '상대방을 찾는 중입니다...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _cancelMatch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('취소'),
                        ),
                      ],
                    )
                else
                    ElevatedButton.icon(
                      onPressed: _connectAndFindMatch,
                      icon: const Icon(Icons.chat_bubble_outline, size: 28),
                      label: const Text(
                        '매칭 시작',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black26,
                      ),
                    ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsScreen(),
                        ),
                      ),
                      child: Text(
                        '이용약관',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyScreen(),
                        ),
                      ),
                      child: Text(
                        '개인정보처리방침',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
