import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'features/analisis/bloc/analisis_bloc.dart';
import 'features/analisis/data/datasources/analisis_datasource.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const PoliCloudyApp());
}

class PoliCloudyApp extends StatelessWidget {
  const PoliCloudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final datasource = DashboardRemoteDatasourceImpl();
    final repository = DashboardRepositoryImpl(datasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DashboardBloc(repository)),
        BlocProvider(create: (_) => AnalisisBloc(AnalisisDatasourceImpl())),
      ],
      child: MaterialApp(
        title: 'PoliCloudy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const DashboardPage(),
      ),
    );
  }
}
