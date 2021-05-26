class NumbersCollection {
  String name;
  int length;

  NumbersCollection({this.name, this.length});
  // NumbersCollection.fromJSON(Map<String, int> data){
  // }

  static Map<String, dynamic> toJSON(List<NumbersCollection> numbersCollections) {
    Map<String, dynamic> json = {};
    numbersCollections.forEach((numbersCollection) => json[numbersCollection.name] = numbersCollection.length);
    return json;
  }
}
