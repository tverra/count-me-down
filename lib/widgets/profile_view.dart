import 'package:count_me_down/database/db_repos.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  final bool header;

  const ProfileView({this.header = true});

  @override
  Widget build(BuildContext context) {
    final Preferences preferences = context.watch<Preferences>();

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        right: false,
        left: false,
        bottom: false,
        child: FutureBuilder<Profile?>(
          future: getProfile(preferences.activeProfileId ?? 0),
          builder: (BuildContext context, AsyncSnapshot<Profile?> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final Profile? profile = snapshot.data;

            if (profile == null) return Container();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (header) Text(
                        'Current profile:',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: utils.getThemeTextColor(context),
                        ),
                      ) else Container(),
                const SizedBox(
                  height: 10.0,
                ),
                _textStyle(context, profile.name ?? ''),
                const SizedBox(
                  height: 5.0,
                ),
                _textStyle(
                  context,
                  'Weight: ',
                  profile.bodyWeight.toString(),
                ),
                _textStyle(
                  context,
                  'Body water content: ',
                  profile.bodyWaterPercentage.toString(),
                ),
                _textStyle(
                  context,
                  'Alcohol absorption time: ',
                  utils.formatDuration(profile.absorptionTime ?? Duration.zero),
                ),
                _textStyle(
                  context,
                  'Metabolized per hour: ',
                  '${profile.perMilMetabolizedPerHour}‰',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _textStyle(BuildContext context, String leading, [String? text]) {
    return Row(
      children: <Widget>[
        Text(
          leading,
          style: TextStyle(
            color: utils.getThemeTextColor(context),
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2.0),
        Text(
          text ?? '',
          style: TextStyle(
            color: utils.getThemeTextColor(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
