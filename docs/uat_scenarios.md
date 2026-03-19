# User Acceptance Testing Scenarios

## UAT-01: Account Creation
1. Open app → Sign Up tab
2. Enter email, password, master password
3. Verify account created and vault accessible

## UAT-02: Vault Item CRUD
1. Tap "+ New" → select Password type
2. Fill name, username, password, URL
3. Save → verify appears in vault list
4. Edit → change password → save
5. Delete → confirm removal

## UAT-03: Autofill (Android)
1. Open Chrome → navigate to login page
2. Tap username field → verify Citadel suggestion appears
3. Select credential → verify fields populated

## UAT-04: Breach Detection
1. Navigate to Watchtower
2. Verify health score displayed
3. Check breached items flagged with red indicator

## UAT-05: Cross-Device Sync
1. Login on Device A → add item
2. Login on Device B → verify item synced
