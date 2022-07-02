import 'package:sembast/timestamp.dart';

class Quote {
  int? id;
  late String content;
  String? author;
  String? source;
  String? notes;
  late DateTime createdAt;
  late DateTime updatedAt;

  Quote(this.content, {this.author, this.source, this.notes, this.id}) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  Quote.fromMap(this.id, Map<String, dynamic> map, {bool hasTimestamp = true}) {
    content = map['content'].toString();
    author = map['author']?.toString();
    source = map['source']?.toString();
    notes = map['notes']?.toString();

    if (hasTimestamp) {
      createdAt = (map['createdAt'] as Timestamp?)?.toDateTime() ?? DateTime.now();
      updatedAt = (map['updatedAt'] as Timestamp?)?.toDateTime() ?? DateTime.now();
    } else {
      createdAt = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
      updatedAt = DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'author': author,
      'source': source,
      'notes': notes,
      'createdAt': Timestamp.fromDateTime(createdAt),
      'updatedAt': Timestamp.fromDateTime(updatedAt),
    };
  }

  @override
  String toString() {
    String text = '"$content"';

    if (source != null) {
      text += ' $source';
      if (author != null) text += ', $author';
    } else if (author != null) {
      text += ' $author';
    }

    return text;
  }

  bool equals(Quote other) => content == other.content && author == other.author && source == other.source;
}
