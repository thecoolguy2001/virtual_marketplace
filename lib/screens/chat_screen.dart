// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/chat_message.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String artistId;

  const ChatScreen({Key? key, required this.artistId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatId;
  List<types.Message> _messages = [];
  late types.User _currentUser;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle unauthenticated state
      Navigator.pop(context);
      return;
    }

    _currentUser = types.User(
      id: currentUser.uid,
      firstName: currentUser.email?.split('@')[0],
    );

    // Generate chat ID based on current user ID and artist ID
    chatId = chatService.generateChatId(currentUser.uid, widget.artistId);

    // Ensure chat document exists
    chatService.createChatIfNotExists(chatId);
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: chatService.getMessages(chatId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading messages'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chatMessages = snapshot.data!;
          _messages = chatMessages.map((msg) => _mapToTypesMessage(msg)).toList();
          return Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _currentUser,
            showUserAvatars: true,
            showUserNames: true,
          );
        },
      ),
    );
  }

  types.Message _mapToTypesMessage(ChatMessage msg) {
    return types.TextMessage(
      author: types.User(id: msg.senderId),
      createdAt: msg.timestamp.seconds * 1000, // Convert to milliseconds
      id: msg.id,
      text: msg.text,
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle unauthenticated state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to send messages')),
      );
      return;
    }

    chatService.sendMessage(chatId, currentUser.uid, message.text);
  }
}