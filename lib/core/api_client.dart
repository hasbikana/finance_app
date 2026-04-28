import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiClient {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.18.15:8080/api', // Ganti dengan URL API Anda
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ))..interceptors.add(_AuthInterceptor());

  static Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}