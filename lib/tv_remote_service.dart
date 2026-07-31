import 'dart:async';
import 'package:flutter_adb/flutter_adb.dart';

/// Service class to handle ADB connection and commands to the Android TV.
class TvRemoteService {
  String? _connectedIp;
  late final AdbCrypto _crypto;

  // Throttling for mouse movement
  Timer? _mouseTimer;
  double _accumulatedDx = 0;
  double _accumulatedDy = 0;

  TvRemoteService() {
    // Initialize the crypto keypair used for the ADB connection
    _crypto = AdbCrypto(adbKeyName: 'adb_tv_remote@dart');
  }

  /// Connects to the TV using its IP address over ADB via Wi-Fi.
  /// Standard ADB over network uses port 5555.
  Future<bool> connect(String ipAddress) async {
    try {
      print('Attempting to connect to TV at $ipAddress:5555...');
      
      // flutter_adb is stateless and connects per command.
      // We test the connection by sending a simple 'echo' command.
      final result = await Adb.sendSingleCommand(
        'echo ping',
        ip: ipAddress, 
        port: 5555, 
        crypto: _crypto, 
      );
      
      _connectedIp = ipAddress;
      print('Successfully connected to TV at $ipAddress (Response: $result)');
      return true;
    } catch (e) {
      print('Error connecting to TV at $ipAddress: $e');
      return false;
    }
  }

  /// Sends a key event to the connected TV.
  Future<void> sendKey(int keyCode) async {
    if (_connectedIp != null) {
      print('Sending key event: $keyCode');
      // Execute the keyevent command without awaiting it to avoid blocking the UI thread
      Adb.sendSingleCommand(
        'input keyevent $keyCode',
        ip: _connectedIp!, 
        port: 5555, 
        crypto: _crypto, 
      ).catchError((e) {
        print('Error sending key event $keyCode: $e');
        return '';
      });
    } else {
      print('Cannot send key: TV is not connected.');
    }
  }

  /// Sends mouse movement delta to the connected TV (simulating trackball).
  /// Uses throttling (50ms interval) to avoid overwhelming the TV's ADB daemon.
  Future<void> sendMouseMovement(double dx, double dy) async {
    if (_connectedIp == null) return;

    _accumulatedDx += dx;
    _accumulatedDy += dy;

    // Only start the timer if it's not currently running
    if (_mouseTimer == null || !_mouseTimer!.isActive) {
      _mouseTimer = Timer(const Duration(milliseconds: 50), () {
        _flushMouseMovement();
      });
    }
  }

  void _flushMouseMovement() {
    if (_connectedIp == null) return;
    if (_accumulatedDx == 0 && _accumulatedDy == 0) return;

    // Adjust multiplier for sensitivity.
    // A factor of 1.5 helps make the swiping feel natural.
    final int moveX = (_accumulatedDx * 1.5).round();
    final int moveY = (_accumulatedDy * 1.5).round();
    
    // Reset accumulators
    _accumulatedDx = 0;
    _accumulatedDy = 0;

    if (moveX == 0 && moveY == 0) return;

    Adb.sendSingleCommand(
      'input roll $moveX $moveY',
      ip: _connectedIp!, 
      port: 5555, 
      crypto: _crypto, 
    ).catchError((e) {
      // Ignore rapid spam errors silently
      return '';
    });
  }

  /// Sends text to the connected TV (e.g., for search bars).
  Future<void> sendText(String text) async {
    if (_connectedIp != null) {
      try {
        print('Sending text: $text');
        // Format the text by replacing spaces with %s as required by ADB
        final formattedText = text.replaceAll(' ', '%s');
        
        await Adb.sendSingleCommand(
          'input text "$formattedText"',
          ip: _connectedIp!, 
          port: 5555, 
          crypto: _crypto, 
        );
      } catch (e) {
        print('Error sending text: $e');
      }
    } else {
      print('Cannot send text: TV is not connected.');
    }
  }

  /// Disconnects or nullifies the connection when no longer needed.
  void disconnect() {
    print('Disconnecting from TV...');
    _mouseTimer?.cancel();
    _connectedIp = null;
    print('Disconnected.');
  }
}
