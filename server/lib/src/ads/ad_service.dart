import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../product/product_service.dart';
import '../quiz/quiz_service.dart';
import 'ad_config.dart';
import 'ad_verifier.dart';

class AdService {
  AdService(this.config, this.verifier, {this.clock = const Clock()});
  final AdConfig config;
  final AdVerifier verifier;
  final Clock clock;
  static final instances = Expando<AdService>();
  static const eventLifetime = Duration(hours: 1);
  static const deliveryGrace = Duration(days: 7);
  static const futureSkew = Duration(minutes: 5);

  AdIntent view(StoredAdIntent i) => AdIntent(
    id: i.nonce,
    purpose: i.purpose,
    targetDate: i.targetDate,
    targetRevision: i.targetRevision,
    adUnit: i.adUnit,
    userId: i.owner,
    customData: i.nonce,
    status:
        i.status == 'pending' && !clock.now().toUtc().isBefore(i.acceptUntil)
        ? 'expired'
        : i.status,
    createdAt: i.createdAt,
    eventExpiresAt: i.eventExpiresAt,
    acceptUntil: i.acceptUntil,
    verifiedAt: i.verifiedAt,
    consumedAt: i.consumedAt,
  );

  Future<AdIntent> create(
    ProductService s,
    String purpose,
    String date,
    int revision,
    AdPlatform platform,
  ) async {
    final eligibilityClock = Clock.fixed(clock.now());
    final placement = config.placements[purpose];
    if (placement == null) throw AdException(code: 'purposeUnconfigured');
    dayStart(date);
    if (revision < 0 || date.compareTo(localDate(eligibilityClock.now())) > 0) {
      throw AdException(code: 'invalidTarget');
    }
    if (purpose == 'extraQuiz') {
      await withClock(
        eligibilityClock,
        () => QuizService(s).extraTarget(date, revision),
      );
    }
    final previous = await StoredAdIntent.db.findFirstRow(
      s.session,
      where: (t) =>
          t.owner.equals(s.owner) &
          t.purpose.equals(purpose) &
          t.targetDate.equals(date) &
          t.targetRevision.equals(revision),
      transaction: s.tx,
    );
    if (previous != null) {
      // A user may retry the same target from the other platform's app, or the
      // console unit may have rotated: rebind only before Google accepted an
      // event, so the app always loads a unit its own AdMob app owns.
      final unit = placement.unit(platform);
      if (previous.transactionId != null || previous.adUnit == unit) {
        return view(previous);
      }
      previous
        ..adUnit = unit
        ..rewardItem = placement.rewardItem
        ..rewardAmount = placement.rewardAmount;
      return view(
        await StoredAdIntent.db.updateRow(
          s.session,
          previous,
          transaction: s.tx,
        ),
      );
    }
    if (purpose == 'dailyReward') {
      await withClock(
        eligibilityClock,
        () => s.claimTarget(date, revision, withAd: true),
      );
    } else if (purpose != 'extraQuiz') {
      throw AdException(code: 'purposeUnavailable');
    }
    // Google timestamps have millisecond precision; do not reject an event in
    // the creation millisecond merely because the server clock has microseconds.
    final now = DateTime.fromMillisecondsSinceEpoch(
      eligibilityClock.now().millisecondsSinceEpoch,
      isUtc: true,
    );
    final random = Random.secure();
    final nonce = base64Url
        .encode(List.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
    final i = await StoredAdIntent.db.insertRow(
      s.session,
      StoredAdIntent(
        owner: s.owner,
        nonce: nonce,
        purpose: purpose,
        targetDate: date,
        targetRevision: revision,
        adUnit: placement.unit(platform),
        rewardItem: placement.rewardItem,
        rewardAmount: placement.rewardAmount,
        createdAt: now,
        eventExpiresAt: now.add(eventLifetime),
        acceptUntil: now.add(eventLifetime).add(deliveryGrace),
      ),
      transaction: s.tx,
    );
    return view(i);
  }

  Future<AdIntent> get(ProductService s, String id) async {
    final i = await StoredAdIntent.db.findFirstRow(
      s.session,
      where: (t) => t.owner.equals(s.owner) & t.nonce.equals(id),
      transaction: s.tx,
    );
    if (i == null) throw AdException(code: 'intentNotFound');
    return view(i);
  }

  Future<void> callback(Session session, String rawQuery) async {
    final event = await verifier.verify(rawQuery);
    final candidate = await StoredAdIntent.db.findFirstRow(
      session,
      where: (t) => t.nonce.equals(event.customData),
    );
    if (candidate == null) throw AdException(code: 'intentNotFound');
    await session.db.transaction((tx) async {
      await lockProductAccount(session, candidate.owner, tx);
      final i = await StoredAdIntent.db.findById(
        session,
        candidate.id!,
        transaction: tx,
      );
      if (i == null) throw AdException(code: 'intentNotFound');
      // The intent snapshots the unit of ITS purpose and platform. Google's
      // ad_unit is the numeric ID after the slash of the unit the app loaded.
      final placement = config.placements[i.purpose];
      if (event.owner != i.owner ||
          (event.unit != i.adUnit && event.unit != i.adUnit.split('/').last) ||
          event.rewardItem != i.rewardItem ||
          event.rewardAmount != i.rewardAmount ||
          placement == null ||
          !AdPlatform.values.any((p) => placement.unit(p) == i.adUnit)) {
        throw AdException(code: 'metadataMismatch');
      }
      // Check accepted-event identity BEFORE age: an acknowledged event remains
      // idempotent even after the delivery deadline and after consumption.
      if (i.transactionId != null) {
        if (i.transactionId == event.transactionId &&
            i.callbackDigest == event.digest) {
          return;
        }
        throw AdException(code: 'intentAlreadyVerified');
      }
      final now = clock.now().toUtc();
      if (!now.isBefore(i.acceptUntil) ||
          event.at.isBefore(i.createdAt) ||
          !event.at.isBefore(i.eventExpiresAt) ||
          event.at.isAfter(now.add(futureSkew))) {
        throw AdException(code: 'eventExpired');
      }
      // Serialize transaction IDs globally, including different owners. Database
      // unique constraint is a second invariant, not an exception-based retry.
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(hashtextextended(@id, 71429))',
        parameters: QueryParameters.named({'id': event.transactionId}),
        transaction: tx,
      );
      final used = await StoredAdIntent.db.findFirstRow(
        session,
        where: (t) => t.transactionId.equals(event.transactionId),
        transaction: tx,
      );
      if (used != null) throw AdException(code: 'transactionReplay');
      i.status = 'verified';
      i.transactionId = event.transactionId;
      i.callbackDigest = event.digest;
      i.eventAt = event.at;
      i.verifiedAt = now;
      await StoredAdIntent.db.updateRow(session, i, transaction: tx);
    });
  }

  /// Only for server integrations. Caller owns tx and must commit the actual
  /// entitlement/grant in that SAME tx. Throws on reuse; no dummy grant exists.
  Future<void> consume(
    Session session,
    Transaction tx, {
    required String owner,
    required String intentId,
    required String purpose,
    required String targetDate,
    required int targetRevision,
  }) async {
    await lockProductAccount(session, owner, tx);
    final i = await StoredAdIntent.db.findFirstRow(
      session,
      where: (t) => t.owner.equals(owner) & t.nonce.equals(intentId),
      transaction: tx,
    );
    if (i == null) throw AdException(code: 'intentNotFound');
    if (i.purpose != purpose ||
        i.targetDate != targetDate ||
        i.targetRevision != targetRevision) {
      throw AdException(code: 'targetMismatch');
    }
    if (i.status != 'verified') throw AdException(code: 'intentNotVerified');
    i.status = 'consumed';
    i.consumedAt = clock.now().toUtc();
    await StoredAdIntent.db.updateRow(session, i, transaction: tx);
  }
}
