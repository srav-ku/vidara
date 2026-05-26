import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../theme/vidara_theme.dart';

class VideoDashboard extends StatefulWidget {
  const VideoDashboard({super.key});

  @override
  State<VideoDashboard> createState() => _VideoDashboardState();
}

class _VideoDashboardState extends State<VideoDashboard> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  final String _videoEmbedUrl = 'https://vidara.to/e/ZmvvPBA6JbxC';

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  @override
  void dispose() {
    // Reset system UI when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);

    if (_webViewController.platform is AndroidWebViewController) {
      (_webViewController.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.setUserAgent(
      "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36"
    );

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'FullScreenChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'enter') {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          } else if (message.message == 'exit') {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            
            Future.delayed(const Duration(milliseconds: 500), () {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectFullScreenListener();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.contains('vidara.to') || 
                url.contains('jwplayer') || 
                url.contains('jnbhi.com') ||
                url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_videoEmbedUrl));
  }

  void _injectFullScreenListener() {
    const String jsCode = '''
      (function() {
        document.addEventListener('fullscreenchange', () => {
          window.FullScreenChannel.postMessage(!!document.fullscreenElement ? 'enter' : 'exit');
        });
        document.addEventListener('webkitfullscreenchange', () => {
          window.FullScreenChannel.postMessage(!!document.webkitFullscreenElement ? 'enter' : 'exit');
        });
      })();
    ''';
    _webViewController.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          
          return SafeArea(
            // Apply SafeArea to prevent nav bar/status bar overlap
            top: !isLandscape,
            bottom: !isLandscape,
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: VidaraTheme.primary)),
              ],
            ),
          );
        },
      ),
    );
  }
}
