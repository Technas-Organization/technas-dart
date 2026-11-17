/// Technas: every Technas product behind one client and one secret.
///
/// ```dart
/// final t = Technas();                              // reads TECHNAS_SECRET
/// final payment = await t.pay.payments.create(amount: 5000, reference: 'order-42',
///     customer: {'email': 'awa@example.com'}, returnUrl: 'https://shop.example/thanks');
/// final user = await t.accounts.users.resolve(phone: '+22890123456', proof: Proof.verified);
/// ```
///
/// The FULL package: it depends on the thin ones (`technas_pay`, `technas_accounts`) and adds
/// only this entry point. Server side only: never ship a secret in a Flutter app.
library;

import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:technas_accounts/technas_accounts.dart';
import 'package:technas_pay/technas_pay.dart';

export 'package:technas_accounts/technas_accounts.dart' hide Json, defaultBaseUrl, sdkVersion;
export 'package:technas_pay/technas_pay.dart';

class Technas {
  /// [secret]: otherwise read from `TECHNAS_SECRET` (then `TECHNAS_PAY_SECRET`).
  /// [httpClient]: your own client (proxy, tests), shared by every product.
  Technas({String? secret, String? baseUrl, http.Client? httpClient})
      : _secret = secret,
        _baseUrl = baseUrl,
        _http = httpClient;

  final String? _secret;
  final String? _baseUrl;
  final http.Client? _http;

  String? get _resolved => _secret ?? Platform.environment['TECHNAS_SECRET'] ?? Platform.environment['TECHNAS_PAY_SECRET'];

  /// Payments: mobile money and card. Created the first time you touch it.
  late final Pay pay = Pay._(_baseUrl == null
      ? TechnasPay(secret: _resolved, httpClient: _http)
      : TechnasPay(secret: _resolved, httpClient: _http, baseUrl: _baseUrl));

  /// Your app's users. Created the first time you touch it.
  late final TechnasAccounts accounts = _baseUrl == null
      ? TechnasAccounts(secret: _resolved, httpClient: _http)
      : TechnasAccounts(secret: _resolved, httpClient: _http, baseUrl: _baseUrl);
}

/// `t.pay`: the thin `technas_pay` client, grouped by resource. Nothing is reimplemented:
/// `payments.create` IS `askForPayment`. Everything else stays reachable as [client].
class Pay {
  Pay._(this.client)
      : payments = Payments._(client),
        refunds = Refunds._(client),
        balance = BalanceCalls._(client),
        webhooks = Webhooks._(client);

  final TechnasPay client;
  final Payments payments;
  final Refunds refunds;
  final BalanceCalls balance;
  final Webhooks webhooks;

  bool get testMode => client.testMode;
}

class Payments {
  Payments._(this._c);
  final TechnasPay _c;

  /// Ask a customer for a payment. Send them to the returned `checkoutUrl`.
  late final create = _c.askForPayment;
  late final get = _c.getPayment;
  late final getByReference = _c.getPaymentByReference;
  late final cancel = _c.cancelPayment;
  late final refund = _c.refund;
  late final list = _c.listTransactions;
}

class Refunds {
  Refunds._(this._c);
  final TechnasPay _c;
  late final get = _c.getRefund;
}

class BalanceCalls {
  BalanceCalls._(this._c);
  final TechnasPay _c;
  late final get = _c.getBalance;
  late final topUp = _c.topUpBalance;
}

class Webhooks {
  Webhooks._(this._c);
  final TechnasPay _c;

  /// The event of a signed webhook, or an exception.
  late final verify = _c.verifyWebhook;
  late final handle = _c.handleWebhook;
}
