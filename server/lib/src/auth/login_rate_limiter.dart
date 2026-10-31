import 'dart:collection';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// All login rate limit settings live here.
const loginRateWindow = Duration(seconds: 60);
const loginRatePerKeyLimit = 30;
const loginRateGlobalLimit = 300;
const loginRateMaxKeys = 10000;

/// Key used when no trustworthy client address is available. It is subject
/// to the global limit only.
const loginRateGlobalKey = 'global';

/// In-memory sliding-window limiter for unauthenticated login starts.
///
/// Limits are per server instance: with N instances the effective limit is
/// N times the configured values. The key is the rightmost X-Forwarded-For
/// entry (the one appended by the proxy); client-supplied entries to its left
/// are not trusted. The socket peer address is never used: behind the Cloud
/// proxy every caller would share one bucket. Addresses are never logged.
class LoginRateLimiter {
  LoginRateLimiter({
    this.clock = const Clock(),
    this.perKeyLimit = loginRatePerKeyLimit,
    this.globalLimit = loginRateGlobalLimit,
  });

  final Clock clock;
  final int perKeyLimit;
  final int globalLimit;
  final _global = Queue<DateTime>();
  final _byKey = <String, Queue<DateTime>>{};

  /// Throws `LoginException(code: 'tooManyAttempts')` when over the limit.
  void check(Session session) => checkKey(keyFor(session.request?.headers));

  /// Rightmost X-Forwarded-For entry when it is a valid IP, else
  /// [loginRateGlobalKey]. Never throws on malformed input.
  static String keyFor(Map<String, Iterable<String>>? headers) {
    final values = headers?['x-forwarded-for'];
    if (values == null || values.isEmpty) return loginRateGlobalKey;
    final last = values.join(',').split(',').last.trim();
    final address = InternetAddress.tryParse(last);
    return address == null ? loginRateGlobalKey : address.address;
  }

  void checkKey(String key) {
    final now = clock.now();
    final cutoff = now.subtract(loginRateWindow);
    _prune(_global, cutoff);
    if (_global.length >= globalLimit) _reject();
    Queue<DateTime>? hits;
    if (key != loginRateGlobalKey) {
      hits = _byKey[key];
      if (hits != null) {
        _prune(hits, cutoff);
        if (hits.length >= perKeyLimit) _reject();
      } else {
        if (_byKey.length >= loginRateMaxKeys) _evict(cutoff);
        hits = _byKey[key] = Queue<DateTime>();
      }
    }
    _global.add(now);
    hits?.add(now);
  }

  /// Number of tracked keys; exposed for the memory bound test.
  int get trackedKeys => _byKey.length;

  void _evict(DateTime cutoff) {
    _byKey.removeWhere((_, hits) {
      _prune(hits, cutoff);
      return hits.isEmpty;
    });
    // Still full: drop the oldest-inserted keys to keep memory bounded.
    while (_byKey.length >= loginRateMaxKeys) {
      _byKey.remove(_byKey.keys.first);
    }
  }

  static void _prune(Queue<DateTime> hits, DateTime cutoff) {
    while (hits.isNotEmpty && !hits.first.isAfter(cutoff)) {
      hits.removeFirst();
    }
  }

  static Never _reject() => throw LoginException(code: 'tooManyAttempts');
}
