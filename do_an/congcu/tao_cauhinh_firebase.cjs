const tep = require('node:fs');
const duongdan = require('node:path');
const tepnguon = process.argv[2];
if (!tepnguon) {
  console.error('Cách dùng: node congcu/tao_cauhinh_firebase.cjs "duongdan/google-services.json"');
  process.exit(1);
}
const nguon = JSON.parse(tep.readFileSync(tepnguon, 'utf8').replace(/^\uFEFF/, ''));
const ungdung = nguon.client?.find(khach => khach.client_info?.android_client_info?.package_name === 'com.example.do_an');
if (!ungdung) throw new Error('File phải thuộc ứng dụng Android có package com.example.do_an.');
const dich = duongdan.join(__dirname,'..','cauhinh_firebase.json');
const cu = tep.existsSync(dich) ? JSON.parse(tep.readFileSync(dich,'utf8').replace(/^\uFEFF/,'')) : {};
const cauhinh = {...cu,
  FIREBASE_MADUAN:nguon.project_info.project_id,
  FIREBASE_MANGUOIGUI:nguon.project_info.project_number,
  FIREBASE_KHOAAPI_ANDROID:ungdung.api_key[0].current_key,
  FIREBASE_MAUNGDUNG_ANDROID:ungdung.client_info.mobilesdk_app_id,
  FIREBASE_MIENDANGNHAP:nguon.project_info.project_id+'.firebaseapp.com',
  FIREBASE_KHOLUUTRU:nguon.project_info.storage_bucket || cu.FIREBASE_KHOLUUTRU || '',
  FIREBASE_KHOAAPI_WEB:cu.FIREBASE_KHOAAPI_WEB||'',
  FIREBASE_MAUNGDUNG_WEB:cu.FIREBASE_MAUNGDUNG_WEB||'',
};
tep.writeFileSync(dich,JSON.stringify(cauhinh,null,2)+'\n','utf8');
console.log('Đã tạo cauhinh_firebase.json cho Android. Không in giá trị cấu hình ra màn hình.');
