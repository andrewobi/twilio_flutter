library twilio_flutter;

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:twilio_flutter/src/models/sent_sms_data.dart';
import 'package:twilio_flutter/src/models/sms.dart';
import 'package:twilio_flutter/src/models/twilio_creds.dart';
import 'package:twilio_flutter/src/repositories/twilio_sms_repository.dart';
import 'package:twilio_flutter/src/services/network.dart';
import 'package:twilio_flutter/src/utils/utils.dart';

class TwilioFlutter {
  TwilioSmsRepository _smsRepository;
  TwilioCreds _twilioCreds;

  /// Creates a TwilioFlutter Object with [accountSid] , [authToken] , [twilioNumber].
  /// [accountSid] , [authToken] , [twilioNumber]  Your Account Sid and Auth Token from twilio.com/console
  ///  Should be not null Strings.
  ///
  /// [twilioNumber] can later be changed.
  TwilioFlutter(
      {@required String accountSid,
      @required String authToken,
      @required String twilioNumber})
      : assert(
            accountSid != null && authToken != null && twilioNumber != null) {
    _smsRepository = TwilioSMSRepositoryImpl();

    String uri =
        '${Utils.baseUri}/${Utils.version}/Accounts/$accountSid/Messages.json';
    String creds = '$accountSid:$authToken';
    _twilioCreds = TwilioCreds(
        accountSid: accountSid,
        authToken: authToken,
        twilioNumber: twilioNumber,
        url: uri,
        cred: creds);
  }

  ///	sendSMS
  ///	 [toNumber] : The number to which text message has to be sent.
  ///	 [messageBody] : The content of the message to be sent.
  ///
  ///	Method called to send text messages to the specified phone number with given content.
  ///
  /// Returns
  ///	201 -> message sent successfully.
  ///
  ///	For more status codes refer
  /// * https://www.twilio.com/docs/api/errors
  Future<int> sendSMS(
      {@required String toNumber, @required String messageBody}) async {
    return await _smsRepository.sendSMS(
        toNumber: toNumber,
        messageBody: messageBody,
        twilioCreds: _twilioCreds);
  }

  /// changeTwilioNumber
  /// [twilioNumber] : A non-null value for new twilio number
  void changeTwilioNumber(String twilioNumber) {
    this._twilioCreds.twilioNumber = twilioNumber;
  }

  sendWhatsApp(
      {@required String toNumber, @required String messageBody}) async {
    String cred = _twilioCreds.cred;

    var bytes = utf8.encode(cred);
    var base64Str = base64.encode(bytes);
    var headers = {
      'Authorization': 'Basic $base64Str',
      'Accept': 'application/json'
    };
    var body = {
      'From': 'whatsapp:' + _twilioCreds.twilioNumber,
      'To': 'whatsapp:' + toNumber,
      'Body': messageBody
    };

    NetworkHelper.postMessageRequest(_twilioCreds.url, headers, body);
  }

  /// Get all messages associated with your account
  /// Pass [pageSize] to get specific page sizes.
  /// [pageSize] value defaults to 20
  Future<SentSmsData> getSmsList({String pageSize}) async {
    return await _smsRepository.getSmsList(
        pageSize: pageSize ?? '20', twilioCreds: _twilioCreds);
  }

  /// Get all data of a specific message
  /// Pass [messageSid] as a non null Message SID.
  Future<Message> getSMS(String messageSid) async {
    return await _smsRepository.getSmsData(
        messageSID: messageSid, twilioCreds: _twilioCreds);
  }

  @deprecated
  Future getSMSList(String url) async {
    var data = await NetworkHelper.getRequest(url);
    List<SMS> smsList = [];
    var messages = data['messages'];
    for (var message in messages) {
      SMS sms = SMS();
      sms.body = message['body'];
      sms.dateCreated = message['date_created'];
      sms.dateSent = message['date_sent'];
      sms.direction = message['direction'];
      sms.errorMessage = message['error_message'];
      sms.from = message['from'];
      sms.to = message['to'];
      sms.messageSid = message['sid'];
      sms.messageURL = message['uri'];
      sms.status = message['status'];
      smsList.add(sms);
    }
    if (smsList.isEmpty) print('Failed');
    return smsList;
  }
}
