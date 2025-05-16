class Message {
  final String id;
  final String sender;
  final String senderModel;
  final String receiver;
  final String receiverModel;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? image;

  Message({
    required this.id,
    required this.sender,
    required this.senderModel,
    required this.receiver,
    required this.receiverModel,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.image,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      senderModel: json['senderModel']?.toString() ?? '',
      receiver: json['receiver']?.toString() ?? '',
      receiverModel: json['receiverModel']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      image: json['image'] != null ? Map<String, dynamic>.from(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender,
      'senderModel': senderModel,
      'receiver': receiver,
      'receiverModel': receiverModel,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'image': image,
    };
  }
} 