import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_driver/core/theme/app_theme.dart';
import 'package:gestion_driver/features/auth/data/firebase_auth_repo.dart';
import 'package:gestion_driver/features/auth/presentation/components/loading.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_state.dart';
import 'package:gestion_driver/features/auth/presentation/pages/auth_page.dart';
import 'package:gestion_driver/firebase_options.dart';
import 'package:gestion_driver/shared/navigation/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(context),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, state) {
            print(state);

            if (state is Unauthenticated) {
              return const AuthPage();
            }
            if (state is Authenticated) {
              return const MainShell();
            } else {
              return const Loading();
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
