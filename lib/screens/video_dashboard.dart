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
    // Allow both landscape modes
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
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url.toLowerCase();
            // Block anything related to YouTube or known ad trackers/redirects
            if (url.contains('youtube.com') || url.contains('youtu.be') || url.contains('doubleclick') || url.contains('googleads')) {
              debugPrint('BLOCKED REDIRECT: $url');
              return NavigationDecision.prevent;
            }
            // Only allow vidara.to and direct media stream hosts
            if (url.contains('vidara.to') || url.contains('.m3u8') || url.contains('.ts') || !request.isMainFrame) {
              return NavigationDecision.navigate;
            }
            debugPrint('PREVENTED UNKNOWN NAV: $url');
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_videoEmbedUrl));
  }

  void _injectCSS() {
    const String jsCode = '''
      (function() {
        // 1. Force Styles
        const style = document.createElement('style');
        style.innerHTML = `
          .jw-icon-pip, [aria-label="Picture-in-Picture"], .jw-settings-pip,
          .jw-icon-fullscreen, [aria-label="Fullscreen"], [aria-label="Exit Fullscreen"] { 
            display: none !important; 
          }
          .jw-display-icon-container .jw-icon {
            transform: scale(0.6) !important;
          }
          .jw-controlbar {
            padding: 0 45px !important;
          }
          .custom-ratio-btn {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            cursor: pointer !important;
            margin: 0 12px !important;
            position: relative !important;
            height: 100% !important;
            z-index: 2147483647 !important;
          }
          .custom-ratio-icon {
            width: 20px;
            height: 16px;
            border: 2px solid white;
            border-radius: 2px;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
          }
          .custom-ratio-icon::after {
            content: 'R';
            font-size: 10px;
            font-weight: 900;
            color: white;
          }
          .custom-ratio-menu {
            position: absolute;
            bottom: 50px;
            right: 0;
            background: rgba(28, 28, 28, 0.95);
            border-radius: 6px;
            padding: 6px 0;
            min-width: 100px;
            display: none;
            flex-direction: column;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
            border: 1px solid rgba(255,255,255,0.1);
          }
          .custom-ratio-menu.active {
            display: flex;
          }
          .ratio-item {
            padding: 10px 15px;
            color: white;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
            text-align: left;
          }
          .ratio-item:hover {
            background: rgba(255,255,255,0.15);
          }
          .ratio-item.selected {
            color: #FF3B30;
            font-weight: 900;
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

        // 2. Aspect Ratio Logic
        function setupAspectRatio() {
          if (document.querySelector('.custom-ratio-btn')) return;

          const video = document.querySelector('video') || document.getElementsByTagName('video')[0];
          const settingsIcon = document.querySelector('.jw-icon-settings') || 
                               document.querySelector('[aria-label="Settings"]') ||
                               document.querySelector('.jw-icon-cc');
          
          const rightGroup = document.querySelector('.jw-controlbar-right-group') || 
                             document.querySelector('.jw-button-container');

          if (video && (settingsIcon || rightGroup)) {
            const btn = document.createElement('div');
            btn.className = 'jw-icon jw-icon-inline custom-ratio-btn';
            btn.innerHTML = `
              <div class="custom-ratio-icon"></div>
              <div class="custom-ratio-menu">
                <div class="ratio-item selected" data-fit="contain">16:9 (Original)</div>
                <div class="ratio-item" data-fit="cover">FILL (Crop)</div>
                <div class="ratio-item" data-fit="fill">FULL (Stretch)</div>
              </div>
            `;
            
            const menu = btn.querySelector('.custom-ratio-menu');
            const items = btn.querySelectorAll('.ratio-item');

            btn.onclick = function(e) {
              e.preventDefault();
              e.stopPropagation();
              
              // Close other menus if open
              document.querySelectorAll('.custom-ratio-menu').forEach(m => {
                if (m !== menu) m.classList.remove('active');
              });
              
              menu.classList.toggle('active');
            };

            items.forEach(item => {
              item.onclick = function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                const fit = this.getAttribute('data-fit');
                video.style.setProperty('object-fit', fit, 'important');
                video.style.setProperty('width', '100%', 'important');
                video.style.setProperty('height', '100%', 'important');
                
                // Update selection UI
                items.forEach(i => i.classList.remove('selected'));
                this.classList.add('selected');
                
                menu.classList.remove('active');
              };
            });

            // Close menu when clicking elsewhere
            document.addEventListener('click', function(e) {
              if (!btn.contains(e.target)) {
                menu.classList.remove('active');
              }
            });

            // Place it right before settings/captions
            if (settingsIcon) {
              settingsIcon.parentNode.insertBefore(btn, settingsIcon);
            } else {
              rightGroup.appendChild(btn);
            }
          }
        }

        setInterval(setupAspectRatio, 1000);
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
