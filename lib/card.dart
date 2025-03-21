import 'dart:ui';

import 'package:shadcn_flutter/shadcn_flutter.dart';

String user_ = "", pass_ = "";

@override
Widget loginCard(BuildContext context, Function(String, String) setUser) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width * 0.8,
    child: Card(
      borderColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Account').semiBold().sans().h4(),
          SizedBox(height: 4),
          Text('Sign in with BestHR').muted().small().sans(),
          SizedBox(height: 24),
          Text('Email').semiBold().small().sans(),
          SizedBox(height: 4),
          TextField(
            placeholder: Text('Your SMC email').sans(),
            onChanged: (value) {
              user_ = value;
            },
            onTap: () {
              print("$user_ - $pass_");
            },
            onTapOutside: (event) {
              print("$user_ - $pass_");
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onSubmitted: (value) => print("$user_ - $pass_"),
          ),
          SizedBox(height: 16),
          Text('Password').semiBold().small().sans(),
          SizedBox(height: 4),
          TextField(
            placeholder: Text('Your BestHR password').sans(),
            obscureText: true,
            onChanged: (value) {
              pass_ = value;
            },
            onTap: () {
              print("$user_ - $pass_");
            },
            onTapOutside: (event) {
              print("$user_ - $pass_");
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onSubmitted: (value) => print("$user_ - $pass_"),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              child: Text('Sign In').sans(),
              onPressed: () {
                print("Signing in with User: $user_ & Pass: $pass_");
                setUser(user_, pass_);
                user_ = "";
                pass_ = "";
              },
            ),
          ),
        ],
      ),
    ),
  );
}
