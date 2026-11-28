const fs=require('node:fs');const path=require('node:path');
const goc=path.join(__dirname,'..');
const cfg=JSON.parse(fs.readFileSync(path.join(goc,'cauhinh_firebase.json'),'utf8').replace(/^\uFEFF/,''));
const mau=JSON.parse(fs.readFileSync(path.join(goc,'.taikhoan_demo.json'),'utf8'));
if(cfg.FIREBASE_MADUAN!=='no-ne-food'||mau.maduan!=='no-ne-food')throw Error('Chỉ dùng với Firebase no-ne-food.');
const db='https://firestore.googleapis.com/v1/projects/no-ne-food/databases/(default)/documents';
const maanh={pho:'photo-1569718212165-3a8278d5f624',pizza:'photo-1513104890138-7c749659a591',com:'photo-1512058564366-18510be2db19',ga:'photo-1562967914-608f82629710',nuoc:'photo-1544145945-f90425340c7e'};
const anhDaDoc=new Map();
async function goi(url,token,body,method=body?'POST':'GET'){
 const r=await fetch(url,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(body?{body:JSON.stringify(body)}:{}),signal:AbortSignal.timeout(30000)});
 const d=await r.json();if(!r.ok)throw Error(d.error?.message||'Không kết nối được Firebase.');return d;
}
async function docAnh(loai){
 if(anhDaDoc.has(loai))return anhDaDoc.get(loai);
 if(!maanh[loai])throw Error('Không có ảnh mẫu cho loại '+loai);
 for(const width of [720,480]){
  const r=await fetch('https://images.unsplash.com/'+maanh[loai]+'?fit=crop&w='+width+'&q=70&fm=jpg',{headers:{Accept:'image/jpeg'},signal:AbortSignal.timeout(30000)});
  if(!r.ok)throw Error('Chưa tải được ảnh minh họa.');
  const bytes=Buffer.from(await r.arrayBuffer());
  if(bytes.length<=200*1024 && bytes[0]===255&&bytes[1]===216&&bytes[2]===255){anhDaDoc.set(loai,bytes);return bytes;}
 }
 throw Error('Ảnh mẫu chưa đạt giới hạn JPEG 200 KB.');
}
async function luuAnh(token,doc,vitri){
 if(doc.fields.duongdananh?.stringValue || !doc.fields.anhmau?.stringValue)return false;
 const bytes=await docAnh(doc.fields.anhmau.stringValue);
 const anh={name:'projects/no-ne-food/databases/(default)/documents/'+vitri,fields:{dulieu:{stringValue:bytes.toString('base64')},loaitep:{stringValue:'image/jpeg'}}};
 await goi(db+':commit',token,{writes:[
  {update:anh,updateTransforms:[{fieldPath:'ngaycapnhat',setToServerValue:'REQUEST_TIME'}]},
  {update:{name:doc.name,fields:{duongdananh:{stringValue:vitri}}},updateMask:{fieldPaths:['duongdananh']},currentDocument:{updateTime:doc.updateTime},...(doc.name.includes('/monan/')?{updateTransforms:[{fieldPath:'ngaycapnhat',setToServerValue:'REQUEST_TIME'}]}:{})},
 ]});
 return true;
}
(async()=>{
 let quans=0,mons=0;
 for(const tk of mau.taikhoan.slice(0,2)){
  const phien=await goi('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key='+encodeURIComponent(cfg.FIREBASE_KHOAAPI_WEB),null,{email:tk.email,password:tk.matkhau,returnSecureToken:true});
  if(phien.localId!==tk.uid)throw Error('UID quán mẫu không khớp.');
  const q=await goi(db+'/quanan/'+tk.uid,phien.idToken);
  if(!q.fields.dulieumau?.booleanValue)throw Error('Công cụ chỉ đổi ảnh của quán mẫu.');
  if(await luuAnh(phien.idToken,q,'anhquanan/'+tk.uid))quans++;
  const mon=await goi(db+'/quanan/'+tk.uid+'/monan',phien.idToken);
  for(const m of mon.documents||[])if(await luuAnh(phien.idToken,m,'anhmonan/'+tk.uid+'/anhmon/'+m.name.split('/').at(-1)))mons++;
 }
 console.log(JSON.stringify({anhQuanDaLuu:quans,anhMonDaLuu:mons,noiluu:'Cloud Firestore no-ne-food',kichthuocToiDa:'200 KB/ảnh JPEG',ghichu:'Ảnh đã có được giữ nguyên; không thay đổi giá, trạng thái hay đơn hàng.'}));
})().catch(e=>{console.error(e.message);process.exitCode=1});
