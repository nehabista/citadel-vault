/// Creates the vault_members collection that failed due to collection ID lookup.
/// Usage: dart run scripts/create_vault_members.dart <admin_email> <admin_password>

import 'dart:convert';
import 'package:http/http.dart' as http;

const pbUrl = 'https://citadelpasswordmanager.pockethost.io';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run scripts/create_vault_members.dart <admin_email> <admin_password>');
    return;
  }

  // Auth
  final authRes = await http.post(
    Uri.parse('$pbUrl/api/admins/auth-with-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'identity': args[0], 'password': args[1]}),
  );
  if (authRes.statusCode != 200) {
    print('Auth failed: ${authRes.body}');
    return;
  }
  final token = jsonDecode(authRes.body)['token'] as String;
  final headers = {'Content-Type': 'application/json', 'Authorization': token};

  // Look up vault_collections ID
  print('Looking up vault_collections ID...');
  final collectionsRes = await http.get(
    Uri.parse('$pbUrl/api/collections'),
    headers: headers,
  );
  final allCollections = jsonDecode(collectionsRes.body);
  final items = (allCollections is List) ? allCollections : (allCollections['items'] ?? allCollections);

  String? vaultCollectionsId;
  String? usersId;
  for (final col in items) {
    if (col['name'] == 'vault_collections') vaultCollectionsId = col['id'];
    if (col['name'] == 'users') usersId = col['id'];
  }

  print('  vault_collections ID: $vaultCollectionsId');
  print('  users ID: $usersId');

  if (vaultCollectionsId == null || usersId == null) {
    print('Could not find required collection IDs');
    return;
  }

  // Create vault_members
  print('Creating vault_members...');
  final res = await http.post(
    Uri.parse('$pbUrl/api/collections'),
    headers: headers,
    body: jsonEncode({
      'name': 'vault_members',
      'type': 'base',
      'schema': [
        {'name': 'vaultId', 'type': 'relation', 'required': true, 'options': {'collectionId': vaultCollectionsId, 'maxSelect': 1}},
        {'name': 'userId', 'type': 'relation', 'required': true, 'options': {'collectionId': usersId, 'maxSelect': 1}},
        {'name': 'role', 'type': 'text', 'required': true, 'options': {'maxSize': 10}},
        {'name': 'encryptedVaultKey', 'type': 'text'},
        {'name': 'invitedAt', 'type': 'date'},
        {'name': 'acceptedAt', 'type': 'date'},
      ],
      'listRule': 'userId = @request.auth.id',
      'viewRule': 'userId = @request.auth.id',
      'createRule': '@request.auth.id != ""',
      'updateRule': 'userId = @request.auth.id',
      'deleteRule': '@request.auth.id != ""',
    }),
  );

  if (res.statusCode == 200 || res.statusCode == 201) {
    print('  ✓ vault_members created successfully!');
  } else {
    print('  ✗ Failed: ${res.statusCode} ${res.body}');
  }
}
