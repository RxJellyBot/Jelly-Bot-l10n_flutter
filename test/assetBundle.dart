import 'dart:io';
import 'package:flutter/services.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    var content = await File('assets/$key').readAsBytes();
    return ByteData.view(content.buffer);
  }
}
