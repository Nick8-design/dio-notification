import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../network/file_upload_service.dart';

class DioFileScreen extends StatefulWidget {
  const DioFileScreen({super.key});

  @override
  State<DioFileScreen> createState() => _DioFileScreenState();
}

class _DioFileScreenState extends State<DioFileScreen> {
  final FileUploadService fileService = FileUploadService();
  List<String> fileList = [];

  @override
  void initState() {

    AwesomeNotifications().isNotificationAllowed().then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    List<String> files = await fileService.fetchallfiles();
    setState(() {
      fileList = files;
    });
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await fileService.uploadFIles(file);
      _loadFiles();
    }
  }

  Future<void> _downloadFile(String fileId) async {
    String message = await fileService.download(fileId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isImage(String filePath) {
    return filePath.endsWith('.png') ||
        filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.gif');
  }

  bool _isVideo(String filePath) {
    return filePath.endsWith('.mp4') ||
        filePath.endsWith('.avi') ||
        filePath.endsWith('.mov') ||
        filePath.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Dio File Upload"),
        backgroundColor: Colors.yellow[300],


      ),
      body: Column(
        children: [
          ListTile(
            trailing: ElevatedButton(
                onPressed: _uploadFile,
                child:const Icon(Icons.upload)
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                String filePath = fileList[index];
                print(filePath);

                return Dismissible(
                  key: Key(filePath),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    fileService.deleteFile(filePath);
                    setState(() {
                      fileList.remove(filePath);
                    });
                  },
                  child:Card(

                    margin: const EdgeInsets.all(8.0),
                  child:
                  Column(
                children: [

                  Stack(
                    children: [
                      Container(
                        child:

                       _isImage(filePath)
                            ?
                           Image.network(
                               "https://files-kvpe.onrender.com/files/$filePath"
                           )
                             : _isVideo(filePath)
                            ? VideoPlayerWidget("https://files-kvpe.onrender.com/files/$filePath")
                            : const Icon(Icons.insert_drive_file), // Default icon
                      ),

                      Positioned(
                        top:12,
                          right:12,
                          child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                fileService.deleteFile(filePath);
                                setState(() {
                                  fileList.remove(filePath);
                                });
                              },
                            ),

                      ),



                    ],
                  ),





                  ListTile(
                    title:  Text(filePath.split('/').last),
                    trailing:  IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          String message = await fileService.download(filePath);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        },
                      ),
                  )


    ],
                  ),

                ),


                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget(this.videoUrl, {Key? key}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController; // Make it nullable

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);

    try {
      await _controller.initialize(); // Wait for video to initialize
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
        );
      });
    } catch (e) {
      print("Video initialization failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null && _controller.value.isInitialized
        ? SizedBox(
      width: 380,
      height: 200,
      child: Chewie(controller: _chewieController!),
    )
        : const Center(child: CircularProgressIndicator()); // Show loading indicator
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
