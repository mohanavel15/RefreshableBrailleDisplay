import 'package:app/text_to_braille.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class FileUpload extends StatefulWidget {
  final String filePath;
  final String fileType;

  const FileUpload({Key? key, required this.filePath, required this.fileType }) : super(key: key);

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  double _uploadProgress = 0.0;
  String _responseCode = '';
  bool _isUploading = false;

  void _uploadFile(BuildContext context) async {
    try {
      setState(() {
        _isUploading = true;
      });

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(widget.filePath),
      });

      Dio dio = Dio();
      dio.options.baseUrl = 'http://192.168.144.142:5000';
      dio.options.connectTimeout = const Duration(seconds: 5);

      dio.interceptors.add(LogInterceptor());

      Response response = await dio.post(widget.fileType == 'pdf' ? '/pdf' : '/img',
        data: formData,
        onSendProgress: (int sent, int total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      setState(() {
        _responseCode = response.statusCode.toString();
        _isUploading = false;
      });

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextToBraille(text: response.data.toString()),
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('File Name: ${widget.filePath}'),
            const SizedBox(height: 16),
            if (_isUploading)
              CircularProgressIndicator(value: _uploadProgress)
            else
              ElevatedButton(
                onPressed: () => _uploadFile(context),
                child: const Text('Upload'),
              ),
            const SizedBox(height: 16),
            if (_uploadProgress > 0.0)
              Text('Upload Progress: ${(_uploadProgress * 100).toStringAsFixed(2)}%'),
            const SizedBox(height: 16),
            if (_responseCode.isNotEmpty)
              Text('Response Code: $_responseCode'),
          ],
        ),
      ),
    );
  }
}
