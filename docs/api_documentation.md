# Citadel Vault — PocketBase API Documentation

## Collections
| Collection | Description | Auth |
|-----------|-------------|------|
| users | User accounts | Email/Password |
| vault_items | Encrypted vault entries | User-only |
| shared_vaults | Shared vault metadata | Members-only |
| sync_metadata | Sync state tracking | User-only |

## Endpoints
- POST /api/collections/users/auth-with-password
- GET /api/collections/vault_items/records
- POST /api/collections/vault_items/records
- PATCH /api/collections/vault_items/records/:id
- DELETE /api/collections/vault_items/records/:id
