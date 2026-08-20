class Wallet {
  final int id;
  final int userId;
  final double balance;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
  });

  factory Wallet.fromJson(
    Map<String, dynamic> json,
  ) {
    return Wallet(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      userId: int.tryParse(
            json['user_id'].toString(),
          ) ??
          0,

      balance: double.tryParse(
            json['balance'].toString(),
          ) ??
          0.0,
    );
  }
}