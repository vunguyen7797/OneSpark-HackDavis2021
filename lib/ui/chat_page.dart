import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/ui/video_call_twillio_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;

  ChatPage(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(key: key);

  @override
  State createState() =>
      ChatPageState(peerId: peerId, peerAvatar: peerAvatar, peerName: peerName);
}

class ChatPageState extends State<ChatPage> {
  ChatPageState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName});

  String peerId;
  String peerAvatar;
  String peerName;
  String uid;
  String myAvatar;

  List<DocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  File _imageFile;
  bool _isLoading;
  bool isShowSticker;
  String photoUrl;

  final TextEditingController _textFieldController = TextEditingController();
  final ScrollController _messageListScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _messageListScrollController.addListener(_scrollListener);

    groupChatId = '';

    _isLoading = false;
    isShowSticker = false;
    photoUrl = '';

    _matchPair();
  }

  _scrollListener() {
    if (_messageListScrollController.offset >=
            _messageListScrollController.position.maxScrollExtent &&
        !_messageListScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
    if (_messageListScrollController.offset <=
            _messageListScrollController.position.minScrollExtent &&
        !_messageListScrollController.position.outOfRange) {
      setState(() {});
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  _matchPair() async {
    prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';
    myAvatar = prefs.getString('photoUrl') ?? '';
    if (uid.hashCode <= peerId.hashCode) {
      groupChatId = '$uid-$peerId';
    } else {
      groupChatId = '$peerId-$uid';
    }

    Firestore.instance
        .collection('users')
        .document(uid)
        .updateData({'chattingWith': peerId});

    setState(() {});
  }

  Future _selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    _imageFile = File(pickedFile.path);

    if (_imageFile != null) {
      setState(() {
        _isLoading = true;
      });
      _uploadFile();
    }
  }

  void _openStickerSelector() {
    _focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future _uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final storageReference = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = storageReference.putFile(_imageFile);
    final snapshot = await uploadTask.onComplete;
    photoUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      _isLoading = false;
      _addSentMessage(photoUrl, 1);
    });
  }

  void _addSentMessage(String content, int dataType) {
    if (content.trim() != '') {
      _textFieldController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idSender': uid,
            'idReceiver': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'dataType': dataType
          },
        );
      });
      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .setData({'id': groupChatId});
      _messageListScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
  }

  bool _isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['idSender'] == uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool _isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['idSender'] != uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _onTapBack() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Firestore.instance
          .collection('users')
          .document(uid)
          .updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 5 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5 * SizeConfig.widthMultiplier),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: ColorPalette.kAccentColor
                                      .withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(50)),
                              padding: EdgeInsets.all(20),
                              child: Icon(
                                FontAwesomeIcons.arrowLeft,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 3 * SizeConfig.heightMultiplier,
                          ),
                          Expanded(
                            child: Text(
                              peerName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rubik(
                                color: ColorPalette.kPrimaryColor,
                                fontSize: 4 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2 * SizeConfig.heightMultiplier,
                    ),
                    _buildMessagesList(),
                    (isShowSticker ? _buildStickerSelector() : Container()),
                    // Input content
                    _buildInputField(),
                  ],
                ),
                _buildLoadingScreen()
              ],
            ),
          ),
        ),
      ),
      onWillPop: _onTapBack,
    );
  }

  Widget _buildMessageItem(int index, DocumentSnapshot document) {
    if (document.data['idSender'] == uid) {
      final userBloc = Provider.of<UserBloc>(context);

      return Padding(
        padding: EdgeInsets.only(bottom: _isLastMessageRight(index) ? 30 : 10),
        child: Row(
          children: <Widget>[
            document.data['dataType'] == 0
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 80),
                      child: Container(
                        child: Text(
                          document.data['content'],
                          style: GoogleFonts.rubik(
                            color: ColorPalette.kPrimaryColor,
                            fontSize: 2 * SizeConfig.textMultiplier,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 5 * SizeConfig.widthMultiplier,
                            vertical: 1.5 * SizeConfig.heightMultiplier),
                        decoration: BoxDecoration(
                            color: ColorPalette.kSecondaryColor,
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  )
                : document.data['dataType'] == 1
                    ? Container(
                        child: CachedNetworkImage(
                          imageUrl: document.data['content'],
                          imageBuilder: (context, imageProvider) => ClipRRect(
                            borderRadius: BorderRadius.circular(
                                5 * SizeConfig.heightMultiplier),
                            child: Container(
                              height: 20 * SizeConfig.heightMultiplier,
                              width: 20 * SizeConfig.heightMultiplier,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            height: 20 * SizeConfig.heightMultiplier,
                            width: 20 * SizeConfig.heightMultiplier,
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(
                                  5 * SizeConfig.heightMultiplier),
                            ),
                            child: SpinKitFadingFour(
                              color: ColorPalette.kPrimaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 20 * SizeConfig.heightMultiplier,
                            width: 20 * SizeConfig.heightMultiplier,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(
                                  5 * SizeConfig.heightMultiplier),
                            ),
                            child: Icon(Icons.error),
                          ),
                        ),
                      )
                    : Container(
                        child: Image.asset(
                          'res/images/${document.data['content']}.gif',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
            SizedBox(
              width: 2 * SizeConfig.widthMultiplier,
            ),
            CachedNetworkImage(
              imageUrl: userBloc.photoUrl,
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius:
                    BorderRadius.circular(5 * SizeConfig.heightMultiplier),
                child: Container(
                  height: 5 * SizeConfig.heightMultiplier,
                  width: 5 * SizeConfig.heightMultiplier,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )),
                ),
              ),
              placeholder: (context, url) => Container(
                height: 5 * SizeConfig.heightMultiplier,
                width: 5 * SizeConfig.heightMultiplier,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius:
                      BorderRadius.circular(5 * SizeConfig.heightMultiplier),
                ),
                child: SpinKitFadingFour(
                  color: ColorPalette.kPrimaryColor,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 5 * SizeConfig.heightMultiplier,
                width: 5 * SizeConfig.heightMultiplier,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius:
                      BorderRadius.circular(5 * SizeConfig.heightMultiplier),
                ),
                child: Icon(Icons.error),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
            bottom: _isLastMessageRight(index) && _isLastMessageLeft(index)
                ? 0
                : 20),
        child: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: peerAvatar,
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(
                          5 * SizeConfig.heightMultiplier),
                      child: Container(
                        height: 5 * SizeConfig.heightMultiplier,
                        width: 5 * SizeConfig.heightMultiplier,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      height: 5 * SizeConfig.heightMultiplier,
                      width: 5 * SizeConfig.heightMultiplier,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(
                            5 * SizeConfig.heightMultiplier),
                      ),
                      child: SpinKitFadingFour(
                        color: ColorPalette.kPrimaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 5 * SizeConfig.heightMultiplier,
                      width: 5 * SizeConfig.heightMultiplier,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                            5 * SizeConfig.heightMultiplier),
                      ),
                      child: Icon(Icons.error),
                    ),
                  ),
                  SizedBox(
                    width: 2 * SizeConfig.widthMultiplier,
                  ),
                  document.data['dataType'] == 0
                      ? Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 80),
                            child: Container(
                              child: Text(
                                document.data['content'],
                                style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontSize: 2 * SizeConfig.textMultiplier,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5 * SizeConfig.widthMultiplier,
                                  vertical: 1.5 * SizeConfig.heightMultiplier),
                              decoration: BoxDecoration(
                                  color: ColorPalette.kPrimaryColor,
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        )
                      : document.data['dataType'] == 1
                          ? Container(
                              child: CachedNetworkImage(
                                imageUrl: document.data['content'],
                                imageBuilder: (context, imageProvider) =>
                                    ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      5 * SizeConfig.heightMultiplier),
                                  child: Container(
                                    height: 20 * SizeConfig.heightMultiplier,
                                    width: 20 * SizeConfig.heightMultiplier,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  height: 20 * SizeConfig.heightMultiplier,
                                  width: 20 * SizeConfig.heightMultiplier,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(
                                        5 * SizeConfig.heightMultiplier),
                                  ),
                                  child: SpinKitFadingFour(
                                    color: ColorPalette.kPrimaryColor,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 20 * SizeConfig.heightMultiplier,
                                  width: 20 * SizeConfig.heightMultiplier,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(
                                        5 * SizeConfig.heightMultiplier),
                                  ),
                                  child: Icon(Icons.error),
                                ),
                              ),
                            )
                          : Container(
                              child: Image.asset(
                                'res/images/${document.data['content']}.gif',
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),
              _isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('MMM dd yyyy kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document.data['timestamp']))),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        ),
      );
    }
  }

  Widget _buildStickerSelector() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _addSentMessage('mimi1', 2),
                child: Image.asset(
                  'res/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi2', 2),
                child: Image.asset(
                  'res/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi3', 2),
                child: Image.asset(
                  'res/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _addSentMessage('mimi4', 2),
                child: Image.asset(
                  'res/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi5', 2),
                child: Image.asset(
                  'res/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi6', 2),
                child: Image.asset(
                  'res/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _addSentMessage('mimi7', 2),
                child: Image.asset(
                  'res/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi8', 2),
                child: Image.asset(
                  'res/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => _addSentMessage('mimi9', 2),
                child: Image.asset(
                  'res/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 30 * SizeConfig.heightMultiplier,
    );
  }

  Widget _buildLoadingScreen() {
    return Positioned(
      child: _isLoading
          ? SpinKitFadingFour(
              color: ColorPalette.kPrimaryColor,
            )
          : Container(),
    );
  }

  Widget _buildInputField() {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: Icon(FontAwesomeIcons.image),
              onPressed: _selectImage,
              color: ColorPalette.kPrimaryColor,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: Icon(Icons.face),
              onPressed: _openStickerSelector,
              color: ColorPalette.kPrimaryColor,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () {
                String roomName = groupChatId;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VideoCallPage.create(context, roomName)));
              },
              color: ColorPalette.kPrimaryColor,
            ),
          ),
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  _addSentMessage(_textFieldController.text, 0);
                },
                style: TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 2 * SizeConfig.textMultiplier),
                controller: _textFieldController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: _focusNode,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _addSentMessage(_textFieldController.text, 0),
              color: ColorPalette.kPrimaryColor,
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 6 * SizeConfig.heightMultiplier,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget _buildMessagesList() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: SpinKitFadingFour(
                color: ColorPalette.kPrimaryColor,
              ),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: SpinKitFadingFour(
                    color: ColorPalette.kPrimaryColor,
                  ));
                } else {
                  listMessage.addAll(snapshot.data.documents);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => _buildMessageItem(
                        index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: _messageListScrollController,
                  );
                }
              },
            ),
    );
  }
}
