import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_key_service.dart';
import 'core/services/logging_service.dart';
import 'core/services/error_handling_service.dart';
import 'core/services/performance_service.dart';
import 'core/providers/settings_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/stock_detail/presentation/providers/stock_detail_provider.dart';
import 'features/watchlist/presentation/providers/watchlist_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/main/presentation/pages/main_page.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandlingService.handleError(
      details.exception,
      stackTrace: details.stack,
      context: 'Flutter Framework',
      showToUser: false,
    );
  };

  // Set up performance tracking
  PerformanceService.startOperation('AppInitialization');

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    LoggingService.info('Environment variables loaded');

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Hive
    await Hive.initFlutter();
    LoggingService.info('Hive initialized');

    // Initialize storage service
    await StorageService.init();
    LoggingService.info('Storage service initialized');

    PerformanceService.endOperation('AppInitialization');

    runApp(const MyApp());
  } catch (error, stackTrace) {
    ErrorHandlingService.handleError(
      error,
      stackTrace: stackTrace,
      context: 'App Initialization',
      showToUser: true,
      userMessage: 'Failed to start the app. Please restart and try again.',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final settingsProvider = SettingsProvider();
            ApiKeyService().setSettingsProvider(settingsProvider);
            // Initialize settings in background
            settingsProvider.initialize();
            return settingsProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider()..loadDashboardData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(
            apiService: ApiService(),
            storageService: StorageService.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StockDetailProvider(
            apiService: ApiService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WatchlistProvider(
            storageService: StorageService.instance,
          )..loadWatchlist(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return FutureBuilder(
            future: settingsProvider.isInitialized
                ? Future.value(true)
                : settingsProvider.initialize(),
            builder: (context, snapshot) {
              return MaterialApp(
                title: 'Indian Stocks',
                debugShowCheckedModeBanner: false,
                themeMode: settingsProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                home: const MainPage(),
                // Global error handling for navigation errors
                builder: (context, child) {
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    return ErrorHandlingService.handleWidgetError(errorDetails);
                  };
                  return child ?? const SizedBox.shrink();
                },
              );
            },
          );
        },
      ),
    );
  }
}
