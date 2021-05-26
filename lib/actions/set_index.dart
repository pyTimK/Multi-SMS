// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../view/home_viewmodel.dart';
// import '../styles.dart';

// class SetIndexAction extends StatelessWidget {
//   const SetIndexAction({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final HomeViewModel _settingsViewModel = Provider.of<HomeViewModel>(context, listen: false);
//     final List<int> input = <int>[0];
//     return Row(children: <Widget>[
//       MyNumberJumpToTextField(input: input),
//       IconButton(
//         color: Colors.orange[200],
//         icon: const Icon(Icons.forward),
//         onPressed: () => _settingsViewModel.changeIndex(input[0]),
//       ),
//     ]);
//   }
// }
