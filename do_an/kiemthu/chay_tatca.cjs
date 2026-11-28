const {spawnSync}=require('node:child_process');
const path=require('node:path');
for(const ten of ['kiemthu_quyen.cjs','kiemthu_dathang.cjs']) {
  const k=spawnSync(process.execPath,[path.join(__dirname,ten)],{stdio:'inherit',env:process.env});
  if(k.status!==0) process.exit(k.status||1);
}
