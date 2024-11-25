import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  ApiServices apiServices = ApiServices();
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  late AnimationController textAnimationController;
  String placeholderText = 'Enter your prompt';
  String displayedText = '';
  late AnimationController controller;
  late Animation<Color?> colorAnimation;
  late Animation<Color?> backgroundColorAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    textAnimationController = AnimationController(
      duration: Duration(milliseconds: placeholderText.length * 100),
      vsync: this,
    );
    textAnimationController.addListener(() {
      int currentIndex =
          (textAnimationController.value * placeholderText.length).floor();
      setState(() {
        displayedText = placeholderText.substring(0, currentIndex);
      });
    });
    textAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          textAnimationController.reset();
          textAnimationController.forward();
        });
      }
    });

    textAnimationController.forward();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(controller);
    backgroundColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    textAnimationController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    String userQuery = messageController.text.trim();
    if (userQuery.isNotEmpty) {
      setState(() {
        messages.add("You: $userQuery"); // Add the user's query to messages
        isLoading = true;
      });
      messageController.clear();

      // Call the API for the response
      final response = await apiServices.getPromptResponse(userQuery);
      if (response != null && response['status'] == 'success') {
        String aiResponse = response['response'];
        setState(() {
          messages.add("AI: $aiResponse"); // Add the AI's response to messages
          isLoading = false;
        });
      } else {
        setState(() {
          messages
              .add("AI: Unable to process your request."); // Add error message
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            AnimatedBuilder(
              animation: colorAnimation,
              builder: (context, child) {
                return Text(
                  'Ai-Bot (content writing)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorAnimation.value,
                  ),
                );
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length + (isLoading ? 1 : 0),
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                itemBuilder: (context, index) {
                  if (isLoading && index == messages.length) {
                    return const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                  /*  bool isOutgoingMessage =
                      messages[messages.length - 1 - index].startsWith("You:"); */
                  return Align(
                    alignment:
                        messages[messages.length - 1 - index].startsWith("You:")
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: messages[messages.length - 1 - index]
                                .startsWith("You:")
                            ? Colors.white
                            : Colors.grey[800],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                          bottomLeft: messages[messages.length - 1 - index]
                                  .startsWith("You:")
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomRight: messages[messages.length - 1 - index]
                                  .startsWith("You:")
                              ? const Radius.circular(0)
                              : const Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        messages[messages.length - 1 - index],
                        style: TextStyle(
                            fontSize: 16,
                            color: messages[messages.length - 1 - index]
                                    .startsWith("You:")
                                ? Colors.black
                                : Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: displayedText,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          sendMessage();
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: sendMessage,
                      child: AnimatedBuilder(
                        animation: backgroundColorAnimation,
                        builder: (context, child) => CircleAvatar(
                          backgroundColor: backgroundColorAnimation.value,
                          child: AnimatedBuilder(
                            animation: colorAnimation,
                            builder: (context, child) => Icon(
                              Icons.send,
                              color: colorAnimation.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'The data you are seeing until 2019 only',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
