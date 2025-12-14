import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ImageCapturePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ValueChanged<String?> onImageCaptured;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const ImageCapturePage({
    super.key,
    required this.cameras,
    required this.onImageCaptured,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<ImageCapturePage> createState() => _ImageCapturePageState();
}

class _ImageCapturePageState extends State<ImageCapturePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _capturedImagePath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.medium, // 720p is usually enough for mobile preview, usage 1080p is better logic wise but this is just preview
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      setState(() => _capturedImagePath = image.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _confirmImage() {
    if (_capturedImagePath != null) {
      widget.onImageCaptured(_capturedImagePath);
    }
  }

  void _retake() {
    setState(() => _capturedImagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return _buildNoCameraView();
    }

    if (_capturedImagePath != null) {
      return _buildPreviewView();
    }

    return _buildCameraView();
  }

  Widget _buildNoCameraView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No camera available'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onSkip,
            child: const Text('SKIP'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onBack,
            child: const Text('BACK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb
                  ? Image.network(
                      _capturedImagePath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Image.file(
                      File(_capturedImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh),
                      label: const Text('RETAKE'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmImage,
                      icon: const Icon(Icons.check),
                      label: const Text('CONFIRM'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Capture Incident',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CameraPreview(_controller!),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('BACK'),
                  ),
                  FloatingActionButton.large(
                    onPressed: _takePicture,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera, size: 48, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text('SKIP'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
