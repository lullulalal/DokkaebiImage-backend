import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:DokkaebieImage/footer/privacy_policy.dart';
import 'package:DokkaebieImage/footer/cookie_preferences.dart';
import 'package:DokkaebieImage/footer/terms_of_use.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dokkaebi Image',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
      ),
      home: const DokkaebiImage(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class DokkaebiImage extends StatefulWidget {
  const DokkaebiImage({super.key});

  @override
  State<DokkaebiImage> createState() => _DokkaebiImageState();
}

class _DokkaebiImageState extends State<DokkaebiImage> {
  //int _counter = 0;
  //String _apiResponse = '';

  Widget? _currentBody;
  int numberOfTools = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentBody = _buildMainContent();
  }

  void moveTool(int index) {
    print('Clicked tool ${index + 1}');

    // Navigator 이동
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (_) => ToolDetailPage(toolIndex: index),
    // ));
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            // Section 1
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'introduce_header'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'introduce'.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Gap Text and Wrap
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(numberOfTools, (index) {
                        return Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () => moveTool(index),
                            hoverColor: Colors.red[50],
                            child: Container(
                              width: 320,
                              height: 150,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/tool${index + 1}.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'tool${index + 1}'.tr(),
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.inter(
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'tool${index + 1}_description'.tr(),
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Section 2
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 32,
                        children: [
                          Image.asset('images/logo.png', height: 90),
                          Text(
                            'explain_header'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'explain'.tr(),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.linkedin),
                            color: const Color(0xFF0A66C2),
                            iconSize: 22,
                            tooltip: 'LinkedIn',
                            onPressed: () async {
                              const url =
                                  'https://www.linkedin.com/in/minsu-seo-6b77a3112/';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.solidEnvelope),
                            color: Colors.black87,
                            iconSize: 22,
                            tooltip: 'Email',
                            onPressed: () async {
                              const email = 'mailto:lullulalal@gmail.com';
                              if (await canLaunchUrl(Uri.parse(email))) {
                                await launchUrl(Uri.parse(email));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Section 3
            Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<Locale>(
                        value: context.locale,
                        underline: const SizedBox(),
                        focusColor: Colors.transparent,
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ko'),
                            child: Text('한국어'),
                          ),
                        ],
                        onChanged: (locale) {
                          if (locale != null) {
                            context.setLocale(locale);
                          }
                        },
                      ),
                    ],
                  ),
                  Text(
                    '© 2025 Dokkaebi Image. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    children: [
                      _footerLink('privacy_policy'.tr(), () {
                        setState(() {
                          _currentBody = const PrivacyPolicyBody();
                        });
                      }),
                      _footerLink('terms_of_use'.tr(), () {
                        setState(() {
                          _currentBody = const TermsOfUseBody();
                        });
                      }),
                      _footerLink('cookie_preferences'.tr(), () {
                        setState(() {
                          _currentBody = const CookiePreferencesBody();
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
  // Future<void> loadStringsData() async {
  //   final jsonString = await rootBundle.loadString('assets/strings_en.json');
  //   setState(() {
  //     stringsData = json.decode(jsonString);
  //   });
  // }

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  // Future<void> _callFastApi() async {
  //   final url = Uri.parse('http://127.0.0.1:8000/hello');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _apiResponse = response.body;
  //       });
  //     } else {
  //       setState(() {
  //         _apiResponse = 'Error: ${response.statusCode}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _apiResponse = 'Error: $e';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 65,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tools',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
            ...List.generate(numberOfTools, (index) {
              return ListTile(
                leading: Image.asset(
                  'assets/images/tool${index + 1}.png',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  'tool${index + 1}'.tr(),
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                onTap: () => moveTool(index),
              );
            }),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentBody = _buildMainContent();
              });
            },
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  'Dokkaebi',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  'Image',
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.apps),
              color: Colors.black87,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: _currentBody,
      // body: Center(
      //   // Center is a layout widget. It takes a single child and positions it
      //   // in the middle of the parent.
      //   child: Column(
      //     // Column is also a layout widget. It takes a list of children and
      //     // arranges them vertically. By default, it sizes itself to fit its
      //     // children horizontally, and tries to be as tall as its parent.
      //     //
      //     // Column has various properties to control how it sizes itself and
      //     // how it positions its children. Here we use mainAxisAlignment to
      //     // center the children vertically; the main axis here is the vertical
      //     // axis because Columns are vertical (the cross axis would be
      //     // horizontal).
      //     //
      //     // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
      //     // action in the IDE, or press "p" in the console), to see the
      //     // wireframe for each widget.
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text('You have pushed the button this many times:'),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headlineMedium,
      //       ),
      //       const SizedBox(height: 40), // Added code - spacing before button
      //       ElevatedButton(
      //         onPressed: _callFastApi, // Added code - button triggers API call
      //         child: const Text('Call FastAPI'), // Added code - button label
      //       ),
      //       const SizedBox(height: 20), // Added code - spacing before response text
      //       Text(
      //         'API Response: $_apiResponse', // Added code - display API response
      //         style: const TextStyle(fontSize: 16),
      //       ),
      //     ],
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
