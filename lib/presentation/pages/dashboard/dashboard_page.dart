import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:velocity_x/velocity_x.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF8FAFC,
        ), // Matches screenshot background
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF5), // Matches screenshot
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    10.widthBox,
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search vault',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _CustomTabBar().pSymmetric(h: 8, v: 8),
            Expanded(
              child: const TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  _TabContent(title: 'All items'),
                  _TabContent(title: 'Passwords'),
                  _TabContent(title: 'Secure notes'),
                  _TabContent(title: 'Contact info'),
                  _TabContent(title: 'Bank accounts'),
                  _TabContent(title: 'Payment cards'),
                  _TabContent(title: 'WIFI passwords'),
                  _TabContent(title: 'Software licenses'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabLabels = [
      {'icon': Icons.grid_view_rounded, 'text': 'All items'},
      {'icon': Icons.lock_outline, 'text': 'Passwords'},
      {'icon': Icons.sticky_note_2_outlined, 'text': 'Secure notes'},
      {'icon': Icons.contact_page_outlined, 'text': 'Contact info'},
      {'icon': Icons.account_balance_wallet_outlined, 'text': 'Bank accounts'},
      {'icon': Icons.credit_card_outlined, 'text': 'Payment cards'},
      {'icon': Icons.wifi_outlined, 'text': 'WIFI passwords'},
      {'icon': Icons.code_outlined, 'text': 'Software licenses'},
    ];

    return TabBar(
      isScrollable: true,
      dividerColor: Colors.transparent,
      tabAlignment: TabAlignment.start,
      splashFactory: NoSplash.splashFactory,
      labelPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 28, 145, 242)),
        borderRadius: BorderRadius.circular(12),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: Colors.transparent,
      labelColor: const Color.fromARGB(255, 4, 9, 64),
      unselectedLabelColor: Colors.grey.shade600,
      tabs:
          tabLabels.map((tab) {
            return Tab(
              height: 3.5.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab['icon'] as IconData, size: 18),
                  6.widthBox,
                  Text(
                    tab['text'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ).pSymmetric(h: 8),
            );
          }).toList(),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String title;
  const _TabContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        "$title (1)".text.black.sm.make(),
        10.heightBox,
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF430297), // Matching Yahoo purple
            child: "Y!".text.white.bold.make(),
          ),
          title: "$title Item".text.make(),
          subtitle: "josefyaduvanshi@gmail.com".text.gray500.sm.make(),
          trailing: const Icon(
            Icons.copy,
            color: Color(0xFF1C91F2),
          ), // blue like your theme
          onTap: () {},
        ),
      ],
    );
  }
}
