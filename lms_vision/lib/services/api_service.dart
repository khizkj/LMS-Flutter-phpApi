import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.100.34/lms_backend/api.php";
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint("JSON decode error: $e");
      debugPrint("Response body: $body");
      return {"status": "error", "message": "Invalid response format"};
    }
  }

  static Future<T> _handleRequest<T>(Future<T> request) async {
    try {
      return await request.timeout(_timeout);
    } on SocketException {
      throw Exception("No internet connection");
    } on HttpException {
      throw Exception("Server error occurred");
    } catch (e) {
      throw Exception("Request failed: $e");
    }
  }

  // ✅ USER AUTHENTICATION
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=login"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'email': email, 'password': password},
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Login error: $e'};
    }
  }

  static Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=register"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'username': username,
            'email': email,
            'password': password,
          },
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Signup error: $e'};
    }
  }

  static Future<bool> logout() async {
    try {
      var response = await _handleRequest(
        http.post(Uri.parse("$baseUrl?action=logout")),
      );
      final data = _safeDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      debugPrint("Logout error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> sessionCheck() async {
    try {
      var response = await _handleRequest(
        http.post(Uri.parse("$baseUrl?action=session_check")),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Session check error: $e'};
    }
  }

  // ✅ ADMIN AUTHENTICATION
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=admin_login"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'email': email, 'password': password},
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Admin login error: $e'};
    }
  }

  // ✅ ADMIN STATISTICS
  static Future<Map<String, dynamic>> adminStats() async {
    try {
      var response = await _handleRequest(
        http.post(Uri.parse("$baseUrl?action=admin_stats")),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Admin stats error: $e'};
    }
  }

  // ✅ COURSE MANAGEMENT
  static Future<Map<String, dynamic>> addCourse({
    required String title,
    required String description,
    File? image,
    String? tags,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl?action=add_course");
      var request = http.MultipartRequest("POST", uri);
      
      request.fields['title'] = title;
      request.fields['description'] = description;
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = tags;
      }
      
      if (image != null && !kIsWeb) {
        var multipartFile = await http.MultipartFile.fromPath('image', image.path);
        request.files.add(multipartFile);
      }

      var streamed = await _handleRequest(request.send());
      var body = await streamed.stream.bytesToString();
      return _safeDecode(body);
    } catch (e) {
      return {"status": "error", "message": "Add Course error: $e"};
    }
  }

  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      var response = await _handleRequest(
        http.post(Uri.parse("$baseUrl?action=get_courses")),
      );

      final data = _safeDecode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['courses'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch courses');
      }
    } catch (e) {
      debugPrint("getCourses error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> deleteCourse(int id) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=delete_course"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'id': id.toString()},
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Delete course error: $e'};
    }
  }

  // ✅ USER MANAGEMENT
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      var response = await _handleRequest(
        http.post(Uri.parse("$baseUrl?action=get_users")),
      );

      final data = _safeDecode(response.body);
      if (data['status'] == 'success') {
        return {
          'status': 'success',
          'data': List<Map<String, dynamic>>.from(data['users'] ?? [])
        };
      } else {
        return {'status': 'error', 'data': [], 'message': data['message']};
      }
    } catch (e) {
      return {'status': 'error', 'data': [], 'message': 'Get users error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=register"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'username': name,
            'email': email,
            'password': password,
          },
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Add user error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=delete_user"),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'id': id.toString()},
        ),
      );
      return _safeDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Delete user error: $e'};
    }
  }

  // ✅ ENROLLMENT MANAGEMENT
  static Future<List<Map<String, dynamic>>> getAvailableCourses(int userId) async {
    try {
      var response = await _handleRequest(
        http.get(Uri.parse("$baseUrl?action=get_available&user_id=$userId")),
      );

      final data = _safeDecode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['courses'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch available courses');
      }
    } catch (e) {
      debugPrint("getAvailableCourses error: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getEnrolledCourses(int userId) async {
    try {
      var response = await _handleRequest(
        http.get(Uri.parse("$baseUrl?action=get_enrolled&user_id=$userId")),
      );

      final data = _safeDecode(response.body);
      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['courses'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch enrolled courses');
      }
    } catch (e) {
      debugPrint("getEnrolledCourses error: $e");
      return [];
    }
  }

  static Future<bool> enrollCourse(int userId, int courseId) async {
    try {
      var response = await _handleRequest(
        http.post(
          Uri.parse("$baseUrl?action=enroll&user_id=$userId"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'course_id': courseId}),
        ),
      );

      final data = _safeDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      debugPrint("enrollCourse error: $e");
      return false;
    }
  }

  // ✅ IMAGE UPLOAD (Legacy support)
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse("$baseUrl?action=upload_image");
      var request = http.MultipartRequest("POST", uri);
      
      var multipartFile = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(multipartFile);

      var streamed = await _handleRequest(request.send());
      var body = await streamed.stream.bytesToString();
      return _safeDecode(body);
    } catch (e) {
      return {"status": "error", "message": "Image upload error: $e"};
    }
  }

  // ✅ UTILITY METHODS
  static String getImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) return '';
    return "http://192.168.100.34/lms_backend/uploads/$imageName";
  }

  static Future<bool> checkConnection() async {
    try {
      var response = await http.get(
        Uri.parse(baseUrl),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ ERROR HANDLING
  static String getErrorMessage(Map<String, dynamic> response) {
    if (response['status'] == 'error') {
      return response['message'] ?? 'An unknown error occurred';
    }
    return 'Operation completed successfully';
  }

  static bool isSuccess(Map<String, dynamic> response) {
    return response['status'] == 'success';
  }
}