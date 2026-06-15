import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:get/get.dart';
import '../../../utils/tms_color.dart';
import '../../../widgets/tms_button.dart';
import '../../../widgets/tms_normaltext.dart';
import '../../pod_page/pod_screen.dart';
import '../docket_controller.dart';

class BluetoothScanWidget extends StatefulWidget {
  const BluetoothScanWidget({Key? key}) : super(key: key);

  @override
  State<BluetoothScanWidget> createState() => _BluetoothScanWidgetState();
}

class _BluetoothScanWidgetState extends State<BluetoothScanWidget> with SingleTickerProviderStateMixin {
  DocketController docketController = Get.find<DocketController>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _checkConnectedDevices();

    docketController.animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (docketController.connectedDeviceId.isEmpty) {
      docketController.onScanPressed();
    }



  }

  Future<void> initPlatformState() async {
    try {
      docketController.adapterState = await docketController.flutterBlueClassicPlugin.value.adapterStateNow;
      docketController.adapterStateSubscription = docketController.flutterBlueClassicPlugin.value.adapterState.listen((current) {
        if (mounted) setState(() => docketController.adapterState = current);
      });
      docketController.scanSubscription = docketController.flutterBlueClassicPlugin.value.scanResults.listen((device) {
        if (mounted) setState(() => docketController.scanResults.add(device));
      });
      docketController.scanningStateSubscription = docketController.flutterBlueClassicPlugin.value.isScanning.listen((isScanning) {
        if (mounted) setState(() => docketController.isScanning.value = isScanning);
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (!mounted) return;
  }

  Future<void> _checkConnectedDevices() async {
    try {
      List<BluetoothDevice>? devices = await docketController.flutterBlueClassicPlugin.value.bondedDevices;

      docketController.isDeviceConnected.value = false;
      if (devices != null) {
        for (BluetoothDevice device in devices) {
          if (device.address == docketController.connectedDeviceId) {
            docketController.isDeviceConnected.value = true;
            if (mounted) {
              docketController.bluetoothIconColor.value = Colors.green;
            }
            break;
          }
        }
      }
    } catch (e) {

    }
  }

  @override
  void dispose() {
    docketController.animationController.dispose();
    if(docketController.isScanningSubscription != null){}
    docketController.isScanningSubscription.cancel();
    super.dispose();
  }

  Widget buildScanButton() {
    return Obx(() {
      return IconButton(
        iconSize: 28,
        onPressed: docketController.connectedDeviceId.isEmpty ? (docketController.isScanning.value ? docketController.onStopPressed : docketController.onScanPressed) : null,
        icon: AnimatedBuilder(
          animation: docketController.animationController,
          builder: (_, child) {
            return Transform.rotate(
              angle: docketController.animationController.value * 2 * 3.1415926535,
              child: child,
            );
          },
          child: Icon(
            Icons.refresh,
            color: docketController.connectedDeviceId.isEmpty ? const Color(0xff232F34) : Colors.grey,
          ),
        ),
        tooltip: docketController.isScanning.value ? "Stop Scan" : "Start Scan",
      );
    });
  }

  List<Widget> _buildScanResultTiles() {
    return docketController.scanResults
        .where((r) => r.name != null)
        .map(
          (r) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TmsText(
                        text: r.name ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 4),
                      TmsText(
                        text: r.address,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColor.black45,
                      ),
                    ],
                  ),
                  trailing: TmsButton(
                    isLoading: docketController.connectingDevice.value?.address == r.address,
                    text: docketController.connectedDevice.value?.address == r.address ? 'Disconnect' : 'Connect',
                    onPressed: () {
                      if (docketController.connectedDevice.value?.address == r.address) {
                        docketController.onDisconnectPressed(r);
                        docketController.isDeviceConnected.value = false;
                        docketController.onScanPressed();
                      } else {
                        docketController.onConnectPressed(r);
                        docketController.isDeviceConnected.value = true;
                      }
                    },
                    enabled: docketController.connectedDevice.value == null || docketController.connectedDevice.value?.address == r.address,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Obx(() {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildScanButton(),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xff232F34),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    children: [
                      if (docketController.scanResults.isEmpty && docketController.connectedDeviceId.isEmpty) ...[
                        Center(
                          child: Text(
                            docketController.isScanning.value ? 'Scanning...' : 'No devices found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ] else if (docketController.scanResults.isNotEmpty) ...[
                        Expanded(
                          child: ListView(
                            children: _buildScanResultTiles(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (docketController.connectedDeviceId.isNotEmpty) {
      docketController.isScanning.value = false;
      docketController.bluetoothIconColor.value = Colors.green;
      docketController.isDeviceConnected.value = true;
    } else {
      docketController.onScanPressed();
      docketController.isDeviceConnected.value = false;
    }
  }
}
