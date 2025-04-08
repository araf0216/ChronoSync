import 'package:chronosync/api.dart';
import 'package:chronosync/helpers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

String user_ = "", pass_ = "";

@override
Widget loginCard(BuildContext context, Function(String, String) setUser,
    Function([String]) viewUpdate) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width * 0.8,
    child: Card(
      borderColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Account').semiBold().sans().h4(),
          Gap(4),
          Text('Sign in with BestHR').muted().small().sans(),
          Gap(24),
          Text('Email').semiBold().small().sans(),
          Gap(4),
          TextField(
            placeholder: Text('Your SMC email').sans(),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              user_ = value;
            },
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          Gap(16),
          Text('Password').semiBold().small().sans(),
          Gap(4),
          TextField(
            placeholder: Text('Your BestHR password').sans(),
            obscureText: true,
            onChanged: (value) {
              pass_ = value;
            },
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          Gap(24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              child:
                  Text('Sign In', textScaler: TextScaler.linear(1.15)).sans(),
              onPressed: () async {
                // print("Signing in User: [$user_]");
                APIService api = APIService();
                bool loggedIn = await api.apiLogin(user_: user_, pass_: pass_);
                if (!loggedIn) {
                  if (!context.mounted) return;
                  showToast(
                    context: context,
                    builder: buildToast('Invalid BestHR Login', true),
                    location: ToastLocation.bottomCenter,
                  );
                  return;
                }
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
