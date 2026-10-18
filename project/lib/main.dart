import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return ChangeNotifierProvider(
            create: (_) => CartProvider(),
            child: MaterialApp(
                title: 'Đặt Đồ Ăn Cho Bạn No Nê',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                    primarySwatch: Colors.orange,
                    primaryColor: Colors.orange,
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
                    useMaterial3: true,
                    appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                    ),
                ),
                home: const HomeScreen(),
            ),
        );
    }
}