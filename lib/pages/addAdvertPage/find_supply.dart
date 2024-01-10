
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class FindSupply extends ConsumerStatefulWidget {
  const FindSupply({Key? key}) : super(key: key);

  @override
  ConsumerState<FindSupply> createState() => _FindSupplyState();
}

class _FindSupplyState extends ConsumerState<FindSupply> {

  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context){
    return Container(child: Center(child: Text("Tedarik bul")),);
  }

}