import 'package:flutter/material.dart';
import 'package:soundcode/soundcode.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool permissionGranted = false;
  AppLifecycleState lastState ;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startSoundCode();

  }

  startSoundCode(){
    SoundCode().requestPermission().then((granted) {
      if (granted) {
        SoundCode().start();
      }
      setState(() {
        permissionGranted = granted;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    print(state.toString());
    if (state == AppLifecycleState.resumed) {
      if(lastState==AppLifecycleState.paused) {
        startSoundCode();
      }
    }
    if (state == AppLifecycleState.paused) {
      SoundCode().stop();
    }
    lastState = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var permission;
    if(permissionGranted)
      {
        permission = Text("Mic permission: OK", style: TextStyle(color: Colors.greenAccent,fontSize: 15),);
      }
    else{
      permission = GestureDetector(
        child: Text("Mic permission: <tap to enable>", style: TextStyle(color: Colors.deepOrangeAccent,fontSize: 15),),
        onTap: (){startSoundCode();},
      );
    }
    return MaterialApp(
      home: Scaffold(
        appBar:
        AppBar(
           title: const Text('Flutter Demo'),
        ),
        body: Center(
            child: Column(
          children: [
            Container(
                margin: EdgeInsets.all(25.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                )),
            Text("SoundCode SDK Demo", style: TextStyle(fontSize: 20)),
            Text('www.cifrasoft.com'),
            Container(height: 10,),
            permission,
            Container(height: 10,),
            Expanded(child: MyListView())
          ],
        )),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  MyListViewState createState() => MyListViewState();
}

class MyListViewState extends State<MyListView> {
  List<ListItem> list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SoundCode().setCallback(callback: (List<int> data) {
      setState(() {list.insert(0,new ListItem(data));});
    });
    SoundCode().setErrorCallback(error: (){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Container(child:Center(child:Text("Audio Init Failed!")), height: 30,),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey,
      ),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: list[i],
          onLongPress: (){print("tap");showAlertDialog(context);},
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {Navigator.pop(context);},
    );
    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed:  () {
        list.clear();
        Navigator.pop(context);
        setState(() {
      });},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("⚠"),
      content: Text("Clear history?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ListItem extends StatelessWidget {
  List<int> data;
  String time;

  ListItem(this.data) {
    var now = DateTime.now();
    DateFormat formatter = DateFormat('HH:mm:ss');
    this.time = formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Text(time +
        " CODE:" +
        data[1].toString() +
        " CNT:" +
        data[2].toString() +
        " TIME:" +
        (data[3] / 1000.0).toStringAsFixed(1) +
        "sec.");
  }
}
