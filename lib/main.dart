import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news/sentiment_service.dart';
import 'news_service.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final SentimentService _sentimentService = SentimentService();
  final NewsService _newsService = NewsService();

  Map<int, String> _sentiments = {};
  List<dynamic> _articles = [];
  int _page = 1;
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final articles = await _newsService.fetchNews(page: _page);
      setState(() {
        _articles.addAll(articles);
      });
      for (int i = 0; i < articles.length; i++) {
        final sentiment = await _sentimentService.analyzeSentiment(
          articles[i]['title'] ?? '',
        );
        setState(() {
          _sentiments[i] = sentiment['sentiment'];
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Chiều cao của AppBar
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/appbar_background.png'), // Đường dẫn đến ảnh
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(60),
                  top: Radius.circular(60),
                ),
              ),
            ),
            Center(
              child: Text(
                'COVID News',
                style: TextStyle(
                  fontSize: 30, // Kích thước chữ lớn hơn
                  fontWeight: FontWeight.bold, // In đậm
                  color: Colors.white, // Màu chữ
                ),
                textAlign: TextAlign.center, // Căn giữa theo chiều ngang
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _articles.length + 1,
        itemBuilder: (context, index) {
          if (index == _articles.length) {
            return _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  _page++;
                });
                _fetchNews();
              },
              child: Text('Load More'),
            );
          }

          final article = _articles[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: article['urlToImage'] ?? '',
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                ListTile(
                  title: Text(article['title'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['description'] ?? 'No Description',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sentiment: ${_sentiments[index] ?? 'Loading...'}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.notifications),
            title: Text('Notifications'),
            activeColor: Colors.blue,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Favorites'),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
