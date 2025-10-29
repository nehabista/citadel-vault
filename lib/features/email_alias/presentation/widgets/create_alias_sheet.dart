// File: lib/features/email_alias/presentation/widgets/create_alias_sheet.dart
// Bottom sheet for creating random or custom email aliases.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/alias_providers.dart';

class CreateAliasSheet extends ConsumerStatefulWidget {
  const CreateAliasSheet({super.key});

  @override
  ConsumerState<CreateAliasSheet> createState() => _CreateAliasSheetState();
}

class _CreateAliasSheetState extends ConsumerState<CreateAliasSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _noteController = TextEditingController();
  final _prefixController = TextEditingController();
  bool _loading = false;

  // Custom alias suffix options
  List<Map<String, dynamic>> _suffixes = [];
  Map<String, dynamic>? _selectedSuffix;
  bool _loadingSuffixes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _suffixes.isEmpty && !_loadingSuffixes) {
        _loadSuffixOptions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  Future<void> _loadSuffixOptions() async {
    setState(() => _loadingSuffixes = true);
    try {
      final options = await ref.read(aliasActionsProvider).getOptions();
      final suffixList = (options['suffixes'] as List?)
              ?.map((s) => s as Map<String, dynamic>)
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _suffixes = suffixList;
          _selectedSuffix = suffixList.isNotEmpty ? suffixList.first : null;
          _loadingSuffixes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSuffixes = false);
        showCitadelSnackBar(context, 'Failed to load options: $e',
            type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create Alias',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4D4DCD),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4D4DCD),
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Random'),
              Tab(text: 'Custom'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRandomTab(),
                _buildCustomTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRandomTab() {
    return Column(
      children: [
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: 'Note (optional)',
            labelStyle: const TextStyle(fontFamily: 'Poppins'),
            hintText: 'e.g., Used for newsletter signup',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4D4DCD), width: 2),
            ),
          ),
        ),
        const Spacer(),
        _buildCreateButton(onPressed: _createRandom),
      ],
    );
  }

  Widget _buildCustomTab() {
    if (_loadingSuffixes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TextField(
          controller: _prefixController,
          decoration: InputDecoration(
            labelText: 'Alias prefix',
            labelStyle: const TextStyle(fontFamily: 'Poppins'),
            hintText: 'my-alias',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4D4DCD), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_suffixes.isNotEmpty)
          DropdownButtonFormField<Map<String, dynamic>>(
            initialValue: _selectedSuffix,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Suffix',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
            ),
            items: _suffixes
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s['suffix'] as String? ?? '',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedSuffix = v),
          ),
        const Spacer(),
        _buildCreateButton(onPressed: _createCustom),
      ],
    );
  }

  Widget _buildCreateButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4D4DCD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Create',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _createRandom() async {
    setState(() => _loading = true);
    try {
      final note =
          _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
      final alias =
          await ref.read(aliasActionsProvider).createRandom(note: note);
      if (mounted) {
        Navigator.pop(context);
        showCitadelSnackBar(context, 'Alias created: ${alias.email}',
            type: SnackBarType.success);
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, 'Creation failed: $e',
            type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCustom() async {
    final prefix = _prefixController.text.trim();
    if (prefix.isEmpty) {
      showCitadelSnackBar(context, 'Enter an alias prefix',
          type: SnackBarType.error);
      return;
    }
    if (_selectedSuffix == null) {
      showCitadelSnackBar(context, 'No suffix available',
          type: SnackBarType.error);
      return;
    }
    setState(() => _loading = true);
    try {
      final signedSuffix = _selectedSuffix!['signed_suffix'] as String;
      final note =
          _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
      final alias = await ref.read(aliasActionsProvider).createCustom(
            prefix: prefix,
            signedSuffix: signedSuffix,
            note: note,
          );
      if (mounted) {
        Navigator.pop(context);
        showCitadelSnackBar(context, 'Alias created: ${alias.email}',
            type: SnackBarType.success);
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, 'Creation failed: $e',
            type: SnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
