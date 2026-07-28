import 'package:flutter/material.dart';

class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Control'),
      ),
      body: const Center(
        child: Text('Remote Screen Placeholder'),
      ),
    );
  }
}
