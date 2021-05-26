import 'package:flutter/material.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/my_permission_handler.dart';
import 'package:mass_text_flutter/services/sms_manager.dart';
import 'package:mass_text_flutter/shared/bouncing_button.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../view/home_viewmodel.dart';

class Home extends StatefulWidget {
  Home(this.changePage);
  final Function(int) changePage;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  final SmsManager _smsManager = SmsManager();

  //To Do:

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final HomeViewModel homeViewModel = Provider.of<HomeViewModel>(context);
    final HomeSettings homeSettings = homeViewModel.homeSettings;
    final MessageSettings messageSettings = homeViewModel.messageSettings;
    final AutoReloadSettings autoReloadSettings = homeViewModel.autoReloadSettings;
    final int index = homeSettings.index;
    print("isSending: ${homeSettings.isSending}");
    final int totalRecipients = homeViewModel.recipientLength;
    final double percentage = totalRecipients == 0 ? 0 : index / totalRecipients;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: 0),
                child: myContainer(
                  TextFormField(
                    key: Key(homeSettings.message),
                    maxLength: messageSettings.hasCharLimit ? messageSettings.charLimit : null,
                    maxLines: null,
                    initialValue: homeSettings.message,
                    decoration: Styles.myInputDecoration().copyWith(
                        hintText: "Write Your Message Here...", hintStyle: TextStyles.medium.colour(Colors.grey)),
                    onChanged: (String val) => homeViewModel.saveMessage(val),
                    style: TextStyles.medium,
                    buildCounter: (_, {currentLength, maxLength, isFocused}) {
                      return maxLength == null
                          ? null
                          : Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                currentLength.toString() + "/" + maxLength.toString(),
                                style: TextStyles.small.weight(FontWeight.w300),
                              ),
                            );
                    },
                  ),
                )),

            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                myContainer(
                  SleekCircularSlider(
                    min: 0,
                    max: 1,
                    initialValue: percentage > 1 ? 1 : percentage,
                    innerWidget: (percentage) => Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(index.toString(), style: TextStyles.large),
                            Text("/$totalRecipients", style: TextStyles.small.weight(FontWeight.w300)),
                          ],
                        )),
                    appearance: CircularSliderAppearance(
                      customColors: CustomSliderColors(hideShadow: true, dotColor: Colors.transparent),
                      customWidths: CustomSliderWidths(trackWidth: 9, progressBarWidth: 12),
                      angleRange: 360,
                      startAngle: -90,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * .6,
                  height: 140,
                ),
                myContainer(
                  autoReloadSettings.willAutoReload ? AutoReload(autoReloadSettings) : null,
                  height: 140,
                  width: MediaQuery.of(context).size.width * .28,
                ),
              ],
            ),
            const SizedBox(height: 10),
            myContainer(
              Text(homeSettings.index == 0 ? " " : homeSettings.error, style: TextStyles.small.weight(FontWeight.w400)),
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Builder(
                  builder: (context) {
                    int _colorTan = 200;
                    String _text = 'Pause';
                    if (!homeSettings.isSending) {
                      _text = homeSettings.index == totalRecipients && homeViewModel.recipientList.length != 0
                          ? 'Reset'
                          : 'Send';
                    }
                    return BouncingButton(
                      _text,
                      () {
                        FocusScope.of(context).unfocus();
                        if (homeSettings.isSending) {
                          homeSettings.isSending = false;
                        } else if (homeViewModel.homeSettings.message == "") {
                          MyToast.show("Write your message first in the top text field");
                          return;
                        } else if (homeViewModel.recipientList == null || homeViewModel.recipientList.length == 0) {
                          MyToast.show("Add and Select contacts first uwu");
                          widget.changePage(1);
                          return;
                        } else if (homeSettings.index == totalRecipients) {
                          homeViewModel.reset();
                        } else {
                          homeSettings.consecutiveErrors = 0;
                          //TODO: HANDLER
                          MyPermissionHandler.checkIfHandler().then((isHandler) {
                            if (!isHandler) {
                              MyToast.show("Must be the default SMS app");
                              homeSettings.isSending = false;
                              return;
                            }
                            homeSettings.isSending = true;
                            _smsManager.sendSms(homeViewModel);
                          });

                          //[Permission.sms, Permission.contacts, Permission.phone]
                          // MyPermissionHandler.hasPermission([]).then((hasPermission) {
                          //   // print(homeViewModel.recipientList.toString());
                          //   if (hasPermission) {
                          //     homeSettings.isSending = true;
                          //     _smsManager.sendSms(homeViewModel);
                          //   } else
                          //     homeSettings.isSending = false;
                          // });
                        }
                      },
                      color: Colors.orange[200],
                      // color: MyColors.darkRed,
                      labelColor: MyColors.violetDark,
                      height: 40,
                      width: 150,
                      labelSize: 14,
                    );
                  },
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                // RaisedButton(
                //   color: Colors.orange[200],
                //   child: const Text('Pause'),
                //   onPressed: () async {
                //     PushNotification.instance
                //         .displayNotification("5 Consecutive Errors Occured", "Tap to launch app", "");
                //   },
                // ),
              ],
            ),
            SizedBox(height: 42),
            // WILL LOAD IN ___

            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AutoReload extends StatelessWidget {
  AutoReload(this.autoReloadSettings);
  final AutoReloadSettings autoReloadSettings;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Will reLoad in', style: TextStyles.small),
      Text("${autoReloadSettings.reloadCountdown}", style: TextStyles.large),
    ]);
  }
}
