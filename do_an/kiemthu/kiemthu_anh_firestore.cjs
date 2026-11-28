const assert=require('node:assert/strict');
const jpeg=require('./anh_thu.cjs');
const {duLieuMau}=require('../congcu/dulieu_mau.cjs');
const host=process.env.FIRESTORE_EMULATOR_HOST,auth=process.env.FIREBASE_AUTH_EMULATOR_HOST;
for(const h of [host,auth])if(!h||!/^(127\.0\.0\.1|localhost):/.test(h))throw Error('Chỉ kiểm tra trên Emulator.');
const db=`http://${host}/v1/projects/demo-no-ne/databases/(default)/documents`;
const ten=p=>'projects/demo-no-ne/databases/(default)/documents/'+p;
let dat=0;
function gt(v){if(typeof v==='boolean')return{booleanValue:v};if(typeof v==='number')return{integerValue:String(v)};return{stringValue:v};}
const fields=d=>Object.fromEntries(Object.entries(d).map(([k,v])=>[k,gt(v)]));
async function goi(url,token,body){const r=await fetch(url,{method:body?'POST':'GET',headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(body?{body:JSON.stringify(body)}:{})});return{ma:r.status,d:await r.json()};}
async function tk(n){const email='anh-'+n+'-'+Date.now()+'@example.com';const r=await goi(`http://${auth}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo`,null,{email,password:'ThuAnh123!',returnSecureToken:true});assert.equal(r.ma,200);return{uid:r.d.localId,email,token:r.d.idToken};}
const moi=(p,d,stamp)=>({update:{name:ten(p),fields:fields(d)},currentDocument:{exists:false},...(stamp?{updateTransforms:[{fieldPath:stamp,setToServerValue:'REQUEST_TIME'}]}:{})});
const sua=(p,d,stamp)=>({update:{name:ten(p),fields:fields(d)},updateMask:{fieldPaths:Object.keys(d)},...(stamp?{updateTransforms:[{fieldPath:stamp,setToServerValue:'REQUEST_TIME'}]}:{})});
const ghi=(t,writes)=>goi(db+':commit',t==='owner'?t:t.token,{writes});
const doc=(p,t)=>goi(db+'/'+p,t?.token);
const ok=r=>assert.equal(r.ma,200,JSON.stringify(r.d));
const cam=r=>assert.ok([401,403].includes(r.ma),JSON.stringify(r.d));
const anh=(p,d={})=>sua(p,{dulieu:jpeg,loaitep:'image/jpeg',...d},'ngaycapnhat');
async function kt(n,f){await f();dat++;console.log('ĐẠT: '+n);}
(async()=>{
 const admin=await tk('admin'),chu=await tk('chu'),cho=await tk('cho'),khach=await tk('khach'),moiChu=await tk('dangky');
 ok(await ghi('owner',[moi('nguoidung/'+admin.uid,{tendangnhap:'adminanh',hoten:'',email:admin.email,sodienthoai:'0901234567',loaitaikhoan:'quantrivien',trangthai:'hoatdong'},'ngaytao')]));
 ok(await ghi(admin,duLieuMau([chu,cho,khach]).map(m=>moi(m.duongdan,m.dulieu,m.thoigian))));
 const dk=[moi('nguoidung/'+moiChu.uid,{tendangnhap:'quanmoi'+moiChu.uid.slice(-5).toLowerCase(),hoten:'',email:moiChu.email,sodienthoai:'0901234567',loaitaikhoan:'chuquan',trangthai:'choduyet'},'ngaytao'),moi('tendangnhap/quanmoi'+moiChu.uid.slice(-5).toLowerCase(),{manguoidung:moiChu.uid}),moi('quanan/'+moiChu.uid,{chuquanid:moiChu.uid,tenquan:'Quán ảnh thật',diachi:'123 Nguyễn Huệ, Quận 1',sodienthoai:'0901234567',mota:'',trangthai:'choduyet',duongdananh:'anhquanan/'+moiChu.uid},'ngaytao')];
 await kt('Đăng ký quán thiếu document ảnh bị từ chối',async()=>cam(await ghi(moiChu,dk)));
 await kt('Đăng ký quán và ảnh Firestore trong cùng batch',async()=>ok(await ghi(moiChu,[...dk,anh('anhquanan/'+moiChu.uid)])));
 await kt('Ảnh đăng ký được lưu thật và đọc lại đúng dữ liệu',async()=>{const r=await doc('anhquanan/'+moiChu.uid,moiChu);ok(r);assert.equal(r.d.fields.dulieu.stringValue,jpeg);});
 const aq='anhquanan/'+chu.uid,ac='anhquanan/'+cho.uid;
 await kt('Chủ quán gắn ảnh thật vào quán mẫu',async()=>ok(await ghi(chu,[anh(aq),sua('quanan/'+chu.uid,{duongdananh:aq})])));
 await kt('Khách xem được ảnh của quán đã duyệt',async()=>ok(await doc(aq,khach)));
 await kt('Chưa đăng nhập không đọc được ảnh',async()=>cam(await doc(aq)));
 await kt('Khách không tải ảnh vào hồ sơ của quán',async()=>cam(await ghi(khach,[anh(aq)])));
 await kt('Chủ quán không đổi ảnh quán khác',async()=>cam(await ghi(cho,[anh(aq)])));
 await kt('Quán chờ duyệt được lưu và xem ảnh riêng',async()=>{ok(await ghi(cho,[anh(ac),sua('quanan/'+cho.uid,{duongdananh:ac})]));ok(await doc(ac,cho));});
 await kt('Khách không xem ảnh quán chưa duyệt',async()=>cam(await doc(ac,khach)));
 await kt('Admin được xem ảnh quán đang chờ duyệt',async()=>ok(await doc(ac,admin)));
 await kt('Từ chối ảnh vượt giới hạn 200 KB sau mã hóa',async()=>cam(await ghi(chu,[anh(aq,{dulieu:'/9j/'+ 'A'.repeat(273068)})])));
 await kt('Từ chối loại ảnh lưu không phải JPEG',async()=>cam(await ghi(chu,[anh(aq,{loaitep:'image/png'})])));
 await kt('Từ chối dữ liệu không đúng khung mã hóa ảnh',async()=>cam(await ghi(chu,[anh(aq,{dulieu:'khongphaianh'})])));
 await kt('Từ chối đường dẫn ảnh quán thuộc người khác',async()=>cam(await ghi(chu,[sua('quanan/'+chu.uid,{duongdananh:ac})])));
 const am='anhmonan/'+chu.uid+'/anhmon/pho_bo_tai',mon='quanan/'+chu.uid+'/monan/pho_bo_tai';
 await kt('Lưu ảnh món và đường dẫn cùng một batch',async()=>ok(await ghi(chu,[anh(am),sua(mon,{duongdananh:am},'ngaycapnhat')])));
 await kt('Khách đọc được ảnh món đang ở quán đã duyệt',async()=>ok(await doc(am,khach)));
 await kt('Không gắn ảnh món của quán khác',async()=>cam(await ghi(chu,[sua(mon,{duongdananh:'anhmonan/'+cho.uid+'/anhmon/pizza_haisan'},'ngaycapnhat')])));
 await kt('Không gắn đường dẫn ảnh chưa tồn tại',async()=>cam(await ghi(chu,[sua('quanan/'+chu.uid+'/monan/com_ga',{duongdananh:'anhmonan/'+chu.uid+'/anhmon/com_ga'},'ngaycapnhat')])));
 await kt('Không tạo ảnh món mồ côi ngoài thực đơn',async()=>cam(await ghi(chu,[anh('anhmonan/'+chu.uid+'/anhmon/chuaco')])));
 await kt('Ảnh và món cùng bị rollback khi giá món không hợp lệ',async()=>{cam(await ghi(chu,[anh(am,{dulieu:jpeg.slice(0,-4)+'AAAA'}),sua(mon,{gia:-1},'ngaycapnhat')]));assert.equal((await doc(am,chu)).d.fields.dulieu.stringValue,jpeg);});
 await kt('Thay ảnh mới nhưng giữ nguyên đường dẫn tham chiếu',async()=>ok(await ghi(chu,[anh(am)])));
 ok(await ghi(admin,[sua('nguoidung/'+chu.uid,{trangthai:'bikhoa'}),sua('quanan/'+chu.uid,{trangthai:'bikhoa'})]));
 await kt('Quán bị khóa không được đổi ảnh',async()=>cam(await ghi(chu,[anh(am)])));
 console.log('HOÀN TẤT: '+dat+' kiểm tra ảnh Firestore đạt.');
})().catch(e=>{console.error(e);process.exitCode=1});
