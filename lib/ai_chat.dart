
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChat extends StatefulWidget {
  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // المفتاح الخاص بك
  final String apiKey = "AIzaSyDiPK9RnaGxdEfP1-rTt4e1L31_3fipvz0";

  // الموديل الذي وجدناه في قائمة مفتاحك
  final String modelName = "gemini-3.1-flash-lite-preview";

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // الرابط المحدث بناءً على قائمة الموديلات التي أرسلتها
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": "OvinTech، خبير في تربية الأغنام والمواشي في الجزائر. أجب بالعربية باختصار."}
              ]
            },
            {
              "role": "model",
              "parts": [
                {"text":" OvinTech. How can I help you?"}
              ]
            },
            ..._messages.map((m) => {
              "role": m['role'] == 'user' ? 'user' : 'model',
              "parts": [{"text": m['content']}]
            }).toList()
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _messages.add({'role': 'model', 'content': reply});
          _isLoading = false;
        });
      } else {
        print("خطأ من جوجل: ${response.body}");
        setState(() {
          _messages.add({'role': 'model', 'content': 'حدث خطأ في الاستجابة.'});
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'model', 'content': 'فشل الاتصال: $e'});
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مساعد OvinTech الذكي"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF4CAF50) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg['content']!,
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: "Ask the livestock bot..."),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}