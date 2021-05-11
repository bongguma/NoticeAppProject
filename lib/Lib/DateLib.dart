import 'package:intl/intl.dart';

class DateLib {
  String formatDateYYYYMMDDHHMMSS() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

    String formattedDate = formatter.format(now);
    return formattedDate;
  }
}
