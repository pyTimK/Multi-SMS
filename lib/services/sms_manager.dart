import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/push_notification.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:sms/sms.dart';

import '../view/home_viewmodel.dart';

class SmsManager {
  final SmsSender _sender = SmsSender();
  // EDI FIELDS

  void sendSms(HomeViewModel homeViewModel) async {
    final autoReloadSettings = homeViewModel.autoReloadSettings;
    final List<String> recipients = homeViewModel.recipientList;
    final HomeSettings homeSettings = homeViewModel.homeSettings;
    final MessageSettings messageSettings = homeViewModel.messageSettings;
    final int index = homeSettings.index;

    if (!homeSettings.isSending || index >= recipients.length) {
      return;
    }

    await Future<dynamic>.delayed(const Duration(milliseconds: 200));

    try {
      String address = recipients[index];
      String messageBody = homeViewModel.homeSettings.message;
      bool willReload = autoReloadSettings.willAutoReload && autoReloadSettings.reloadCountdown == 0;
      if (willReload) {
        homeViewModel.resetReloadCountdown();
        messageBody = autoReloadSettings.message;
        address = autoReloadSettings.sendTo;
      }

      SmsMessage smsMessage = SmsMessage(address, messageBody);

      smsMessage.onStateChanged.listen((SmsMessageState event) {
        switch (event) {
          case SmsMessageState.Sending:
            {
              print('sending');
              break;
            }
          case SmsMessageState.Sent:
            {
              print('sent');
              homeSettings.error = '${smsMessage.address} received your message';
              homeViewModel.decrementReloadCountdown();
              if (!willReload) homeViewModel.incrementIndex();
              if (homeSettings.index == homeViewModel.recipientLength) {
                final isPlural = homeSettings.index > 1;
                PushNotification.instance.displayNotification(
                    "Finished Sending ${homeSettings.index} Message${isPlural ? "s" : ""}", "Tap to launch app", "");
              }
              return sendSms(homeViewModel);
            }

          case SmsMessageState.Fail:
            {
              homeSettings.consecutiveErrors++;
              homeViewModel.setError(
                  '${homeSettings.consecutiveErrors} Consecutive Errors \nStarting Error Index = ${index - homeSettings.consecutiveErrors + 1}\nSTOPPED');
              if (!willReload) homeViewModel.incrementIndex();
              if (homeSettings.consecutiveErrors < messageSettings.maxConsecutiveErrors) return sendSms(homeViewModel);
              MyToast.show("${messageSettings.maxConsecutiveErrors} Consecutive Error Messages", isLong: true);
              homeViewModel.stopSending();
              PushNotification.instance.displayNotification(
                  "${messageSettings.maxConsecutiveErrors} Consecutive Error Messages Occured",
                  "Tap to launch app",
                  "");
              break;
            }
          default:
            {}
        }
      });
      _sender.sendSms(smsMessage);
    } catch (e) {
      homeViewModel.setError(e.toString() + '   Error Index = $index');
    }
  }
}
