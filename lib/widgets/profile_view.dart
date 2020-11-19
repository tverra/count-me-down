import 'package:count_me_down/database/db_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  final bool header;

  ProfileView({this.header = true});

  @override
  Widget build(BuildContext context) {
    final Preferences preferences = context.watch<Preferences>();

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        right: false,
        left: false,
        bottom: false,
        child: FutureBuilder(
          future: ProfileRepo.getProfile(preferences.activeProfileId),
          builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final Profile profile = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header
                    ? Text(
                        'Current profile:',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Utils.getThemeTextColor(context),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 10.0,
                ),
                _textStyle(context, profile.name),
                SizedBox(
                  height: 5.0,
                ),
                _textStyle(
                  context,
                  'Weight: ',
                  '${profile.bodyWeight.toString()}',
                ),
                _textStyle(
                  context,
                  'Body water content: ',
                  '${profile.bodyWaterPercentage.toString()}',
                ),
                _textStyle(
                  context,
                  'Alcohol absorption time: ',
                  '${Utils.formatDuration(profile.absorptionTime)}',
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

  Widget _textStyle(BuildContext context, String leading, [String text]) {
    return Row(
      children: [
        Text(
          leading ?? '',
          style: TextStyle(
            color: Utils.getThemeTextColor(context),
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 2.0),
        Text(
          text ?? '',
          style: TextStyle(
            color: Utils.getThemeTextColor(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
