// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:serial/serial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SerialPort? _port;
  String line = "";

  final _controller1 = TextEditingController();

  Future<void> _openPort() async {
    await _port?.close();

    final port = await window.navigator.serial.requestPort();
    await port.open(baudRate: 921600);

    _port = port;

    _startReceiving(port);

    setState(() {});
  }

  Future<void> _writeToPort(Uint8List data) async {
    if (data.isEmpty) {
      return;
    }

    final port = _port;

    if (port == null) {
      return;
    }

    final writer = port.writable.writer;

    await writer.ready;
    await writer.write(data);

    await writer.ready;
    await writer.close();
  }

  Future<void> _startReceiving(SerialPort port) async {
    final reader = port.readable.reader;
    StringBuffer buffer = StringBuffer();

    while (true) {
      ReadableStreamDefaultReadResult result = await reader.read();
      if (result.done) break;

      String data = String.fromCharCodes(result.value);
      buffer.write(data);

      while (buffer.toString().contains('\n')) {
        String line = buffer.toString().split('\n').first;
        buffer = StringBuffer(buffer.toString().substring(line.length + 1));
        // print(line);

        setState(() {
          this.line = line;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    //final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Port'),
        actions: [
          IconButton(
            onPressed: _openPort,
            icon: const Icon(Icons.link),
            tooltip: 'Open Serial Port',
          ),
          IconButton(
            onPressed: _port == null
                ? null
                : () async {
                    await _port?.close();
                    _port = null;

                    setState(() {});
                  },
            icon: const Icon(Icons.close),
            tooltip: 'Close Serial Port',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(12),
          // 受信データ表示
          Text(line),
          // グラフ表示
          Row(
            children: [
              SizedBox(
                width: size.width / 2,
                height: size.height / 2,
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(10, (i) {
                      return BarChartGroupData(
                        x: i + 1,
                        barRods: [
                          BarChartRodData(
                            toY: i.toDouble() - 5,
                            color: Colors.blue,
                          ),
                        ],
                      );
                    }),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1, // 1単位で水平線を表示
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 0.5,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // 1単位で表示
                          getTitlesWidget: (value, meta) {
                            return Text(value.toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text("${value}ch");
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(),
                      leftTitles: const AxisTitles(),
                    ),
                  ),
                ),
              ),
              Gap(((size.width / 2) - (size.height / 2)) / 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // stats icon here!!
                        Icon(
                          Icons.sports_esports_outlined,
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size.height / 2 - 36,
                    height: size.height / 2 - 36,
                    decoration: BoxDecoration(
                      // color: Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.grey,
                        width: 8,
                      ),
                    ),
                    // 四角に円を描画
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            const Gap(12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Gap(12),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                const Gap(12),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Gap(12),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                const Gap(12),
                              ],
                            ),
                            const Gap(12),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 75,
                              height: size.height / 2,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: 40,
                              height: size.height / 2 - 80,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.do_not_touch,
                                size: 36,
                              ),
                            ),
                            const Gap(24),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: 40,
                              height: size.height / 2 - 80,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.do_not_touch,
                                size: 36,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: 40,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.back_hand,
                                size: 36,
                              ),
                            ),
                            const Gap(75),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.south,
                            size: 80,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Gap(((size.width / 2) - (size.height / 2)) / 2),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextFormField(
                    controller: _controller1,
                  ),
                ),
                const Gap(8),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    child: const Text('Send'),
                    onPressed: () {
                      _writeToPort(
                          Uint8List.fromList(_controller1.text.codeUnits));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
