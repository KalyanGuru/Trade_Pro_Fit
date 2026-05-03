// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $TokensTable extends Tokens with TableInfo<$TokensTable, Token> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _accessTokenMeta =
      const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
      'access_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refreshTokenMeta =
      const VerificationMeta('refreshToken');
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
      'refresh_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, accessToken, refreshToken, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokens';
  @override
  VerificationContext validateIntegrity(Insertable<Token> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
          _accessTokenMeta,
          accessToken.isAcceptableOrUnknown(
              data['access_token']!, _accessTokenMeta));
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
          _refreshTokenMeta,
          refreshToken.isAcceptableOrUnknown(
              data['refresh_token']!, _refreshTokenMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Token map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Token(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token']),
      refreshToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}refresh_token']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $TokensTable createAlias(String alias) {
    return $TokensTable(attachedDatabase, alias);
  }
}

class Token extends DataClass implements Insertable<Token> {
  final int id;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresAt;
  const Token(
      {required this.id, this.accessToken, this.refreshToken, this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || accessToken != null) {
      map['access_token'] = Variable<String>(accessToken);
    }
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    return map;
  }

  TokensCompanion toCompanion(bool nullToAbsent) {
    return TokensCompanion(
      id: Value(id),
      accessToken: accessToken == null && nullToAbsent
          ? const Value.absent()
          : Value(accessToken),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory Token.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Token(
      id: serializer.fromJson<int>(json['id']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accessToken': serializer.toJson<String?>(accessToken),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'expiresAt': serializer.toJson<int?>(expiresAt),
    };
  }

  Token copyWith(
          {int? id,
          Value<String?> accessToken = const Value.absent(),
          Value<String?> refreshToken = const Value.absent(),
          Value<int?> expiresAt = const Value.absent()}) =>
      Token(
        id: id ?? this.id,
        accessToken: accessToken.present ? accessToken.value : this.accessToken,
        refreshToken:
            refreshToken.present ? refreshToken.value : this.refreshToken,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  Token copyWithCompanion(TokensCompanion data) {
    return Token(
      id: data.id.present ? data.id.value : this.id,
      accessToken:
          data.accessToken.present ? data.accessToken.value : this.accessToken,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Token(')
          ..write('id: $id, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accessToken, refreshToken, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Token &&
          other.id == this.id &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.expiresAt == this.expiresAt);
}

class TokensCompanion extends UpdateCompanion<Token> {
  final Value<int> id;
  final Value<String?> accessToken;
  final Value<String?> refreshToken;
  final Value<int?> expiresAt;
  const TokensCompanion({
    this.id = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  TokensCompanion.insert({
    this.id = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  static Insertable<Token> custom({
    Expression<int>? id,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<int>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  TokensCompanion copyWith(
      {Value<int>? id,
      Value<String?>? accessToken,
      Value<String?>? refreshToken,
      Value<int?>? expiresAt}) {
    return TokensCompanion(
      id: id ?? this.id,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokensCompanion(')
          ..write('id: $id, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $InstrumentsTable extends Instruments
    with TableInfo<$InstrumentsTable, Instrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentKeyMeta =
      const VerificationMeta('instrumentKey');
  @override
  late final GeneratedColumn<String> instrumentKey = GeneratedColumn<String>(
      'instrument_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [instrumentKey, symbol, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(Insertable<Instrument> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_key')) {
      context.handle(
          _instrumentKeyMeta,
          instrumentKey.isAcceptableOrUnknown(
              data['instrument_key']!, _instrumentKeyMeta));
    } else if (isInserting) {
      context.missing(_instrumentKeyMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentKey};
  @override
  Instrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instrument(
      instrumentKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instrument_key'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }
}

class Instrument extends DataClass implements Insertable<Instrument> {
  final String instrumentKey;
  final String symbol;
  final String? name;
  const Instrument(
      {required this.instrumentKey, required this.symbol, this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_key'] = Variable<String>(instrumentKey);
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      instrumentKey: Value(instrumentKey),
      symbol: Value(symbol),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory Instrument.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instrument(
      instrumentKey: serializer.fromJson<String>(json['instrumentKey']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrumentKey': serializer.toJson<String>(instrumentKey),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String?>(name),
    };
  }

  Instrument copyWith(
          {String? instrumentKey,
          String? symbol,
          Value<String?> name = const Value.absent()}) =>
      Instrument(
        instrumentKey: instrumentKey ?? this.instrumentKey,
        symbol: symbol ?? this.symbol,
        name: name.present ? name.value : this.name,
      );
  Instrument copyWithCompanion(InstrumentsCompanion data) {
    return Instrument(
      instrumentKey: data.instrumentKey.present
          ? data.instrumentKey.value
          : this.instrumentKey,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instrument(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(instrumentKey, symbol, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instrument &&
          other.instrumentKey == this.instrumentKey &&
          other.symbol == this.symbol &&
          other.name == this.name);
}

class InstrumentsCompanion extends UpdateCompanion<Instrument> {
  final Value<String> instrumentKey;
  final Value<String> symbol;
  final Value<String?> name;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.instrumentKey = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String instrumentKey,
    required String symbol,
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : instrumentKey = Value(instrumentKey),
        symbol = Value(symbol);
  static Insertable<Instrument> custom({
    Expression<String>? instrumentKey,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instrumentKey != null) 'instrument_key': instrumentKey,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith(
      {Value<String>? instrumentKey,
      Value<String>? symbol,
      Value<String?>? name,
      Value<int>? rowid}) {
    return InstrumentsCompanion(
      instrumentKey: instrumentKey ?? this.instrumentKey,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentKey.present) {
      map['instrument_key'] = Variable<String>(instrumentKey.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MinuteBarsTable extends MinuteBars
    with TableInfo<$MinuteBarsTable, MinuteBar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MinuteBarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentKeyMeta =
      const VerificationMeta('instrumentKey');
  @override
  late final GeneratedColumn<String> instrumentKey = GeneratedColumn<String>(
      'instrument_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
      'ts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<double> open = GeneratedColumn<double>(
      'open', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<double> high = GeneratedColumn<double>(
      'high', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<double> low = GeneratedColumn<double>(
      'low', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<double> close = GeneratedColumn<double>(
      'close', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
      'volume', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [instrumentKey, ts, open, high, low, close, volume];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'minute_bars';
  @override
  VerificationContext validateIntegrity(Insertable<MinuteBar> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_key')) {
      context.handle(
          _instrumentKeyMeta,
          instrumentKey.isAcceptableOrUnknown(
              data['instrument_key']!, _instrumentKeyMeta));
    } else if (isInserting) {
      context.missing(_instrumentKeyMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
          _openMeta, open.isAcceptableOrUnknown(data['open']!, _openMeta));
    } else if (isInserting) {
      context.missing(_openMeta);
    }
    if (data.containsKey('high')) {
      context.handle(
          _highMeta, high.isAcceptableOrUnknown(data['high']!, _highMeta));
    } else if (isInserting) {
      context.missing(_highMeta);
    }
    if (data.containsKey('low')) {
      context.handle(
          _lowMeta, low.isAcceptableOrUnknown(data['low']!, _lowMeta));
    } else if (isInserting) {
      context.missing(_lowMeta);
    }
    if (data.containsKey('close')) {
      context.handle(
          _closeMeta, close.isAcceptableOrUnknown(data['close']!, _closeMeta));
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentKey, ts};
  @override
  MinuteBar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MinuteBar(
      instrumentKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instrument_key'])!,
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ts'])!,
      open: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}open'])!,
      high: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}high'])!,
      low: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}low'])!,
      close: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}close'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}volume'])!,
    );
  }

  @override
  $MinuteBarsTable createAlias(String alias) {
    return $MinuteBarsTable(attachedDatabase, alias);
  }
}

class MinuteBar extends DataClass implements Insertable<MinuteBar> {
  final String instrumentKey;
  final int ts;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  const MinuteBar(
      {required this.instrumentKey,
      required this.ts,
      required this.open,
      required this.high,
      required this.low,
      required this.close,
      required this.volume});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_key'] = Variable<String>(instrumentKey);
    map['ts'] = Variable<int>(ts);
    map['open'] = Variable<double>(open);
    map['high'] = Variable<double>(high);
    map['low'] = Variable<double>(low);
    map['close'] = Variable<double>(close);
    map['volume'] = Variable<double>(volume);
    return map;
  }

  MinuteBarsCompanion toCompanion(bool nullToAbsent) {
    return MinuteBarsCompanion(
      instrumentKey: Value(instrumentKey),
      ts: Value(ts),
      open: Value(open),
      high: Value(high),
      low: Value(low),
      close: Value(close),
      volume: Value(volume),
    );
  }

  factory MinuteBar.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MinuteBar(
      instrumentKey: serializer.fromJson<String>(json['instrumentKey']),
      ts: serializer.fromJson<int>(json['ts']),
      open: serializer.fromJson<double>(json['open']),
      high: serializer.fromJson<double>(json['high']),
      low: serializer.fromJson<double>(json['low']),
      close: serializer.fromJson<double>(json['close']),
      volume: serializer.fromJson<double>(json['volume']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrumentKey': serializer.toJson<String>(instrumentKey),
      'ts': serializer.toJson<int>(ts),
      'open': serializer.toJson<double>(open),
      'high': serializer.toJson<double>(high),
      'low': serializer.toJson<double>(low),
      'close': serializer.toJson<double>(close),
      'volume': serializer.toJson<double>(volume),
    };
  }

  MinuteBar copyWith(
          {String? instrumentKey,
          int? ts,
          double? open,
          double? high,
          double? low,
          double? close,
          double? volume}) =>
      MinuteBar(
        instrumentKey: instrumentKey ?? this.instrumentKey,
        ts: ts ?? this.ts,
        open: open ?? this.open,
        high: high ?? this.high,
        low: low ?? this.low,
        close: close ?? this.close,
        volume: volume ?? this.volume,
      );
  MinuteBar copyWithCompanion(MinuteBarsCompanion data) {
    return MinuteBar(
      instrumentKey: data.instrumentKey.present
          ? data.instrumentKey.value
          : this.instrumentKey,
      ts: data.ts.present ? data.ts.value : this.ts,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MinuteBar(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('ts: $ts, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(instrumentKey, ts, open, high, low, close, volume);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MinuteBar &&
          other.instrumentKey == this.instrumentKey &&
          other.ts == this.ts &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume);
}

class MinuteBarsCompanion extends UpdateCompanion<MinuteBar> {
  final Value<String> instrumentKey;
  final Value<int> ts;
  final Value<double> open;
  final Value<double> high;
  final Value<double> low;
  final Value<double> close;
  final Value<double> volume;
  final Value<int> rowid;
  const MinuteBarsCompanion({
    this.instrumentKey = const Value.absent(),
    this.ts = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MinuteBarsCompanion.insert({
    required String instrumentKey,
    required int ts,
    required double open,
    required double high,
    required double low,
    required double close,
    required double volume,
    this.rowid = const Value.absent(),
  })  : instrumentKey = Value(instrumentKey),
        ts = Value(ts),
        open = Value(open),
        high = Value(high),
        low = Value(low),
        close = Value(close),
        volume = Value(volume);
  static Insertable<MinuteBar> custom({
    Expression<String>? instrumentKey,
    Expression<int>? ts,
    Expression<double>? open,
    Expression<double>? high,
    Expression<double>? low,
    Expression<double>? close,
    Expression<double>? volume,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instrumentKey != null) 'instrument_key': instrumentKey,
      if (ts != null) 'ts': ts,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MinuteBarsCompanion copyWith(
      {Value<String>? instrumentKey,
      Value<int>? ts,
      Value<double>? open,
      Value<double>? high,
      Value<double>? low,
      Value<double>? close,
      Value<double>? volume,
      Value<int>? rowid}) {
    return MinuteBarsCompanion(
      instrumentKey: instrumentKey ?? this.instrumentKey,
      ts: ts ?? this.ts,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentKey.present) {
      map['instrument_key'] = Variable<String>(instrumentKey.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (open.present) {
      map['open'] = Variable<double>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<double>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<double>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<double>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MinuteBarsCompanion(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('ts: $ts, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PredictionsTable extends Predictions
    with TableInfo<$PredictionsTable, Prediction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PredictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentKeyMeta =
      const VerificationMeta('instrumentKey');
  @override
  late final GeneratedColumn<String> instrumentKey = GeneratedColumn<String>(
      'instrument_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
      'ts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _horizonMeta =
      const VerificationMeta('horizon');
  @override
  late final GeneratedColumn<int> horizon = GeneratedColumn<int>(
      'horizon', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _retPredMeta =
      const VerificationMeta('retPred');
  @override
  late final GeneratedColumn<double> retPred = GeneratedColumn<double>(
      'ret_pred', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _curveMeta = const VerificationMeta('curve');
  @override
  late final GeneratedColumn<String> curve = GeneratedColumn<String>(
      'curve', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [instrumentKey, ts, horizon, retPred, curve];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'predictions';
  @override
  VerificationContext validateIntegrity(Insertable<Prediction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_key')) {
      context.handle(
          _instrumentKeyMeta,
          instrumentKey.isAcceptableOrUnknown(
              data['instrument_key']!, _instrumentKeyMeta));
    } else if (isInserting) {
      context.missing(_instrumentKeyMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('horizon')) {
      context.handle(_horizonMeta,
          horizon.isAcceptableOrUnknown(data['horizon']!, _horizonMeta));
    } else if (isInserting) {
      context.missing(_horizonMeta);
    }
    if (data.containsKey('ret_pred')) {
      context.handle(_retPredMeta,
          retPred.isAcceptableOrUnknown(data['ret_pred']!, _retPredMeta));
    } else if (isInserting) {
      context.missing(_retPredMeta);
    }
    if (data.containsKey('curve')) {
      context.handle(
          _curveMeta, curve.isAcceptableOrUnknown(data['curve']!, _curveMeta));
    } else if (isInserting) {
      context.missing(_curveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Prediction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prediction(
      instrumentKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instrument_key'])!,
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ts'])!,
      horizon: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}horizon'])!,
      retPred: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ret_pred'])!,
      curve: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}curve'])!,
    );
  }

  @override
  $PredictionsTable createAlias(String alias) {
    return $PredictionsTable(attachedDatabase, alias);
  }
}

class Prediction extends DataClass implements Insertable<Prediction> {
  final String instrumentKey;
  final int ts;
  final int horizon;
  final double retPred;
  final String curve;
  const Prediction(
      {required this.instrumentKey,
      required this.ts,
      required this.horizon,
      required this.retPred,
      required this.curve});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_key'] = Variable<String>(instrumentKey);
    map['ts'] = Variable<int>(ts);
    map['horizon'] = Variable<int>(horizon);
    map['ret_pred'] = Variable<double>(retPred);
    map['curve'] = Variable<String>(curve);
    return map;
  }

  PredictionsCompanion toCompanion(bool nullToAbsent) {
    return PredictionsCompanion(
      instrumentKey: Value(instrumentKey),
      ts: Value(ts),
      horizon: Value(horizon),
      retPred: Value(retPred),
      curve: Value(curve),
    );
  }

  factory Prediction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prediction(
      instrumentKey: serializer.fromJson<String>(json['instrumentKey']),
      ts: serializer.fromJson<int>(json['ts']),
      horizon: serializer.fromJson<int>(json['horizon']),
      retPred: serializer.fromJson<double>(json['retPred']),
      curve: serializer.fromJson<String>(json['curve']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrumentKey': serializer.toJson<String>(instrumentKey),
      'ts': serializer.toJson<int>(ts),
      'horizon': serializer.toJson<int>(horizon),
      'retPred': serializer.toJson<double>(retPred),
      'curve': serializer.toJson<String>(curve),
    };
  }

  Prediction copyWith(
          {String? instrumentKey,
          int? ts,
          int? horizon,
          double? retPred,
          String? curve}) =>
      Prediction(
        instrumentKey: instrumentKey ?? this.instrumentKey,
        ts: ts ?? this.ts,
        horizon: horizon ?? this.horizon,
        retPred: retPred ?? this.retPred,
        curve: curve ?? this.curve,
      );
  Prediction copyWithCompanion(PredictionsCompanion data) {
    return Prediction(
      instrumentKey: data.instrumentKey.present
          ? data.instrumentKey.value
          : this.instrumentKey,
      ts: data.ts.present ? data.ts.value : this.ts,
      horizon: data.horizon.present ? data.horizon.value : this.horizon,
      retPred: data.retPred.present ? data.retPred.value : this.retPred,
      curve: data.curve.present ? data.curve.value : this.curve,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prediction(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('ts: $ts, ')
          ..write('horizon: $horizon, ')
          ..write('retPred: $retPred, ')
          ..write('curve: $curve')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(instrumentKey, ts, horizon, retPred, curve);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prediction &&
          other.instrumentKey == this.instrumentKey &&
          other.ts == this.ts &&
          other.horizon == this.horizon &&
          other.retPred == this.retPred &&
          other.curve == this.curve);
}

class PredictionsCompanion extends UpdateCompanion<Prediction> {
  final Value<String> instrumentKey;
  final Value<int> ts;
  final Value<int> horizon;
  final Value<double> retPred;
  final Value<String> curve;
  final Value<int> rowid;
  const PredictionsCompanion({
    this.instrumentKey = const Value.absent(),
    this.ts = const Value.absent(),
    this.horizon = const Value.absent(),
    this.retPred = const Value.absent(),
    this.curve = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PredictionsCompanion.insert({
    required String instrumentKey,
    required int ts,
    required int horizon,
    required double retPred,
    required String curve,
    this.rowid = const Value.absent(),
  })  : instrumentKey = Value(instrumentKey),
        ts = Value(ts),
        horizon = Value(horizon),
        retPred = Value(retPred),
        curve = Value(curve);
  static Insertable<Prediction> custom({
    Expression<String>? instrumentKey,
    Expression<int>? ts,
    Expression<int>? horizon,
    Expression<double>? retPred,
    Expression<String>? curve,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instrumentKey != null) 'instrument_key': instrumentKey,
      if (ts != null) 'ts': ts,
      if (horizon != null) 'horizon': horizon,
      if (retPred != null) 'ret_pred': retPred,
      if (curve != null) 'curve': curve,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PredictionsCompanion copyWith(
      {Value<String>? instrumentKey,
      Value<int>? ts,
      Value<int>? horizon,
      Value<double>? retPred,
      Value<String>? curve,
      Value<int>? rowid}) {
    return PredictionsCompanion(
      instrumentKey: instrumentKey ?? this.instrumentKey,
      ts: ts ?? this.ts,
      horizon: horizon ?? this.horizon,
      retPred: retPred ?? this.retPred,
      curve: curve ?? this.curve,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentKey.present) {
      map['instrument_key'] = Variable<String>(instrumentKey.value);
    }
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (horizon.present) {
      map['horizon'] = Variable<int>(horizon.value);
    }
    if (retPred.present) {
      map['ret_pred'] = Variable<double>(retPred.value);
    }
    if (curve.present) {
      map['curve'] = Variable<String>(curve.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PredictionsCompanion(')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('ts: $ts, ')
          ..write('horizon: $horizon, ')
          ..write('retPred: $retPred, ')
          ..write('curve: $curve, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClustersTable extends Clusters with TableInfo<$ClustersTable, Cluster> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClustersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<int> ts = GeneratedColumn<int>(
      'ts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _instrumentKeyMeta =
      const VerificationMeta('instrumentKey');
  @override
  late final GeneratedColumn<String> instrumentKey = GeneratedColumn<String>(
      'instrument_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clusterMeta =
      const VerificationMeta('cluster');
  @override
  late final GeneratedColumn<int> cluster = GeneratedColumn<int>(
      'cluster', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [ts, instrumentKey, cluster, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clusters';
  @override
  VerificationContext validateIntegrity(Insertable<Cluster> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('instrument_key')) {
      context.handle(
          _instrumentKeyMeta,
          instrumentKey.isAcceptableOrUnknown(
              data['instrument_key']!, _instrumentKeyMeta));
    } else if (isInserting) {
      context.missing(_instrumentKeyMeta);
    }
    if (data.containsKey('cluster')) {
      context.handle(_clusterMeta,
          cluster.isAcceptableOrUnknown(data['cluster']!, _clusterMeta));
    } else if (isInserting) {
      context.missing(_clusterMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Cluster map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cluster(
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ts'])!,
      instrumentKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instrument_key'])!,
      cluster: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cluster'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $ClustersTable createAlias(String alias) {
    return $ClustersTable(attachedDatabase, alias);
  }
}

class Cluster extends DataClass implements Insertable<Cluster> {
  final int ts;
  final String instrumentKey;
  final int cluster;
  final String label;
  const Cluster(
      {required this.ts,
      required this.instrumentKey,
      required this.cluster,
      required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ts'] = Variable<int>(ts);
    map['instrument_key'] = Variable<String>(instrumentKey);
    map['cluster'] = Variable<int>(cluster);
    map['label'] = Variable<String>(label);
    return map;
  }

  ClustersCompanion toCompanion(bool nullToAbsent) {
    return ClustersCompanion(
      ts: Value(ts),
      instrumentKey: Value(instrumentKey),
      cluster: Value(cluster),
      label: Value(label),
    );
  }

  factory Cluster.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cluster(
      ts: serializer.fromJson<int>(json['ts']),
      instrumentKey: serializer.fromJson<String>(json['instrumentKey']),
      cluster: serializer.fromJson<int>(json['cluster']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ts': serializer.toJson<int>(ts),
      'instrumentKey': serializer.toJson<String>(instrumentKey),
      'cluster': serializer.toJson<int>(cluster),
      'label': serializer.toJson<String>(label),
    };
  }

  Cluster copyWith(
          {int? ts, String? instrumentKey, int? cluster, String? label}) =>
      Cluster(
        ts: ts ?? this.ts,
        instrumentKey: instrumentKey ?? this.instrumentKey,
        cluster: cluster ?? this.cluster,
        label: label ?? this.label,
      );
  Cluster copyWithCompanion(ClustersCompanion data) {
    return Cluster(
      ts: data.ts.present ? data.ts.value : this.ts,
      instrumentKey: data.instrumentKey.present
          ? data.instrumentKey.value
          : this.instrumentKey,
      cluster: data.cluster.present ? data.cluster.value : this.cluster,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cluster(')
          ..write('ts: $ts, ')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('cluster: $cluster, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ts, instrumentKey, cluster, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cluster &&
          other.ts == this.ts &&
          other.instrumentKey == this.instrumentKey &&
          other.cluster == this.cluster &&
          other.label == this.label);
}

class ClustersCompanion extends UpdateCompanion<Cluster> {
  final Value<int> ts;
  final Value<String> instrumentKey;
  final Value<int> cluster;
  final Value<String> label;
  final Value<int> rowid;
  const ClustersCompanion({
    this.ts = const Value.absent(),
    this.instrumentKey = const Value.absent(),
    this.cluster = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClustersCompanion.insert({
    required int ts,
    required String instrumentKey,
    required int cluster,
    required String label,
    this.rowid = const Value.absent(),
  })  : ts = Value(ts),
        instrumentKey = Value(instrumentKey),
        cluster = Value(cluster),
        label = Value(label);
  static Insertable<Cluster> custom({
    Expression<int>? ts,
    Expression<String>? instrumentKey,
    Expression<int>? cluster,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ts != null) 'ts': ts,
      if (instrumentKey != null) 'instrument_key': instrumentKey,
      if (cluster != null) 'cluster': cluster,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClustersCompanion copyWith(
      {Value<int>? ts,
      Value<String>? instrumentKey,
      Value<int>? cluster,
      Value<String>? label,
      Value<int>? rowid}) {
    return ClustersCompanion(
      ts: ts ?? this.ts,
      instrumentKey: instrumentKey ?? this.instrumentKey,
      cluster: cluster ?? this.cluster,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ts.present) {
      map['ts'] = Variable<int>(ts.value);
    }
    if (instrumentKey.present) {
      map['instrument_key'] = Variable<String>(instrumentKey.value);
    }
    if (cluster.present) {
      map['cluster'] = Variable<int>(cluster.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClustersCompanion(')
          ..write('ts: $ts, ')
          ..write('instrumentKey: $instrumentKey, ')
          ..write('cluster: $cluster, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TokensTable tokens = $TokensTable(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $MinuteBarsTable minuteBars = $MinuteBarsTable(this);
  late final $PredictionsTable predictions = $PredictionsTable(this);
  late final $ClustersTable clusters = $ClustersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tokens, instruments, minuteBars, predictions, clusters];
}

typedef $$TokensTableCreateCompanionBuilder = TokensCompanion Function({
  Value<int> id,
  Value<String?> accessToken,
  Value<String?> refreshToken,
  Value<int?> expiresAt,
});
typedef $$TokensTableUpdateCompanionBuilder = TokensCompanion Function({
  Value<int> id,
  Value<String?> accessToken,
  Value<String?> refreshToken,
  Value<int?> expiresAt,
});

class $$TokensTableTableManager extends RootTableManager<
    _$AppDb,
    $TokensTable,
    Token,
    $$TokensTableFilterComposer,
    $$TokensTableOrderingComposer,
    $$TokensTableCreateCompanionBuilder,
    $$TokensTableUpdateCompanionBuilder> {
  $$TokensTableTableManager(_$AppDb db, $TokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TokensTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TokensTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<String?> refreshToken = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
          }) =>
              TokensCompanion(
            id: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> accessToken = const Value.absent(),
            Value<String?> refreshToken = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
          }) =>
              TokensCompanion.insert(
            id: id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
          ),
        ));
}

class $$TokensTableFilterComposer
    extends FilterComposer<_$AppDb, $TokensTable> {
  $$TokensTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get accessToken => $state.composableBuilder(
      column: $state.table.accessToken,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get refreshToken => $state.composableBuilder(
      column: $state.table.refreshToken,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get expiresAt => $state.composableBuilder(
      column: $state.table.expiresAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TokensTableOrderingComposer
    extends OrderingComposer<_$AppDb, $TokensTable> {
  $$TokensTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get accessToken => $state.composableBuilder(
      column: $state.table.accessToken,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get refreshToken => $state.composableBuilder(
      column: $state.table.refreshToken,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get expiresAt => $state.composableBuilder(
      column: $state.table.expiresAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$InstrumentsTableCreateCompanionBuilder = InstrumentsCompanion
    Function({
  required String instrumentKey,
  required String symbol,
  Value<String?> name,
  Value<int> rowid,
});
typedef $$InstrumentsTableUpdateCompanionBuilder = InstrumentsCompanion
    Function({
  Value<String> instrumentKey,
  Value<String> symbol,
  Value<String?> name,
  Value<int> rowid,
});

class $$InstrumentsTableTableManager extends RootTableManager<
    _$AppDb,
    $InstrumentsTable,
    Instrument,
    $$InstrumentsTableFilterComposer,
    $$InstrumentsTableOrderingComposer,
    $$InstrumentsTableCreateCompanionBuilder,
    $$InstrumentsTableUpdateCompanionBuilder> {
  $$InstrumentsTableTableManager(_$AppDb db, $InstrumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$InstrumentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$InstrumentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> instrumentKey = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstrumentsCompanion(
            instrumentKey: instrumentKey,
            symbol: symbol,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String instrumentKey,
            required String symbol,
            Value<String?> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstrumentsCompanion.insert(
            instrumentKey: instrumentKey,
            symbol: symbol,
            name: name,
            rowid: rowid,
          ),
        ));
}

class $$InstrumentsTableFilterComposer
    extends FilterComposer<_$AppDb, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer(super.$state);
  ColumnFilters<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$InstrumentsTableOrderingComposer
    extends OrderingComposer<_$AppDb, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MinuteBarsTableCreateCompanionBuilder = MinuteBarsCompanion Function({
  required String instrumentKey,
  required int ts,
  required double open,
  required double high,
  required double low,
  required double close,
  required double volume,
  Value<int> rowid,
});
typedef $$MinuteBarsTableUpdateCompanionBuilder = MinuteBarsCompanion Function({
  Value<String> instrumentKey,
  Value<int> ts,
  Value<double> open,
  Value<double> high,
  Value<double> low,
  Value<double> close,
  Value<double> volume,
  Value<int> rowid,
});

class $$MinuteBarsTableTableManager extends RootTableManager<
    _$AppDb,
    $MinuteBarsTable,
    MinuteBar,
    $$MinuteBarsTableFilterComposer,
    $$MinuteBarsTableOrderingComposer,
    $$MinuteBarsTableCreateCompanionBuilder,
    $$MinuteBarsTableUpdateCompanionBuilder> {
  $$MinuteBarsTableTableManager(_$AppDb db, $MinuteBarsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MinuteBarsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MinuteBarsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> instrumentKey = const Value.absent(),
            Value<int> ts = const Value.absent(),
            Value<double> open = const Value.absent(),
            Value<double> high = const Value.absent(),
            Value<double> low = const Value.absent(),
            Value<double> close = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MinuteBarsCompanion(
            instrumentKey: instrumentKey,
            ts: ts,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String instrumentKey,
            required int ts,
            required double open,
            required double high,
            required double low,
            required double close,
            required double volume,
            Value<int> rowid = const Value.absent(),
          }) =>
              MinuteBarsCompanion.insert(
            instrumentKey: instrumentKey,
            ts: ts,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            rowid: rowid,
          ),
        ));
}

class $$MinuteBarsTableFilterComposer
    extends FilterComposer<_$AppDb, $MinuteBarsTable> {
  $$MinuteBarsTableFilterComposer(super.$state);
  ColumnFilters<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get open => $state.composableBuilder(
      column: $state.table.open,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get high => $state.composableBuilder(
      column: $state.table.high,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get low => $state.composableBuilder(
      column: $state.table.low,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get close => $state.composableBuilder(
      column: $state.table.close,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get volume => $state.composableBuilder(
      column: $state.table.volume,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$MinuteBarsTableOrderingComposer
    extends OrderingComposer<_$AppDb, $MinuteBarsTable> {
  $$MinuteBarsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get open => $state.composableBuilder(
      column: $state.table.open,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get high => $state.composableBuilder(
      column: $state.table.high,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get low => $state.composableBuilder(
      column: $state.table.low,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get close => $state.composableBuilder(
      column: $state.table.close,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get volume => $state.composableBuilder(
      column: $state.table.volume,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PredictionsTableCreateCompanionBuilder = PredictionsCompanion
    Function({
  required String instrumentKey,
  required int ts,
  required int horizon,
  required double retPred,
  required String curve,
  Value<int> rowid,
});
typedef $$PredictionsTableUpdateCompanionBuilder = PredictionsCompanion
    Function({
  Value<String> instrumentKey,
  Value<int> ts,
  Value<int> horizon,
  Value<double> retPred,
  Value<String> curve,
  Value<int> rowid,
});

class $$PredictionsTableTableManager extends RootTableManager<
    _$AppDb,
    $PredictionsTable,
    Prediction,
    $$PredictionsTableFilterComposer,
    $$PredictionsTableOrderingComposer,
    $$PredictionsTableCreateCompanionBuilder,
    $$PredictionsTableUpdateCompanionBuilder> {
  $$PredictionsTableTableManager(_$AppDb db, $PredictionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PredictionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PredictionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> instrumentKey = const Value.absent(),
            Value<int> ts = const Value.absent(),
            Value<int> horizon = const Value.absent(),
            Value<double> retPred = const Value.absent(),
            Value<String> curve = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PredictionsCompanion(
            instrumentKey: instrumentKey,
            ts: ts,
            horizon: horizon,
            retPred: retPred,
            curve: curve,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String instrumentKey,
            required int ts,
            required int horizon,
            required double retPred,
            required String curve,
            Value<int> rowid = const Value.absent(),
          }) =>
              PredictionsCompanion.insert(
            instrumentKey: instrumentKey,
            ts: ts,
            horizon: horizon,
            retPred: retPred,
            curve: curve,
            rowid: rowid,
          ),
        ));
}

class $$PredictionsTableFilterComposer
    extends FilterComposer<_$AppDb, $PredictionsTable> {
  $$PredictionsTableFilterComposer(super.$state);
  ColumnFilters<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get horizon => $state.composableBuilder(
      column: $state.table.horizon,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get retPred => $state.composableBuilder(
      column: $state.table.retPred,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get curve => $state.composableBuilder(
      column: $state.table.curve,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PredictionsTableOrderingComposer
    extends OrderingComposer<_$AppDb, $PredictionsTable> {
  $$PredictionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get horizon => $state.composableBuilder(
      column: $state.table.horizon,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get retPred => $state.composableBuilder(
      column: $state.table.retPred,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get curve => $state.composableBuilder(
      column: $state.table.curve,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ClustersTableCreateCompanionBuilder = ClustersCompanion Function({
  required int ts,
  required String instrumentKey,
  required int cluster,
  required String label,
  Value<int> rowid,
});
typedef $$ClustersTableUpdateCompanionBuilder = ClustersCompanion Function({
  Value<int> ts,
  Value<String> instrumentKey,
  Value<int> cluster,
  Value<String> label,
  Value<int> rowid,
});

class $$ClustersTableTableManager extends RootTableManager<
    _$AppDb,
    $ClustersTable,
    Cluster,
    $$ClustersTableFilterComposer,
    $$ClustersTableOrderingComposer,
    $$ClustersTableCreateCompanionBuilder,
    $$ClustersTableUpdateCompanionBuilder> {
  $$ClustersTableTableManager(_$AppDb db, $ClustersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ClustersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ClustersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> ts = const Value.absent(),
            Value<String> instrumentKey = const Value.absent(),
            Value<int> cluster = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClustersCompanion(
            ts: ts,
            instrumentKey: instrumentKey,
            cluster: cluster,
            label: label,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int ts,
            required String instrumentKey,
            required int cluster,
            required String label,
            Value<int> rowid = const Value.absent(),
          }) =>
              ClustersCompanion.insert(
            ts: ts,
            instrumentKey: instrumentKey,
            cluster: cluster,
            label: label,
            rowid: rowid,
          ),
        ));
}

class $$ClustersTableFilterComposer
    extends FilterComposer<_$AppDb, $ClustersTable> {
  $$ClustersTableFilterComposer(super.$state);
  ColumnFilters<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get cluster => $state.composableBuilder(
      column: $state.table.cluster,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ClustersTableOrderingComposer
    extends OrderingComposer<_$AppDb, $ClustersTable> {
  $$ClustersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get instrumentKey => $state.composableBuilder(
      column: $state.table.instrumentKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get cluster => $state.composableBuilder(
      column: $state.table.cluster,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TokensTableTableManager get tokens =>
      $$TokensTableTableManager(_db, _db.tokens);
  $$InstrumentsTableTableManager get instruments =>
      $$InstrumentsTableTableManager(_db, _db.instruments);
  $$MinuteBarsTableTableManager get minuteBars =>
      $$MinuteBarsTableTableManager(_db, _db.minuteBars);
  $$PredictionsTableTableManager get predictions =>
      $$PredictionsTableTableManager(_db, _db.predictions);
  $$ClustersTableTableManager get clusters =>
      $$ClustersTableTableManager(_db, _db.clusters);
}
