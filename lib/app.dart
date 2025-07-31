import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

import 'routing/route_link.dart';



class CItadelVaultApp extends StatefulWidget {
  const CItadelVaultApp({super.key});

  @override
  State<CItadelVaultApp> createState() => _GhumPhirAppState();
}

class _GhumPhirAppState extends State<CItadelVaultApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light().copyWith(
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xff4D4DCD),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: ((BuildContext context, Widget? widget) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Column(
              children: [
                Container(
                  child:
                      "ERROR".text
                          .textStyle(
                            GoogleFonts.quicksand(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .bold
                          .xl
                          .make(),
                ),
                Container(child: details.exception.toString().text.make()),
              ],
            ),
          );
        };
        return widget!;
      }),
    );
  }
}
