import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _image;

  Future<void> _pickImage() async {
    await _requestPermissions(); // Solicita permisos

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return; // Asegúrate de que haya una imagen seleccionada

    final uri = Uri.parse("https://4284-2803-a3e0-18c3-53b0-40f2-2303-dfff-3469.ngrok-free.app/upload");
    //final uri = Uri.parse("https://1234abcd.ngrok.io/upload");
    //final uri = Uri.parse("http://192.168.18.39:3000/upload"); // Cambia según tu entorno
    //final uri = Uri.parse("http://http://10.0.2.2:3000/upload");

    final request = http.MultipartRequest("POST", uri);

    try {
      // Adjuntar el archivo a la solicitud
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Este debe coincidir con el nombre esperado por el servidor
        _image!.path,
      ));

      // Enviar la solicitud al servidor
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imagen subida con éxito")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al subir la imagen")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Solicita permisos de almacenamiento
    var storageStatus = await Permission.storage.request();

    if (!storageStatus.isGranted) {
      // Si el permiso es temporalmente negado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permiso de almacenamiento es necesario para esta función")),
      );

      // Manejar denegación permanente
      if (storageStatus.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Permiso permanentemente denegado. Por favor, habilítalo en Configuración."),
          ),
        );
        await openAppSettings(); // Abre configuración de la app
      }
      return; // Finaliza si no se otorgan permisos
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subir Imagen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text("No se seleccionó ninguna imagen")
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Seleccionar Imagen"),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Subir Imagen"),
            ),
          ],
        ),
      ),
    );
  }
}
