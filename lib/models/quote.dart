class Quote {
  int id;
  String content;
  String author;
  String source;

  Quote(this.content, {this.author: 'Anonymous', this.source, this.id});

  Quote.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.content = map['content'];
    this.author = map['author'];
    this.source = map['source'];
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
