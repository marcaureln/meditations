class Quote {
  String content; // the quote itself
  String author; // who said ?
  String source; // where the quote is from ? a book, a tv show, ...

  Quote(this.content, {this.author: 'Anonymous', this.source});
}
