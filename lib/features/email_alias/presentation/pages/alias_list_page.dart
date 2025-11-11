// File: lib/features/email_alias/presentation/pages/alias_list_page.dart
// Alias list page with tabs for SimpleLogin and DuckDuckGo providers.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/alias_providers.dart';
import '../widgets/create_alias_sheet.dart';
import '../widgets/duckduckgo_tab.dart';
import '../widgets/simplelogin_tab.dart';

class AliasListPage extends ConsumerStatefulWidget {
  const AliasListPage({super.key});

  @override
  ConsumerState<AliasListPage> createState() => _AliasListPageState();
}

class _AliasListPageState extends ConsumerState<AliasListPage>
    with SingleTickerProviderStateMixin {
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_showSearch) {
        setState(() {
          _showSearch = false;
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search aliases...',
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                'Email Aliases',
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4D4DCD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4D4DCD),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'SimpleLogin'),
            Tab(text: 'DuckDuckGo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SimpleLoginTab(searchQuery: _searchQuery),
          DuckDuckGoTab(searchQuery: _searchQuery),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          // Only show FAB for SimpleLogin tab when API key is configured
          if (_tabController.index == 0) {
            final apiKeyAsync = ref.watch(aliasApiKeyProvider);
            if (apiKeyAsync.value != null) {
              return FloatingActionButton(
                backgroundColor: const Color(0xFF4D4DCD),
                onPressed: () => _showCreateSheet(context),
                child: const Icon(Icons.add, color: Colors.white),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateAliasSheet(),
    );
  }
}
