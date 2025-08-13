import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const CheckServicesApp());
}

class CheckServicesApp extends StatelessWidget {
  const CheckServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Services',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ServicesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final Map<String, Map<String, int>> services = {
    'Mail': {
      'POP3': 110,
      'IMAP': 143,
      'SMTP': 25,
    },
    'Http': {
      'HTTP (80)': 80,
      'HTTPS (443)': 443,
    },
    'SMB': {
      'SMB': 445,
    },
  };

  final Map<String, bool> expanded = {};
  final Map<String, Map<String, bool?>> status = {};
  final String host = '192.168.1.200';

  @override
  void initState() {
    super.initState();

    for (var service in services.keys) {
      expanded[service] = false;
      status[service] = {};
      for (var protocol in services[service]!.keys) {
        status[service]![protocol] = null;
      }
    }

    _checkAllServices();
  }

  Future<bool> _checkPort(String host, int port, {Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkAllServices() async {
    for (var service in services.keys) {
      for (var protocol in services[service]!.keys) {
        final port = services[service]![protocol]!;
        final result = await _checkPort(host, port);
        setState(() {
          status[service]![protocol] = result;
        });
      }
    }
  }

  bool getServiceStatus(String service) {
    final protocols = status[service]!;
    return protocols.values.any((s) => s == true);
  }

  Widget _buildProtocolTile(String service, String protocol, bool? isOnline) {
    Icon icon;
    if (isOnline == null) {
      icon = const Icon(Icons.help_outline, color: Colors.grey);
    } else if (isOnline) {
      icon = const Icon(Icons.check_circle, color: Colors.green);
    } else {
      icon = const Icon(Icons.cancel, color: Colors.red);
    }
    return ListTile(
      title: Text(protocol),
      trailing: icon,
    );
  }

  Widget _buildServiceTile(String service) {
    final isExpanded = expanded[service]!;
    final serviceOnline = getServiceStatus(service);
    final icon = serviceOnline
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.cancel, color: Colors.red);

    return ExpansionTile(
      key: PageStorageKey(service),
      title: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expandedState) {
        setState(() {
          expanded[service] = expandedState;
        });
      },
      children: services[service]!.keys
          .map((protocol) => _buildProtocolTile(service, protocol, status[service]![protocol]))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Services'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/icon.png'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkAllServices();
        },
        child: ListView(
          children: services.keys.map(_buildServiceTile).toList(),
        ),
      ),
    );
  }
}