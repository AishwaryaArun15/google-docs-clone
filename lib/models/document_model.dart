class DocumentModel {
  final String title;
  final String uid;
  final List content;
  final DateTime createdAt;
  final String id;

  DocumentModel({
    required this.title,
    required this.uid,
    required this.content,
    required this.createdAt,
    required this.id,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      title: json['title'] ?? '',
      uid: json['uid'] ?? '',
      content: List<dynamic>.from(json['content']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'uid': uid,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }

  DocumentModel copyWith({
    String? title,
    String? uid,
    List<dynamic>? content,
    DateTime? createdAt,
    String? id,
  }) {
    return DocumentModel(
      title: title ?? this.title,
      uid: uid ?? this.uid,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}
