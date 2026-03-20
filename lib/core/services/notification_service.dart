import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<String?> pendingRoute = ValueNotifier<String?>(null);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final initialPayload = launchDetails?.didNotificationLaunchApp == true
        ? launchDetails?.notificationResponse?.payload
        : null;
    _setPendingReviewRoute(initialPayload);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await initialize();

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleWorryReminder({
    required String worryId,
    required String content,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    final now = DateTime.now();
    if (!scheduledAt.isAfter(now)) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'worry_review_channel',
        '걱정 다시 보기',
        channelDescription: '설정한 시간이 되면 다시 볼 걱정을 알려줍니다.',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _notificationIdFor(worryId),
      '다시 꺼내볼 시간이에요',
      _bodyFor(content),
      tz.TZDateTime.from(scheduledAt, tz.UTC),
      details,
      payload: worryId,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelWorryReminder(String worryId) async {
    await initialize();
    await _plugin.cancel(_notificationIdFor(worryId));
  }

  int _notificationIdFor(String worryId) {
    return worryId.codeUnits.fold<int>(
      0,
      (value, unit) => (value * 31 + unit) & 0x7fffffff,
    );
  }

  void clearPendingRoute() {
    pendingRoute.value = null;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _setPendingReviewRoute(response.payload);
  }

  void _setPendingReviewRoute(String? worryId) {
    final trimmed = worryId?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    pendingRoute.value = '/review/$trimmed';
  }

  String _bodyFor(String content) {
    final trimmed = content.trim().replaceAll('\n', ' ');
    if (trimmed.isEmpty) return '그때의 마음을 다시 확인해보세요.';
    if (trimmed.length <= 45) return trimmed;
    return '${trimmed.substring(0, 45)}...';
  }
}
