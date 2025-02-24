import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileUploadService {
  final String baseUrl = "https://files-kvpe.onrender.com";



  // https://cloudy-4jzqow.fly.dev/files
  // https://file-upload-6nhr.onrender.com/files
  final Dio dio = Dio();

  Future<void> uploadFIles(File file) async {
    try {
      String fileName = file.path
          .split("/")
          .last;

      
      FormData data = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,filename: fileName)
      });

     await dio.post("$baseUrl/upload", data: data);


trigernotification();
      print ("success upload");
    }

    catch (e){
print("error uploading $e");
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
      } else {
        print("Failed to delete: ${response.data}");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }


  Future<String> download(String filename)async{
    try {
      print("Downloading from: $baseUrl/files/$filename");

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    String savePath="";

      if (selectedDirectory == null || !Directory(selectedDirectory).existsSync()) {

      Directory directory=await getApplicationDocumentsDirectory();
      savePath = "${directory.path}/$filename";
      await dio.download("$baseUrl/files/$filename", savePath);
      return "File downloaded to: $savePath";
    }else{
        savePath = "$selectedDirectory/$filename";

      }



      // Ensure directory exists before saving
      Directory saveDirectory = Directory(savePath).parent;
      if (!saveDirectory.existsSync()) {
        saveDirectory.createSync(recursive: true);
      }

      await dio.download("$baseUrl/files/$filename", savePath);
      return "File downloaded to: $savePath";
    } catch (e) {
      print("error $e");
      return "Download failed: $e";
    }
  }


trigernotification(){
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 8,
            channelKey: "upload_success",
            title: "File Uploaded",
          body: "1 file uploaded successfully"
        )

    );
}




}