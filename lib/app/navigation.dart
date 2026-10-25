import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

class NavItem {
  const NavItem(this.label, this.route, this.icon);
  final String label;
  final String route;
  final IconData icon;
}

/// Top-level sections, in the order the design shows them.
const List<NavItem> kNavItems = [
  NavItem('Overview', AppRoutes.dashboard, Icons.space_dashboard_outlined),
  NavItem('User Management', AppRoutes.users, Icons.people_alt_outlined),
  NavItem('Content (CMS)', AppRoutes.content, Icons.article_outlined),
  NavItem('Others', AppRoutes.others, Icons.more_horiz),
];
