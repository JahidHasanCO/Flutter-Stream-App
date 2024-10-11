import 'package:flutter/material.dart';
import 'package:stream_app/l10n/l10n.dart';
import 'package:stream_app/router/router.dart';

class AppView extends StatelessWidget {
   AppView({super.key});

      final router = AppRouter(initialLocation: RouteNames.mediaPlayer.asPath);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
        debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
  
      routerConfig: router.config,
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppView();
  }
}
