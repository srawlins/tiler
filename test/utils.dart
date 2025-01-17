import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:tiler/tiler.dart';

/// A bundle for tests.
final _DiskAssetBundle testBundle = _DiskAssetBundle('test');

void testMapRender(
  String mapName, {
  String? goldenName,
  Offset offset = Offset.zero,
  Size size = const Size(1000, 1000),
  double scale = 1.0,
}) {
  testWidgets(mapName, (tester) async {
    await expectMapRender(tester, mapName, goldenName, offset, size, scale);
  });
}

Future<void> expectMapRender(
  WidgetTester tester,
  String mapName,
  String? goldenName,
  Offset offset,
  Size size,
  double scale,
) async {
  final map = (await tester.runAsync(
    () => loadMap(testBundle, mapFile(mapName)),
  ))!;

  await tester.pumpWidget(
    RepaintBoundary(child: TileMap(map, offset, size, scale: scale)),
  );

  // TODO: Find a way to make goldens the same across platforms). For now, just
  // run on Windows+macOS where I can easily update.
  if (Platform.isWindows || Platform.isMacOS) {
    await expectLater(
      find.byType(RepaintBoundary),
      matchesGoldenFile(goldenFile(goldenName ?? mapName)),
    );
  }
}

String goldenFile(String name) =>
    'test-maps/${name}_${Platform.operatingSystem}.png';

String mapFile(String name) => 'test-maps/$name.json';

class _DiskAssetBundle extends AssetBundle {
  final String rootFolder;
  _DiskAssetBundle(this.rootFolder);

  @override
  Future<ByteData> load(String key) async {
    final file = File(path.normalize(path.join(rootFolder, key)));
    assert(file.existsSync());
    final bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<T> loadStructuredData<T>(
          String key, Future<T> Function(String value) parser) =>
      throw UnimplementedError();
}
