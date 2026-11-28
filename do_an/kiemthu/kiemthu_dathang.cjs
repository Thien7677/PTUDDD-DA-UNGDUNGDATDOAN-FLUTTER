const assert=require('node:assert/strict');
const {duLieuMau}=require('../congcu/dulieu_mau.cjs');
const maychu=process.env.FIRESTORE_EMULATOR_HOST, xacthuc=process.env.FIREBASE_AUTH_EMULATOR_HOST, kholuutru=process.env.FIREBASE_STORAGE_EMULATOR_HOST;
for(const h of [maychu,xacthuc,kholuutru]) if(!h||!/^(127\.0\.0\.1|localhost):/.test(h)) throw new Error('Chỉ chạy kiểm thử trên Firebase Emulator cục bộ.');
const goc=`http://${maychu}/v1/projects/demo-no-ne/databases/(default)/documents`;
const daydu=t=>'projects/demo-no-ne/databases/(default)/documents/'+t;
let sodadat=0;
async function goi(url,token,noidung,method='POST'){
  const p=await fetch(url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(noidung?{body:JSON.stringify(noidung)}:{})});
  return{ma:p.status,dulieu:await p.json()};
}
async function tk(ten){const email='dathang-'+ten+'-'+Date.now()+'@example.com';const k=await goi(`http://${xacthuc}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`,null,{email,password:'DemoThuNghiem123!',returnSecureToken:true});assert.equal(k.ma,200);return{uid:k.dulieu.localId,email,token:k.dulieu.idToken};}
function gt(v){if(Array.isArray(v))return{arrayValue:{values:v.map(gt)}};if(typeof v==='boolean')return{booleanValue:v};if(typeof v==='number')return Number.isInteger(v)?{integerValue:String(v)}:{doubleValue:v};if(v&&typeof v==='object')return{mapValue:{fields:truong(v)}};return{stringValue:v};}
const truong=d=>Object.fromEntries(Object.entries(d).map(([k,v])=>[k,gt(v)]));
function ghiMoi(ten,d,thoigian=['ngaytao']){return{update:{name:daydu(ten),fields:truong(d)},currentDocument:{exists:false},...(thoigian.length?{updateTransforms:thoigian.map(t=>({fieldPath:t,setToServerValue:'REQUEST_TIME'}))}:{})};}
function sua(ten,d,thoigian=[]){return{update:{name:daydu(ten),fields:truong(d)},updateMask:{fieldPaths:Object.keys(d)},...(thoigian.length?{updateTransforms:thoigian.map(t=>({fieldPath:t,setToServerValue:'REQUEST_TIME'}))}:{})};}
const ghi=(t,writes)=>goi(goc+':commit',typeof t==='string'?t:t.token,{writes});
const doc=(ten,t)=>goi(goc+'/'+ten,t?.token,null,'GET');
function dat(k){assert.equal(k.ma,200,JSON.stringify(k));}
function cam(k){assert.ok([401,403].includes(k.ma),JSON.stringify(k));}
async function kt(ten,ham){await ham();sodadat++;console.log('ĐẠT: '+ten);}
const loctheo=(truong,giatri)=>({structuredQuery:{from:[{collectionId:'donhang'}],...(truong?{where:{fieldFilter:{field:{fieldPath:truong},op:'EQUAL',value:{stringValue:giatri}}}}:{})}});

