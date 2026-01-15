// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleTxAdapter extends TypeAdapter<SaleTx> {
  @override
  final int typeId = 5;

  @override
  SaleTx read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleTx()
      ..id = fields[0] as int
      ..date = fields[1] as DateTime
      ..sellerUserId = fields[2] as int?
      ..sellerUsername = fields[3] as String
      ..branchId = fields[4] as int?
      ..branchName = fields[5] as String
      ..customerName = fields[6] as String
      ..items = (fields[7] as List).cast<TxItem>()
      ..totalSell = fields[8] as double
      ..totalCost = fields[9] as double
      ..totalProfit = fields[10] as double
      ..branchPhone = fields[11] as String?
      ..craftPrice = fields[12] as double;
  }

  @override
  void write(BinaryWriter writer, SaleTx obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.sellerUserId)
      ..writeByte(3)
      ..write(obj.sellerUsername)
      ..writeByte(4)
      ..write(obj.branchId)
      ..writeByte(5)
      ..write(obj.branchName)
      ..writeByte(6)
      ..write(obj.customerName)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.totalSell)
      ..writeByte(9)
      ..write(obj.totalCost)
      ..writeByte(10)
      ..write(obj.totalProfit)
      ..writeByte(11)
      ..write(obj.branchPhone)
      ..writeByte(12)
      ..write(obj.craftPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleTxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
