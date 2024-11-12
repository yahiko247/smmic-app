import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/subcomponents/devices/battery_level.dart';
import 'package:smmic/subcomponents/devices/device_name.dart';
import 'package:smmic/subcomponents/devices/digital_display.dart';
import 'package:smmic/subcomponents/devices/gauge.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/providers/devices_provider.dart';
import '../../../subcomponents/devices/device_dialog.dart';
import 'package:smmic/utils/logs.dart';

class SensorNodeCard extends StatefulWidget {
  const SensorNodeCard({super.key, required this.deviceInfo, required this.deviceSnapshot});

  final SensorNode deviceInfo;
  final SensorNodeSnapshot? deviceSnapshot;

  @override
  State<SensorNodeCard> createState() => _SensorNodeCardState();
}

class _SensorNodeCardState extends State<SensorNodeCard> {

  final ApiRequest _apiRequest = ApiRequest();
  final ApiRoutes _apiRoutes = ApiRoutes();
  final Logs _logs = Logs(tag: 'Sensor Node Card()');

  final StreamController<SensorNodeSnapshot> _snapshotStreamController = StreamController<SensorNodeSnapshot>.broadcast();
  final StreamController<SMAlerts> _alertsStreamController = StreamController<SMAlerts>.broadcast();

  StreamController<SMAlerts> get smStreamController => _alertsStreamController;
  StreamController<SensorNodeSnapshot> get streamController => _snapshotStreamController;

  SensorNodeSnapshot? cardReadings;
  SensorNodeSnapshot? sqlCardReadings;
  SMAlerts? alertsStreamData;

  Color? tempColor;
  Color? moistureColor;
  Color? humidityColor;

  int? tempAlert;
  int? humidityAlert;
  int? moistureAlert;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    _snapshotStreamController.close();
    _alertsStreamController.close();
    super.dispose();
  }
  Color _getColor(int? alertCode, Map<int,Color> colorMap){
    return colorMap[alertCode] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final SensorNodeSnapshot deviceSnapshot = widget.deviceSnapshot ?? SensorNodeSnapshot.placeHolder(deviceId: widget.deviceInfo.deviceID);

    final DeviceDialog _skDeviceDialog = DeviceDialog(
        context: context,
        deviceID: widget.deviceInfo.deviceID,
        latitude: widget.deviceInfo.latitude,
        longitude: widget.deviceInfo.longitude
    );

    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SensorNodePage(
            deviceID: widget.deviceInfo.deviceID,
            latitude: widget.deviceInfo.latitude,
            longitude: widget.deviceInfo.longitude,
            deviceName: widget.deviceInfo.deviceName,
            deviceInfo: widget.deviceInfo,
            streamController: streamController,);
      })),
      child: Stack(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
              decoration: BoxDecoration(
                  color: context.watch<UiProvider>().isDark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: context.watch<UiProvider>().isDark ? Colors.white.withOpacity(0.09) : Colors.black.withOpacity(0.09),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4))
                  ]),
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: DeviceName(deviceName: widget.deviceInfo.deviceName)),
                        Expanded(
                            flex: 1,
                            //TODO: add snapshot data here
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.device_thermostat_outlined,color: tempColor,),
                                Icon(Icons.water_drop_outlined, color: moistureColor),
                                Icon(Icons.water, color: humidityColor,)
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                DigitalDisplay(
                                  value: deviceSnapshot.temperature,
                                  valueType: 'temperature',
                                ),
                                DigitalDisplay(
                                  value: deviceSnapshot.humidity,
                                  valueType: 'humidity',
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                                alignment: Alignment.center,
                                child: RadialGauge(
                                    valueType: 'soilMoisture',
                                    value:  deviceSnapshot.soilMoisture,
                                    limit: 100)),
                          )
                        ],
                      )),
                ],
              )
          ),
          Container(
            padding: const EdgeInsets.only(right: 37, top: 12),
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RotatedBox(
                  quarterTurns: 2,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.pencil_circle,
                      size: 20,
                    ),
                    color: context.watch<UiProvider>().isDark
                        ? Colors.white.withOpacity(0.30)
                        : Colors.black.withOpacity(0.30),
                    onPressed: () {
                      _skDeviceDialog.renameSNDialog();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                RotatedBox(
                  quarterTurns: 2,
                  child: Icon(
                    CupertinoIcons.arrow_down_left_circle,
                    size: 20,
                    color: context.watch<UiProvider>().isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
