import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessi',
      home: Scaffold(
        appBar: AppBar(title: const Text('Accessi Utenti')),
        body: const AccessiPage(),
      ),
    );
  }
}

class AccessiPage extends StatefulWidget {
  const AccessiPage({super.key});

  @override
  State<AccessiPage> createState() => _AccessiPageState();
}

class _AccessiPageState extends State<AccessiPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> utenti = [];
  bool loading = false;
  String? error;

  Future<void> fetchUtenti(String numero) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final uri = Uri.parse('http://192.168.1.102:5000/utenti?numero=$numero');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          utenti = data;
        });
      } else {
        setState(() {
          error = 'Errore dal server: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Errore: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget buildUtente(dynamic utente) {
    final dentro = utente['dentro'] == 0;
    return ListTile(
      leading: utente['foto'] != null
          ? Image.memory(base64Decode(utente['foto']))
          : const Icon(Icons.person),
      title: Text('${utente['Nome']} ${utente['Cognome']}'),
      subtitle: Text(dentro ? 'Dentro' : 'Fuori'),
      tileColor: dentro ? Colors.green[100] : Colors.red[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Inserisci numero',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              fetchUtenti(value);
            },
          ),
          const SizedBox(height: 20),
          if (loading) const CircularProgressIndicator(),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          Expanded(
            child: ListView.builder(
              itemCount: utenti.length,
              itemBuilder: (context, index) => buildUtente(utenti[index]),
            ),
          )
        ],
      ),
    );
  }
}