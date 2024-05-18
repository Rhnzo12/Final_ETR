// import 'package:etr_philearn_mad2/api.dart';
import 'package:etr_philearn_mad2/firebase_options.dart';
import 'package:etr_philearn_mad2/provider/toggle_mode_prvider.dart';
import 'package:etr_philearn_mad2/screen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseApi().initNotifications();
  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkModeProvider(),
      child: const Philearn(),
    ),
  );
}

class Philearn extends StatelessWidget {
  const Philearn({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: SplashScreen(),
      theme: context.watch<DarkModeProvider>().isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      // home: RegisterScreen(),
    );
  }
}
