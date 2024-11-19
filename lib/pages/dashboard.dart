import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smmic/components/devices/cards/sink_node_card.dart';
import 'package:smmic/components/drawer.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/subcomponents/weatherComponents/weatherWidgets.dart';
import 'package:smmic/pages/forcastpage.dart';
import 'package:smmic/providers/theme_provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _appBarBgAnimController;
  late Animation<double> _appBarBgAnimation ;
  late AnimationController _weatherOpacityAnimationController;
  late Animation<double> _weatherOpacityAnimation;

  // datetime functions, styles
  String _formatTime(DateTime dateTime) {
    final hours = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hours:$minutes $period";
  }

  Stream<String> _currentTimeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      return _formatTime(now);
    });
  }

  final TextStyle _headerItemsTextStyle = const TextStyle(
    color: Colors.white,
    fontSize: 23,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500
  );

  @override
  void initState() {
    _scrollController.addListener(_onScroll);

    _appBarBgAnimController = AnimationController(
        vsync: this,
        duration: const Duration(
            milliseconds: 500
        ),
    );

    _appBarBgAnimation = Tween<double>(begin: 0, end: 0.90).animate(
      CurvedAnimation(
          parent: _appBarBgAnimController,
          curve: Curves.easeOutExpo
      ),
    );

    _weatherOpacityAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300
      )
    );

    _weatherOpacityAnimation = Tween<double>(begin: 1, end: 0.0).animate(
      CurvedAnimation(
          parent: _weatherOpacityAnimationController,
          curve: Curves.easeOutExpo
      ),
    );

    super.initState();
  }

  void _onScroll() {
    double scrollOffset = _scrollController.offset;
    if (scrollOffset > 175) {
      setState(() {
        _appBarBgAnimController.duration = const Duration(milliseconds: 500);
        _appBarBgAnimController.forward();
        _weatherOpacityAnimationController.forward();
      });
    } else {
      setState(() {
        _appBarBgAnimController.duration = const Duration(milliseconds: 300);
        _appBarBgAnimController.reverse();
        _weatherOpacityAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _weatherOpacityAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(14, 14, 14, 1)
          : const Color.fromRGBO(230, 230, 230, 1),
      drawer: const ComponentDrawer(),
      body: Stack(
        children: [
          _drawCircle(),
          Stack(
            children: [
              AnimatedBuilder(
                  animation: _weatherOpacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _weatherOpacityAnimation.value,
                      child: _weatherWidget(),
                    );
                  }
              ),
              SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 315),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap),
                      const SizedBox(height: 15),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap),
                      const SizedBox(height: 15),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap),
                      const SizedBox(height: 15),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap),
                      const SizedBox(height: 15),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap),
                      const SizedBox(height: 15),
                      ..._buildSinkCards(context.watch<DevicesProvider>().sinkNodeMap)
                    ],
                  )
              )
            ],
          ),
          Positioned(
            top: 50,
            left: (MediaQuery.of(context).size.width / 2)
                - (MediaQuery.of(context).size.width * 0.90) / 2,
            child: Center(
              child: _appBar(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSinkCards(Map<String, SinkNode> sinkNodeMap) {
    return sinkNodeMap.keys.map((id) {
      return SinkNodeCard(
          deviceInfo: sinkNodeMap[id]!
      );
    }).toList();
  }

  Widget _weatherWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForcastPage())
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 20
              ),
              height: 150,
              child: const Center(
                child: WeatherComponentsWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    const double appBarHeight = 60;
    double appBarWidth = MediaQuery.of(context).size.width * 0.90;

    return Stack(
      children: [
        // TODO: i blur ang background
        AnimatedBuilder(
          animation: _appBarBgAnimation,
          builder: (context, child) {
            double width = MediaQuery.of(context).size.width * _appBarBgAnimation.value;
            return Transform.translate(
              // TODO: because offset queries screen width, it might break on other devices
              offset: Offset(((MediaQuery.of(context).size.width - width) / 2) - 20, 0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0,
                      sigmaY: 5.0
                  ),
                  child: Container(
                    width: width,
                    height: appBarHeight,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: const BorderRadius.all(Radius.circular(100)),
                    ),
                  ),
                ),
              )
            );
          },
        ),
        Container(
          height: appBarHeight,
          width: appBarWidth,
          decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(100))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 1),
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: SvgPicture.asset('assets/icons/menu.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcATop,
                      ),
                    ),
                  );
                },
              ),
              Text(
                'Hi ${context.watch<UserDataProvider>().user!.firstName.split(' ').first}!',
                style: _headerItemsTextStyle,
              ),
              const SizedBox(width: 10),
              StreamBuilder(
                  stream: _currentTimeStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: _headerItemsTextStyle,
                      );
                    } else {
                      return Text(
                        _formatTime(DateTime.now()),
                        style: _headerItemsTextStyle,
                      );
                    }
                  }
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () {
                    context.read<UiProvider>().changeTheme();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: context.watch<UiProvider>().isDark
                        ? SvgPicture.asset('assets/icons/clear_night.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(98, 245, 255, 1),
                          BlendMode.srcATop
                      ),
                    )
                        : SvgPicture.asset('assets/icons/clear_day2.svg',
                      width: 27,
                      height: 27,
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(255, 232, 62, 1),
                          BlendMode.srcATop
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _drawCircle() {
    double width = MediaQuery.of(context).size.width;
    double size = 1.55 * width;
    return Positioned(
      top: -200,
      left: width / 2 - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: context.watch<UiProvider>().isDark
                ? const Color.fromRGBO(45, 59, 89, 1)
                : const Color.fromRGBO(194, 161, 98, 1),
            shape: BoxShape.circle
        ),
      ),
    );
  }

}