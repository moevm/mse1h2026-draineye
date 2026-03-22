import 'package:camera/camera.dart';
import 'package:drain_eye/presentation/screens/user/model_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const _teal = Color(0xFF0D9488);
const _gray500 = Color(0xFF64748B);
const _viewportBg = Color(0xFF1E293B);

/// Экран камеры для новой инспекции (UC-8).
/// Область видоискателя показывает живой превью с камеры устройства.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  bool _initializing = true;
  bool _isCapturing = false;
  bool _permissionDenied = false;
  bool _permanentlyDenied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  Future<void> _prepareCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      setState(() {
        _initializing = false;
        _permissionDenied = true;
        _permanentlyDenied = true;
      });
      return;
    }
    if (!status.isGranted) {
      setState(() {
        _initializing = false;
        _permissionDenied = true;
        _permanentlyDenied = false;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
    } catch (e) {
      setState(() {
        _initializing = false;
        _error = 'Не удалось получить список камер: $e';
      });
      return;
    }

    if (_cameras.isEmpty) {
      setState(() {
        _initializing = false;
        _error = 'На устройстве не найдено камер';
      });
      return;
    }

    var idx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (idx < 0) idx = 0;
    _selectedCameraIndex = idx;

    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _setupController(CameraDescription description) async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    await _controller?.dispose();
    _controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _controller = null;
          _initializing = false;
          _error = 'Ошибка камеры: $e';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _initializing = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _initializing || _isCapturing) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _initializing || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final xfile = await c.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModelResultScreen(photoPath: xfile.path),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось сделать фото: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: _buildViewport()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _circleButton(Icons.photo_library_outlined, 44, onPressed: null),
              GestureDetector(
                onTap: _isCapturing ? null : _takePicture,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _teal,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                    ],
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                ),
              ),
              _circleButton(
                Icons.flip_camera_android,
                44,
                onPressed: _cameras.length > 1 && !_isCapturing ? _switchCamera : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: _controller?.value.isInitialized == true && !_isCapturing ? _takePicture : null,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Сделать фото', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _gray500,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModelResultScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Из галереи', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewport() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: _viewportBg,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (_permissionDenied) _buildPermissionMessage(),
            if (!_permissionDenied && _error != null) _buildErrorMessage(),
            if (!_permissionDenied && _error == null && _initializing) const Center(child: CircularProgressIndicator(color: _teal)),
            if (!_permissionDenied && _error == null && !_initializing && _controller?.value.isInitialized == true)
              _buildLivePreview(),
            if (!_permissionDenied && _error == null && !_initializing && _controller?.value.isInitialized == true) ..._viewportOverlays(),
          ],
        ),
      ),
    );
  }

  List<Widget> _viewportOverlays() {
    return [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 1, height: 30, color: Colors.white38),
          const SizedBox(height: 6),
          Container(height: 1, width: 30, color: Colors.white38),
          const SizedBox(height: 6),
          Container(width: 1, height: 30, color: Colors.white38),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, width: 30, color: Colors.white38),
          const SizedBox(width: 6),
          const SizedBox(width: 1, height: 1),
          const SizedBox(width: 6),
          Container(height: 1, width: 30, color: Colors.white38),
        ],
      ),
      Positioned(
        bottom: 24,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Наведите на дренажную систему',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    ];
  }

  Widget _buildLivePreview() {
    final c = _controller!;
    final previewSize = c.value.previewSize;

    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: previewSize != null
            ? SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(c),
              )
            : AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: CameraPreview(c),
              ),
      ),
    );
  }

  Widget _buildPermissionMessage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          Text(
            _permanentlyDenied
                ? 'Доступ к камере отключён. Включите его в настройках приложения.'
                : 'Нужен доступ к камере для съёмки инспекций.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (_permanentlyDenied)
            FilledButton(
              onPressed: openAppSettings,
              child: const Text('Открыть настройки'),
            )
          else
            FilledButton(
              onPressed: () {
                setState(() {
                  _permissionDenied = false;
                  _initializing = true;
                });
                _prepareCamera();
              },
              child: const Text('Запросить снова'),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          _error ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  static Widget _circleButton(IconData icon, double size, {VoidCallback? onPressed}) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, color: _gray500, size: 22),
    );
    if (onPressed == null) {
      return Opacity(opacity: 0.5, child: child);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: child,
      ),
    );
  }
}
