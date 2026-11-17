# Technas for Dart

Payments and user accounts behind **one client and one secret**. [Lire en français](README.fr.md).

```dart
import 'package:technas/technas.dart';

final t = Technas();                             // reads TECHNAS_SECRET

final payment = await t.pay.payments.create(
  amount: 5000, reference: 'order-42',
  customer: {'email': 'awa@example.com', 'name': 'Awa Mensah'},
  returnUrl: 'https://shop.example/thanks',
);
print(payment.checkoutUrl);

final user = await t.accounts.users.resolve(phone: '+22890123456', proof: Proof.verified);
final check = await t.accounts.tokens.verify(accessToken);
```

## Pick your package

Like a toolkit that ships in several builds, Technas comes in variants. Same code, different cuts:

| You want | Install |
|---|---|
| Everything | `technas` (this package): `import 'package:technas/technas.dart'` |
| Payments only | [`technas_pay`](https://github.com/Technas-Organization/technas-pay-dart) |
| User accounts only | [`technas_accounts`](https://github.com/Technas-Organization/technas-accounts-dart) |

The full package depends on the thin ones, never the reverse: a thin package pulls in nothing from
another product. Inside `technas`, a product client is created the first time you touch it.

## Install

```yaml
# pubspec.yaml
dependencies:
  technas:
    git:
      url: https://github.com/Technas-Organization/technas-dart.git
      ref: v0.1.0
```

Dart 3.3+. **Server side only**: never ship a secret in a Flutter app (there, use [`technas_flutter_auth`](https://github.com/Technas-Organization/technas-flutter-auth) for sign-in and `package:technas_pay/app.dart` for payments, through your backend).

Your secret comes from the [console](https://console.technas.fr) (**Developers › Keys**):
`tps_test_…` for the sandbox (no real money, sandbox users), `tps_live_…` for production. Put it
in `TECHNAS_SECRET`.

## What is inside

| | |
|---|---|
| `t.pay.payments` | `create`, `get`, `getByReference`, `cancel`, `refund`, `list` |
| `t.pay.refunds` / `t.pay.balance` | `get` / `get`, `topUp` |
| `t.pay.webhooks` | `verify`, `handle` (signed webhooks) |
| `t.pay.client` | The whole thin `technas_pay` client, for everything else (payout destination, card account, currency rules…) |
| `t.accounts.users` | `resolve`, `get`, `list`, `setRoles`, `disable`, `enable`, `revokeSessions` |
| `t.accounts.roles` / `t.accounts.tokens` | `list`, `declare` / `verify` |
| `t.accounts.config()` | What your app plugs in to sign users in |

Each product keeps its own documentation: [payments](https://github.com/Technas-Organization/technas-pay-dart#readme),
[accounts](https://github.com/Technas-Organization/technas-accounts-dart#readme). The full API reference lives in the console
(**Developers › Reference**).

## Tests

```yaml
dart pub get
dart test
```

MIT licence.
