import 'dart:convert';
import 'dart:typed_data';

class Protocol {
  static Uint8List constructMessage(List<int> header, Map<String, dynamic> data) {
    // 将 JSON 数据转换为 UTF-8 编码的字节
    final jsonData = utf8.encode(json.encode(data));

    // 创建4字节的长度字段
    final length = ByteData(4);
    length.setUint32(0, jsonData.length, Endian.big);

    // 合并用于计算 CRC 的数据
    final dataForCRC = [...header, ...length.buffer.asUint8List(), ...jsonData];

    // 计算 CRC
    final crc = calculateModbusCRC(dataForCRC);

    // 创建2字节的校验和
    final checksum = ByteData(2);
    checksum.setUint16(0, crc, Endian.little);

    // 合并所有数据
    return Uint8List.fromList([...header, ...length.buffer.asUint8List(), ...jsonData, ...checksum.buffer.asUint8List()]);
  }

  static int calculateModbusCRC(List<int> buffer) {
    int crc = 0xFFFF;
    for (int byte in buffer) {
      crc ^= byte;
      for (int j = 0; j < 8; j++) {
        if (crc & 0x0001 != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc = crc >> 1;
        }
      }
    }
    // 高低字节互换
    return ((crc << 8) & 0xFF00) | ((crc >> 8) & 0x00FF);
  }
}
