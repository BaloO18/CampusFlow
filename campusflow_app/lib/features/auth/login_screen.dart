import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'amina@campus.bf');
  final _motDePasse = TextEditingController();
  bool _envoi = false;
  bool _masque = true;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      await CampusScope.of(context).connexion(_email.text, _motDePasse.text);
    } catch (e) {
      if (mounted) setState(() => _erreur = '$e');
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const blanc = Colors.white;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primary.darken(0.4)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.s6,
                    56,
                    AppTokens.s6,
                    48,
                  ),
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Logo CampusFlow',
                        image: true,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: blanc,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.event_available_rounded,
                            size: 48,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.s5),
                      Text(
                        'CampusFlow',
                        style: text.headlineMedium?.copyWith(color: blanc),
                      ),
                      const SizedBox(height: AppTokens.s1),
                      Text(
                        'Toutes vos échéances, une seule liste.',
                        textAlign: TextAlign.center,
                        style: text.bodyLarge?.copyWith(
                          color: blanc.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.s6),
                  child: Form(
                    key: _form,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Connexion', style: text.headlineSmall),
                          const SizedBox(height: AppTokens.s1),
                          Text(
                            'Content de vous revoir !',
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppTokens.s6),
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v ?? '').contains('@')
                                ? null
                                : 'Saisissez un email valide',
                          ),
                          const SizedBox(height: AppTokens.s4),
                          TextFormField(
                            controller: _motDePasse,
                            obscureText: _masque,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _masque
                                    ? 'Afficher le mot de passe'
                                    : 'Masquer le mot de passe',
                                icon: Icon(
                                  _masque
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () =>
                                    setState(() => _masque = !_masque),
                              ),
                            ),
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _seConnecter(),
                            validator: (v) => (v ?? '').length >= 4
                                ? null
                                : 'Au moins 4 caractères',
                          ),
                          if (_erreur case final message?) ...[
                            const SizedBox(height: AppTokens.s4),
                            Text(
                              message,
                              style: TextStyle(color: scheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppTokens.s6),
                          FilledButton(
                            onPressed: _envoi ? null : _seConnecter,
                            child: _envoi
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      semanticsLabel: 'Connexion en cours',
                                    ),
                                  )
                                : const Text('Se connecter'),
                          ),
                          const SizedBox(height: AppTokens.s4),
                          Text(
                            'Démo : n’importe quel mot de passe de 4 caractères ou plus.',
                            textAlign: TextAlign.center,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
