import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final List<Message> messages = [];
  final TextEditingController promptController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isDarkMode = false;
  bool _isLoading = false;

  static const MaterialColor customPurple = MaterialColor(
    0xFF673AB7,
    <int, Color>{
      50: Color(0xFFF3E5F5),
      100: Color(0xFFE1BEE7),
      200: Color(0xFFCE93D8),
      300: Color(0xFFBA68C8),
      400: Color(0xFF9C27B0),
      500: Color(0xFF673AB7),
      600: Color(0xFF5E35B1),
      700: Color(0xFF512DA8),
      800: Color(0xFF4527A0),
      900: Color(0xFF311B92),
    },
  );

  Future<void> generateContent(String prompt) async {
    const apiKey = your apikey
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final timestamp = DateTime.now();

    setState(() {
      _isLoading = true;
      messages.add(
        Message(content: prompt, isUserMessage: true, timestamp: timestamp),
      );
    });

    final response = await model.generateContent([Content.text(prompt)]);

    setState(() {
      messages.add(
        Message(
          content: response.text.toString(),
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
  }

  void copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        backgroundColor: customPurple.shade400,
      ),
    );
  }

  void shareContent(String content) {
    Share.share(content);
  }

  void regenerateContent(int index) async {
    if (messages[index].isUserMessage) {
      final prompt = messages[index].content;
      await generateContent(prompt);
    }
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message deleted!'),
        backgroundColor: customPurple.shade400,
      ),
    );
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              promptController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customPurple.shade600,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [customPurple.shade400, customPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Teacher',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _isDarkMode = !_isDarkMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: message.isUserMessage
                            ? LinearGradient(
                                colors: [
                                  customPurple.shade400,
                                  customPurple.shade600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: message.isUserMessage ? null : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft:
                              Radius.circular(message.isUserMessage ? 20 : 4),
                          bottomRight:
                              Radius.circular(message.isUserMessage ? 4 : 20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: message.isUserMessage
                                  ? Colors.white
                                  : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('hh:mm a')
                                    .format(message.timestamp),
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: message.isUserMessage
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.copy_rounded,
                                      size: 18.0,
                                      color: message.isUserMessage
                                          ? Colors.white.withOpacity(0.8)
                                          : customPurple.shade400,
                                    ),
                                    onPressed: () =>
                                        copyToClipboard(message.content),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.share_rounded,
                                      size: 18.0,
                                      color: message.isUserMessage
                                          ? Colors.white.withOpacity(0.8)
                                          : customPurple.shade400,
                                    ),
                                    onPressed: () =>
                                        shareContent(message.content),
                                  ),
                                  if (!message.isUserMessage)
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        size: 18.0,
                                        color: customPurple.shade400,
                                      ),
                                      onPressed: () =>
                                          regenerateContent(index),
                                    ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.delete_rounded,
                                      size: 18.0,
                                      color: message.isUserMessage
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.red.shade400,
                                    ),
                                    onPressed: () => deleteMessage(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(customPurple.shade400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: customPurple.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                        color: customPurple.shade200,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: promptController,
                      decoration: const InputDecoration(
                        hintText: 'Ask something...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: _isListening
                        ? LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          )
                        : LinearGradient(
                            colors: [
                              customPurple.shade400,
                              customPurple.shade600
                            ],
                          ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _listen,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [customPurple.shade400, customPurple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      final prompt = promptController.text;
                      if (prompt.isNotEmpty) {
                        generateContent(prompt);
                        promptController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
  });
}
