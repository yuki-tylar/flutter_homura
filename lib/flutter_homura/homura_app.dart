import 'package:flutter/material.dart';
import 'flutter_homura.dart';

class HomuraApp extends StatefulWidget {
  final Widget child;
  final Widget? childBeforeInitialized;
  final Widget? childOnError;
  final Map? facebookConfig;

  const HomuraApp({
    Key? key,
    required this.child,
    this.childBeforeInitialized,
    this.childOnError,
    this.facebookConfig,
  }) : super(key: key);

  @override
  _HomuraAppState createState() => _HomuraAppState();
}

class _HomuraAppState extends State<HomuraApp> {
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var homura = Homura.instance;

    return Directionality(
        textDirection: TextDirection.ltr,
        child: homura.onFire
            ? widget.child
            : FutureBuilder(
                future: homura.fire(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return widget.child;
                  } else if (snapshot.hasError) {
                    return widget.childOnError ??
                        const Center(
                          child: Text('Error'),
                        );
                  } else {
                    return widget.childBeforeInitialized ?? Container();
                  }
                },
              ));
  }
}
