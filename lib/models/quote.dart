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
    return 'Quote<id:$id, content:$content, author:$author, source:$source>';
  }
}
