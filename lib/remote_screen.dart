import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tv_remote_service.dart';

class RemoteScreen extends StatefulWidget {
  final TvRemoteService tvRemoteService;

  const RemoteScreen({super.key, required this.tvRemoteService});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  bool _isMouseMode = false;

  void _showKeyboardBottomSheet(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type to send...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      widget.tvRemoteService.sendText(text);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blueAccent),
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    widget.tvRemoteService.sendText(textController.text);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemoteButton(IconData icon, int keyCode, {Color? color, double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[800],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.tvRemoteService.sendKey(keyCode);
          },
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackpad() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: GestureDetector(
          onPanUpdate: (details) {
            widget.tvRemoteService.sendMouseMovement(details.delta.dx, details.delta.dy);
          },
          onTap: () {
            HapticFeedback.lightImpact();
            widget.tvRemoteService.sendKey(66); // Enter/OK for left click
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[700]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Trackpad Area',
                    style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteControls() {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Top Area: Power, Mute, Source
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRemoteButton(Icons.power_settings_new, 26, color: Colors.redAccent),
                _buildRemoteButton(Icons.volume_off, 164), // Mute
                _buildRemoteButton(Icons.input, 178),      // Source/Input
              ],
            ),
          ),
          
          const Spacer(),
          
          // D-Pad (Center Area)
          SizedBox(
            height: 220,
            width: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // D-Pad Background
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  child: _buildRemoteButton(Icons.keyboard_arrow_up, 19),
                ),
                Positioned(
                  bottom: 10,
                  child: _buildRemoteButton(Icons.keyboard_arrow_down, 20),
                ),
                Positioned(
                  left: 10,
                  child: _buildRemoteButton(Icons.keyboard_arrow_left, 21),
                ),
                Positioned(
                  right: 10,
                  child: _buildRemoteButton(Icons.keyboard_arrow_right, 22),
                ),
                // Center / OK Button
                _buildRemoteButton(Icons.circle, 66, color: Colors.grey[700], size: 70),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Navigation and Volume Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRemoteButton(Icons.arrow_back, 4),
                _buildRemoteButton(Icons.home, 3),
                _buildRemoteButton(Icons.volume_down, 25),
                _buildRemoteButton(Icons.volume_up, 24),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Media Player Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                _buildRemoteButton(Icons.skip_previous, 88, size: 50),
                _buildRemoteButton(Icons.fast_rewind, 89, size: 50),
                _buildRemoteButton(Icons.play_arrow, 85, size: 50), // Play/Pause
                _buildRemoteButton(Icons.stop, 86, size: 50),
                _buildRemoteButton(Icons.fast_forward, 90, size: 50),
                _buildRemoteButton(Icons.skip_next, 87, size: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark theme background
      appBar: AppBar(
        title: const Text('Remote Control', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Toggle between Remote and Mouse modes
          Row(
            children: [
              const Icon(Icons.mouse, color: Colors.white70, size: 20),
              Switch(
                value: _isMouseMode,
                activeColor: Colors.blueAccent,
                onChanged: (value) {
                  setState(() {
                    _isMouseMode = value;
                  });
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white),
            onPressed: () => _showKeyboardBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.power_off, color: Colors.redAccent),
            onPressed: () {
              HapticFeedback.heavyImpact();
              widget.tvRemoteService.disconnect();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isMouseMode) _buildTrackpad() else _buildRemoteControls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
