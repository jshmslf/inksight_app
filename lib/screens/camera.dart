import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:inksight/constants/colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  QRViewController? qrController;
  bool isFlashOn = false;
  String selectedButton = 'Handwritten Analyzer';
  String? qrCodeLink;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final aspectRatio = cameraController?.value.aspectRatio ?? 1;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'Futura',
                      fontSize: 40,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 3,
                          color: Color.fromARGB(68, 0, 0, 0),
                        ),
                      ],
                    ),
                    children: [
                      TextSpan(
                        text: 'Ink',
                        style: TextStyle(color: Color(0xFF00B4D8)),
                      ),
                      TextSpan(
                        text: 'Sight',
                        style: TextStyle(color: Color(0xFF03045E)),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/img/userIcon.png',
                  height: 50,
                )
              ],
            ),
          ),

          // Camera Preview or QR View
          Container(
            height: MediaQuery.sizeOf(context).height * 0.60,
            width: MediaQuery.sizeOf(context).width * 0.90,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera Preview
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: CameraPreview(cameraController!),
                  ),
                  // QR Code Scanner overlay
                  if (selectedButton == 'QR Code')
                    Positioned.fill(
                      child: QRView(
                        key: UniqueKey(),
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: Colors.red,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 300,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Text Button
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(5),
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTextButton('Handwritten Analyzer'),
                _buildTextButton('Document'),
                _buildTextButton('Photo'),
                _buildTextButton('QR Code'),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Buttons Below
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
                color: mainBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  )
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/img/Image.png',
                    height: 50,
                  ),
                  onPressed: () async {},
                ),
                CaptureButton(
                  onPressed: () {
                    _captureButtonPressed();
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    isFlashOn
                        ? 'assets/img/Flash-on.png'
                        : 'assets/img/Flash-Off.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () {
                    setState(() {
                      _toggleFlash();
                    });
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    qrController?.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        setState(() {
          qrCodeLink = scanData.code;
        });
        controller.dispose();
        _showQRDialog();
      }
    });
  }

  void _captureButtonPressed() {
    if (selectedButton == 'QR Code') {
      if (qrCodeLink != null) {
        _showQRDialog();
      } else {
        _showNoQRCodeDialog();
      }
    } else {
      // Handle other button presses
    }
  }

  void _showNoQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Custom border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No QR Code Detected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFDisplay', // Replace with your font family
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please scan a QR code to proceed.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SFDisplay', // Replace with your font family
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SFDisplay', // Replace with your font family
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRDialog() {
    if (qrCodeLink == null) {
      // If no QR code link is detected, show the "No QR Code Detected" dialog
      _showNoQRCodeDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Custom border radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code Detected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFDisplay', // Replace with your font family
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                qrCodeLink!,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'YourFontFamily', // Replace with your font family
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Copy the link to the clipboard
                      Clipboard.setData(ClipboardData(text: qrCodeLink!));
                    },
                    child: Text(
                      'Copy Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily:
                            'SFDisplay', // Replace with your font family
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Open the link in the browser
                      launchUrl(Uri.parse(qrCodeLink!));
                    },
                    child: Text(
                      'Open in Browser',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily:
                            'YourFontFamily', // Replace with your font family
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvalidLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Link'),
        content:
            const Text('The scanned QR code does not contain a valid URL.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedButton = text;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: selectedButton == text ? mainBlue : const Color(0xFF707070),
          fontSize: 10,
          fontFamily: 'SFRounded',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        setState(() {});
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      setState(() {
        isFlashOn = !isFlashOn;
        cameraController!
            .setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
      });
    }
  }
}

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CaptureButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Circle (Border)
          Container(
            width: 70, // Size of the outer circle
            height: 70, // Size of the outer circle
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white, // Outline color
                width: 2.0, // Outline thickness
              ),
            ),
          ),
          // Inner Circle (Filled)
          Container(
            width: 50, // Size of the inner circle
            height: 50, // Size of the inner circle
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Fill color of the inner circle
            ),
          ),
        ],
      ),
    );
  }
}
