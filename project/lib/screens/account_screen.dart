import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'owner_orders_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final error = _isLogin
        ? await auth.signIn(_emailCtrl.text, _passCtrl.text)
        : await auth.register(_emailCtrl.text, _passCtrl.text, _nameCtrl.text);

    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 12),
              Text(
                auth.user?.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              // --- ĐÚNG VỊ TRÍ LÀ Ở ĐÂY ---
              Text(
                'Role: ${auth.role} | UID: ${auth.user?.uid}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (auth.isOwner) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnerOrdersScreen()),
                    );
                  },
                  icon: const Icon(Icons.storefront),
                  label: const Text('Quản lý đơn hàng (Chủ quán)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9532F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                onPressed: () => auth.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Đăng nhập No Nê' : 'Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isLogin) ...[
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9532F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Chưa có tài khoản? Đăng ký ngay' : 'Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}