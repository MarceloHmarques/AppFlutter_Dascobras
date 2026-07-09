import 'package:DasCobras/app/viewmodels/sale_viewmodel/sale_history_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:DasCobras/app/views/initial_splash/initial_splash_page.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:DasCobras/app/viewmodels/reports_viewmodel/reports_viewmodel.dart';
import 'package:DasCobras/app/viewmodels/client_viewmodel/client_viewmodel.dart';
import 'package:DasCobras/app/viewmodels/sale_viewmodel/sale_viewmodel.dart';
import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:DasCobras/app/viewmodels/commission_viewmodel/commission_report_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['UrlSupa']!,
    anonKey: dotenv.env['SecretKey']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeSearchViewmodel()),

        ChangeNotifierProvider(create: (_) => ClientViewModel()),

        ChangeNotifierProvider(create: (_) => SaleViewModel()),

        ChangeNotifierProvider(create: (_) => ReportsViewModel()),

        ChangeNotifierProvider(create: (_) => SaleHistoryViewModel()),

        ChangeNotifierProvider(create: (_) => CarregamentoViewModel()), 

        ChangeNotifierProvider(create: (_) => CommissionReportViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: const Locale('pt', 'BR'),

      supportedLocales: const [Locale('pt', 'BR')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const InitialSplashPage(),
    );
  }
}
