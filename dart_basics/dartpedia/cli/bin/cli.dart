import 'dart:io';
import 'package:http/http.dart' as http;
const version = '0.0.1';

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {//若运行参数为空或为help，则输出帮助信息
    printUsage();
  } 
  else if (arguments.first =='version'){//若运行参数为version，则输出版本号
    print('Dartpedia version: $version');
  }
  else if(arguments.first=='wikipedia'){
    final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchWikipedia(inputArgs);
  }
  else {
    printUsage();
  }
}

void searchWikipedia(List<String>? arguments) async{//搜索维基百科
  final String? articleTitle;

  if(arguments == null || arguments.isEmpty){//若运行参数为空，则提示用户输入文章标题
    print('Please provide an article title.');

    final inputFromStdin= stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print('No article title provided. Exiting.');
      return;
    }
    articleTitle = inputFromStdin;
  } else {
    articleTitle = arguments.join(' ');//将参数列表中的字符串连接成一个字符串，使用空格分隔
  }
  print('Looking up articles about "$articleTitle". Please wait.');
  var articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent);
}

void printUsage() { // Add this new function
  print(
    "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
  );
}

Future<String> getWikipediaArticle(String articleTitle) async {
    final url = Uri.https(//创建一个新的URI对象，使用HTTPS协议
    'en.wikipedia.org', // Wikipedia API domain
    '/api/rest_v1/page/summary/$articleTitle', // API path for article summary
  );
  final response = await http.get(url); //发送HTTP GET请求到指定的URL，并等待响应

  if (response.statusCode == 200) {
    return response.body; //如果响应状态码为200（表示请求成功），则返回响应的正文内容
  }

  //如果响应状态码不是200，则返回一个错误消息，包含文章标题和实际的状态码
  return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';
  //You'll add more code here soon
}