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
    // Force landscape mode immediately
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initWebViewController();
  }

  @override
  void dispose() {
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectCSS();
          },
        ),
      )
      ..loadRequest(Uri.parse(_videoEmbedUrl));
  }

  void _injectCSS() {
    const String jsCode = '''
      (function() {
        const style = document.createElement('style');
        style.innerHTML = `
          .jw-icon-pip, [aria-label="Picture-in-Picture"], .jw-settings-pip { 
            display: none !important; 
          }
          .jw-display-icon-container .jw-icon {
            transform: scale(0.6) !important;
          }
          .jw-title {
            display: block !important;
            font-size: 14px !important;
            font-weight: 500 !important;
            padding: 10px 15px !important;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.8) !important;
          }
          @media (orientation: landscape) {
            .jw-title {
              font-size: 13px !important;
              font-weight: 300 !important;
              letter-spacing: 0.8px !important;
              color: rgba(255, 255, 255, 0.85) !important;
              text-shadow: 0 2px 4px rgba(0,0,0,0.5) !important;
              padding: 20px 25px !important;
              transition: opacity 0.25s ease-in-out !important;
              opacity: 1 !important;
              display: block !important;
            }
            .jw-flag-user-inactive .jw-title {
              opacity: 0 !important;
              pointer-events: none !important;
            }
          }
        `;
        document.head.appendChild(style);
      })();
    ''';
    _webViewController.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: VidaraTheme.primary)),
        ],
      ),
    );
  }
}
