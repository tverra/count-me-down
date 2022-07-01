import 'dart:typed_data';

import 'package:count_me_down/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class GraphPage extends StatefulWidget {
  static const String routeName = '/graph';

  const GraphPage();

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  Stream<List<dynamic>>? _getGraphStream;
  Uint8List? _imageData;

  @override
  void initState() {
    _getGraphStream = _getGraph();

    super.initState();
  }

  @override
  void dispose() {
    _getGraphStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_getGraphStream == null) return const CircularProgressIndicator();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: StreamBuilder<List<dynamic>>(
        initialData: const <dynamic>[],
        stream: _getGraphStream,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<dynamic>> snapshot,
        ) {
          final Uint8List? imageData = _imageData;

          if (imageData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _Graph(imageData: imageData);
        },
      ),
    );
  }

  Stream<List<dynamic>> _getGraph() async* {
    final Preferences preferences = context.read<Preferences>();
    final Map<String, String> headers = <String, String>{
      'Accept': 'image/png',
    };

    for (; mounted && preferences.drinkWebHook != null;) {
      final http.Response response = await http.get(
        Uri.parse(preferences.drinkWebHook ?? ''),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Uint8List data = response.bodyBytes;

        setState(() {
          _imageData = data;
        });

        yield data;
      }

      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }
}

class _Graph extends StatelessWidget {
  final Uint8List imageData;

  const _Graph({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image(image: MemoryImage(imageData)),
      ),
    );
  }
}
