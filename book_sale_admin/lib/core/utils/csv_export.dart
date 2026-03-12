import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Generates CSV content from headers and rows.
String generateCsv({
  required List<String> headers,
  required List<List<String>> rows,
}) {
  final buffer = StringBuffer();

  // Header row
  buffer.writeln(headers.map(_escapeCsvField).join(','));

  // Data rows
  for (final row in rows) {
    buffer.writeln(row.map(_escapeCsvField).join(','));
  }

  return buffer.toString();
}

/// Escapes a CSV field: wraps in quotes if it contains commas, quotes, or newlines.
String _escapeCsvField(String field) {
  if (field.contains(',') || field.contains('"') || field.contains('\n')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}

/// Triggers a CSV download in the browser (web) or returns bytes for sharing (mobile).
/// Returns the raw CSV bytes for platform-specific handling.
Uint8List csvToBytes(String csvContent) {
  return Uint8List.fromList(utf8.encode(csvContent));
}
