import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/news.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news.category),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (news.coverImage.isNotEmpty)
              Image.network(
                news.coverImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),

            // Title and Meta Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(news.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${news.viewCount} lượt xem',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      news.summary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content with HTML
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Html(
                          data: news.content,
                          shrinkWrap: true,
                          style: {
                            "html": Style(
                              backgroundColor: Colors.white,
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "body": Style(
                              fontSize: FontSize(16),
                              lineHeight: const LineHeight(1.8),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            "p": Style(
                              margin: Margins.only(bottom: 16),
                            ),
                            "h1": Style(
                              fontSize: FontSize(24),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(bottom: 16, top: 24),
                            ),
                            "h2": Style(
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(bottom: 12, top: 20),
                            ),
                            "img": Style(
                              alignment: Alignment.center,
                              margin: Margins.symmetric(vertical: 16),
                              width: Width(constraints.maxWidth),
                            ),
                            "a": Style(
                              color: Colors.blue,
                              textDecoration: TextDecoration.underline,
                            ),
                            "table": Style(
                              border: Border.all(color: Colors.grey),
                              margin: Margins.symmetric(vertical: 16),
                            ),
                            "tr": Style(
                              border: Border.all(color: Colors.grey),
                            ),
                            "th": Style(
                              padding: HtmlPaddings.all(8),
                              backgroundColor: Colors.grey[200],
                              border: Border.all(color: Colors.grey),
                            ),
                            "td": Style(
                              padding: HtmlPaddings.all(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            "ul": Style(
                              margin: Margins.only(left: 16, bottom: 16),
                            ),
                            "li": Style(
                              margin: Margins.only(bottom: 8),
                            ),
                          },
                          onLinkTap: (url, _, __) {
                            if (url != null) {
                              _launchUrl(url);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 