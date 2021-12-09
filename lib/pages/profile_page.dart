import 'package:count_me_down/database/profile_repo.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:count_me_down/pages/start_page.dart';
import 'package:count_me_down/utils/mass.dart';
import 'package:count_me_down/utils/percentage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _genderValue = 65.0;
  Future<Profile> _activeProfileFuture;

  @override
  void initState() {
    _activeProfileFuture = _getActiveProfile();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit profile'),
      ),
      body: FutureBuilder<Profile>(
          future: _activeProfileFuture,
          builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
            final Profile profile = snapshot.data;

            return Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Profile name',
                        helperText: 'Profile name',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      validator: (String value) {
                        final String formatted = value.trim();

                        if (formatted == null || formatted == '') {
                          return 'Invalid value';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: 'Weight (in kilos)',
                        helperText: 'Weight (in kilos)',
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: (String value) {
                        final String formatted =
                            value.trim().replaceAll(',', '.');
                        final double parsed = double.tryParse(formatted);

                        if (parsed == null || parsed < 0) {
                          return 'Invalid value';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: double.infinity,
                      child: DropdownButton<double>(
                        value: _genderValue,
                        dropdownColor: Colors.white,
                        underline: Divider(
                          thickness: 1,
                          color: Colors.black38,
                        ),
                        itemHeight: 80.0,
                        items: <double>[70.0, 60.0, 65.0]
                            .map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text(Profile.getGender(value)),
                          );
                        }).toList(),
                        onChanged: (double newValue) {
                          setState(() {
                            _genderValue = newValue;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Gender',
                        style: TextStyle(color: Colors.black54, fontSize: 12.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () => _onSubmit(profile),
                        child: Text('Save'),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<void> _onSubmit(Profile profile) async {
    if (!_formKey.currentState.validate()) return;

    profile.name = _nameController.text;
    profile.bodyWeight =
        Mass((double.parse(_weightController.text) * 1000).round());
    profile.bodyWaterPercentage = Percentage(_genderValue / 100);

    await ProfileRepo.updateProfile(profile);

    Navigator.of(context)
        .pushNamedAndRemoveUntil(StartPage.routeName, (route) => false);
  }

  Future<Profile> _getActiveProfile() async {
    final Preferences preferences = context.read<Preferences>();
    final int activeProfileId = preferences.activeProfileId;
    Profile profile;

    if (activeProfileId == null) {
      profile = await ProfileRepo.getLatestProfile();
    } else {
      profile = await ProfileRepo.getProfile(activeProfileId);
    }

    _nameController.text = profile.name;
    _weightController.text = profile.bodyWeight.kilos.toString();
    _genderValue = profile.bodyWaterPercentage.percentage;

    return profile;
  }
}
