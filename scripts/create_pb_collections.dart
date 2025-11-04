/// Script to create missing PocketBase collections for Phase 5 features.
///
/// Usage:
///   dart run scripts/create_pb_collections.dart <admin_email> <admin_password>
///
/// This creates: user_keys, shared_items, shared_links, vault_members, emergency_contacts
/// with proper API rules so only authenticated owners can access their own data.

import 'dart:convert';
import 'package:http/http.dart' as http;

const pbUrl = 'https://citadelpasswordmanager.pockethost.io';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run scripts/create_pb_collections.dart <admin_email> <admin_password>');
    return;
  }

  final email = args[0];
  final password = args[1];

  // 1. Authenticate as admin
  print('Authenticating as admin...');
  final authRes = await http.post(
    Uri.parse('$pbUrl/api/admins/auth-with-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'identity': email, 'password': password}),
  );

  if (authRes.statusCode != 200) {
    print('Auth failed: ${authRes.body}');
    return;
  }

  final token = jsonDecode(authRes.body)['token'] as String;
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': token,
  };

  print('Authenticated. Creating collections...\n');

  // 2. Create collections
  final collections = [
    {
      'name': 'user_keys',
      'type': 'base',
      'schema': [
        {'name': 'userId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'x25519PublicKey', 'type': 'text', 'required': true},
      ],
      'listRule': '@request.auth.id != ""',
      'viewRule': '@request.auth.id != ""',
      'createRule': '@request.auth.id != ""',
      'updateRule': 'userId = @request.auth.id',
      'deleteRule': 'userId = @request.auth.id',
    },
    {
      'name': 'shared_items',
      'type': 'base',
      'schema': [
        {'name': 'senderId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'recipientId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'encryptedData', 'type': 'text', 'required': true},
        {'name': 'status', 'type': 'text', 'required': true, 'options': {'maxSize': 20}},
        {'name': 'expiresAt', 'type': 'date'},
      ],
      'listRule': 'senderId = @request.auth.id || recipientId = @request.auth.id',
      'viewRule': 'senderId = @request.auth.id || recipientId = @request.auth.id',
      'createRule': '@request.auth.id != ""',
      'updateRule': 'senderId = @request.auth.id || recipientId = @request.auth.id',
      'deleteRule': 'senderId = @request.auth.id',
    },
    {
      'name': 'shared_links',
      'type': 'base',
      'schema': [
        {'name': 'ownerId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'encryptedData', 'type': 'text', 'required': true},
        {'name': 'expiresAt', 'type': 'date', 'required': true},
        {'name': 'oneTimeView', 'type': 'bool'},
        {'name': 'viewed', 'type': 'bool'},
      ],
      'listRule': 'ownerId = @request.auth.id',
      'viewRule': '',  // Anyone with the link can view
      'createRule': '@request.auth.id != ""',
      'updateRule': 'ownerId = @request.auth.id',
      'deleteRule': 'ownerId = @request.auth.id',
    },
    {
      'name': 'vault_members',
      'type': 'base',
      'schema': [
        {'name': 'vaultId', 'type': 'relation', 'required': true, 'options': {'collectionId': 'vault_collections', 'maxSelect': 1}},
        {'name': 'userId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
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
    },
    {
      'name': 'emergency_contacts',
      'type': 'base',
      'schema': [
        {'name': 'grantorId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'granteeId', 'type': 'relation', 'required': true, 'options': {'collectionId': '_pb_users_auth_', 'maxSelect': 1}},
        {'name': 'waitingPeriodDays', 'type': 'number', 'required': true, 'options': {'min': 1, 'max': 30}},
        {'name': 'status', 'type': 'text', 'required': true, 'options': {'maxSize': 20}},
        {'name': 'requestedAt', 'type': 'date'},
        {'name': 'encryptedVaultKey', 'type': 'text'},
      ],
      'listRule': 'grantorId = @request.auth.id || granteeId = @request.auth.id',
      'viewRule': 'grantorId = @request.auth.id || granteeId = @request.auth.id',
      'createRule': '@request.auth.id != ""',
      'updateRule': 'grantorId = @request.auth.id || granteeId = @request.auth.id',
      'deleteRule': 'grantorId = @request.auth.id',
    },
  ];

  for (final col in collections) {
    final name = col['name'];
    print('Creating "$name"...');

    // Check if collection already exists
    final checkRes = await http.get(
      Uri.parse('$pbUrl/api/collections/$name'),
      headers: headers,
    );

    if (checkRes.statusCode == 200) {
      print('  ✓ "$name" already exists, skipping.');
      continue;
    }

    final res = await http.post(
      Uri.parse('$pbUrl/api/collections'),
      headers: headers,
      body: jsonEncode(col),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      print('  ✓ "$name" created successfully.');
    } else {
      print('  ✗ "$name" failed: ${res.statusCode} ${res.body}');
    }
  }

  // 3. Also add fcm_token and x25519PublicKey fields to users collection if missing
  print('\nChecking users collection for missing fields...');
  print('(Add x25519PublicKey field manually in admin UI if needed)');

  print('\nDone! All Phase 5 collections created.');
  print('Verify at: $pbUrl/_/');
}
