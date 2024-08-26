// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:serial/serial.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SerialPort? _port;
  String line = "";

  List<double> chData = List.generate(12, (i) => 0.0);
  List<Widget> elements = [];

  double angleRadians = 0.0;

  double imu = 0;

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
    String buffer = "";

    while (true) {
      ReadableStreamDefaultReadResult result = await reader.read();
      if (result.done) break;

      String data = String.fromCharCodes(result.value);
      // print(data.contains('\n'));
      if (!data.contains('\n')) {
        buffer += data;
      } else {
        buffer += data;
        print("before:$buffer");

        String line = buffer;
        line = line.replaceAll('\n', '|');
        print("after1:${line.split('|')}");
        line = line.split('|')[1];

        if (line.contains('|') || line.contains('\n')) {
          buffer = "";
          continue;
        }

        print("after2:$line");
        try {
          line.split(',').forEach((element) {
            elements.add(Text(element));
          });
        } catch (e) {
          print(e);
          print("continue");
          buffer = "";
          continue;
        }

        try {
          for (int i = 0; i < 12; i++) {
            chData[i] = double.parse(line.split(',')[i].split(':').last);
          }
          imu = chData[11];

          // // 角度をラジアンで求める
          // angleRadians = atan2(chData[4] * -1, chData[2]);
        } catch (e) {
          print(e);
          print("continue");
          buffer = "";
          continue;
        }
        print("chData:$chData");

        setState(() {
          this.line = line;
          chData;
          imu;
          // elements;
        });
        buffer = "";
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
          const Divider(),
          // グラフ表示
          Row(
            children: [
              const Gap(32),
              SizedBox(
                width: size.height / 1.75,
                height: size.height / 1.75,
                child: Row(
                  children: List.generate(10, (int index) {
                    return SizedBox(
                      width: size.height / 1.75 / 10,
                      height: size.height / 1.75,
                      child: Column(
                        children: [
                          const Gap(32),
                          SizedBox(
                            width: size.height / 3 / 10,
                            height: size.height / 1.75 - 81,
                            child: ValueLine(
                              value: chData[index],
                              // height: 20,
                            ),
                          ),
                          const Gap(32),
                          Text(
                            '${index + 1}ch',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
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
                        Align(
                          alignment: Alignment.center,
                          // angleRadians
                          child: Transform.rotate(
                            angle: math.pi + imu / 180 * math.pi,
                            child: const Icon(
                              Icons.south,
                              size: 80,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Gap(32),
                ],
              ),
              const Spacer(),
              Container(
                width: size.height / 3,
                height: size.height / 1.75,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: elements,
                  ),
                ),
              ),
              const Gap(32),
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

class ValueLine extends StatelessWidget {
  final double value;
  final Color? color;
  // final double height;

  const ValueLine({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height / 1.75 - 81;
    double localValue = value;
    if (value > 1) {
      localValue = 1;
    } else if (value < -1) {
      localValue = -1;
    }
    return Column(
      children: value > 0
          ? [
              Container(
                width: 5,
                height: height / 2 - (height / 2 * localValue),
              ),
              Container(
                width: 5,
                height: height / 2 * localValue,
                color: color ?? Colors.blue,
              ),
              Container(
                width: 5,
                height: height / 2,
              ),
            ]
          : [
              Container(
                width: 5,
                height: height / 2,
              ),
              Container(
                width: 5,
                height: height / 2 * localValue.abs(),
                color: color ?? Colors.blue,
              ),
              Container(
                width: 5,
                height: height / 2 - (height / 2 * localValue.abs()),
              ),
            ],
    );
  }
}
