import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:typed_data'; // Importación necesaria para Uint8List
import 'dart:convert'; // Importar para usar utf8

class ConnectionScreen extends StatefulWidget {
  final BluetoothDevice device;

  ConnectionScreen({required this.device});

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothConnection? connection;
  bool isConnecting = true;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.device.address);
      print('Conectado a ${widget.device.name}');
      setState(() {
        isConnecting = false;
      });
    } catch (e) {
      print('No se pudo conectar: $e');
      setState(() {
        isConnecting = false;
      });
    }
  }

  void _sendCommand(String command) async {
    if (connection != null && connection!.isConnected) {
      // Convierte el comando en bytes y lo envía
      connection!.output.add(utf8.encode(command + "\n")); // Añade un salto de línea si es necesario
      await connection!.output.allSent; // Espera a que se envíen todos los datos
      print('Comando enviado: $command'); // Imprime el comando enviado
    } else {
      print('No hay conexión para enviar el comando.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectado a ${widget.device.name}'),
      ),
      body: Center(
        child: isConnecting
            ? CircularProgressIndicator() // Muestra un indicador de carga mientras se conecta
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Conexión exitosa!'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _sendCommand("I"); // Envía el comando para el primer botón
                    },
                    child: Text("Izquierda"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _sendCommand("D"); // Envía el comando para el segundo botón
                    },
                    child: Text("Derecha"),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    connection?.dispose(); // Cerrar la conexión al salir de la pantalla
    super.dispose();
  }
}
