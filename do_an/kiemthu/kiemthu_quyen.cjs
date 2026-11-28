const assert = require('node:assert/strict');
const maychu = process.env.FIRESTORE_EMULATOR_HOST;
const maychuxacthuc = process.env.FIREBASE_AUTH_EMULATOR_HOST;
if (!maychu || !maychuxacthuc || !/^(127\.0\.0\.1|localhost):/.test(maychu) || !/^(127\.0\.0\.1|localhost):/.test(maychuxacthuc)) {
  throw new Error('Chỉ chạy kiểm thử với Firebase Emulator trên máy cục bộ.');
}
const goc = `http://${maychu}/v1/projects/demo-no-ne/databases/(default)/documents`;
let sodadat = 0;
async function goi(duongdan, token, noidung, phuongthuc = 'POST') {
  const phanhoi = await fetch(duongdan, {
    method: phuongthuc,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    ...(noidung ? { body: JSON.stringify(noidung) } : {}),
  });
  return { ma: phanhoi.status, dulieu: await phanhoi.json() };
}
async function taotaikhoan(ten) {
  const email = `${ten}-${Date.now()}@example.com`;
  const kq = await goi(`http://${maychuxacthuc}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, null, { email, password: 'ThuNghiem123!', returnSecureToken: true });
  assert.equal(kq.ma, 200, JSON.stringify(kq.dulieu));
  return { uid: kq.dulieu.localId, token: kq.dulieu.idToken, email };
}
const truong = dulieu => Object.fromEntries(Object.entries(dulieu).map(([k,v]) => [k, {stringValue:v}]));
function ghimoi(duongdan, dulieu) {
  return {
    update: { name: `projects/demo-no-ne/databases/(default)/documents/${duongdan}`, fields: truong(dulieu) },
    currentDocument: {exists:false},
    updateTransforms: [{fieldPath:'ngaytao',setToServerValue:'REQUEST_TIME'}],
  };
}
function suatrangthai(duongdan, trangthai) {
  return { update: {name:`projects/demo-no-ne/databases/(default)/documents/${duongdan}`,fields:truong({trangthai})}, updateMask:{fieldPaths:['trangthai']} };
}
const ten = tk => 'tk' + tk.uid.toLowerCase().slice(0,24);
const hoso = (tk,loaitaikhoan='khachhang',trangthai='hoatdong') => ({hoten:'',tendangnhap:ten(tk),email:tk.email,sodienthoai:'0901234567',loaitaikhoan,trangthai});
const quan = tk => ({chuquanid:tk.uid,tenquan:'Bếp Nhà An',diachi:'123 Nguyễn Huệ, Quận 1',duongdananh:`anhquanan/${tk.uid}/anhdaidien.png`,sodienthoai:'0901234567',mota:'',trangthai:'choduyet'});
const ghi = (tk,writes) => {
  const hsomoi = writes.find(w => w.currentDocument?.exists === false && w.update.name.endsWith('/nguoidung/'+tk.uid));
  if (hsomoi) writes.push({update:{name:`projects/demo-no-ne/databases/(default)/documents/tendangnhap/${hsomoi.update.fields.tendangnhap.stringValue}`,fields:truong({manguoidung:tk.uid})}});
  return goi(goc+':commit',tk.token,{writes});
};
async function kiemtra(ten, ham) { await ham(); sodadat++; console.log('ĐẠT: '+ten); }
function biTuChoi(kq) { assert.ok([401,403].includes(kq.ma), JSON.stringify(kq)); }
async function chay() {
  const khach=await taotaikhoan('khach'), khac=await taotaikhoan('khac'), chu=await taotaikhoan('chuquan'), admin=await taotaikhoan('admin');
  const maychuanh = process.env.FIREBASE_STORAGE_EMULATOR_HOST;
  if (!maychuanh || !/^(127\.0\.0\.1|localhost):/.test(maychuanh)) throw new Error('Cần Storage Emulator cục bộ.');
  const khoanh = `http://${maychuanh}/v0/b/demo-no-ne.firebasestorage.app/o`;
  const anh = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEUlEQVR4nGP4z8DwnwGMgRQAH+4D/dJQfRoAAAAASUVORK5CYII=','base64');
  const taianh = (tk,uid,loai='image/png',dulieu=anh,tep='anhdaidien.png') => fetch(khoanh+'?uploadType=media&name='+encodeURIComponent(`anhquanan/${uid}/${tep}`),{method:'POST',headers:{Authorization:`Bearer ${tk.token}`,'Content-Type':loai},body:dulieu});
  await kiemtra('Không tải ảnh sang thư mục của người khác',async()=>{assert.ok([401,403].includes((await taianh(khach,chu.uid)).status));});
  await kiemtra('Ảnh sai kiểu MIME bị từ chối',async()=>{assert.ok([401,403].includes((await taianh(chu,chu.uid,'text/plain')).status));});
  await kiemtra('Ảnh quá 5 MB bị từ chối',async()=>{assert.ok([401,403].includes((await taianh(chu,chu.uid,'image/png',Buffer.alloc(5*1024*1024+1))).status));});
  await kiemtra('Chủ quán tải ảnh trước khi gửi hồ sơ',async()=>{const kq=await taianh(chu,chu.uid);assert.equal(kq.status,200,await kq.text());});
  const duongdananh = khoanh+'/'+encodeURIComponent(`anhquanan/${chu.uid}/anhdaidien.png`);
  await kiemtra('Người khác không được xem ảnh quán chưa duyệt',async()=>{const kq=await fetch(duongdananh+'?alt=media',{headers:{Authorization:`Bearer ${khac.token}`}});assert.ok([401,403].includes(kq.status));});
  await kiemtra('Không tạo hồ sơ thiếu tên tài khoản duy nhất',async()=>{biTuChoi(await goi(goc+':commit',khac.token,{writes:[ghimoi('nguoidung/'+khac.uid,hoso(khac))]}));});
  await kiemtra('Khách tạo hồ sơ chính mình',async()=>{const kq=await ghi(khach,[ghimoi('nguoidung/'+khach.uid,hoso(khach))]);assert.equal(kq.ma,200,JSON.stringify(kq));});
  await kiemtra('Tên tài khoản trùng bị từ chối',async()=>{biTuChoi(await ghi(khac,[ghimoi('nguoidung/'+khac.uid,{...hoso(khac),tendangnhap:ten(khach)})]));});
  await kiemtra('Đọc hồ sơ của chính mình',async()=>{assert.equal((await goi(goc+'/nguoidung/'+khach.uid,khach.token,null,'GET')).ma,200);});
  await kiemtra('Người khác không được đọc hồ sơ khách',async()=>{biTuChoi(await goi(goc+'/nguoidung/'+khach.uid,khac.token,null,'GET'));});
  await kiemtra('Chưa đăng nhập không đọc được hồ sơ',async()=>{biTuChoi(await goi(goc+'/nguoidung/'+khach.uid,null,null,'GET'));});
  await kiemtra('Không được tự đăng ký admin',async()=>{biTuChoi(await ghi(admin,[ghimoi('nguoidung/'+admin.uid,hoso(admin,'quantrivien'))]));});
  await kiemtra('Không được ghi mật khẩu vào hồ sơ',async()=>{biTuChoi(await ghi(khac,[ghimoi('nguoidung/'+khac.uid,{...hoso(khac),matkhau:'KhongDuocLuu'})]));});
  await kiemtra('Không được mạo danh email',async()=>{biTuChoi(await ghi(khac,[ghimoi('nguoidung/'+khac.uid,{...hoso(khac),email:khach.email})]));});
  await kiemtra('Chủ quán phải tạo hồ sơ quán trong cùng batch',async()=>{biTuChoi(await ghi(chu,[ghimoi('nguoidung/'+chu.uid,hoso(chu,'chuquan','choduyet'))]));});
  await kiemtra('Quán thiếu đường dẫn ảnh bị từ chối',async()=>{const thieu=quan(chu);delete thieu.duongdananh;biTuChoi(await ghi(chu,[ghimoi('nguoidung/'+chu.uid,hoso(chu,'chuquan','choduyet')),ghimoi('quanan/'+chu.uid,thieu)]));});
  await kiemtra('Quán không được dùng đường dẫn ảnh của người khác',async()=>{biTuChoi(await ghi(chu,[ghimoi('nguoidung/'+chu.uid,hoso(chu,'chuquan','choduyet')),ghimoi('quanan/'+chu.uid,{...quan(chu),duongdananh:`anhquanan/${khach.uid}/anhdaidien.png`})]));});
  await kiemtra('Đăng ký chủ quán và quán chờ duyệt cùng lúc',async()=>{const kq=await ghi(chu,[ghimoi('nguoidung/'+chu.uid,hoso(chu,'chuquan','choduyet')),ghimoi('quanan/'+chu.uid,quan(chu))]);assert.equal(kq.ma,200,JSON.stringify(kq));});
  await kiemtra('Không xóa ảnh sau khi đã gửi hồ sơ quán',async()=>{const kq=await fetch(duongdananh,{method:'DELETE',headers:{Authorization:`Bearer ${chu.token}`}});assert.ok([401,403].includes(kq.status));});
  await kiemtra('Chủ quán được xem ảnh chính mình',async()=>{const kq=await fetch(duongdananh+'?alt=media',{headers:{Authorization:`Bearer ${chu.token}`}});assert.equal(kq.status,200);assert.deepEqual(Buffer.from(await kq.arrayBuffer()),anh);});
  await kiemtra('Chủ quán không tự duyệt tài khoản',async()=>{biTuChoi(await ghi(chu,[suatrangthai('nguoidung/'+chu.uid,'hoatdong'),suatrangthai('quanan/'+chu.uid,'hoatdong')]));});
  await kiemtra('Khách không tự tạo hồ sơ quán',async()=>{biTuChoi(await ghi(khach,[ghimoi('quanan/'+khach.uid,quan(khach))]));});
  await kiemtra('Khách không được tự đổi vai trò',async()=>{biTuChoi(await ghi(khach,[{update:{name:`projects/demo-no-ne/databases/(default)/documents/nguoidung/${khach.uid}`,fields:truong({loaitaikhoan:'quantrivien'})},updateMask:{fieldPaths:['loaitaikhoan']}}]));});
  // Chỉ dùng quyền owner của Emulator để cấp admin cho dữ liệu kiểm thử.
  const capadmin=await goi(goc+':commit','owner',{writes:[ghimoi('nguoidung/'+admin.uid,hoso(admin,'quantrivien'))]});
  assert.equal(capadmin.ma,200,JSON.stringify(capadmin));
  await kiemtra('Admin không duyệt lệch trạng thái tài khoản và quán',async()=>{biTuChoi(await ghi(admin,[suatrangthai('nguoidung/'+chu.uid,'hoatdong')]));});
  await kiemtra('Admin duyệt đồng thời tài khoản và quán',async()=>{const kq=await ghi(admin,[suatrangthai('nguoidung/'+chu.uid,'hoatdong'),suatrangthai('quanan/'+chu.uid,'hoatdong')]);assert.equal(kq.ma,200,JSON.stringify(kq));});
  await kiemtra('Admin có thể đọc hồ sơ để duyệt',async()=>{assert.equal((await goi(goc+'/nguoidung/'+chu.uid,admin.token,null,'GET')).ma,200);});
  await kiemtra('Admin được xem ảnh quán để duyệt',async()=>{const kq=await fetch(duongdananh+'?alt=media',{headers:{Authorization:`Bearer ${admin.token}`}});assert.equal(kq.status,200);});
  console.log(`HOÀN TẤT: ${sodadat} kiểm tra phân quyền đạt.`);
}
chay().catch(loi=>{console.error(loi);process.exitCode=1;});
