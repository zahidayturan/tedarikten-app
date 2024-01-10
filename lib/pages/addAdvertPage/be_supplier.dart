
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BeSupplier extends ConsumerStatefulWidget {
  const BeSupplier({Key? key}) : super(key: key);

  @override
  ConsumerState<BeSupplier> createState() => _BeSupplierState();
}

class _BeSupplierState extends ConsumerState<BeSupplier> {

  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context){
    return Container(child: Center(child: Text("Tedarikçi ol")),);
  }

}