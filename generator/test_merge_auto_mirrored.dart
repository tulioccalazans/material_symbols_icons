/// Standalone test for the mergeAutoMirroredIconNames() logic in
/// update_metadata.dart.  Run with:  dart run test_merge_auto_mirrored.dart
/// Exits 0 on success, 1 on failure.
import 'dart:io';

import 'update_metadata.dart' show mergeAutoMirroredIconNames;

int failures = 0;

void expectSet(String description, Set<String> actual, Set<String> expected) {
  final missing = expected.difference(actual);
  final extra = actual.difference(expected);
  if (missing.isEmpty && extra.isEmpty) {
    print('PASS: $description');
  } else {
    failures++;
    print('FAIL: $description');
    if (missing.isNotEmpty) print('  missing: ${missing.join(", ")}');
    if (extra.isNotEmpty) print('  extra: ${extra.join(", ")}');
  }
}

void main() {
  // Icons not examined this run carry their previous status forward.
  expectSet(
    'unexamined icons carry forward from previous list',
    mergeAutoMirroredIconNames(
      previous: {'arrow_back', 'send', 'reply'},
      examined: {'battery_full'},
      detected: {},
      currentIconNames: {'arrow_back', 'send', 'reply', 'battery_full'},
    ),
    {'arrow_back', 'send', 'reply'},
  );

  // Newly detected icons are added.
  expectSet(
    'newly detected icon is added to the merged list',
    mergeAutoMirroredIconNames(
      previous: {'arrow_back'},
      examined: {'single_arrow'},
      detected: {'single_arrow'},
      currentIconNames: {'arrow_back', 'single_arrow'},
    ),
    {'arrow_back', 'single_arrow'},
  );

  // An icon examined this run and NOT detected loses its status
  // (fresh detection is authoritative for examined icons).
  expectSet(
    'examined icon no longer detected is removed',
    mergeAutoMirroredIconNames(
      previous: {'arrow_back', 'send'},
      examined: {'send'},
      detected: {},
      currentIconNames: {'arrow_back', 'send'},
    ),
    {'arrow_back'},
  );

  // Icons no longer in the current icon set are dropped.
  expectSet(
    'icons removed from the font are dropped',
    mergeAutoMirroredIconNames(
      previous: {'arrow_back', 'retired_icon'},
      examined: {},
      detected: {},
      currentIconNames: {'arrow_back'},
    ),
    {'arrow_back'},
  );

  // Full --overwrite style run: everything examined, detections win outright.
  expectSet(
    'full run replaces previous list with detections',
    mergeAutoMirroredIconNames(
      previous: {'arrow_back', 'stale'},
      examined: {'arrow_back', 'stale', 'send'},
      detected: {'arrow_back', 'send'},
      currentIconNames: {'arrow_back', 'stale', 'send'},
    ),
    {'arrow_back', 'send'},
  );

  if (failures > 0) {
    print('$failures test(s) FAILED');
    exit(1);
  }
  print('All tests passed.');
}
