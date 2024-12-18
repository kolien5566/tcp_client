import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'protocol.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Socket? socket;
  bool isConnected = false;
  bool isSendingData = false;
  Timer? secondDataTimer;

  final ScrollController _scrollController = ScrollController();
// 添加一个字符串存储日志
  final List<String> _logs = [];

// 添加一个方法来添加日志
  void addLog(String log) {
    setState(() {
      _logs.add("[${DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now())}] $log");
    });
  }

  Future<void> connect() async {
    try {
      socket = await Socket.connect('ems-monitor.kayz.tech', 7777);
      addLog('Connected to server');
      addLog('Remote: ${socket!.remoteAddress.address}:${socket!.remotePort}');
      addLog('Local: ${socket!.address.address}:${socket!.port}');

      setState(() {
        isConnected = true;
      });

      socket!.listen(
        (List<int> data) {
          addLog('Received: ${data.toString()}');
        },
        onError: (error) {
          addLog('Error: $error');
          disconnect();
        },
        onDone: () {
          addLog('Server disconnected');
          disconnect();
        },
      );
    } catch (e) {
      addLog('Failed to connect: $e');
    }
  }

  void disconnect() {
    stopSendingData();
    socket?.destroy();
    socket = null;
    setState(() {
      isConnected = false;
    });
  }

  void sendData(String data) {
    if (socket != null && isConnected) {
      socket!.write(data);
    }
  }

  void stopSendingData() {
    secondDataTimer?.cancel();
    secondDataTimer = null;
    setState(() {
      isSendingData = false;
    });
  }

  void sendLoginAndSecondData() {
    // 登录数据
    final loginHeader = [0x01, 0x01, 0x02];
    final loginData = {
      'UserName': 'aws_singapore_nlb',
      'CompanyName': 'l_CompanyName_temp',
      'password': '123456',
    };

    final loginMessage = Protocol.constructMessage(loginHeader, loginData);
    socket?.add(loginMessage);

    // 设置定时器发送秒级数据
    secondDataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final secondHeader = [0x01, 0x01, 0x10];
      final secondData = {
        'Time': DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()),
        'SN': 'aws_singapore_nlb',
        'Ppv1': '0',
        'Ppv2': '0',
        'Ppv3': '0',
        'Ppv4': '0',
        'PrealL1': '0',
        'PrealL2': '0',
        'PrealL3': '0',
        'PmeterL1': '0',
        'PmeterL2': '0',
        'PmeterL3': '0',
        'PmeterDC': '0',
        'PmeterDCL1': '0',
        'PmeterDCL2': '0',
        'PmeterDCL3': '0',
        'Pbat': '0',
        'SOC': '0.0',
        'GCPower': '0',
        'UPSModel': '0',
        'SYSMode': '0',
        'Sva': '0',
        'VarAC': '0',
        'VarDC': '0'
      };
      final secondMessage = Protocol.constructMessage(secondHeader, secondData);
      socket?.add(secondMessage);
    });

    setState(() {
      isSendingData = true;
    });
  }

  void sendExplicitText() {
    final List<int> data = [
      0x22,
      0x35,
      0x2e,
      0x30,
      0x30,
      0x30,
      0x22,
      0x2c,
      0x22,
      0x50,
      0x6f,
      0x69,
      0x6e,
      0x76,
      0x22,
      0x3a,
      0x22,
      0x35,
      0x2e,
      0x30,
      0x30,
      0x30,
      0x22,
      0x2c,
      0x22,
      0x43,
      0x6f,
      0x62,
      0x61,
      0x74,
      0x22,
      0x3a,
      0x22,
      0x30,
      0x2e,
      0x30,
      0x30,
      0x30,
      0x22,
      0x2c,
      0x22,
      0x55,
      0x73,
      0x63,
      0x61,
      0x70,
      0x61,
      0x63,
      0x69,
      0x74,
      0x79,
      0x22,
      0x3a,
      0x22,
      0x30,
      0x22,
      0x2c,
      0x22,
      0x45,
      0x4d,
      0x53,
      0x50,
      0x6c,
      0x61,
      0x74,
      0x66,
      0x6f,
      0x72,
      0x6d,
      0x22,
      0x3a,
      0x22,
      0x45,
      0x4d,
      0x53,
      0x33,
      0x2e,
      0x36,
      0x22,
      0x2c,
      0x22,
      0x4d,
      0x69,
      0x6e,
      0x76,
      0x22,
      0x3a,
      0x22,
      0x42,
      0x57,
      0x2d,
      0x49,
      0x4e,
      0x56,
      0x2d,
      0x53,
      0x50,
      0x42,
      0x35,
      0x4b,
      0x22,
      0x2c,
      0x22,
      0x49,
      0x4e,
      0x56,
      0x74,
      0x79,
      0x70,
      0x65,
      0x22,
      0x3a,
      0x22,
      0x42,
      0x59,
      0x54,
      0x45,
      0x5f,
      0x57,
      0x41,
      0x54,
      0x54,
      0x5f,
      0x42,
      0x35,
      0x22,
      0x2c,
      0x22,
      0x4d,
      0x62,
      0x61,
      0x74,
      0x22,
      0x3a,
      0x22,
      0x22,
      0x2c,
      0x22,
      0x4d,
      0x6d,
      0x65,
      0x74,
      0x65,
      0x72,
      0x22,
      0x3a,
      0x22,
      0x43,
      0x54,
      0x22,
      0x2c,
      0x22,
      0x50,
      0x56,
      0x4d,
      0x65,
      0x74,
      0x65,
      0x72,
      0x4d,
      0x6f,
      0x64,
      0x65,
      0x22,
      0x3a,
      0x22,
      0x30,
      0x22,
      0x2c,
      0x22,
      0x41,
      0x43,
      0x44,
      0x43,
      0x22,
      0x3a,
      0x22,
      0x32,
      0x22,
      0x2c,
      0x22,
      0x49,
      0x6e,
      0x73,
      0x74,
      0x61,
      0x6c,
      0x6c,
      0x4d,
      0x65,
      0x74,
      0x65,
      0x72,
      0x4f,
      0x70,
      0x74,
      0x69,
      0x6f,
      0x6e,
      0x22,
      0x3a
    ];
    socket?.add(data);
    socket?.add(data);
    socket?.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: isConnected ? null : connect,
                  child: const Text('连接'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isConnected ? disconnect : null,
                  child: const Text('断开'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isSendingData)
              ElevatedButton(
                onPressed: isConnected ? sendLoginAndSecondData : null,
                child: const Text('登录,持续发送秒级数据'),
              ),
            if (isSendingData)
              ElevatedButton(
                onPressed: isConnected ? stopSendingData : null,
                child: const Text('取消'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isConnected ? sendExplicitText : null,
              child: const Text('发送明文'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _logs.clear();
                });
              },
              child: const Text('清空日志'),
            ),
            // 添加日志显示区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return SelectableText(
                      _logs[index],
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    socket?.destroy();
    super.dispose();
  }
}
