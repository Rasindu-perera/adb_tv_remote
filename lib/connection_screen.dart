import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'tv_remote_service.dart';
import 'remote_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // Controller for IP address input
  final TextEditingController _ipController = TextEditingController();
  
  // Instance of the ADB remote service
  final TvRemoteService _tvRemoteService = TvRemoteService();
  
  // Loading state for UI updates
  bool _isLoading = false;
  bool _isScanning = false;

  Future<void> _scanNetworkForTv() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      if (wifiIP != null && wifiIP.isNotEmpty) {
        final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
        bool found = false;

        for (int i = 1; i < 255; i++) {
          final ipToTest = '$subnet.$i';
          try {
            final socket = await Socket.connect(ipToTest, 5555, timeout: const Duration(milliseconds: 300));
            socket.destroy();
            
            if (mounted) {
              setState(() {
                _ipController.text = ipToTest;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('TV Found: $ipToTest'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            found = true;
            break;
          } catch (e) {
            // Ignore connection errors and continue scanning
          }
        }

        if (!found && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No TV found on port 5555.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('saved_tv_ip');
    if (savedIp != null && savedIp.isNotEmpty) {
      setState(() {
        _ipController.text = savedIp;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ipAddress = _ipController.text.trim();
    if (ipAddress.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Attempt connection
    final success = await _tvRemoteService.connect(ipAddress);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Save the successful IP address
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_tv_ip', ipAddress);

        // Navigate to the remote control screen if successful
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RemoteScreen(tvRemoteService: _tvRemoteService)),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection failed. Please check the IP and ensure TV debugging is on.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to TV'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.tv,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _ipController,
                // Best available keyboard type for IP addresses on mobile
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'TV IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wifi),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Connect',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _isScanning || _isLoading ? null : _scanNetworkForTv,
                icon: _isScanning 
                    ? const SizedBox(
                        width: 16, height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      ) 
                    : const Icon(Icons.search),
                label: Text(_isScanning ? 'Scanning...' : 'Scan for TV on Network'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
