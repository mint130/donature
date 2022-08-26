import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_model.dart';


class ChatProvider extends ChangeNotifier{
  

  var chattingList = <ChatModel>[];

  Future load()  async{
    var now = DateTime.now().millisecondsSinceEpoch;
    var result = await FirebaseFirestore.instance.collection('/chattingroom_list/TRyiSq9MTxcJiao5TcHL/message_list').where('time', isGreaterThan: now).orderBy('time', descending: true).get();
    var l = result.docs.map((e) => ChatModel.fromMap(
              id: e.id,
              //name: element.name,
              map: e.data() as Map<String, dynamic>
            ));
    chattingList.addAll(l);
    notifyListeners();
  }
}