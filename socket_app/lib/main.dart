import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

final stompClient = StompClient(
  // Node.js를 사용하면 Socket.io를 사용하는 것이 일반적이고 StompConfig()
  // -> ws://주소방식 ex) ws://192.168.0.5:8080
  // Spring을 사용한다면 SocketJS를 이용하는 것이 일반적이다. StompConfig.SockJS()
  // -> http://주소/ws 방식 ex) http://192.168.0.5:8080/ws
  config: StompConfig.SockJS(
    url: 'http://192.168.0.5:8080/ws',
    webSocketConnectHeaders: {
      "transports": ["websocket"]
    },
    onConnect: onConnect,
    beforeConnect: () async {
      print('waiting to connect...');
      await Future.delayed(Duration(milliseconds: 200));
      print('connecting...');
    },
    onWebSocketError: (dynamic error) => print(error.toString()),
    //stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
    //webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
  ),
);

void onConnect(StompFrame frame) {
  print("연결시도");
  stompClient.subscribe(
    destination: '/topic/public',
    headers: {},
    callback: (frame) {
      print("구독완료");
      //List<dynamic>? result = json.decode(frame.body!);
      print(frame.body!);
    },
  );

  stompClient.send(
      destination: '/app/chat.addUser',
      body: json.encode({"sender": "ssar", "type": "JOIN"}),
      headers: {});
}

void main() {
  stompClient.activate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello World"),
            ElevatedButton(
              onPressed: () {
                stompClient.send(
                    destination: '/app/chat.sendMessage',
                    body: json.encode(
                        {"sender": "ssar", "content": "반가워", "type": "CHAT"}),
                    headers: {});
              },
              child: Text("메시지 전송"),
            ),
          ],
        ),
      ),
    );
  }
}
