import 'package:clockify/api.dart';
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
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
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
            onTapOutside: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              child: Text('Sign In').sans(),
              onPressed: () async {
                print("Signing in User: [$user_]");
                APIService api = APIService();
                bool loggedIn = await api.apiLogin(user_: user_, pass_: pass_);
                if (!loggedIn) {
                  Widget buildToast(BuildContext context, ToastOverlay overlay) {
                    return SurfaceCard(
                      child: Basic(
                        title: const Text('Invalid BestHR Login').sans(),
                        trailing: PrimaryButton(
                            size: ButtonSize.small,
                            onPressed: () {
                              overlay.close();
                            },
                            child: const Text('Close').sans()),
                        trailingAlignment: Alignment.center,
                      ),
                    );
                  }

                  showToast(context: context, builder: buildToast, location: ToastLocation.bottomCenter);
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
