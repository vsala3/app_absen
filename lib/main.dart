import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewAbsen(),
    );
  }
}

class WebViewAbsen extends StatefulWidget {
  const WebViewAbsen({Key? key}) : super(key: key);

  @override
  State<WebViewAbsen> createState() => _WebViewAbsenState();
}

class _WebViewAbsenState extends State<WebViewAbsen> {
  InAppWebViewController? webViewController;
  final LocalAuthentication auth = LocalAuthentication();
  String deviceId = "Mencari ID...";

  @override
  void initState() {
    super.initState();
    _initPermissionsAndDevice();
  }

  // 1. Meminta Izin Perangkat (Kamera & GPS) dan mengambil Hardware ID
  Future<void> _initPermissionsAndDevice() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();

    var deviceInfo = DeviceInfoPlugin();
    String id = "";

    try {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id ?? "unknown_android";
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor ?? "unknown_ios";
      }
    } catch (e) {
      id = "error_get_id";
    }

    setState(() {
      deviceId = id;
    });
  }

  // 2. Fungsi memicu sensor Sidik Jari / Wajah Hardware HP
  Future<bool> _biometricCheck() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      // PERBAIKAN: Menghapus keyword 'const' agar kompatibel dengan local_auth versi baru
      return await auth.authenticate(
        localizedReason: 'Tempel sidik jari Anda untuk konfirmasi absen',
        options: const AuthenticationOptions(
          biometricOnly: true, // Wajib sidik jari/wajah hardware asli
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // 3. Fungsi mengambil Koordinat GPS HP yang Akurat
  Future<Map<String, double>> _getCurrentGPS() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
    } catch (e) {
      return {"latitude": 0.0, "longitude": 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri("https://hrmis.up.railway.app")),
          
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false, 
            ),
          ),
          
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },

          onWebViewCreated: (controller) {
            webViewController = controller;
            
            controller.addJavaScriptHandler(
              handlerName: 'getHardwareId',
              callback: (args) {
                return deviceId;
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'pemicuBiometrikHP',
              callback: (args) async {
                return await _biometricCheck();
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'getGPSPerangkat',
              callback: (args) async {
                return await _getCurrentGPS();
              },
            );
          },
        ),
      ),
    );
  }
}