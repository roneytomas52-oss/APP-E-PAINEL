import 'package:sixam_mart_delivery/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateConverterHelper {
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
  }

  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat('dd MMM yyyy  ${_timeFormatter()}').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    try {
      return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
    } catch(_) {
      return DateFormat('dd').format(DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime));
    }
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static DateTime convertStringToDatetime(String dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }

  static String isoStringToLocalTimeOnly(String dateTime) {
    return DateFormat(_timeFormatter()).format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalAMPM(String dateTime) {
    return DateFormat('a').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateAnTime(String dateTime) {
    return DateFormat('dd/MMM/yyyy ${_timeFormatter()}').format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter()).format(DateFormat('hh:mm:ss').parse(time));
  }

  // static int timeDistanceInMin(String time) {
  //   DateTime currentTime = Get.find<SplashController>().currentTime.toLocal();
  //   DateTime rangeTime = dateTimeStringToDate(time).toLocal();
  //   return currentTime.difference(rangeTime).inMinutes;
  // }

  static String timeDistanceInMin(String time) {
    final currentTime = Get.find<SplashController>().currentTime.toLocal();

    late DateTime rangeTime;
    try {
      rangeTime = DateTime.parse(time).toLocal(); // safest for Z-format times
    } catch (_) {
      rangeTime = convertStringToDatetime(time).toLocal();
    }

    final duration = currentTime.difference(rangeTime);

    if (duration.inSeconds < 60) {
      return "${duration.inSeconds} ${duration.inSeconds != 1 ? 'secs_ago'.tr : 'sec_ago'.tr}";
    } else if (duration.inMinutes < 60) {
      return "${duration.inMinutes} ${duration.inMinutes > 1 ? 'mins_ago'.tr : 'min_ago'.tr}";
    } else if (duration.inHours < 24) {
      return "${duration.inHours} ${duration.inHours > 1 ? 'hours_ago'.tr : 'hour_ago'.tr}";
    } else {
      return "${duration.inDays} ${duration.inDays > 1 ? 'days_ago'.tr : 'day_ago'.tr}";
    }
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel!.timeformat == '24' ? 'HH:mm' : 'hh:mm a';
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy ').format(dateTime.toLocal());
  }

  static String dateTimeStringForDisbursement(String time) {
    var newTime = '${time.substring(0,10)} ${time.substring(11,23)}';
    return DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime));
  }

  static String dateTimeForCoupon(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String convertTodayYesterdayDate(String createdAt) {
    final DateTime createdDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    if (createdDate.year == now.year && createdDate.month == now.month && createdDate.day == now.day) {
      return 'Today';
    }

    final DateTime yesterday = now.subtract(const Duration(days: 1));
    if (createdDate.year == yesterday.year && createdDate.month == yesterday.month && createdDate.day == yesterday.day) {
      return 'Yesterday';
    }

    return formatter.format(createdDate);
  }

  static String convertTimeDifferenceInMinutes(String createdAt) {
    final DateTime createdDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(createdAt);
    final DateTime now = DateTime.now();

    if (createdDate.year == now.year && createdDate.month == now.month && createdDate.day == now.day) {
      int differenceInMinutes = now.difference(createdDate).inMinutes;
      return '$differenceInMinutes ${'min_ago'.tr}';
    } else {
      return DateFormat('h:mm a').format(createdDate);
    }
  }

  static String utcToDateTime(String dateTime) {
    return DateFormat('dd MMM, yyyy h:mm a').format(DateTime.parse(dateTime).toLocal());
  }

  static String localDateToStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()}\nd-MMM-yyyy ').format(dateTime.toLocal());
  }

  static String formatUtcTime(String utcString) {
    DateTime dateTime = DateTime.parse(utcString).toLocal();

    final formatter = DateFormat('dd MMM yyyy ${_timeFormatter()}');
    return formatter.format(dateTime);
  }

  static String beforeTimeFormat(String time, {DateTime? now, int showFullDateThreshold = 30, bool isWithUTC = false}) {
    final currentTime = now ?? DateTime.now();
    DateTime pastTime = isWithUTC ? DateTime.parse(time) : dateTimeStringToDate(time);
    final Duration difference = currentTime.difference(pastTime);

    if (difference.isNegative) {
      return 'in the future';
    }

    final int seconds = difference.inSeconds;

    if (seconds < 60) {
      return 'just_now'.tr;
    }

    if (seconds < 86400) { // Less than 1 day
      final int totalMinutes = difference.inMinutes;
      final int hours = (totalMinutes / 60).floor();
      final int minutes = totalMinutes % 60;

      if (hours > 0) {
        final String hourText = '${hours}h';
        final String minuteText = minutes > 0 ? ' ${minutes}min' : '';
        return '$hourText$minuteText ${'ago'.tr}';
      } else {
        return '${minutes}min ${'ago'.tr}';
      }
    } else if (seconds < 604800) { // Less than 7 days
      final int totalHours = difference.inHours;
      final int days = (totalHours / 24).floor();
      final int hours = totalHours % 24;

      final String dayText = '${days}d';
      final String hourText = hours > 0 ? ' ${hours}h' : '';
      return '$dayText$hourText ${'ago'.tr}';
    }

    List<_TimeUnit> units = [
      _TimeUnit(cutoffSeconds: 2592000, unitName: 'week'.tr, conversionFactor: 604800),
      _TimeUnit(cutoffSeconds: 31536000, unitName: 'month'.tr, conversionFactor: 2592000),
      _TimeUnit(cutoffSeconds: 999999999999, unitName: 'year'.tr, conversionFactor: 31536000),
    ];

    for (final unit in units) {
      if (seconds < unit.cutoffSeconds) {
        final int value = (seconds / unit.conversionFactor).floor();
        return '$value ${unit.unitName.tr} ${'ago'.tr}';
      }
    }

    final int years = (seconds / 31536000).floor();
    return '$years ${'year'.tr} ${'ago'.tr}';
  }

  static String isoStringToDateTimeString(String dateTime) {
    return DateFormat('dd MMM yyyy  ${_timeFormatter()}').format(isoStringToLocalDate(dateTime));
  }

  static DateTime isoUtcStringToLocalTimeOnly(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime, true).toLocal();
  }

  static String isoStringToLocalDateAndTime(String dateTime) {
    return DateFormat('dd MMM yyyy \'at\' ${_timeFormatter()}').format(isoUtcStringToLocalTimeOnly(dateTime));
  }

  static int countDays(DateTime ? dateTime) {
    final startDate = dateTime!;
    final endDate = DateTime.now();
    final difference = endDate.difference(startDate).inDays;
    return difference;
  }

  static String convert24HourTimeTo12HourTimeWithDay(DateTime time, bool isToday) {
    if(isToday){
      return DateFormat('\'Today at\' ${_timeFormatter()}').format(time);
    }else{
      return DateFormat('\'Yesterday at\' ${_timeFormatter()}').format(time);
    }
  }

  static String convertStringTimeToDateTime (DateTime time){
    return DateFormat('EEE \'at\' ${_timeFormatter()}').format(time.toLocal());
  }

  static String stringDateTimeToTimeOnly(String dateTime) {
    return DateFormat(_timeFormatter()).format(DateFormat('yyyy-MM-dd HH:mm').parse(dateTime));
  }
  static String localToIsoString(DateTime dateTime) {
    return DateFormat('d MMMM, yyyy ').format(dateTime.toLocal());
  }

  static String dateTimeStringToMonthAndYear(String dateTime) {
    return DateFormat('MMM, yyyy').format(DateFormat('yyyy-MM-ddTHH:mm:ss').parse(dateTime));
  }
}

class _TimeUnit {
  final int cutoffSeconds;
  final String unitName;
  final int conversionFactor;

  const _TimeUnit({
    required this.cutoffSeconds,
    required this.unitName,
    required this.conversionFactor,
  });
}
