const http=require('node:http');
const fs=require('node:fs');
const path=require('node:path');
const goc=path.resolve(__dirname,'..','build','web');
if(!fs.existsSync(path.join(goc,'index.html'))) throw new Error('Cần chạy flutter build web trước.');
const mime={'.html':'text/html; charset=utf-8','.js':'application/javascript','.json':'application/json','.css':'text/css','.wasm':'application/wasm','.png':'image/png','.jpg':'image/jpeg','.svg':'image/svg+xml','.ttf':'font/ttf','.otf':'font/otf'};
const server=http.createServer((req,res)=>{
  let ten;
  try{ten=decodeURIComponent(new URL(req.url,'http://localhost').pathname);}catch(_){res.writeHead(400);res.end();return;}
  let tep=path.resolve(goc,'.'+ten);
  const rel=path.relative(goc,tep);
  if(rel.startsWith('..')||path.isAbsolute(rel)){res.writeHead(403);res.end();return;}
  if(!fs.existsSync(tep)||fs.statSync(tep).isDirectory()) tep=path.join(goc,'index.html');
  res.writeHead(200,{'Content-Type':mime[path.extname(tep)]||'application/octet-stream','Cache-Control':'no-store'});
  fs.createReadStream(tep).pipe(res);
});
server.listen(0,'localhost',()=>console.log('No Nê đang chạy tại http://localhost:'+server.address().port));
