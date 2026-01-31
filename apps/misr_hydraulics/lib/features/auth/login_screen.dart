import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import '../../session/session_provider.dart';
import '../home/home_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: null,
            centerTitle: false,
            flexibleSpace: SafeArea(
              bottom: false,
              child: SizedBox.expand(
                child: Image.asset(
                  'images/strip.jpg',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تسجيل الدخول',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: userCtrl,
                      decoration:
                          const InputDecoration(labelText: 'اسم المستخدم'),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      decoration:
                          const InputDecoration(labelText: 'كلمة المرور'),
                      obscureText: true,
                      textDirection: TextDirection.rtl,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() {
                                  loading = true;
                                  error = null;
                                });
                                final repo = UserRepo();
                                final u = await repo.login(
                                  userCtrl.text.trim(),
                                  passCtrl.text,
                                );
                                if (u == null) {
                                  setState(() {
                                    error = 'بيانات الدخول غير صحيحة';
                                    loading = false;
                                  });
                                  return;
                                }
                                ref.read(sessionProvider.notifier).state = u;
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const HomeShell()),
                                  );
                                }
                              },
                        child: loading ? const Text('...') : const Text('دخول'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
