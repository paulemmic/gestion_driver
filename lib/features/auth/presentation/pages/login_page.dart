import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/auth/presentation/components/my_button.dart';
import 'package:gestion_driver/features/auth/presentation/components/my_textfield.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function() togglePages;

  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();

  void login() {
    final String email = emailController.text;
    final String pw = pwController.text;

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email & password.")),
      );
    }
  }

  void openForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Forgot Password?"),
        content: MyTextfield(
          controller: emailController,
          hintText: "Enter email..",
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String message = await authCubit.forgotPassword(
                emailController.text,
              );
              if (message == "Password reset email sent! Check your inbox.") {
                Navigator.pop(context);
                emailController.clear();
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: Text("Reset"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Center(child: Text('Login'))),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("", style: TextStyle(fontSize: 16)),

                const SizedBox(height: 25),

                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextfield(
                  controller: pwController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => openForgotPassword(),
                      child: Text(
                        "Mot de passe oublié?",
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                MyButton(onTap: login, text: "SE CONNECTER"),

                SizedBox(height: 25),

                // Row(
                //   children: [
                //     Expanded(
                //       child: Divider(
                //         color: Theme.of(context).colorScheme.secondary,
                //       ),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //       child: Text("Or sign in with"),
                //     ),
                //     Expanded(
                //       child: Divider(
                //         color: Theme.of(context).colorScheme.tertiary,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 25),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     MyAppleSignInButton(
                //       onTap: () async {
                //         authCubit.signInWithApple();
                //       },
                //     ),
                //     const SizedBox(width: 10),
                //     MyGoogleSignInButton(
                //       onTap: () async {
                //         authCubit.signInWithGoogle();
                //       },
                //     ),
                //   ],
                // ),
                SizedBox(height: 18),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Inscrivez-vous maintenant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
