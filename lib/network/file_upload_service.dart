import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../permission.dart';

class FileUploadService {
  final String baseUrl = "https://files-kvpe.onrender.com";



  // https://cloudy-4jzqow.fly.dev/files
  // https://file-upload-6nhr.onrender.com/files
  final Dio dio = Dio();

  Future<void> uploadFIles(File file) async {
    String fileName="";
    try {
       fileName = file.path
          .split("/")
          .last;

      
      FormData data = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,filename: fileName)
      });

     await dio.post("$baseUrl/upload", data: data);


trigernotification(fileName, "uploaded Successfully.","File Uploaded");
      print ("success upload");
    }

    catch (e){
print("error uploading $e");
trigernotification(fileName, "was not uploaded.","Failed Upload");
    }
  }

  Future<List<String>> fetchallfiles()async{
    try{
      Response response =await dio.get('$baseUrl/files');

      return List<String>.from(response.data['files']);
  }

  catch (e){
    print("Error: $e");
    return []; // Return empty list on error
  }
}


  Future<void> deleteFile(String fileName) async {
    try {
      Response response = await dio.delete('$baseUrl/files/$fileName'); // Ensure correct URL
      if (response.statusCode == 200) {
        print("File deleted successfully");
        trigernotification(fileName, "deleted Successfully.","File Deleted");
      } else {
        trigernotification(fileName, "was not deleted.","Failed to delete");
        print("Failed to delete: ${response.data}");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }



  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }



  Future<String> getDownloadPath() async {
    Directory? directory = await getExternalStorageDirectory();
    return directory!.path;  // Example: /storage/emulated/0/Android/data/com.example.app/files
  }

  Future<String> download(String filename) async {
    await _requestStoragePermission();

    try {
      print("Downloading from: $baseUrl/files/$filename");

      // Step 1: Let user pick a folder
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      // Step 2: If user cancels folder selection, show a message
      if (selectedDirectory == null) {
        return "Download cancelled: No folder selected";
      }

      // Step 3: Save file inside the selected folder
      String savePath = "$selectedDirectory/$filename";

      // Ensure directory exists before saving
      Directory saveDirectory = Directory(selectedDirectory);
      if (!saveDirectory.existsSync()) {
        saveDirectory.createSync(recursive: true);
      }

      // Step 4: Start Download
      await Dio().download("$baseUrl/files/$filename", savePath);

      // Step 5: Trigger Notification (if implemented)
      trigernotification(filename, "Downloaded successfully", "File saved at $savePath");

      return "File downloaded to: $savePath";
    } catch (e) {
      print("Error: $e");
      trigernotification(filename, "Download failed", "Download failed: $e");
      return "Download failed: $e";
    }
  }
  // Future<String> download(String filename) async {
  //   await _requestStoragePermission();
  //
  //   try {
  //     print("Downloading from: $baseUrl/files/$filename");
  //
  //     // Get an accessible directory
  //     String directoryPath = await getDownloadPath();
  //     String savePath = "$directoryPath/$filename";
  //
  //     // Ensure directory exists
  //     Directory saveDirectory = Directory(directoryPath);
  //     if (!saveDirectory.existsSync()) {
  //       saveDirectory.createSync(recursive: true);
  //     }
  //
  //     // Download file
  //     await dio.download("$baseUrl/files/$filename", savePath);
  //     trigernotification(filename, "Downloaded successfully", "File downloaded");
  //
  //     return "File downloaded to: $savePath";
  //   } catch (e) {
  //     print("Error: $e");
  //     trigernotification(filename, "Download failed", "Download failed: $e");
  //     return "Download failed: $e";
  //   }
  // }

trigernotification(String fileName,String status,String title){
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 8,
            channelKey: "upload_success",
            title: title,
          body: "$fileName $status"
        )

    );
}




}