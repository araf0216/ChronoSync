import 'package:clockify/helpers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart';
// import 'data.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  final DateTime date;
  final TimeOfDay inTime;
  final TimeOfDay outTime;

  APIService({required this.date, required this.inTime, required this.outTime});

  Future<void> apiUpload() async {
    String dateStr = DateFormat("yyyy-MM-dd").format(date);
    String inTimeStr = "${dateStr}T${timeStrPost(inTime)}-05:00";
    String outTimeStr = "${dateStr}T${timeStrPost(outTime)}-05:00";

    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("user") ?? "",
        pass = prefs.getString("pass") ?? "";

    if (user.isEmpty || pass.isEmpty) {
      print("failed to find user when performing upload");
      return;
    }

    final Uri loginUrl =
        Uri.parse("https://www.besthrcloud.com/names.nsf?Login");

    final Uri formUrl = Uri.parse(
        "https://s3.besthrcloud.com/hrcloud/Timesheet045.nsf/CreatePastCheckInCheckoutEmployee.xsp");

    final Uri clockUrl = Uri.parse(
        "https://s3.besthrcloud.com/hrcloud/Timesheet045.nsf/CreatePastCheckInCheckoutEmployee.xsp?\$\$ajaxid=view:_id1:Message");

    Map<String, String> logData = {
      "Username": user,
      "Password": pass,
    };

    Map<String, String> clockData = {
      "view:_id1:inputText1": inTimeStr,
      "view:_id1:inputText2": outTimeStr,
      "view:_id1:comboBox2": "Final",
      "\$\$viewid": "vuid_v",
      "\$\$xspsubmitid": "view:_id1:eventHandler1",
      "view:_id1": "view:_id1",
    };

    String vuid = "", cookie = "";

    Client client = Client();

    Response response = await client.post(loginUrl, body: logData);

    Map<String, String> headers = {};

    if (response.statusCode == 302) {
      print("still redirecting");

      cookie = response.headers["set-cookie"] ?? cookie;
      cookie = cookie.split(";")[0];
      print("Cookie: $cookie");
      headers["Cookie"] = cookie;

      String redirUrl = response.headers["location"]!;

      response = await client.get(Uri.parse(redirUrl), headers: headers);
    }

    if (response.statusCode != 200) {
      print("full fail");
      return;
    }

    if (headers["Cookie"] == null) {
      print("something failed");
      return;
    }

    response = await client.get(formUrl, headers: headers);

    cookie = response.headers["set-cookie"] != null
        ? response.headers["set-cookie"]!.split(";")[0]
        : "";
    print(cookie);

    cookie =
        cookie != "" ? "${headers["Cookie"]}; $cookie" : headers["Cookie"]!;
    print("Updated cookie variable:\n$cookie");
    headers["Cookie"] = cookie;

    dom.Document doc = html.parse(response.body);

    dom.Element? vuidEl = doc.getElementById("view\\:_id1__VUID");

    if (vuidEl == null) {
      print("element not found");
      return;
    }

    vuid = vuidEl.attributes["value"]!;
    print(vuid);

    clockData["\$\$viewid"] = vuid;

    print("Ready to clock in for:");
    print(inTimeStr);
    print(outTimeStr);

    response = await client.post(clockUrl, body: clockData, headers: headers);

    print(response.statusCode);
  }
}
