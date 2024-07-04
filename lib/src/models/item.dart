class Item {
  String merke;
  String modell;
  int aar;
  String barcode;
  String type;
  int rentalStatus;
  String tilstand;

  Item(
      {required this.merke,
      required this.modell,
      required this.aar,
      required this.barcode,
      required this.type,
      required this.rentalStatus,
      required this.tilstand});

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      merke: json['merke'] as String,
      modell: json['modell'] as String,
      aar: json['aar'] as int,
      barcode: json['barcode'] as String,
      type: json['type'] as String,
      rentalStatus: int.parse(json['status']),
      tilstand: json['tilstand'] as String,
    );
  }

  putBarcode(String barrcode) {
    return Item(
        aar: aar,
        merke: merke,
        modell: modell,
        type: type,
        tilstand: tilstand,
        rentalStatus: rentalStatus,
        barcode: barrcode);
  }

  // Method to convert Item to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'merke': merke.toLowerCase(),
      'modell': modell.toLowerCase(),
      'aar': aar,
      'barcode': barcode,
      'type': type.toLowerCase(),
      'status': rentalStatus,
      'tilstand': tilstand.toLowerCase()
    };
  }
}
