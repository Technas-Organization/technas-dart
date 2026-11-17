# Technas pour Dart

Les paiements et les comptes de vos utilisateurs derrière **un seul client et un seul secret**.
[Read in English](README.md).

```dart
import 'package:technas/technas.dart';

final t = Technas();                             // lit TECHNAS_SECRET

final payment = await t.pay.payments.create(
  amount: 5000, reference: 'commande-42',
  customer: {'email': 'awa@exemple.com', 'name': 'Awa Mensah'},
  returnUrl: 'https://boutique.exemple/merci',
);
print(payment.checkoutUrl);

final user = await t.accounts.users.resolve(phone: '+22890123456', proof: Proof.verified);
final check = await t.accounts.tokens.verify(jetonDAcces);
```

## Choisir son paquet

Comme une boîte à outils livrée en plusieurs variantes, Technas se prend à la carte. Le même
code, plusieurs découpes :

| Vous voulez | Installer |
|---|---|
| Tout | `technas` (ce paquet) : `import 'package:technas/technas.dart'` |
| Les paiements seuls | [`technas_pay`](https://github.com/Technas-Organization/technas-pay-dart) |
| Les comptes seuls | [`technas_accounts`](https://github.com/Technas-Organization/technas-accounts-dart) |

Le paquet complet dépend des paquets minces, jamais l'inverse : un paquet mince ne tire rien d'un
autre produit. Dans `technas`, le client d'un produit n'est créé qu'au moment où vous y touchez.

## Installer

```yaml
# pubspec.yaml
dependencies:
  technas:
    git:
      url: https://github.com/Technas-Organization/technas-dart.git
      ref: v0.1.0
```

Dart 3.3 ou plus. **Côté serveur seulement** : jamais de secret dans une app Flutter (là, prenez [`technas_flutter_auth`](https://github.com/Technas-Organization/technas-flutter-auth) pour la connexion et `package:technas_pay/app.dart` pour les paiements, en passant par votre serveur).

Votre secret vient de la [console](https://console.technas.fr) (**Développeurs › Clés**) :
`tps_test_…` pour le bac à sable (aucun argent réel, utilisateurs du bac à sable), `tps_live_…`
pour la production. Posez-le dans `TECHNAS_SECRET`.

## Ce qu'il y a dedans

| | |
|---|---|
| `t.pay.payments` | `create`, `get`, `getByReference`, `cancel`, `refund`, `list` |
| `t.pay.refunds` / `t.pay.balance` | `get` / `get`, `topUp` |
| `t.pay.webhooks` | `verify`, `handle` (webhooks signés) |
| `t.pay.client` | Tout le client mince `technas_pay`, pour le reste (numéro de reversement, compte carte, règles de devise…) |
| `t.accounts.users` | `resolve`, `get`, `list`, `setRoles`, `disable`, `enable`, `revokeSessions` |
| `t.accounts.roles` / `t.accounts.tokens` | `list`, `declare` / `verify` |
| `t.accounts.config()` | Ce que votre app branche pour connecter ses utilisateurs |

Chaque produit garde sa documentation : [paiements](https://github.com/Technas-Organization/technas-pay-dart#readme),
[comptes](https://github.com/Technas-Organization/technas-accounts-dart/blob/main/README.fr.md). La référence complète de l'API est dans
la console (**Développeurs › Référence**).

## Tests

```yaml
dart pub get
dart test
```

Licence MIT.
