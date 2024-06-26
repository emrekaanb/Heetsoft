import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadFile(File? file) async {
  if (file != null) {
    try {
      String fileName = file.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child("uploads/$fileName");
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }
  return null;
}
