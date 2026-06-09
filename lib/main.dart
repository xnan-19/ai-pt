import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/env_loader.dart';
import 'viewmodels/main_viewmodel.dart';
import 'views/main_screen.dart';

void main() async {
  // 确保 Flutter 框架绑定初始化完成
  WidgetsFlutterBinding.ensureInitialized();
  
  // 在应用启动前，异步读取解析本地 .env 环境变量（获取 GEMINI_API_KEY）
  await EnvLoader.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainViewModel()),
      ],
      child: MaterialApp(
        title: 'AI 实验室 极简版',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          // 全局浅色高雅主题，背景与 Compose screenshot 保持统一
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E2022),
            primary: const Color(0xFF1E2022),
            surface: Colors.white,
            background: const Color(0xFFF7F8FA),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF1E2022)),
            bodyMedium: TextStyle(color: Color(0xFF1E2022)),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
