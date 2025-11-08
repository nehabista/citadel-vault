/// Adds the missing ownerPublicKey field to the vault_members collection.
/// Usage: dart run scripts/fix_vault_members_schema.dart <admin_email> <admin_password>

import 'dart:convert';
import 'package:http/http.dart' as http;

const pbUrl = 'https://citadelpasswordmanager.pockethost.io';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print(
      'Usage: dart run scripts/fix_vault_members_schema.dart '
      '<admin_email> <admin_password>',
    );
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
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': token,
  };

  // Look up vault_members collection
  print('Looking up vault_members collection...');
  final collectionsRes = await http.get(
    Uri.parse('$pbUrl/api/collections'),
    headers: headers,
  );
  final allCollections = jsonDecode(collectionsRes.body);
  final items = (allCollections is List)
      ? allCollections
      : (allCollections['items'] ?? allCollections);

  Map<String, dynamic>? vaultMembersCol;
  for (final col in items) {
    if (col['name'] == 'vault_members') {
      vaultMembersCol = col as Map<String, dynamic>;
      break;
    }
  }

  if (vaultMembersCol == null) {
    print('vault_members collection not found. Run create_vault_members.dart first.');
    return;
  }

  final collectionId = vaultMembersCol['id'] as String;
  final existingSchema =
      List<Map<String, dynamic>>.from(vaultMembersCol['schema'] as List);

  print('  vault_members ID: $collectionId');
  print('  Existing fields: ${existingSchema.map((f) => f['name']).toList()}');

  // Check if ownerPublicKey already exists
  final alreadyExists =
      existingSchema.any((f) => f['name'] == 'ownerPublicKey');
  if (alreadyExists) {
    print('  ownerPublicKey field already exists. Nothing to do.');
    return;
  }

  // Add ownerPublicKey field to existing schema
  existingSchema.add({
    'name': 'ownerPublicKey',
    'type': 'text',
    'required': false,
    'options': {},
  });

  print('Patching vault_members schema to add ownerPublicKey...');
  final patchRes = await http.patch(
    Uri.parse('$pbUrl/api/collections/$collectionId'),
    headers: headers,
    body: jsonEncode({'schema': existingSchema}),
  );

  if (patchRes.statusCode == 200) {
    print('  Done! ownerPublicKey field added to vault_members.');
  } else {
    print('  Failed: ${patchRes.statusCode} ${patchRes.body}');
  }
}
