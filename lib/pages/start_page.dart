import 'package:count_me_down/pages/profile_page.dart';
import 'package:count_me_down/pages/sessions_page.dart';
import 'package:count_me_down/pages/settings_page.dart';
import 'package:count_me_down/widgets/menu_element.dart';
import 'package:count_me_down/widgets/profile_view.dart';
import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 200,
              elevation: 4.0,
              floating: true,
              forceElevated: true,
              flexibleSpace: ClipRect(
                child: OverflowBox(
                  child: ProfileView(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MenuElement(
                text: 'Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfilePage.routeName);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: MenuElement(
                text: 'Sessions',
                onPressed: () {
                  Navigator.of(context).pushNamed(SessionsPage.routeName);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: MenuElement(
                text: 'Settings',
                onPressed: () {
                  Navigator.of(context).pushNamed(SettingsPage.routeName);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
