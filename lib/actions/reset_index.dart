import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles.dart';
import '../view/home_viewmodel.dart';

class ResetIndexAction extends StatelessWidget {
  const ResetIndexAction({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeViewModel _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    return IconButton(
      color: Colors.orange[200],
      icon: const Icon(Icons.replay),
      onPressed: () {
        showDialog(
            context: context,
            child: AlertDialog(
              backgroundColor: MyColors.violet,
              title: Text("Confirm Restart", style: TextStyles.medium.size(22)),
              content: Text("This will set index to zero.", style: TextStyles.medium.size(14)),
              actions: [
                MyTextButton(text: "No", onPressed: () => Navigator.pop(context)),
                MyTextButton(
                    text: "Yes",
                    onPressed: () {
                      _homeViewModel.reset();
                      Navigator.pop(context);
                    }),
              ],
            ));
      },
    );
  }
}
