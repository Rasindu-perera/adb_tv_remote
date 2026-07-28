import 'package:flutter/material.dart';
import 'tv_remote_service.dart';

class RemoteScreen extends StatelessWidget {
  final TvRemoteService tvRemoteService;

  const RemoteScreen({super.key, required this.tvRemoteService});

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
          onTap: () => tvRemoteService.sendKey(keyCode),
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Power Button (Top Area)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildRemoteButton(Icons.power_settings_new, 26, color: Colors.redAccent),
                const SizedBox(width: 30),
              ],
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
            
            // Bottom Area Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRemoteButton(Icons.arrow_back, 4),
                      _buildRemoteButton(Icons.home, 3),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRemoteButton(Icons.volume_down, 25),
                      _buildRemoteButton(Icons.volume_up, 24),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
