function duLieuMau(taikhoan) {
  const [chu, pizza, khach] = taikhoan;
  const suffix = chu.uid.slice(-6).toLowerCase().replace(/[^a-z0-9]/g,'x');
  const hoso = (tk, ten, loai, trangthai) => ({duongdan:'nguoidung/'+tk.uid, dulieu:{tendangnhap:ten+suffix, hoten:'', email:tk.email, sodienthoai:'0901234567', loaitaikhoan:loai, trangthai, dulieumau:true}, thoigian:'ngaytao'});
  const cac = [hoso(chu,'demoquan','chuquan','hoatdong'),hoso(pizza,'demopizza','chuquan','choduyet'),hoso(khach,'demokhach','khachhang','hoatdong')];
  for(const tk of cac.slice()) cac.push({duongdan:'tendangnhap/'+tk.dulieu.tendangnhap,dulieu:{manguoidung:tk.duongdan.split('/')[1]}});
  cac.push({duongdan:'quanan/'+chu.uid,dulieu:{chuquanid:chu.uid,tenquan:'Phở Hà Nội',diachi:'123 Nguyễn Huệ, Quận 1, TP.HCM',sodienthoai:'0901234567',mota:'Phở bò truyền thống · Món Việt',trangthai:'hoatdong',phigiaohang:15000,dangmocua:true,anhmau:'pho',duongdananh:'',dulieumau:true},thoigian:'ngaytao'});
  cac.push({duongdan:'quanan/'+pizza.uid,dulieu:{chuquanid:pizza.uid,tenquan:'Pizza Nhà Mình',diachi:'45 Lê Lợi, Quận 1, TP.HCM',sodienthoai:'0901234567',mota:'Pizza nóng hổi · Đồ Ý',trangthai:'choduyet',phigiaohang:20000,dangmocua:true,anhmau:'pizza',duongdananh:'',dulieumau:true},thoigian:'ngaytao'});
  for(const [id,ten,gia,mota,nhom,anh] of [
    ['pho_bo_tai','Phở bò tái',55000,'Thịt bò mềm, nước dùng thanh','Món chính','pho'],
    ['pho_bo_nam','Phở bò nạm',60000,'Nạm bò hầm mềm, bánh phở dai','Món chính','pho'],
    ['pho_ga','Phở gà',50000,'Gà ta, hành và rau thơm','Món chính','pho'],
    ['com_ga','Cơm gà',45000,'Cơm nóng cùng gà và rau củ','Món chính','com'],
    ['nuoc_suoi','Nước suối',10000,'Chai 500 ml','Đồ uống','nuoc'],
    ['tra_da','Trà đá',5000,'Trà mát dùng cùng bữa ăn','Đồ uống','nuoc'],
  ]) cac.push({duongdan:'quanan/'+chu.uid+'/monan/'+id,dulieu:{tenmon:ten,gia,mota,nhom,anhmau:anh,dangban:true},thoigian:'ngaycapnhat'});
  for(const [id,ten,gia] of [['pizza_haisan','Pizza hải sản',189000],['pizza_phomai','Pizza phô mai',129000]]) cac.push({duongdan:'quanan/'+pizza.uid+'/monan/'+id,dulieu:{tenmon:ten,gia,mota:'Đế mỏng, nóng hổi từ lò',nhom:'Món chính',anhmau:'pizza',dangban:true},thoigian:'ngaycapnhat'});
  return cac;
}
module.exports={duLieuMau};
