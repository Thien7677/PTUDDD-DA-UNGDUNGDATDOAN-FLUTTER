const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const readline=require('node:readline/promises');
const {duLieuMau}=require('./dulieu_mau.cjs');
const goc=path.join(__dirname,'..');
const c=JSON.parse(fs.readFileSync(path.join(goc,'cauhinh_firebase.json'),'utf8').replace(/^\uFEFF/,''));
if(c.FIREBASE_MADUAN!=='no-ne-food') throw new Error('Công cụ này chỉ dành cho dự án no-ne-food của nhóm.');
const url='https://firestore.googleapis.com/v1/projects/no-ne-food/databases/(default)/documents';
const auth='https://identitytoolkit.googleapis.com/v1/accounts:';
async function goi(url, token, body, method='POST') {
  const p=await fetch(url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(body?{body:JSON.stringify(body)}:{}),signal:AbortSignal.timeout(30000)});
  const d=await p.json();
  if(!p.ok) throw new Error(d.error?.message || 'Không hoàn tất yêu cầu Firebase.');
  return d;
}
function truong(v){if(typeof v==='boolean')return{booleanValue:v};if(typeof v==='number')return{integerValue:String(v)};return{stringValue:v};}
async function matkhauAn(){
  if(!process.stdin.isTTY) throw new Error('Hãy chạy trực tiếp trong Terminal của VS Code để nhập mật khẩu an toàn.');
  process.stdout.write('Mật khẩu admin (không hiển thị): ');
  process.stdin.setRawMode(true);process.stdin.resume();process.stdin.setEncoding('utf8');
  return await new Promise((resolve,reject)=>{
    let s='';
    const nhap=b=>{for(const ky of b){if(ky==='\u0003'){don();reject(new Error('Đã hủy.'));return;}if(ky==='\r'||ky==='\n'){don();resolve(s);return;}if(ky==='\u007f'||ky==='\b'){s=s.slice(0,-1);}else{s+=ky;}}};
    function don(){process.stdin.off('data',nhap);process.stdin.setRawMode(false);process.stdin.pause();process.stdout.write('\n');}
    process.stdin.on('data',nhap);
  });
}
async function chay(){
  const tep=path.join(goc,'.taikhoan_demo.json');
  let mau=fs.existsSync(tep)?JSON.parse(fs.readFileSync(tep,'utf8')):{maduan:'no-ne-food',taikhoan:[]};
  if(mau.maduan!=='no-ne-food') throw new Error('File tài khoản mẫu thuộc dự án khác.');
  let email,password;
  if(process.argv.includes('--quantri-cucbo')){
    if(!mau.quantri||mau.quantri.email!=='admin@example.com') throw new Error('Chưa có tài khoản admin cục bộ. Chạy congcu/tao_admin_demo.cjs trước.');
    email=mau.quantri.email;password=mau.quantri.matkhau;
  }else{
    const rl=readline.createInterface({input:process.stdin,output:process.stdout});
    email=(await rl.question('Email admin [admin@example.com]: ')).trim() || 'admin@example.com';
    rl.close();
    password=await matkhauAn();
  }
  const admin=await goi(auth+'signInWithPassword?key='+encodeURIComponent(c.FIREBASE_KHOAAPI_WEB),null,{email,password,returnSecureToken:true});
  if(process.argv.includes('--quantri-cucbo') && admin.localId!==mau.quantri.uid) throw new Error('UID admin không khớp file cục bộ.');
  const h=await goi(url+'/nguoidung/'+admin.localId,admin.idToken,null,'GET');
  if(h.fields?.loaitaikhoan?.stringValue!=='quantrivien'||h.fields?.trangthai?.stringValue!=='hoatdong') throw new Error('Tài khoản chưa có quyền admin. Trong Firebase Console, mở nguoidung/'+admin.localId+' và đặt loaitaikhoan = quantrivien, trangthai = hoatdong. Xem HUONG_DAN_DEMO.md.');
  const nhan=['Chủ quán Phở Hà Nội','Chủ quán Pizza chờ duyệt','Khách đặt món'];
  for(let i=mau.taikhoan.length;i<3;i++){
    const suffix=crypto.randomBytes(4).toString('hex');
    const email='demo.'+['chuquan','pizza','khach'][i]+'.'+suffix+'@example.com';
    const matkhau=crypto.randomBytes(15).toString('base64url')+'aA1!';
    const tk=await goi(auth+'signUp?key='+encodeURIComponent(c.FIREBASE_KHOAAPI_WEB),null,{email,password:matkhau,returnSecureToken:true});
    mau.taikhoan.push({nhan:nhan[i],uid:tk.localId,email,matkhau});
    fs.writeFileSync(tep,JSON.stringify(mau,null,2)+'\n');
  }
  const writes=[];
  for(const m of duLieuMau(mau.taikhoan)){
    try{
      const p=await fetch(url+'/'+m.duongdan,{headers:{Authorization:'Bearer '+admin.idToken},signal:AbortSignal.timeout(20000)});
      if(p.ok) continue;
      if(p.status!==404) throw new Error('Chưa đọc được đường dẫn '+m.duongdan+'. Hãy triển khai firestore.rules mới.');
    }catch(e){throw new Error(e.message);}
    writes.push({update:{name:'projects/no-ne-food/databases/(default)/documents/'+m.duongdan,fields:Object.fromEntries(Object.entries(m.dulieu).map(([k,v])=>[k,truong(v)]))},currentDocument:{exists:false},...(m.thoigian?{updateTransforms:[{fieldPath:m.thoigian,setToServerValue:'REQUEST_TIME'}]}:{})});
  }
  if(writes.length) await goi(url+':commit',admin.idToken,{writes});
  const khach=mau.taikhoan[2];
  const phienkhach=await goi(auth+'signInWithPassword?key='+encodeURIComponent(c.FIREBASE_KHOAAPI_WEB),null,{email:khach.email,password:khach.matkhau,returnSecureToken:true});
  const chu=mau.taikhoan[0];
  const donmau=[
    [{monid:'pho_bo_tai',tenmon:'Phở bò tái',gia:55000,soluong:2}],
    [{monid:'com_ga',tenmon:'Cơm gà',gia:45000,soluong:1},{monid:'nuoc_suoi',tenmon:'Nước suối',gia:10000,soluong:1}],
  ];
  for(let i=0;i<donmau.length;i++){
    const ten='donhang/demo_'+khach.uid+'_'+String(i+1).padStart(6,'0');
    const cu=await fetch(url+'/'+ten,{headers:{Authorization:'Bearer '+phienkhach.idToken},signal:AbortSignal.timeout(20000)});
    if(cu.ok)continue;
    if(cu.status!==404)throw new Error('Chưa đọc được đơn mẫu. Kiểm tra quy tắc Firestore.');
    const tienmon=donmau[i].reduce((s,m)=>s+m.gia*m.soluong,0);
    const dulieu={quanid:chu.uid,khachid:khach.uid,tenquan:'Phở Hà Nội',nguoinhan:'Khách Demo',sodienthoai:'0901234567',diachi:'123 Nguyễn Huệ, Quận 1, TP.HCM',ghichu:'Đơn mẫu dùng để trình bày đồ án',cacmon:donmau[i],mamon:donmau[i].map(m=>m.monid),tienmon,phigiaohang:15000,tongtien:tienmon+15000,trangthai:'choxacnhan',thanhtoan:'cod',trangthaithanhtoan:'chuathanhtoan',capnhatboi:khach.uid};
    function chuyentruong(v){if(Array.isArray(v))return{arrayValue:{values:v.map(chuyentruong)}};if(v&&typeof v==='object')return{mapValue:{fields:Object.fromEntries(Object.entries(v).map(([k,x])=>[k,chuyentruong(x)]))}};return truong(v);}
    await goi(url+':commit',phienkhach.idToken,{writes:[{update:{name:'projects/no-ne-food/databases/(default)/documents/'+ten,fields:Object.fromEntries(Object.entries(dulieu).map(([k,v])=>[k,chuyentruong(v)]))},currentDocument:{exists:false},updateTransforms:['ngaytao','ngaycapnhat'].map(t=>({fieldPath:t,setToServerValue:'REQUEST_TIME'}))}]});
  }
  console.log('Đã nạp dữ liệu mẫu. Các dữ liệu đã có được giữ nguyên.');
  console.log('Xem tài khoản mẫu tại: '+tep+'. File này đã được loại khỏi Git.');
}
chay().catch(e=>{console.error('Chưa nạp được dữ liệu mẫu: '+e.message);process.exitCode=1;});
