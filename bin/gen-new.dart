import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class OTPTokenGenerator {
  static const String hmacSha1Algorithm = "HmacSHA1";
  static const int timeStepSeconds = 30;
  static const int otpLength = 6;

  static String generateSecretKey() {
    var random = Random.secure();
    var bytes = List<int>.generate(20, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  static String generateTOTP(String secretKey) {
    int timeWindow = (DateTime.now().millisecondsSinceEpoch ~/ 1000) ~/ timeStepSeconds;
    List<int> keyBytes = base64.decode(secretKey);
    var hmac = Hmac(sha1, keyBytes);

    var hash = hmac.convert(_longToBytes(timeWindow)).bytes;

    // Dynamic Truncation
    int offset = hash[hash.length - 1] & 0xF;
    int truncatedHash = 0;
    for (int i = 0; i < 4; ++i) {
      truncatedHash <<= 8;
      truncatedHash |= (hash[offset + i] & 0xFF);
    }
    truncatedHash &= 0x7FFFFFFF;
    truncatedHash %= pow(10, otpLength).toInt();

    return truncatedHash.toString().padLeft(otpLength, '0');
  }

  static Uint8List _longToBytes(int value) {
    var result = Uint8List(8);
    for (int i = 7; i >= 0; i--) {
      result[i] = (value & 0xFF);
      value >>= 8;
    }
    return result;
  }
}

Future<void> main() async {
  /*String secretKey = OTPTokenGenerator.generateSecretKey();
  print("Secret Key: $secretKey");
  String otp = OTPTokenGenerator.generateTOTP(secretKey);
  print("OTP: $otp");*/

  while (true){
    String otp = OTPTokenGenerator.generateTOTP("x6lBGOgb/SWb8Fxa3SrLCAVoxGg=");
    print("OTP: $otp");

    DateTime now = DateTime.now();
    print("Current date and time: $now");


    await Future.delayed(Duration(seconds: 1));
  }
}
