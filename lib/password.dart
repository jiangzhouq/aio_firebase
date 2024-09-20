import 'package:aio_firebase/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class PasswordController extends GetxController {
  void checkPassword(String pin) {
    if (pin == '816251') {
      Get.to(() => HomePage());
    } else {
      Get.dialog(AlertDialog(
        title: Text('错误'),
        content: Text('密码错误'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('确定'),
          ),
        ],
      ));
    }
  }
  // 在这里添加控制器逻辑
}

class PasswordView extends GetView<PasswordController> {
  const PasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('roskspace aio'),
      ),
      body: Center(
        child: Pinput(
          length: 6,
          onCompleted: (pin) {
            controller.checkPassword(pin);
          },
        ),
      ),
    );
  }
}
