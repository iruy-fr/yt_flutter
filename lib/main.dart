import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterTube',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoInfoPage(),
    );
  }
}

class VideoInfoPage extends StatefulWidget {
  @override
  _VideoInfoPageState createState() => _VideoInfoPageState();
}

class _VideoInfoPageState extends State<VideoInfoPage> {
  final String videoId = 'J4BVaXkwmM8'; // Substitua pelo ID do vídeo do YouTube
  final String apiKey = 'AIzaSyC-LmHe9mCuY53GczQQQf-YKmpXXTFFbdI';   // Substitua pela sua chave da API do YouTube

  YoutubePlayerController? _youtubeController;
  Map<String, dynamic>? videoInfo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVideoInfo();
    _initializeYoutubePlayer();
  }

  // Inicializar o YouTube Player
  void _initializeYoutubePlayer() {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      params: YoutubePlayerParams(
        autoPlay: false,
        showControls: true,
        showFullscreenButton: true,

      ),
    );
  }

  // Função para buscar informações do vídeo
  Future<void> _fetchVideoInfo() async {
    try {
      final info = await getYoutubeVideoInfo(videoId, apiKey);
      setState(() {
        videoInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterTube'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            YoutubePlayerIFrame(controller: _youtubeController),
            const SizedBox(height: 20),
            Text('Views: ${videoInfo?['viewCount']}'),
            Text('Likes: ${videoInfo?['likeCount']}'),
            Text('Comments: ${videoInfo?['commentCount']}'),
            Text('Title: ${videoInfo?['estimatedWatchTime']}'),
          ],
        ),
      ),
    );
  }
}

// Função para fazer a requisição HTTP e obter as estatísticas do vídeo
Future<Map<String, dynamic>> getYoutubeVideoInfo(String videoId, String apiKey) async {
  final String url = 'https://www.googleapis.com/youtube/v3/videos?part=statistics&id=$videoId&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Parse the JSON data
    final Map<String, dynamic> data = json.decode(response.body);

    if (data['items'].isNotEmpty) {
      // Retornar as estatísticas do vídeo
      return data['items'][0]['statistics'];
    } else {
      throw Exception('Video not found');
    }
  } else {
    throw Exception('Failed to load video info');
  }
}
