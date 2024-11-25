import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServices {
  // Fetch the response for a given user query
  Future<Map<String, dynamic>?> getPromptResponse(String userQuery) async {
    final String baseUrl =
        'https://content-writter-bot.onrender.com/user_prompt';
    final String url = '$baseUrl?user_query=$userQuery';

    try {
      final response = await http.get(Uri.parse(url));

      // Check the status code to determine if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response if successful
        final data = jsonDecode(response.body);
        print("Response Data: $data");
        return data; // Return the data here
      } else {
        // Handle error responses
        print("Request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print("An error occurred: $e");
      return null;
    }
  }

  // Send data to the server (for example, for saving a user prompt)
  Future<Map<String, dynamic>?> sendPromptData(String userQuery) async {
    final String baseUrl =
        'https://content-writter-bot.onrender.com/user_prompt';
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_query": userQuery,
        }),
      );

      // Check the status code to determine if the request was successful
      if (response.statusCode == 200) {
        // Decode the JSON response if successful
        final data = jsonDecode(response.body);
        print("Response Data: $data");
        return data; // Return the data here
      } else {
        // Handle error responses
        print("Request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print("An error occurred: $e");
      return null;
    }
  }
}
