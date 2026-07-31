import 'package:flutter_adb/flutter_adb.dart';

/// Service class to handle ADB connection and commands to the Android TV.
class TvRemoteService {
  String? _connectedIp;
  late final AdbCrypto _crypto;

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
      try {
        print('Sending key event: $keyCode');
        // Execute the keyevent command
        await Adb.sendSingleCommand(
          'input keyevent $keyCode',
          ip: _connectedIp!, 
          port: 5555, 
          crypto: _crypto, 
        );
      } catch (e) {
        print('Error sending key event $keyCode: $e');
      }
    } else {
      print('Cannot send key: TV is not connected.');
    }
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
    // Since flutter_adb sends single commands per connection instance in this mode,
    // disconnecting simply means forgetting the IP address.
    _connectedIp = null;
    print('Disconnected.');
  }
}
