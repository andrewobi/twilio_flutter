import 'package:twilio_flutter/src/shared/dto/twilio_messaging_service_creds.dart';

import '../../shared/dto/twilio_creds.dart';
import '../dto/message.dart';
import '../dto/sms_data.dart';

abstract class TwilioSMSService {
  Future<int> sendSMS(
      {required String toNumber,
      required String messageBody,
      required TwilioCreds twilioCreds,
      String? fromNumber});

  Future<SmsData> getSmsList(
      {required String? pageSize, required TwilioCreds twilioCreds});

  Future<Message> getSmsData(
      {required String messageSID, required TwilioCreds twilioCreds});

  Future<int> sendScheduledSms(
      {required String toNumber,
      required String messageBody,
      required TwilioMessagingServiceCreds twilioCreds,
      required String sendAt,
      String? fromNumber});

  Future<int> cancelScheduledSms({
    required String messageSid,
    required TwilioMessagingServiceCreds twilioCreds,
  });
}
