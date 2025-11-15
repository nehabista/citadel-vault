/// Script to tighten PocketBase API rules for all sharing-related collections.
///
/// Usage:
///   dart run scripts/fix_security_rules.dart <admin_email> <admin_password>
///
/// CRITICAL SECURITY FIXES:
///   - vault_items: only owner can list/view/update/delete; any auth user can create
///   - vault_members: only vault owner can add/update members (was: any authenticated user)
///   - vault_collections: only owner or members can list/view; only owner can update/delete
///   - shared_items: only sender can update/delete; only sender/recipient can view
///   - shared_links: anyone with link ID can view (key is in URL fragment)
///   - emergency_contacts: only grantor can update
///   - user_keys: any authenticated user can look up public keys; only owner can modify

import 'dart:convert';
import 'package:http/http.dart' as http;

const pbUrl = 'https://citadelpasswordmanager.pockethost.io';

/// Security rules per collection. Keys match PocketBase collection names.
final Map<String, Map<String, String?>> securityRules = {
  'vault_collections': {
    'listRule':
        'owner = @request.auth.id || @request.auth.id ?= vault_members_via_vaultId.userId',
    'viewRule':
        'owner = @request.auth.id || @request.auth.id ?= vault_members_via_vaultId.userId',
    'createRule': '@request.auth.id != ""',
    'updateRule': 'owner = @request.auth.id',
    'deleteRule': 'owner = @request.auth.id',
  },
  'vault_members': {
    'listRule':
        'userId = @request.auth.id || vaultId.owner = @request.auth.id',
    'viewRule':
        'userId = @request.auth.id || vaultId.owner = @request.auth.id',
    'createRule': 'vaultId.owner = @request.auth.id',
    'updateRule': 'vaultId.owner = @request.auth.id',
    'deleteRule':
        'vaultId.owner = @request.auth.id || userId = @request.auth.id',
  },
  'shared_items': {
    'listRule':
        'senderId = @request.auth.id || recipientId = @request.auth.id',
    'viewRule':
        'senderId = @request.auth.id || recipientId = @request.auth.id',
    'createRule': '@request.auth.id != ""',
    'updateRule': 'senderId = @request.auth.id',
    'deleteRule': 'senderId = @request.auth.id',
  },
  'shared_links': {
    'listRule': 'ownerId = @request.auth.id',
    'viewRule': '', // Anyone with link ID can view (key is in URL fragment)
    'createRule': '@request.auth.id != ""',
    'updateRule': 'ownerId = @request.auth.id',
    'deleteRule': 'ownerId = @request.auth.id',
  },
  'emergency_contacts': {
    'listRule':
        'grantorId = @request.auth.id || granteeId = @request.auth.id',
    'viewRule':
        'grantorId = @request.auth.id || granteeId = @request.auth.id',
    'createRule': '@request.auth.id != ""',
    'updateRule': 'grantorId = @request.auth.id',
    'deleteRule': 'grantorId = @request.auth.id',
  },
  'vault_items': {
    'listRule': 'owner = @request.auth.id',
    'viewRule': 'owner = @request.auth.id',
    'createRule': '@request.auth.id != ""',
    'updateRule': 'owner = @request.auth.id',
    'deleteRule': 'owner = @request.auth.id',
  },
  'user_keys': {
    'listRule': '@request.auth.id != ""',
    'viewRule': '@request.auth.id != ""',
    'createRule': '@request.auth.id != ""',
    'updateRule': 'userId = @request.auth.id',
    'deleteRule': 'userId = @request.auth.id',
  },
};

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print(
      'Usage: dart run scripts/fix_security_rules.dart <admin_email> <admin_password>',
    );
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
    print('Auth failed (${authRes.statusCode}): ${authRes.body}');
    return;
  }

  final token = jsonDecode(authRes.body)['token'] as String;
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': token,
  };

  print('Authenticated successfully.\n');

  // 2. Patch each collection's API rules
  var successCount = 0;
  var failCount = 0;

  for (final entry in securityRules.entries) {
    final collectionName = entry.key;
    final rules = entry.value;

    print('Patching "$collectionName" API rules...');

    // First, get the collection to find its ID
    final getRes = await http.get(
      Uri.parse('$pbUrl/api/collections/$collectionName'),
      headers: headers,
    );

    if (getRes.statusCode != 200) {
      print(
        '  SKIP: "$collectionName" not found (${getRes.statusCode}). '
        'Create it first with create_pb_collections.dart.',
      );
      failCount++;
      continue;
    }

    final collectionId = jsonDecode(getRes.body)['id'] as String;

    // PATCH the collection with updated rules
    final patchRes = await http.patch(
      Uri.parse('$pbUrl/api/collections/$collectionId'),
      headers: headers,
      body: jsonEncode(rules),
    );

    if (patchRes.statusCode == 200) {
      print('  OK: "$collectionName" rules updated.');
      successCount++;
    } else {
      print(
        '  FAIL: "$collectionName" (${patchRes.statusCode}): ${patchRes.body}',
      );
      failCount++;
    }
  }

  print('\n--- Summary ---');
  print('Updated: $successCount');
  print('Failed:  $failCount');

  if (failCount == 0) {
    print('\nAll security rules applied successfully.');
  } else {
    print('\nSome rules failed. Check output above and fix manually if needed.');
  }

  print('\nVerify rules at: $pbUrl/_/');
}
