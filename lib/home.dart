import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Machine {
  String? sn;
  String? pid;
  String? command;
  final isEditing = false.obs;
  final commandController = TextEditingController();

  Machine({this.sn, this.pid, this.command});
}

class HomeController extends GetxController {
  List<Machine> machines = [];
  late FirebaseApp firebaseApp;
  late FirebaseDatabase rtdb;

  Future<void> updateCommand(Machine machine, String command) async {
    machines = [];
    refresh();
    print('更新命令：${machine.sn} ${command}');
    DatabaseReference ref = rtdb.ref('forupdate/${machine.sn}');
    await ref.update({'command': command}).timeout(Duration(seconds: 5));
    await firebaseTest();
    refresh();
  }

  Future<void> firebaseTest() async {
    print('开始测试 Firebase');
    DatabaseReference ref = rtdb.ref('forupdate');

    // 获取 ref 的快照
    DataSnapshot snapshot = await ref.get();
    // 检查是否有数据
    if (snapshot.exists) {
      // 遍历并打印数据

      for (String item in (snapshot.value as Map).keys) {
        print((snapshot.value as Map)[item]['sn']);
        machines.add(Machine(
            sn: (snapshot.value as Map)[item]['sn'],
            pid: (snapshot.value as Map)[item]['pid'],
            command: (snapshot.value as Map)[item]['command']));
      }
      // 对machines列表进行排序，无command的在前面，有command的在后面
      machines.sort((a, b) {
        if (a.command == null || a.command!.isEmpty) {
          return -1;
        } else if (b.command == null || b.command!.isEmpty) {
          return 1;
        } else {
          return 0;
        }
      });
    } else {
      print('forupdate 中没有数据');
    }
    refresh();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    firebaseApp = Firebase.app();
    rtdb = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL:
            'https://rockspaceaio-default-rtdb.asia-southeast1.firebasedatabase.app');
    firebaseTest();
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rockspace aio'),
      ),
      body: GetBuilder<HomeController>(
          init: HomeController(),
          builder: (_) {
            return _.machines.isEmpty
                ? RefreshIndicator(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    onRefresh: () => _.firebaseTest())
                : Center(
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          defaultColumnWidth: IntrinsicColumnWidth(),
                          children: [
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('SN',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('PID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Command',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ..._.machines
                                .map((e) => TableRow(
                                      children: [
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SelectableText(e.sn ?? '',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SelectableText(e.pid ?? '',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Obx(() => e
                                                          .isEditing.value
                                                      ? TextField(
                                                          controller: e
                                                              .commandController,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                          textAlign:
                                                              TextAlign.center,
                                                          onSubmitted: (value) =>
                                                              _.updateCommand(
                                                                  e, value),
                                                          onEditingComplete:
                                                              () => e.isEditing
                                                                      .value =
                                                                  false,
                                                        )
                                                      : Text(e.command ?? '',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                          textAlign: TextAlign
                                                              .center)),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    e.isEditing.value =
                                                        !e.isEditing.value;
                                                    if (e.isEditing.value) {
                                                      e.commandController.text =
                                                          e.command ?? '';
                                                    } else {
                                                      _.updateCommand(
                                                          e,
                                                          e.commandController
                                                              .text);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  );
          }),
    );
  }
}
