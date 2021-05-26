import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mass_text_flutter/models/user.dart';
import 'package:mass_text_flutter/pages/premium_screen.dart';
import 'package:mass_text_flutter/services/auth.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/shared/bouncing_button.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:mass_text_flutter/shared/settingsVariable.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:mass_text_flutter/view/home_viewmodel.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<ContactsViewModel>(context, listen: false).loadData().then((_) => setState(() => {}));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _premiumViewModel = Provider.of<PremiumViewModel>(context, listen: false);
    final _contactsViewModel = Provider.of<ContactsViewModel>(context, listen: false);
    final _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final _auth = AuthService();
    final _homeSettings = _homeViewModel.homeSettings;
    final _messageSettings = _homeViewModel.messageSettings;
    final _autoReloadSettings = _homeViewModel.autoReloadSettings;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 16),
          PremiumScreen(),
          SizedBox(height: 16),
          SettingsBlock(
            "Message",
            [
              SettingsTile("Change index to", Builder(
                builder: (context) {
                  Provider.of<HomeViewModel>(context);
                  return SettingsTextField(
                    _homeSettings.index.toString(),
                    (newIndex) {
                      _homeViewModel.changeIndex(int.tryParse(newIndex) ?? 0);
                    },
                    willChangeKey: true,
                    textFieldKey: SettingsVariable.instance.messageIndex.toString(),
                    onTap: () => _homeSettings.isSending = false,
                  );
                },
              )),
              SettingsTile(
                  "Consecutive errors before stopping",
                  SettingsTextField(_messageSettings.maxConsecutiveErrors.toString(), (newVal) {
                    _homeViewModel.changeMaxConsecutiveErrors(int.tryParse(newVal) ?? 5);
                  }, charLimit: 6, format: "[0-9]")),
              if (_premiumViewModel.isPremium()) ...[
                SettingsTile(
                    "Has character limit",
                    SettingsCheckBox(_messageSettings.hasCharLimit, (isChecked) {
                      FocusScope.of(context).unfocus();
                      _homeViewModel.toggleHasCharLimit();
                      setState(() {});
                    }),
                    isPremium: true),

                // if (_homeViewModel.messageSettings.hasCharLimit)
                AnimatedHider(
                  _messageSettings.hasCharLimit,
                  SettingsTile(
                      "Character limit",
                      SettingsTextField(_messageSettings.charLimit.toString(),
                          (newVal) => _homeViewModel.changeCharLimit(int.tryParse(newVal) ?? 150)),
                      isPremium: true),
                ),
              ],
            ],
            top: 0,
          ),
          SettingsBlock(
            "Phone Number Format",
            [
              Builder(
                builder: (context) {
                  final _contactsViewModel = Provider.of<ContactsViewModel>(context);
                  final _phoneFormatSettings = _contactsViewModel.phoneFormatSettings;
                  final _trailingLength = _phoneFormatSettings.trailingLength;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                        child: Text(
                      "+${_phoneFormatSettings.prefix} ${Constants.allowedPhoneNumbersLength[_trailingLength]}",
                      style: TextStyles.medium.weight(FontWeight.w300).copyWith(wordSpacing: 5),
                    )),
                  );
                },
              ),
              Divider(color: MyColors.divider, indent: 16, endIndent: 16),

              SettingsTile(
                "Country Code Prefix",
                Container(
                  // width: double.minPositive,
                  child: CountryCodePicker(
                    onChanged: (cc) =>
                        _contactsViewModel.changePrefix(cc.dialCode.substring(1, cc.dialCode.length) ?? "63"),
                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    initialSelection: 'PH',
                    // optional. Shows only country name and flag
                    showCountryOnly: false,
                    // optional. Shows only country name and flag when popup is closed.
                    showOnlyCountryWhenClosed: false,
                    // optional. aligns the flag and the Text left
                    alignLeft: false,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black54,
                    boxDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      color: MyColors.violet,
                    ),
                    searchDecoration: Styles.myInputDecoration().copyWith(
                      prefixIcon: Icon(Icons.search, color: MyColors.violetLighter),
                    ),
                    closeIcon: Icon(Icons.close, color: MyColors.violetLighter, size: 24),
                    dialogSize: Size(MediaQuery.of(context).size.width - 100, MediaQuery.of(context).size.height - 200),
                    searchStyle: TextStyles.medium,
                    textStyle: TextStyles.medium,
                    dialogTextStyle: TextStyles.small.size(14).weight(FontWeight.w300),
                  ),
                ),
              ),
              // SettingsTile(
              //     "Country Code Prefix",
              //     SettingsTextField(_phoneFormatSettings.prefix, (newVal) => _contactsViewModel.changePrefix(newVal),
              //         charLimit: 6, format: "[0-9]", keyboardType: TextInputType.phone, prefix: "+")),
              SettingsTile(
                "Length of trailing numbers",
                Builder(
                  builder: (context) {
                    Provider.of<ContactsViewModel>(context);
                    final _contactsViewModel = Provider.of<ContactsViewModel>(context);
                    final _phoneFormatSettings = _contactsViewModel.phoneFormatSettings;
                    return DropdownButton(
                      dropdownColor: MyColors.violetDark,
                      value: _phoneFormatSettings.trailingLength,
                      iconEnabledColor: Colors.purpleAccent,
                      isDense: true,
                      onTap: () => FocusScope.of(context).unfocus(),
                      items: Constants.allowedPhoneNumbersLength.keys
                          .toList()
                          .map((el) => DropdownMenuItem(child: Text("${el}", style: TextStyles.medium), value: el))
                          .toList(),
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        if (_phoneFormatSettings.trailingLength == value) return;
                        _contactsViewModel.changeTrailingLength(value);
                      },
                    );
                  },
                ),
              ),
            ],
            help: "This ensures that all added phone numbers are in the valid format.",
          ),
          SettingsBlock(
            "Auto ReLoad",
            [
              SettingsTile(
                  "Will reLoad automatically",
                  SettingsCheckBox(_autoReloadSettings.willAutoReload, (isChecked) {
                    FocusScope.of(context).unfocus();
                    _homeViewModel.toggleWillAutoReload();
                    setState(() {});
                  })),
              // if (_homeViewModel.autoReloadSettings.willAutoReload)
              AnimatedHider(
                _homeViewModel.autoReloadSettings.willAutoReload,
                Column(children: _autoReloadTiles(_homeViewModel)),
                height: 70 * 4.0,
              ),
            ],
            help:
                "This sends a specific message to a chosen recipient after sending some number of messages. This is especially useful for registering unlimited texts to your provider.",
          ),
          SettingsBlock(
            "Account",
            [
              Builder(
                builder: (context) {
                  final user = Provider.of<MyUser>(context);
                  String email = user == null ? "NaN" : (user.email ?? "NaN");
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                        child: Text(
                      email,
                      style: TextStyles.medium.weight(FontWeight.w300).copyWith(wordSpacing: 5),
                    )),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: BouncingButton(
                  "LOG OUT",
                  () async {
                    bool success = await _auth.signOut();
                    if (success) Navigator.pushReplacementNamed(context, Constants.LoginRoute);
                  },
                  width: double.infinity,
                  height: 40,
                  color: Color(0xFF181818),
                  labelColor: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              Center(child: Text("Mass Text v 1.0.0", style: TextStyle(color: Color(0xFF929292), fontSize: 12))),
              // if (_homeViewModel.autoReloadSettings.willAutoReload)
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<SettingsTile> _autoReloadTiles(HomeViewModel homeViewModel) {
    final _autoReloadSettings = homeViewModel.autoReloadSettings;
    return [
      SettingsTile("Change index to", Builder(
        builder: (context) {
          Provider.of<HomeViewModel>(context);
          return SettingsTextField(
            _autoReloadSettings.reloadCountdown.toString(),
            (newIndex) {
              homeViewModel.changeAutoReloadIndex(int.tryParse(newIndex) ?? 850);
            },
            willChangeKey: true,
            textFieldKey: SettingsVariable.instance.autoReloadIndex.toString(),
          );
        },
      )),
      SettingsTile(
          "Occurs every",
          SettingsTextField(_autoReloadSettings.totalReloadCountdown.toString(), (newTotal) {
            homeViewModel.changeTotalReloadCountdown(int.tryParse(newTotal) ?? 850);
          }, suffix: "txt")),
      SettingsTile(
          "Message",
          SettingsTextField(_autoReloadSettings.message, (newMessage) {
            homeViewModel.changeAutoReloadMessage(newMessage ?? "GOCOMBOAHBFA14");
          }, charLimit: 200, format: "[a-zA-Z0-9]", keyboardType: TextInputType.text, width: 180)),
      SettingsTile(
          "Send to",
          SettingsTextField(_autoReloadSettings.sendTo, (newSendTo) {
            homeViewModel.changeSendTo(newSendTo ?? "8080");
          }, format: "[0-9+]", keyboardType: TextInputType.phone, charLimit: 20, width: 180)),
    ];
  }

  @override
  bool get wantKeepAlive => true;
}

class AnimatedHider extends StatelessWidget {
  AnimatedHider(this.show, this.child, {this.height = 70});
  final bool show;
  final Widget child;
  final double height;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: show ? height : 0,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  SettingsBlock(this.title, this.tiles, {this.top = 48, this.help});
  final String title;
  final List<Widget> tiles;
  final double top;
  final String help;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: top),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: MyColors.violetDark,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyles.medium.colour(Colors.white70)),
                  if (help != null)
                    GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                backgroundColor: MyColors.violet,
                                // title: Text("Confirm Restart", style: TextStyles.medium.size(22)),
                                content: Text(help, style: TextStyles.medium.size(18)),
                                actions: [MyTextButton(text: "Close", onPressed: () => Navigator.pop(context))],
                              ));
                        },
                        child: Icon(Icons.info_outline, color: Colors.white70)),
                ],
              )),
        ),

        ListView.builder(
          itemCount: tiles.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => tiles[index],
          // separatorBuilder: (context, index) => Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Divider(color: MyColors.divider),
          // ),
        )
        // ...tiles,
        // Divider(color: Color(0xFFB29ECF), height: 0),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  SettingsTile(this.title, this.trailing, {this.isPremium = false});

  final String title;
  final Widget trailing;
  final bool isPremium;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 70,
        child: Column(children: [
          ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              title: Wrap(children: [
                Text(title, style: TextStyles.medium),
                SizedBox(width: 8),
                if (isPremium) SizedBox(width: 24, height: 24, child: Image.asset("assets/diamond_orange.png"))
              ]),
              trailing: trailing),
          Divider(color: MyColors.divider),
        ]),
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  SettingsTextField(
    this.initialValue,
    this.onChanged, {
    this.suffix = "",
    this.charLimit = 6,
    this.format = "[0-9]",
    this.keyboardType = TextInputType.number,
    this.width = 100,
    this.prefix = "",
    this.willChangeKey = false,
    this.textFieldKey = "",
    this.isEnabled = true,
    this.onTap = null,
  });
  final String initialValue;
  final Function(String) onChanged;
  final String suffix;
  final String prefix;
  final int charLimit;
  final String format;
  final TextInputType keyboardType;
  final double width;
  final bool willChangeKey;
  final String textFieldKey;
  final bool isEnabled;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    String initVal = initialValue;
    return Container(
      alignment: Alignment.centerRight,
      width: width,
      height: 30,
      child: TextFormField(
        key: Key(willChangeKey ? textFieldKey : initVal),
        enabled: isEnabled,
        initialValue: initVal,
        decoration: Styles.myInputDecoration(padding: EdgeInsets.all(6)).copyWith(
          suffixStyle: TextStyles.small.weight(FontWeight.w300).size(10),
          suffixText: suffix,
          prefixStyle: TextStyles.medium,
          prefixText: prefix,
        ),
        textAlign: TextAlign.right,
        style: TextStyles.medium,
        inputFormatters: [
          LengthLimitingTextInputFormatter(charLimit),
          FilteringTextInputFormatter.allow(RegExp(format))
        ],
        keyboardType: keyboardType,
        onTap: onTap,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsCheckBox extends StatefulWidget {
  SettingsCheckBox(this.initialValue, this.onChanged);
  final bool initialValue;
  final Function(bool) onChanged;
  @override
  _SettingsCheckBoxState createState() => _SettingsCheckBoxState();
}

class _SettingsCheckBoxState extends State<SettingsCheckBox> {
  bool isChecked;
  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isChecked,
      onChanged: (isCheckedNew) {
        isChecked = isCheckedNew;
        widget.onChanged(isCheckedNew);
      },
      activeColor: MyColors.violetLighter,
    );
  }
}
