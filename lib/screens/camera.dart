import 'dart:io'; // Import this for File operations
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:inksight/constants/colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool isFlashOn = false;
  String selectedButton = 'Handwritten Analyzer';
  final MobileScannerController scannerController = MobileScannerController();
  String result = "";
  XFile? selectedImage; // Variable to store the selected image
  bool isPhotoMode = false; // State variable to toggle between camera and photo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (!isPhotoMode) {
      if (cameraController == null || !cameraController!.value.isInitialized) {
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
            // HEADER
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/img/InkSight-textLogo.png',
                      height: screenHeight * 0.04,
                    ),
                    Image.asset(
                      'assets/img/userIcon.png',
                      height: screenHeight * 0.05,
                    ),
                  ],
                ),
              ),
            ),

            // Camera Preview
            Expanded(
              child: Container(
                width: screenWidth * 0.9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (selectedButton == 'QR Code')
                      MobileScanner(
                        controller: scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty) {
                            final barcode = barcodes.first;
                            if (barcode.rawValue != null) {
                              final String code = barcode.rawValue!;
                              // Pause scanning
                              scannerController.stop();
                              // Show dialog and resume scanning after dialog is dismissed
                              _showQrCodeDialog(code).then((_) {
                                scannerController.start();
                              });
                            }
                          }
                        },
                        fit: BoxFit.cover,
                      )
                    else if (cameraController != null &&
                        cameraController!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: aspectRatio,
                        child: CameraPreview(cameraController!),
                      ),
                  ],
                ),
              ),
            ),

            // Text Button
            const SizedBox(height: 30),
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
            const SizedBox(height: 10),

            // Buttons Below
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 70,
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
                  // Image Icon
                  IconButton(
                    icon: Image.asset(
                      'assets/img/Image.png',
                      height: 35,
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = pickedFile;
                          isPhotoMode = true; // Switch to photo mode
                        });
                      }
                    },
                  ),
                  // Capture Icon
                  IconButton(
                    icon: Image.asset(
                      'assets/img/captureButton.png',
                      height: 90,
                    ),
                    onPressed: () async {},
                  ),
                  // Flash Icon
                  IconButton(
                    icon: Image.asset(
                      isFlashOn
                          ? 'assets/img/Flash-on.png'
                          : 'assets/img/Flash-Off.png',
                      height: 35,
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
            const SizedBox(height: 20),
          ],
        ),
      );
    } else {
      // Photo Mode
      File imageFile = File(selectedImage!.path);
      img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
      double aspectRatio = image.width / image.height;

      return SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // HEADER with Back Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: mainBlue),
                      onPressed: () {
                        setState(() {
                          isPhotoMode = false; // Switch back to camera mode
                          selectedImage = null; // Clear the selected image
                        });
                      },
                    ),
                    Image.asset(
                      'assets/img/InkSight-textLogo.png',
                      height: screenHeight * 0.04,
                    ),
                    Image.asset(
                      'assets/img/userIcon.png',
                      height: screenHeight * 0.05,
                    ),
                  ],
                ),
              ),
            ),

            // Selected Image
            Expanded(
              child: Container(
                width: screenWidth * 0.9,
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
            ),

            // Text Button
            const SizedBox(height: 30),
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
            const SizedBox(height: 10),

            // Buttons Below
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 70,
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
                  // Image Icon
                  IconButton(
                    icon: Image.asset(
                      'assets/img/Image.png',
                      height: 35,
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          selectedImage = pickedFile;
                        });
                      }
                    },
                  ),
                  // Capture Icon
                  IconButton(
                    icon: Image.asset(
                      'assets/img/captureButton.png',
                      height: 90,
                    ),
                    onPressed: () async {},
                  ),
                  // Flash Icon
                  IconButton(
                    icon: Image.asset(
                      isFlashOn
                          ? 'assets/img/Flash-on.png'
                          : 'assets/img/Flash-Off.png',
                      height: 35,
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
            const SizedBox(height: 20),
          ],
        ),
      );
    }
  }

  Future<void> _showQrCodeDialog(String code) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Code Detected',
                  style: TextStyle(
                    fontFamily: 'SFDisplay',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'SFDisplay',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Copy',
                        style: TextStyle(
                          fontFamily: 'SFDisplay',
                          color: mainBlue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _launchInBrowser(code);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Open in Browser',
                        style: TextStyle(
                          fontFamily: 'SFDisplay',
                          color: mainBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  void dispose() {
    // Reset the system UI when the widget is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    cameraController?.dispose();
    scannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _launchInBrowser(String string) async {
    await launchUrl(Uri.parse(string));
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
      );
      await cameraController?.initialize();
      if (mounted) {
        setState(() {});
      }
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
