import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String _apiUrl = dotenv.get('API_URL');

  // Login
  static Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
    } else {
      return null;
    }
  }

  // Registro
  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  // Obtener token almacenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Obtener headers con token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las tareas
  static Future<List<Map<String, dynamic>>> getTasks() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_apiUrl/tareas'), headers: headers);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  // Obtener una tarea por ID
  static Future<Map<String, dynamic>> getTaskById(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(Uri.parse('$_apiUrl/tareas/$id'), headers: headers);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }

  // Crear una nueva tarea
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> task) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$_apiUrl/tareas'),
      headers: headers,
      body: json.encode(task),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  // Actualizar una tarea
  static Future<Map<String, dynamic>> updateTask(int id, Map<String, dynamic> task) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: headers,
      body: json.encode(task),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Marcar una tarea como completada
  static Future<Map<String, dynamic>> toggleTaskCompletion(int id, bool completed) async {
    final headers = await _getAuthHeaders();
    final response = await http.patch(
      Uri.parse('$_apiUrl/tareas/$id'),
      headers: headers,
      body: json.encode({'completada': completed}),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  // Eliminar una tarea
  static Future<void> deleteTask(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(Uri.parse('$_apiUrl/tareas/$id'), headers: headers);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}
