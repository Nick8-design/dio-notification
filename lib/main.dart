import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:file_notification/permission.dart';
import 'package:file_notification/ui/diocrud.dart';


import 'package:flutter/material.dart';



Future<void> main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: "upload_success",
          channelName: "File upload",
          channelDescription: "File is succssfully uploaded"
      )
    ],
    debug: true,
  );

  await requestStoragePermission();

  runApp(const MyApp());


}





class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:  const DioFileScreen()
    );
  }
}
