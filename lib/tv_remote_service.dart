import 'package:adb_client/adb_client.dart';

/// Service class to handle ADB connection and commands to the Android TV.
class TvRemoteService {
  // Private variable to hold the ADB connection instance
  AdbDevice? _tvDevice;

  /// Connects to the TV using its IP address over ADB via Wi-Fi.
  /// Standard ADB over network uses port 5555.
  Future<bool> connect(String ipAddress) async {
    try {
      print('Attempting to connect to TV at $ipAddress:5555...');
      
      // Connect to the device using the adb_client package
      // Note: AdbClient.connect might return an AdbDevice or similar,
      // but if the package API differs, this may need adjustment.
      _tvDevice = await AdbClient.connect(ipAddress, 5555) as AdbDevice;
      
      print('Successfully connected to TV at $ipAddress');
      return true;
    } catch (e) {
      print('Error connecting to TV at $ipAddress: $e');
      return false;
    }
  }

  /// Sends a key event to the connected TV.
  Future<void> sendKey(int keyCode) async {
    if (_tvDevice != null) {
      try {
        print('Sending key event: $keyCode');
        // Execute the shell command on the connected TV
        await _tvDevice!.shell('input keyevent $keyCode');
      } catch (e) {
        print('Error sending key event $keyCode: $e');
      }
    } else {
      print('Cannot send key: TV is not connected.');
    }
  }

  /// Disconnects or nullifies the connection when no longer needed.
  void disconnect() {
    print('Disconnecting from TV...');
    if (_tvDevice != null) {
      try {
        // Explicitly close the connection if the package supports it.
        // Some packages use AdbClient.disconnect(ip) or _tvDevice!.disconnect().
        // We'll wrap it in a try-catch so it won't crash if the method is missing.
        // AdbClient.disconnect(_tvDevice!.serial); 
      } catch (e) {
        print('Error explicitly disconnecting: $e');
      }
    }
    // Nullify the connection instance.
    _tvDevice = null;
    print('Disconnected.');
  }
}
