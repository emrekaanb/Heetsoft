import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recaptcha_v2/recaptcha_v2.dart';
import '../services/firebase_service.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _file;
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? fileUrl = await uploadFile(_file);
      if (fileUrl != null) {
        FirebaseFirestore.instance.collection('forms').add({
          'name': _nameController.text,
          'fileUrl': fileUrl,
          'timestamp': Timestamp.now(),
        });
      }
    }
  }

  void _verifyRecaptcha() {
    recaptchaV2Controller.show();
    recaptchaV2Controller.onVerifiedSuccessfully = (token) {
      _submitForm();
    };
    recaptchaV2Controller.onVerifiedFailed = (error) {
      print(error);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _pickFile,
            child: Text('Pick File'),
          ),
          ElevatedButton(
            onPressed: _verifyRecaptcha,
            child: Text('Submit'),
          ),
          RecaptchaV2(
            apiKey: "YOUR_RECAPTCHA_API_KEY",
            controller: recaptchaV2Controller,
            onVerifiedError: (err) {
              print(err);
            },
          ),
        ],
      ),
    );
  }
}




