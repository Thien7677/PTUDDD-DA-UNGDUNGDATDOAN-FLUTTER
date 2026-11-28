const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const goc = path.join(__dirname, '..');
const tep = path.join(goc, '.taikhoan_demo.json');
const cauhinh = JSON.parse(fs.readFileSync(path.join(goc, 'cauhinh_firebase.json'), 'utf8').replace(/^\uFEFF/, ''));
if (cauhinh.FIREBASE_MADUAN !== 'no-ne-food') throw new Error('Chỉ dùng cho dự án no-ne-food.');
const email = 'admin@example.com';
const tendangnhap = 'admindemo';
const gocAuth = 'https://identitytoolkit.googleapis.com/v1/accounts:';
const gocDulieu = 'https://firestore.googleapis.com/v1/projects/no-ne-food/databases/(default)/documents';
async function goi(url, token, dulieu, phuongthuc = 'POST') {
  const phanhoi = await fetch(url, {
    method: phuongthuc,
    headers: {'Content-Type': 'application/json', ...(token ? {Authorization: 'Bearer ' + token} : {})},
    ...(dulieu ? {body: JSON.stringify(dulieu)} : {}),
    signal: AbortSignal.timeout(30000),
  });
  const ketqua = await phanhoi.json();
  if (!phanhoi.ok && phanhoi.status !== 404) throw new Error(ketqua.error?.message || 'Yêu cầu Firebase không thành công.');
  return {matrangthai: phanhoi.status, dulieu: ketqua};
}
async function chay() {
  const mau = fs.existsSync(tep) ? JSON.parse(fs.readFileSync(tep, 'utf8')) : {maduan: 'no-ne-food', taikhoan: []};
  if (mau.maduan !== 'no-ne-food') throw new Error('File tài khoản mẫu thuộc dự án khác.');
  let phien;
  if (mau.quantri) {
    if (mau.quantri.email !== email) throw new Error('Email admin cục bộ không khớp.');
    phien = (await goi(gocAuth + 'signInWithPassword?key=' + encodeURIComponent(cauhinh.FIREBASE_KHOAAPI_WEB), null, {
      email, password: mau.quantri.matkhau, returnSecureToken: true,
    })).dulieu;
    if (phien.localId !== mau.quantri.uid) throw new Error('UID tài khoản cục bộ không khớp.');
  } else {
    const matkhau = crypto.randomBytes(18).toString('base64url') + 'aA1!';
    try {
      phien = (await goi(gocAuth + 'signUp?key=' + encodeURIComponent(cauhinh.FIREBASE_KHOAAPI_WEB), null, {
        email, password: matkhau, returnSecureToken: true,
      })).dulieu;
    } catch (loi) {
      if (loi.message.includes('EMAIL_EXISTS')) throw new Error('Email admin đã tồn tại nhưng chưa có thông tin cục bộ. Hãy đăng nhập tài khoản đó; công cụ không đặt lại mật khẩu.');
      throw loi;
    }
    if (!phien.localId || !phien.idToken) throw new Error('Firebase chưa trả lại tài khoản hợp lệ.');
    mau.quantri = {nhan: 'Admin demo', uid: phien.localId, email, matkhau};
    fs.writeFileSync(tep, JSON.stringify(mau, null, 2) + '\n', {mode: 0o600});
  }
  const duongdan = '/nguoidung/' + phien.localId;
  const hoso = await goi(gocDulieu + duongdan, phien.idToken, null, 'GET');
  if (hoso.matrangthai === 404) {
    const chuoitruong = chuoi => ({stringValue: chuoi});
    const dulieu = {
      tendangnhap, hoten: '', email, sodienthoai: '0901234567', loaitaikhoan: 'khachhang', trangthai: 'hoatdong',
    };
    await goi(gocDulieu + ':commit', phien.idToken, {writes: [
      {update: {name: 'projects/no-ne-food/databases/(default)/documents' + duongdan,
        fields: Object.fromEntries(Object.entries(dulieu).map(([k, v]) => [k, chuoitruong(v)]))},
        currentDocument: {exists: false}, updateTransforms: [{fieldPath: 'ngaytao', setToServerValue: 'REQUEST_TIME'}]},
      {update: {name: 'projects/no-ne-food/databases/(default)/documents/tendangnhap/' + tendangnhap,
        fields: {manguoidung: chuoitruong(phien.localId)}}, currentDocument: {exists: false}},
    ]});
  }
  const ketqua = (await goi(gocDulieu + duongdan, phien.idToken, null, 'GET')).dulieu;
  if (ketqua.fields?.email?.stringValue !== email || ketqua.fields?.tendangnhap?.stringValue !== tendangnhap) throw new Error('Hồ sơ Firebase chưa khớp tài khoản demo.');
  console.log(JSON.stringify({email, uid: phien.localId, loaitaikhoan: ketqua.fields.loaitaikhoan.stringValue,
    trangthai: ketqua.fields.trangthai.stringValue, teptaikhoan: tep}, null, 2));
}
chay().catch(loi => {console.error('Chưa chuẩn bị được admin demo: ' + loi.message); process.exitCode = 1;});
