import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_echarts/flutter_echarts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final PageController pageController = PageController(viewportFraction: 0.9);

  List<Map<String, dynamic>> _data1 = [
    {'name': 'Please wait', 'value': 0}
  ];

  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.amber,
    Colors.grey,
    Colors.purple
  ];

  Random random = Random();

  int currentIndex = -1;
  late final webcontroller;

  getData1() async {
    await Future.delayed(Duration(seconds: 4));

    const dataObj = [
      {
        'name': 'Jan',
        'value': 8726.2453,
      },
      {
        'name': 'Feb',
        'value': 2445.2453,
      },
      {
        'name': 'Mar',
        'value': 6636.2400,
      },
      {
        'name': 'Apr',
        'value': 4774.2453,
      },
      {
        'name': 'May',
        'value': 1066.2453,
      },
      {
        'name': 'Jun',
        'value': 4576.9932,
      },
      {
        'name': 'Jul',
        'value': 8926.9823,
      }
    ];

    this.setState(() {
      this._data1 = dataObj;
    });
  }

  @override
  void initState() {
    super.initState();
    this.getData1();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Flutter Echarts'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          barChart(),
          SizedBox(height: 32),
          itemList(),
        ],
      ),
    );
  }

  Widget itemList() {
    return Container(
      height: 300,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });

          //change selected state to index
          webcontroller.evaluateJavascript('''
            chart.dispatchAction({
                    type: 'select',
                    seriesIndex: 0,
                    dataIndex: $value,
                  });
          ''');
        },
        itemCount: _data1.length,
        itemBuilder: (context, index) {
          return itemContainer(index);
        },
      ),
    );
  }

  Widget itemContainer(int index) {
    Map<String, dynamic> item = _data1[index];
    return Container(
      alignment: Alignment.center,
      color: colors[index],
      child: Text(
        item['value'].toString(),
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget barChart() {
    String option = '''
                  {
                    dataset: {
                      dimensions: ['name', 'value'],
                      source: ${jsonEncode(_data1)},
                    },
                    color: ['#3398DB'],
                    legend: {
                      data: ['直接访问', '背景'],
                      show: false,
                    },
                    grid: {
                      left: '0%',
                      right: '0%',
                      bottom: '5%',
                      top: '7%',
                      height: '85%',
                      containLabel: true,
                      z: 22,
                    },
                    xAxis: [{
                      type: 'category',
                      gridIndex: 0,
                      axisTick: {
                        show: false,
                      },
                      axisLine: {
                        lineStyle: {
                          color: '#0c3b71',
                        },
                      },
                      axisLabel: {
                        show: true,
                        color: 'rgb(170,170,170)',
                        formatter: function xFormatter(value, index) {
                          if (index === 6) {
                            return `\${value}\\n*`;
                          }
                          return value;
                        },
                      },
                    }],
                    yAxis: {
                      type: 'value',
                      gridIndex: 0,
                      splitLine: {
                        show: false,
                      },
                      axisTick: {
                          show: false,
                      },
                      axisLine: {
                        lineStyle: {
                          color: '#0c3b71',
                        },
                      },
                      axisLabel: {
                        color: 'rgb(170,170,170)',
                      },
                      splitNumber: 12,
                      splitArea: {
                        show: true,
                        areaStyle: {
                          color: ['rgba(250,250,250,0.0)', 'rgba(250,250,250,0.05)'],
                        },
                      },
                    },
                    series: [{
                      name: '合格率',
                      type: 'scatter',
                      symbolSize: 16,
                      xAxisIndex: 0,
                      yAxisIndex: 0,
                      select:{
                        itemStyle:{
                          color:'rgba(200, 82, 82, 1)'
                          }
                      },
                      selectedMode: true,
                      itemStyle: {
                        normal: {
                          barBorderRadius: 5,
                          color: {
                            type: 'linear',
                            x: 0,
                            y: 0,
                            x2: 0,
                            y2: 1,
                            colorStops: [
                              {
                                offset: 0, color: '#00feff',
                              },
                              {
                                offset: 1, color: '#027eff',
                              },
                              {
                                offset: 1, color: '#0286ff',
                              },
                            ],
                          },
                        },
                      },
                      zlevel: 11,
                    }],
                  }
                ''';

    return Container(
      child: Echarts(
        reloadAfterInit: true,
        captureAllGestures: true,
        option: option,
        extraScript: '''
                  chart.on('click', (params) => {
                    if(params.componentType === 'series') {
                      Messager.postMessage(JSON.stringify({
                        type: 'select',
                        payload: params.dataIndex,
                      }));
                    }
                  });
                ''',
        onMessage: (String message) {
          Map<String, dynamic> messageAction = jsonDecode(message);
          if (messageAction['type'] == 'select') {
            int index = messageAction['payload'];
            Map<String, dynamic> item = _data1[index];
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(item['name'].toString() + ': ' + '${item['value']}'),
              duration: Duration(seconds: 2),
            ));

            setState(() {
              currentIndex = index;
            });

            pageController.jumpToPage(
              currentIndex,
            );
          }
        },
        onLoad: (controller) {
          webcontroller = controller;
        },
      ),
      width: 300,
      height: 250,
    );
  }
}
