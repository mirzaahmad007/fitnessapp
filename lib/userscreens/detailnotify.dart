import 'package:flutter/material.dart';

import 'detailnotify.dart';

class Detailnotify extends StatefulWidget {
  Detailnotify({super.key});

  @override
  State<Detailnotify> createState() => _DetailnotifyState();
}

class _DetailnotifyState extends State<Detailnotify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
        centerTitle: true,

      ),
      body: Column(
        children: [
          Image(image: AssetImage("assets/images/plant.png", ),
            height: 200,
            width: 200,
            fit: BoxFit.cover,

          ),
          SizedBox(height: 25,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){}, child: Text("25%")
              ),
              SizedBox(width: 15,),
              ElevatedButton(onPressed: (){}, child: Text("80%")
              ),
              SizedBox(width: 15,),
              ElevatedButton(onPressed: (){}, child: Text("60%")
              )
            ],
          )
        ],
      ),
    );
  }
}
