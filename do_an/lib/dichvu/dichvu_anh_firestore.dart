import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../mohinh/anh_quan.dart';
import 'dichvu_anhquan.dart';

abstract final class DichVuAnhFirestore {
  static String anhQuan(String uid) => 'anhquanan/$uid';
  static String anhMon(String uid, String monid) =>
      'anhmonan/$uid/anhmon/$monid';

  static Future<Map<String, dynamic>> duLieu(AnhQuan anh) async {
    final nen = await DichVuAnhQuan.nenDeLuu(anh);
    return {
      'dulieu': base64Encode(nen.dulieu),
      'loaitep': 'image/jpeg',
      'ngaycapnhat': FieldValue.serverTimestamp(),
    };
  }
}
