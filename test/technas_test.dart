// One secret, two products, each speaking to its own routes.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:technas/technas.dart';
import 'package:test/test.dart';

const secret = 'tps_test_pk_demo12345678.whsec_demo';
const uid = '7d3f2a10-1111-4222-8333-444455556666';

void main() {
  test('pay and accounts share the secret and speak to their own routes', () async {
    final seen = <http.Request>[];
    final client = MockClient((request) async {
      seen.add(request);
      const headers = {'content-type': 'application/json; charset=utf-8'};
      if (request.url.path == '/v1/payments') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
            jsonEncode({
              'id': '9c1f0a10-2222-4333-8444-555566667777',
              'status': 'pending',
              'reference': body['reference'],
              'amount': body['amount'],
              'currency': 'XOF',
              'mode': 'test',
              'checkout_url': 'https://pay-api.technas.fr/test-checkout/x',
            }),
            200,
            headers: headers);
      }
      if (request.url.path == '/v1/accounts/users/resolve') {
        return http.Response(
            jsonEncode(
                {'id': uid, 'created': true, 'phone': '+22890000002', 'phone_verified': true, 'email': null, 'email_verified': false}),
            200,
            headers: headers);
      }
      return http.Response(jsonEncode({'code': 'not_found', 'message': 'Not found'}), 404, headers: headers);
    });
    final t = Technas(secret: secret, httpClient: client);
    final payment = await t.pay.payments.create(
        amount: 5000,
        reference: 'order-42',
        currency: 'XOF',
        customer: {'email': 'awa@example.com', 'name': 'Awa Mensah'},
        returnUrl: 'https://shop.example/thanks');
    final user = await t.accounts.users.resolve(phone: '+22890000002', proof: Proof.verified);
    expect(payment.reference, 'order-42');
    expect(user.id, uid);
    expect([for (final r in seen) r.url.path], ['/v1/payments', '/v1/accounts/users/resolve']);
    expect({for (final r in seen) r.headers['Authorization']}, {'Bearer pk_demo12345678'});
    expect(t.pay.testMode && t.accounts.testMode, isTrue);
    expect(identical(t.pay, t.pay), isTrue);
  });
}
