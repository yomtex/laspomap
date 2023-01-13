import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SliderPanel extends StatefulWidget {
  const SliderPanel({Key? key}) : super(key: key);

  @override
  State<SliderPanel> createState() => _SliderPanelState();
}

class _SliderPanelState extends State<SliderPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SlidingUpPanelExample"),
      ),
      // SlidingUpPanel with panel and collapsed
      body: SlidingUpPanel(
        panel: Center(
          child: Text("This is the sliding Widget"),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              // changing radius that we define above
              borderRadius: BorderRadius.circular(20)
          ),
          // collapsed text
          child: Center(
            child: Text(
              "This is the collapsed Widget",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // main body or content behind the panel
        body: Center(
          child: Text("This is the Widget behind the sliding panel"),
        ),
        borderRadius:  BorderRadius.circular(20),
      ),
    );
  }
}
