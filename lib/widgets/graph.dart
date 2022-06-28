import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Tæll me ned'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<TimeSeriesSales> data = [TimeSeriesSales(DateTime.now(), 0)];
  double buffer = 0;
  double perMille = 0;

  @override
  void initState() {
    super.initState();
    _loop();
  }

  @override
  Widget build(BuildContext context) {
    final List<charts.Series<TimeSeriesSales, DateTime>> seriesList = [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Tablet',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            width: double.infinity,
            child: Text(
              '‰',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Container(
            height: 500.0,
            child: DateTimeComboLinePointChart(
              seriesList,
              animate: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            width: double.infinity,
            child: Text(
              't',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Increment',
          child: Icon(Icons.local_drink),
          onPressed: () {
            buffer += 0.6;
          }),
    );
  }

  Future<void> _loop() async {
    Future.delayed(Duration(seconds: 1), () {
      if (buffer > 0) {
        perMille += 0.2;
        buffer -= 0.2;
      } else if (perMille > 0.1) {
        perMille -= 0.1;
      } else {
        perMille = 0;
      }

      setState(() {
        data.add(TimeSeriesSales(DateTime.now(), perMille));
      });
    }).then((value) => _loop());
  }

  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 50; c > 0; c--) {
      data[DateTime.now().subtract(Duration(minutes: c))] =
          c.toDouble() * factor;
    }

    return data;
  }
}

class DateTimeComboLinePointChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DateTimeComboLinePointChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      defaultRenderer: charts.LineRendererConfig(),
      customSeriesRenderers: [
        charts.PointRendererConfig(customRendererId: 'customPoint')
      ],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false)),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          minute:
              charts.TimeFormatterSpec(format: 'mm', transitionFormat: 'HH:mm'),
        ),
      ),
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
