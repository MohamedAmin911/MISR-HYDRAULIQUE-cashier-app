// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TxItemAdapter extends TypeAdapter<TxItem> {
  @override
  final int typeId = 4;

  @override
  TxItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TxItem()
      ..productId = fields[0] as int
      ..productName = fields[1] as String
      ..craftPriceAtSale = fields[2] as double
      ..sellPriceAtSale = fields[3] as double
      ..quantity = fields[4] as int
      ..categoryName = fields[5] as String?
      ..baseSellPriceAtSale = fields[6] as double?
      ..buyPriceAtSale = fields[7] as double?
      ..buyPrice = fields[8] as double?;
  }

  @override
  void write(BinaryWriter writer, TxItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.craftPriceAtSale)
      ..writeByte(3)
      ..write(obj.sellPriceAtSale)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.categoryName)
      ..writeByte(6)
      ..write(obj.baseSellPriceAtSale)
      ..writeByte(7)
      ..write(obj.buyPriceAtSale)
      ..writeByte(8)
      ..write(obj.buyPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TxItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
