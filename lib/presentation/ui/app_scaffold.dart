import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.scaffoldKey,
    this.title,
    this.leading,
    this.actions,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    required this.body,
    this.bodyPadding,
  });

  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget body;
  final EdgeInsets? bodyPadding;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final content = bodyPadding == null
        ? body
        : Padding(padding: bodyPadding!, child: body);

    return Scaffold(
      key: scaffoldKey,
      drawer: drawer,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
            ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.header),
        child: SafeArea(
          top: true,
          bottom: true,
          child: content,
        ),
      ),
    );
  }
}

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    if (!scrollable) {
      return content;
    }
    return SingleChildScrollView(child: content);
  }
}