async function chay(){
  const admin=await tk('admin'),chu=await tk('chu'),pizza=await tk('pizza'),khach=await tk('khach'),khac=await tk('khac');
  dat(await ghi('owner',[ghiMoi('nguoidung/'+admin.uid,{hoten:'',tendangnhap:'adminthu',email:admin.email,sodienthoai:'0901234567',loaitaikhoan:'quantrivien',trangthai:'hoatdong'})]));
  const png=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGP4z8DAwMDAxAAAHQUBAfZDy6IAAAAASUVORK5CYII=','base64');
  const urlanh=`http://${kholuutru}/v0/b/demo-no-ne.firebasestorage.app/o`;
  const photo=await fetch(urlanh+'?uploadType=media&name='+encodeURIComponent(`anhquanan/${pizza.uid}/anhdaidien.png`),{method:'POST',headers:{Authorization:'Bearer '+pizza.token,'Content-Type':'image/png'},body:png});
  assert.equal(photo.status,200);
  await kt('Admin nạp dữ liệu mẫu đúng quyền trên chính Firestore',async()=>{dat(await ghi(admin,duLieuMau([chu,pizza,khach]).map(m=>ghiMoi(m.duongdan,m.dulieu,m.thoigian?[m.thoigian]:[]))));});
  await kt('Khách khác tự tạo hồ sơ hợp lệ',async()=>{dat(await ghi(khac,[ghiMoi('nguoidung/'+khac.uid,{hoten:'',tendangnhap:'khacthu'+khac.uid.slice(-5).toLowerCase(),email:khac.email,sodienthoai:'0901234567',loaitaikhoan:'khachhang',trangthai:'hoatdong'}),ghiMoi('tendangnhap/khacthu'+khac.uid.slice(-5).toLowerCase(),{manguoidung:khac.uid},[])]));});
  await kt('Khách chỉ truy vấn các quán đang hoạt động',async()=>{dat(await goi(goc+':runQuery',khach.token,{structuredQuery:{from:[{collectionId:'quanan'}],where:{fieldFilter:{field:{fieldPath:'trangthai'},op:'EQUAL',value:{stringValue:'hoatdong'}}}}}));});
  await kt('Không đọc được quán chưa duyệt',async()=>{cam(await doc('quanan/'+pizza.uid,khach));});
  await kt('Chủ quán chưa duyệt được xem thực đơn của mình',async()=>{dat(await doc('quanan/'+pizza.uid+'/monan/pizza_haisan',pizza));});
  await kt('Chủ quán chưa duyệt được mở danh sách đơn của mình',async()=>{dat(await goi(goc+':runQuery',pizza.token,loctheo('quanid',pizza.uid)));});
  const pathanh=urlanh+'/'+encodeURIComponent(`anhquanan/${pizza.uid}/anhdaidien.png`)+'?alt=media';
  await kt('Ảnh quán chưa duyệt không công khai cho khách',async()=>{assert.ok([401,403].includes((await fetch(pathanh,{headers:{Authorization:'Bearer '+khach.token}})).status));});
  await kt('Admin xem được ảnh quán chưa duyệt trong giới hạn truy cập',async()=>{assert.equal((await fetch(pathanh,{headers:{Authorization:'Bearer '+admin.token}})).status,200);});
  await kt('Khách không sửa được thực đơn',async()=>{cam(await ghi(khach,[sua('quanan/'+chu.uid+'/monan/pho_bo_tai',{gia:1},['ngaycapnhat'])]));});
  await kt('Quán không sửa thực đơn của quán khác',async()=>{cam(await ghi(chu,[sua('quanan/'+pizza.uid+'/monan/pizza_haisan',{gia:1},['ngaycapnhat'])]));});
  await kt('Giá bán âm bị từ chối',async()=>{cam(await ghi(chu,[sua('quanan/'+chu.uid+'/monan/pho_bo_tai',{gia:-1},['ngaycapnhat'])]));});
  await kt('Quán cập nhật giá món hợp lệ',async()=>{dat(await ghi(chu,[sua('quanan/'+chu.uid+'/monan/pho_bo_tai',{gia:55000},['ngaycapnhat'])]));});
  const tien=110000, phi=15000;
  const don={quanid:chu.uid,khachid:khach.uid,tenquan:'Phở Hà Nội',nguoinhan:'Khách Demo',sodienthoai:'0901234567',diachi:'123 Nguyễn Huệ, Quận 1',ghichu:'Không hành',cacmon:[{monid:'pho_bo_tai',tenmon:'Phở bò tái',gia:55000,soluong:2}],tienmon:tien,phigiaohang:phi,tongtien:tien+phi,trangthai:'choxacnhan',thanhtoan:'cod',trangthaithanhtoan:'chuathanhtoan',capnhatboi:khach.uid};
  const them=(id,d=don,t=khach)=>ghi(t,[ghiMoi('donhang/'+id,{...d,mamon:d.cacmon.map(m=>m.monid)},['ngaytao','ngaycapnhat'])]);
  await kt('Đọc ID đơn chưa tồn tại để đặt hàng chống gửi trùng',async()=>{assert.equal((await doc('donhang/chuatontai',khach)).ma,404);});
  await kt('Đơn COD đúng giá được máy chủ chấp nhận',async()=>{dat(await them('donhop le'.replace(' ','')));});
  const id='donhople';
  await kt('Không giả mạo giảm giá món kể cả tính lại tổng',async()=>{cam(await them('giagia',{...don,cacmon:[{...don.cacmon[0],gia:1}],tienmon:2,tongtien:15002}));});
  await kt('Không sửa tổng tiền đơn hàng',async()=>{cam(await them('saitong',{...don,tongtien:1}));});
  await kt('Không được tự miễn phí giao hàng',async()=>{cam(await them('saiphi',{...don,phigiaohang:0,tongtien:tien}));});
  await kt('Không đặt món thuộc quán khác trong một đơn',async()=>{cam(await them('saiguon',{...don,cacmon:[{monid:'pizza_haisan',tenmon:'Pizza hải sản',gia:189000,soluong:1}],tienmon:189000,tongtien:204000}));});
  await kt('Không khai hai dòng trùng món',async()=>{cam(await them('trungmon',{...don,cacmon:[...don.cacmon,...don.cacmon],tienmon:220000,tongtien:235000}));});
  for(const sl of [0,21,1.5]) await kt('Từ chối số lượng không hợp lệ: '+sl,async()=>{cam(await them('soluong'+String(sl).replace('.','_'),{...don,cacmon:[{...don.cacmon[0],soluong:sl}],tienmon:55000*sl,tongtien:55000*sl+phi}));});
  await kt('Không giả mạo đã thanh toán lúc tạo đơn',async()=>{cam(await them('paid',{...don,trangthaithanhtoan:'dathanhtoan'}));});
  await kt('Chủ quán không tự tạo đơn vai trò khách',async()=>{cam(await them('quanlamkhach',{...don,khachid:chu.uid,capnhatboi:chu.uid},chu));});
  const six=duLieuMau([chu,pizza,khach]).filter(m=>m.duongdan.startsWith('quanan/'+chu.uid+'/monan/')).slice(0,4).map(m=>({monid:m.duongdan.split('/').at(-1),tenmon:m.dulieu.tenmon,gia:m.dulieu.gia,soluong:1}));
  const sum=six.reduce((s,m)=>s+m.gia,0);
  await kt('Đơn 4 món khác nhau đủ ngân sách kiểm tra máy chủ',async()=>{dat(await them('bonmon',{...don,cacmon:six,tienmon:sum,tongtien:sum+phi}));});
  await kt('Đơn quá 4 món khác nhau bị từ chối',async()=>{cam(await them('namm on'.replace(' ',''),{...don,cacmon:[...six,{monid:'nuoc_suoi',tenmon:'Nước suối',gia:10000,soluong:1}],tienmon:sum+10000,tongtien:sum+10000+phi}));});
  await kt('Quán tạm nghỉ không nhận đơn',async()=>{dat(await ghi(chu,[sua('quanan/'+chu.uid,{dangmocua:false})]));cam(await them('quannghi'));dat(await ghi(chu,[sua('quanan/'+chu.uid,{dangmocua:true})]));});
  await kt('Khách đọc được đơn của mình',async()=>{dat(await doc('donhang/'+id,khach));});
  await kt('Khách khác không đọc được đơn',async()=>{cam(await doc('donhang/'+id,khac));});
  await kt('Quán khác không đọc được đơn',async()=>{cam(await doc('donhang/'+id,pizza));});
  await kt('Quán xử lý đọc được đơn của mình',async()=>{dat(await doc('donhang/'+id,chu));});
  await kt('Khách truy vấn đơn của mình',async()=>{dat(await goi(goc+':runQuery',khach.token,loctheo('khachid',khach.uid)));});
  await kt('Khách không liệt kê toàn bộ đơn',async()=>{cam(await goi(goc+':runQuery',khach.token,loctheo()));});
  await kt('Admin xem được toàn bộ đơn',async()=>{dat(await goi(goc+':runQuery',admin.token,loctheo()));});
  const capnhat=(tk,d)=>ghi(tk,[sua('donhang/'+id,{...d,capnhatboi:tk.uid},['ngaycapnhat'])]);
  await kt('Không nhảy từ chờ xác nhận sang đã giao',async()=>{cam(await capnhat(chu,{trangthai:'dagiao'}));});
  await kt('Khách không tự xác nhận giao trước khi đang giao',async()=>{cam(await capnhat(khach,{trangthai:'dagiao'}));});
  await kt('Quán tạm dừng đơn mới vẫn được xử lý đơn cũ; khách không được nhận thay',async()=>{dat(await ghi(chu,[sua('quanan/'+chu.uid,{dangmocua:false})]));cam(await capnhat(khach,{trangthai:'dangchuanbi'}));dat(await capnhat(chu,{trangthai:'dangchuanbi'}));dat(await ghi(chu,[sua('quanan/'+chu.uid,{dangmocua:true})]));});
  await kt('Chưa đi giao không được xác nhận thu tiền',async()=>{cam(await capnhat(chu,{trangthaithanhtoan:'dathanhtoan'}));});
  await kt('Quán bắt đầu giao hàng',async()=>{dat(await capnhat(chu,{trangthai:'danggiao'}));});
  await kt('Khách xác nhận nhận hàng nhưng không xác nhận tiền cho quán',async()=>{dat(await capnhat(khach,{trangthai:'dagiao'}));assert.equal((await doc('donhang/'+id,chu)).dulieu.fields.trangthaithanhtoan.stringValue,'chuathanhtoan');cam(await capnhat(khach,{trangthaithanhtoan:'dathanhtoan'}));});
  await kt('Quán ghi nhận đã thu tiền COD',async()=>{dat(await capnhat(chu,{trangthaithanhtoan:'dathanhtoan'}));});
  await kt('Không đảo ngược đơn đã giao hoặc tiền đã thu',async()=>{cam(await capnhat(chu,{trangthai:'dangchuanbi'}));cam(await capnhat(chu,{trangthaithanhtoan:'chuathanhtoan'}));});
  await kt('Không sửa giá trị đơn sau khi đặt',async()=>{cam(await capnhat(chu,{tongtien:1}));});
  await kt('Admin duyệt hồ sơ mẫu thứ hai theo cặp',async()=>{dat(await ghi(admin,[sua('quanan/'+pizza.uid,{trangthai:'hoatdong'}),sua('nguoidung/'+pizza.uid,{trangthai:'hoatdong'})]));});
  await kt('Khách được xem ảnh của quán đã duyệt',async()=>{assert.equal((await fetch(pathanh,{headers:{Authorization:'Bearer '+khach.token}})).status,200);});
  await kt('Khách bị khóa không được đặt hoặc đọc đơn tiếp',async()=>{dat(await ghi(admin,[sua('nguoidung/'+khach.uid,{trangthai:'bikhoa'})]));cam(await them('khachbikhoa'));cam(await doc('donhang/'+id,khach));});
  console.log('HOÀN TẤT: '+sodadat+' kiểm tra đặt hàng, thực đơn và phân quyền đạt.');
}
chay().catch(e=>{console.error(e);process.exitCode=1;});
