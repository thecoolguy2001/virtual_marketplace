// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generate a unique chat ID based on user IDs
  String generateChatId(String userId1, String userId2) {
    // Ensure consistent ordering
    return userId1.hashCode <= userId2.hashCode 
        ? '$userId1-$userId2' 
        : '$userId2-$userId1';
  }

  // Fetch messages for a specific chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _db.collection('Chats').doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList()
      );
  }

  // Send a message
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    var uuid = Uuid();
    await _db.collection('Chats').doc(chatId)
      .collection('messages')
      .doc(uuid.v4())
      .set({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }

  // Optionally, add method to create a chat document if it doesn't exist
  Future<void> createChatIfNotExists(String chatId) async {
    DocumentReference chatDoc = _db.collection('Chats').doc(chatId);
    DocumentSnapshot doc = await chatDoc.get();
    if (!doc.exists) {
      await chatDoc.set({
        'participants': chatId.split('-'), // Assuming chatId is 'user1-user2'
      });
    }
  }
}