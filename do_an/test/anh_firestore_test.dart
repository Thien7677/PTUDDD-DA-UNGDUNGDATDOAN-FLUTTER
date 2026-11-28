import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as anh;
import 'package:do_an/dichvu/dichvu_anhquan.dart';
import 'package:do_an/mohinh/anh_quan.dart';
import 'package:do_an/mohinh/ban_hang.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Ảnh lớn được thu nhỏ, lưu JPEG dưới 200 KB và đọc lại được', () async {
    final hinh=anh.Image(width:1400,height:1000);
    for(final p in hinh){p.r=(p.x*29+p.y*17)%256;p.g=(p.x*13+p.y*31)%256;p.b=(p.x+p.y*11)%256;}
    final dauvao=AnhQuan(dulieu:anh.encodePng(hinh),dinhdang:'png');
    final nen=await DichVuAnhQuan.nenDeLuu(dauvao);
    expect(nen.dinhdang,'jpg');
    expect(nen.dulieu.length,lessThanOrEqualTo(200*1024));
    final doc=anh.decodeJpg(nen.dulieu)!;
    expect(doc.width,lessThanOrEqualTo(960));
    expect(doc.height,greaterThan(0));
    expect(base64Decode(base64Encode(nen.dulieu)),nen.dulieu);
  });
  test('Đọc thực đơn cũ thiếu trường ảnh và giữ đường dẫn ảnh thật khi lưu', () {
    final cu=MonAn.tuDuLieu('q','m',{'tenmon':'Phở bò','gia':55000});
    expect(cu.duongdananh,'');
    final moi=MonAn.tuDuLieu('q','m',{'tenmon':'Phở bò','gia':55000,'duongdananh':'anhmonan/q/anhmon/m'});
    expect(moi.dulieu['duongdananh'],'anhmonan/q/anhmon/m');
  });
}
