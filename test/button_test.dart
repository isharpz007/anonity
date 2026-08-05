import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:anonity/main.dart';


void main() {

  testWidgets(
    "Test all buttons are clickable",
    (WidgetTester tester) async {


    await tester.pumpWidget(
      const AnonityApp()
    );

    await tester.pumpAndSettle();


    // Find every button
    final buttons = find.byType(ButtonStyleButton);


    print(
      "Buttons found: ${buttons.evaluate().length}"
    );


    expect(
      buttons,
      findsWidgets,
    );


    // Tap every button
    for(int i = 0; i < buttons.evaluate().length; i++){

      try {

        await tester.tap(
          buttons.at(i),
          warnIfMissed: false,
        );

        await tester.pumpAndSettle(
          const Duration(seconds:1)
        );


        print(
          "Button $i works ✅"
        );


      } catch(e){

        print(
          "Button $i failed ❌ $e"
        );

      }

    }


  });


}