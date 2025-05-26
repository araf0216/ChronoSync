import 'package:chronosync/encryption.dart';
import 'package:chronosync/helpers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';

class APIService {
  APIService();

  final Uri loginUrl = Uri.parse("https://www.besthrcloud.com/names.nsf?Login");

  final Uri formUrl = Uri.parse(
      "https://s3.besthrcloud.com/hrcloud/Timesheet045.nsf/CreatePastCheckInCheckoutEmployee.xsp");

  final Uri clockUrl = Uri.parse(
      "https://s3.besthrcloud.com/hrcloud/Timesheet045.nsf/CreatePastCheckInCheckoutEmployee.xsp?\$\$ajaxid=view:_id1:Message");

  Client client = Client();
  Map<String, String> headers = {};
  late Response response;

  String vuid = "", cookie = "";

  Future<bool> apiLogin({String? user_, String? pass_}) async {
    String user, pass;
    bool terminate = false;

    if (user_ != null && pass_ != null) {
      user = user_;
      pass = pass_;
      terminate = true;
    } else {
      // SecureDataCache instance (loaded on userset)
      user = SecureDataCache.single.user ?? "";
      pass = SecureDataCache.single.pass ?? "";
    }

    if (user.isEmpty || pass.isEmpty) {
      // print("failed to find user when logging in");
      client.close();
      return false;
    }

    Map<String, String> logData = {
      "Username": user,
      "Password": pass,
    };

    response = await client.post(loginUrl, body: logData);

    if (response.statusCode == 302) {
      // print("still redirecting");

      cookie = response.headers["set-cookie"] ?? cookie;
      cookie = cookie.split(";")[0];
      // print("Cookie: $cookie");
      headers["Cookie"] = cookie;

      String redirUrl = response.headers["location"]!;

      response = await client.get(Uri.parse(redirUrl), headers: headers);
    }

    if (response.statusCode != 200) {
      // print("full fail");
      client.close();
      return false;
    }

    if (headers["Cookie"] == null) {
      // print("something failed");
      client.close();
      return false;
    }

    response = await client.get(formUrl, headers: headers);

    cookie = response.headers["set-cookie"] != null
        ? response.headers["set-cookie"]!.split(";")[0]
        : "";

    cookie =
        cookie != "" ? "${headers["Cookie"]}; $cookie" : headers["Cookie"]!;
    headers["Cookie"] = cookie;

    dom.Document doc = html.parse(response.body);

    dom.Element? vuidEl = doc.getElementById("view\\:_id1__VUID");

    if (vuidEl == null) {
      // print("element not found - failed to log in");
      client.close();
      return false;
    }

    vuid = vuidEl.attributes["value"]!;
    // print(vuid);

    if (terminate) {
      client.close();
    }

    return true;
  }

  Future<void> apiUpload(
      {required DateTime date,
      required TimeOfDay inTime,
      required TimeOfDay outTime}) async {
    bool loggedIn = await apiLogin();

    if (!loggedIn) {
      // print("something went wrong logging in");
      client.close();
      return;
    }

    String dateStr = DateFormat("yyyy-MM-dd").format(date);
    String inTimeStr = "${dateStr}T${timeStrPost(inTime)}-05:00";
    String outTimeStr = "${dateStr}T${timeStrPost(outTime)}-05:00";

    Map<String, String> clockData = {
      "view:_id1:inputText1": inTimeStr,
      "view:_id1:inputText2": outTimeStr,
      "view:_id1:comboBox2": "Final",
      "\$\$viewid": "vuid_v",
      "\$\$xspsubmitid": "view:_id1:eventHandler1",
      "view:_id1": "view:_id1",
    };

    clockData["\$\$viewid"] = vuid;

    // print("Ready to clock in for:");
    // print(inTimeStr);
    // print(outTimeStr);

    response = await client.post(clockUrl, body: clockData, headers: headers);

    // print(response.statusCode);
    client.close();
    return;
  }
}
