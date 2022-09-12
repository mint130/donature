import 'package:donation_nature/alarm/service/alarm_serivce.dart';
import 'package:donation_nature/board/service/post_service.dart';
import 'package:donation_nature/chat/domain/chatting_room.dart';
import 'package:donation_nature/chat/service/chat_service.dart';
import 'package:donation_nature/screen/board/board_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:donation_nature/mypage/user_manage.dart';
import 'package:donation_nature/screen/chat/chat_detail_screen.dart';
import './post_edit_screen.dart';

import 'package:donation_nature/board/domain/post.dart';

class PostDetailScreen extends StatefulWidget {
  Post post;

  PostDetailScreen(this.post);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostService postService = PostService();

  ChatService chatService = ChatService();

  Widget build(BuildContext context) {
    User? user = UserManage().getUser();
    DateTime dateTime = widget.post.date!.toDate();

    return user != null //user가 로그인 해있을 때
        ? Builder(builder: (context) {
            bool isWriter = false;
            bool isNanum = false;
            if (user.email == widget.post.userEmail)
              isWriter = true; //로그인 한 유저가 글쓴이일 때
            if (widget.post.tagMore != '알리기') isNanum = true; //나눔글일 때
            return Scaffold(
                appBar: AppBar(),
                body: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.post.isDone
                          ? Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                              child: Text(
                                "나눔완료",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff416E5C),
                                  ),
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "${widget.post.tagMore}",
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xff416E5C)),
                              ),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child: Text(
                          widget.post.title!,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "#${widget.post.tagDisaster}",
                            style: TextStyle(
                                color: Color(0xff416E5C),
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "#${widget.post.locationSiDo} ${widget.post.locationGuGunSi}",
                            style: TextStyle(
                                color: Color(0xff416E5C),
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          Spacer(),
                          if (isWriter == false && widget.post.isDone == false)
                            //로그인 한 상태에서 글 작성자가 본인이 아니고 나눔완료 전일 때 관심목록 추가 가능
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(
                                PostService().isLiked(widget.post, user)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Color(0xff416E5C),
                              ),
                              onPressed: () {
                                setState(() {
                                  PostService().likePost(widget.post, user);
                                  PostService().isLiked(widget.post, user)
                                      ? ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("관심 목록에 추가되었습니다.")))
                                      : null;
                                });
                              },
                            ),
                        ],
                      ),
                      Divider(
                        height: 20,
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          Text("글쓴이: " + widget.post.writer!),
                          VerticalDivider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Text(dateTime.toLocal().toString().substring(5, 16)),
                          Spacer(),
                          if (isWriter == true &&
                              widget.post.isDone ==
                                  false) //글 작성자가 본인이고 나눔 완료 전일 때 수정 삭제 가능
                            Transform.scale(
                              scale: 0.8,
                              child: Row(children: [
                                deleteButton(context),
                                editButton(context)
                              ]),
                            )
                        ],
                      ),
                      Divider(
                        height: 20,
                        thickness: 1,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: widget.post.imageUrl != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "${widget.post.imageUrl}"),
                                              fit: BoxFit.cover)),
                                      height: 400,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      widget.post.content!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    widget.post.content!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                      ))
                    ],
                  ),
                ),
                floatingActionButton: isWriter == false &&
                        widget.post.isDone == false
                    //본인이 작성한 글이 아니고
                    //나눔완료 전이면 채팅 가능
                    ? FloatingActionButton.extended(
                        onPressed: () async {
                          ChattingRoom _chattingRoom;
                          if (PostService().isChatted(widget.post, user)) {
                            _chattingRoom = await ChatService().getChattingRoom(
                                widget.post.chatUsers![user.email]);
                            // 채팅한적 있는 경우 기존 채팅방으로 이동
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ChatDetailScreen(
                                        userName: widget.post.writer!,
                                        chattingRoom: _chattingRoom,
                                        reference: widget
                                            .post.chatUsers![user.email]))));
                          } else {
                            // 채팅한적 없는 경우 새 채팅방 생성
                            List<String> users = [];
                            users.add(user.email!);
                            users.add(widget.post.userEmail!);
                            List<String> nicknames = [];
                            nicknames.add(user.displayName!);
                            nicknames.add(widget.post.writer!);
                            List<String> userUID = [];
                            userUID.add(user.uid);
                            userUID.add(widget.post.writerUID!);

                            _chattingRoom = ChattingRoom(
                                user: users,
                                nickname: nicknames,
                                userUID: userUID,
                                post: widget.post);

                            _chattingRoom.chatReference = await chatService
                                .createChattingRoom(_chattingRoom.toJson());
                            AlarmService.createChattingRoomAlarm(
                                user.uid,
                                widget.post.writerUID,
                                user.displayName,
                                widget.post.writer);
                            widget.post.chatUsers![user.email] =
                                _chattingRoom.chatReference;
                            PostService().updatePost(
                                reference: widget.post.reference!,
                                json: widget.post.toJson());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ChatDetailScreen(
                                        userName: widget.post.writer!,
                                        chattingRoom: _chattingRoom,
                                        reference:
                                            _chattingRoom.chatReference!))));
                          }
                        },
                        label: Text('채팅하기'),
                        backgroundColor: Color(0xff416E5C),
                        icon: Icon(Icons.chat_bubble),
                      )
                    :
                    //본인이 작성한 글이고, 나눔 관련 글이고, 나눔완료 전일 때 나눔 종료 가능
                    isWriter == true &&
                            isNanum == true &&
                            widget.post.isDone == false
                        //나눔관련 글이 맞고 나눔완료 전일 때
                        ? FloatingActionButton.extended(
                            backgroundColor: Color(0xff416E5C),
                            icon: Icon(Icons.check),
                            label: Text('나눔종료'),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    return AlertDialog(
                                      title: const Text(
                                        '나눔을 종료하시겠습니까?',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      content: const Text(
                                        '나눔을 종료하면 수정/삭제가 불가합니다.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      actions: [
                                        ButtonTheme(
                                            minWidth: 20,
                                            child: FlatButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  PostService()
                                                      .isDone(widget.post);
                                                  setState(() {
                                                    widget.post.isDone = true;
                                                  });
                                                  //나눔이 완료되었습니다

                                                  Navigator.push(
                                                      ctx,
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              BoardScreen())));
                                                },
                                                child: Text("예"))),
                                        ButtonTheme(
                                          minWidth: 20,
                                          child: FlatButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Text(
                                                "아니오",
                                                style: TextStyle(
                                                    color: Color(0xff416E5C)),
                                              )),
                                        )
                                      ],
                                    );
                                  });
                            })
                        : Container());
          })
        : //유저가 로그인 안 한 경우
        Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.post.isDone
                      ? Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0))),
                          child: Text(
                            "나눔완료",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xff416E5C),
                              ),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "${widget.post.tagMore}",
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff416E5C)),
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Text(
                      widget.post.title!,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        "#${widget.post.tagDisaster}",
                        style: TextStyle(
                            color: Color(0xff416E5C),
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "#${widget.post.locationSiDo} ${widget.post.locationGuGunSi}",
                        style: TextStyle(
                            color: Color(0xff416E5C),
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                      Spacer(),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 1.5,
                  ),
                  Row(
                    children: [
                      Text("글쓴이: " + widget.post.writer!),
                      VerticalDivider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      Text(dateTime.toLocal().toString().substring(5, 16)),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 1.5,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: widget.post.imageUrl != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              "${widget.post.imageUrl}"),
                                          fit: BoxFit.cover)),
                                  height: 400,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  widget.post.content!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                widget.post.content!,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                  ))
                ],
              ),
            ),
          );
  }

  TextButton editButton(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        //수정버튼
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostEditScreen(
                        post: widget.post,
                      )));
        },
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: Colors.black,
            ),
            Text(
              "수정",
              style: TextStyle(color: Colors.black),
            )
          ],
        ));
  }

  TextButton deleteButton(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        //삭제버튼
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  content: Text("게시글을 삭제하시겠습니까?"),
                  actions: [
                    ButtonTheme(
                      minWidth: 20.0,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            PostService().deletePost(widget.post);
                            Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                    builder: ((context) => BoardScreen())));
                          },
                          child: Text(
                            "예",
                            style: TextStyle(color: Color(0xff416E5C)),
                          )),
                    ),
                    ButtonTheme(
                      minWidth: 20,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            "아니오",
                            style: TextStyle(color: Color(0xff416E5C)),
                          )),
                    ),
                  ],
                );
              });
        },
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.black),
            Text(
              "삭제",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ));
  }
}