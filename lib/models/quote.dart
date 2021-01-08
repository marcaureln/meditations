class Quote {
  int id;
  String content;
  String author;
  String source;

  Quote(this.content, {this.author, this.source, this.id});

  Quote.fromMap(this.id, Map<String, dynamic> map) {
    content = map['content'];
    author = map['author'];
    source = map['source'];
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'author': author,
      'source': source,
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
}
