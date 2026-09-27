import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:utm_pawsitive/core/cat_matching_service.dart';
import 'package:utm_pawsitive/core/image_util.dart';
import 'package:utm_pawsitive/core/workflows.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'treasury excludes pending receipts and duplicate legacy shop donations',
    () {
      expect(
        verifiedTotal([
          {'amount': 20, 'status': 'verified', 'source': 'manual'},
          {'amount': 90, 'status': 'pending'},
          {'amount': 20, 'status': 'paid', 'source': 'shop_checkout'},
          {'amount': 50, 'status': 'verified', 'refundedCents': 1000},
          {'amount': 100, 'status': 'refunded'},
        ], 'amount'),
        60,
      );
    },
  );
  test(
    'drafts survive store recreation and are isolated between users',
    () async {
      SharedPreferences.setMockInitialValues({});
      await ReportDraftStore(
        'one',
      ).save({'requestId': 'same-id', 'location': 'Library'});
      expect((await ReportDraftStore('one').load())?['requestId'], 'same-id');
      expect(await ReportDraftStore('two').load(), isNull);
      await ReportDraftStore('one').clear();
      expect(await ReportDraftStore('one').load(), isNull);
    },
  );
  test('image signatures operate on decoded pixels and have finite values', () {
    final pixels = img.Image(width: 64, height: 64);
    img.fill(pixels, color: img.ColorRgb8(180, 100, 50));
    final sig = CatMatchingService.instance.buildSignature(
      Uint8List.fromList(img.encodePng(pixels)),
    );
    expect(sig.length, 128);
    expect(sig.every((v) => v.isFinite), isTrue);
    expect(sig.any((v) => v > 0), isTrue);
    expect(ImageUtil.encodeThumbnail(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
