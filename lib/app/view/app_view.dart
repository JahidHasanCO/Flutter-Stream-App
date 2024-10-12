import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_app/l10n/l10n.dart';
import 'package:stream_app/router/router.dart';
import 'package:stream_app/shared/repositories/download_repo.dart';
import 'package:stream_app/theme/app_themes.dart';

/*

Play link:
https://vz-5dc327cb-9de.b-cdn.net/5d22127d-51dd-4420-9276-74d55673ee99/playlist.m3u8
Hint: The link can be played with an HLS player.

Download link:
https://vz-5dc327cb-9de.b-cdn.net/5d22127d-51dd-4420-9276-74d55673ee99/play_720p.mp4

*/

class AppView extends StatelessWidget {
  AppView({super.key});

  final router = AppRouter(initialLocation: RouteNames.mediaPlayer.asPath);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: appTheme(),
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
    return RepositoryProvider(
      create: (context) => DownloadRepo(),
      child: AppView(),
    );
  }
}
