import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> messages = [];
  double _dragOffset = 0; // To track drag offset for animation purposes

  // Function to format the time
  String getFormattedTime(int seconds) {
    DateTime now = DateTime.now().add(Duration(seconds: seconds));
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Function to send a new message
  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      final newMessage = {
        "message": _controller.text,
        "time": "",
        "type": "sent",
        "sliderValue": 0, // Placeholder for time adjustment
        "isDragged": false,
      };

      setState(() {
        messages.add(newMessage);

        _listKey.currentState?.insertItem(
          messages.length - 1,
          duration: Duration(milliseconds: 300),
        );
      });

      _controller.clear();
    }
  }

  // Update the isDragged property for all messages
  void updateAllMessagesDragged(bool isDragged) {
    setState(() {
      for (var message in messages) {
        message["isDragged"] = isDragged;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              "assets/images/dp.jpg",
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),
        title: const Text(
          "Uday Friend",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                var message = messages[index];
                bool isSent = message["type"] == "sent";
                String time = getFormattedTime(0); // Get the formatted time

                return SizeTransition(
                  sizeFactor: animation,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.primaryDelta! < 0) {
                        updateAllMessagesDragged(true);
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      updateAllMessagesDragged(false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: isSent
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSent ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message["message"]!,
                              style: TextStyle(
                                color: isSent ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (message["isDragged"])
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
