import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('alphachat_outbox');
  runApp(const AlphaChatApp());
}

class AlphaChatApp extends StatelessWidget {
  const AlphaChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlphaChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          surface: Color(0xFF111827),
        ),
      ),
      home: const ChatHomeScreen(),
    );
  }
}

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool isOfflineMeshMode = false;
  final List<Map<String, String>> _messages = [
    {
      "sender": "@aicha",
      "text": "Bienvenue sur AlphaChat ! L'application fonctionne en ligne et hors ligne.",
      "route": "Cloud"
    }
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "@vivien",
        "text": text,
        "route": isOfflineMeshMode ? "Mesh P2P" : "Cloud 5G"
      });
    });

    if (isOfflineMeshMode) {
      var box = Hive.box('alphachat_outbox');
      box.add({"recipient": "@aicha", "payload": text, "timestamp": DateTime.now().toIso8601String()});
    }

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("AlphaChat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Créée par Vivien Wendpayangda SINA", style: TextStyle(fontSize: 11, color: Colors.blueAccent)),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(isOfflineMeshMode ? "Mesh" : "Online", style: const TextStyle(fontSize: 11)),
              Switch(
                value: isOfflineMeshMode,
                onChanged: (val) {
                  setState(() {
                    isOfflineMeshMode = val;
                  });
                },
                activeColor: Colors.blueAccent,
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: isOfflineMeshMode ? Colors.blue.withOpacity(0.15) : Colors.green.withOpacity(0.15),
            child: Row(
              children: [
                Icon(
                  isOfflineMeshMode ? Icons.bluetooth : Icons.wifi,
                  size: 16,
                  color: isOfflineMeshMode ? Colors.blueAccent : Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  isOfflineMeshMode
                      ? "Mode Off-Grid (Bluetooth / Wi-Fi Mesh Actif)"
                      : "Connecté au Serveur Cloud AlphaChat",
                  style: TextStyle(
                    fontSize: 12,
                    color: isOfflineMeshMode ? Colors.blueAccent : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["sender"] == "@vivien";
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg["text"]!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          "Canal : ${msg["route"]}",
                          style: const TextStyle(color: Colors.white54, fontSize: 9),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF111827),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Message chiffré AlphaChat...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0B0F17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
