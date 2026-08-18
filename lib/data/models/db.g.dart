// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsCollection on Isar {
  IsarCollection<Settings> get settings => this.collection();
}

const SettingsSchema = CollectionSchema(
  name: r'Settings',
  id: -8656046621518759136,
  properties: {
    r'allTodosSortOption': PropertySchema(
      id: 0,
      name: r'allTodosSortOption',
      type: IsarType.byte,
      enumMap: _SettingsallTodosSortOptionEnumValueMap,
    ),
    r'amoledTheme': PropertySchema(
      id: 1,
      name: r'amoledTheme',
      type: IsarType.bool,
    ),
    r'appFont': PropertySchema(id: 2, name: r'appFont', type: IsarType.string),
    r'autoBackupEnabled': PropertySchema(
      id: 3,
      name: r'autoBackupEnabled',
      type: IsarType.bool,
    ),
    r'autoBackupFrequency': PropertySchema(
      id: 4,
      name: r'autoBackupFrequency',
      type: IsarType.byte,
      enumMap: _SettingsautoBackupFrequencyEnumValueMap,
    ),
    r'autoBackupPath': PropertySchema(
      id: 5,
      name: r'autoBackupPath',
      type: IsarType.string,
    ),
    r'autoEraseCompletedEnabled': PropertySchema(
      id: 6,
      name: r'autoEraseCompletedEnabled',
      type: IsarType.bool,
    ),
    r'autoEraseCompletedFrequency': PropertySchema(
      id: 7,
      name: r'autoEraseCompletedFrequency',
      type: IsarType.byte,
      enumMap: _SettingsautoEraseCompletedFrequencyEnumValueMap,
    ),
    r'caldavAllowInsecure': PropertySchema(
      id: 8,
      name: r'caldavAllowInsecure',
      type: IsarType.bool,
    ),
    r'caldavCalendarHref': PropertySchema(
      id: 9,
      name: r'caldavCalendarHref',
      type: IsarType.string,
    ),
    r'caldavCalendarName': PropertySchema(
      id: 10,
      name: r'caldavCalendarName',
      type: IsarType.string,
    ),
    r'caldavCtag': PropertySchema(
      id: 11,
      name: r'caldavCtag',
      type: IsarType.string,
    ),
    r'caldavEnabled': PropertySchema(
      id: 12,
      name: r'caldavEnabled',
      type: IsarType.bool,
    ),
    r'caldavLastError': PropertySchema(
      id: 13,
      name: r'caldavLastError',
      type: IsarType.string,
    ),
    r'caldavLastSyncTime': PropertySchema(
      id: 14,
      name: r'caldavLastSyncTime',
      type: IsarType.dateTime,
    ),
    r'caldavPendingDeletes': PropertySchema(
      id: 15,
      name: r'caldavPendingDeletes',
      type: IsarType.string,
    ),
    r'caldavUrl': PropertySchema(
      id: 16,
      name: r'caldavUrl',
      type: IsarType.string,
    ),
    r'caldavUsername': PropertySchema(
      id: 17,
      name: r'caldavUsername',
      type: IsarType.string,
    ),
    r'calendarFormat': PropertySchema(
      id: 18,
      name: r'calendarFormat',
      type: IsarType.string,
    ),
    r'calendarSortOption': PropertySchema(
      id: 19,
      name: r'calendarSortOption',
      type: IsarType.byte,
      enumMap: _SettingscalendarSortOptionEnumValueMap,
    ),
    r'colorPalette': PropertySchema(
      id: 20,
      name: r'colorPalette',
      type: IsarType.string,
    ),
    r'defaultCategoryId': PropertySchema(
      id: 21,
      name: r'defaultCategoryId',
      type: IsarType.long,
    ),
    r'defaultCategorySeeded': PropertySchema(
      id: 22,
      name: r'defaultCategorySeeded',
      type: IsarType.bool,
    ),
    r'defaultScreen': PropertySchema(
      id: 23,
      name: r'defaultScreen',
      type: IsarType.string,
    ),
    r'deviceCalendarId': PropertySchema(
      id: 24,
      name: r'deviceCalendarId',
      type: IsarType.string,
    ),
    r'deviceCalendarSyncEnabled': PropertySchema(
      id: 25,
      name: r'deviceCalendarSyncEnabled',
      type: IsarType.bool,
    ),
    r'firstDay': PropertySchema(
      id: 26,
      name: r'firstDay',
      type: IsarType.string,
    ),
    r'isImage': PropertySchema(id: 27, name: r'isImage', type: IsarType.bool),
    r'language': PropertySchema(
      id: 28,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastAutoBackupTime': PropertySchema(
      id: 29,
      name: r'lastAutoBackupTime',
      type: IsarType.dateTime,
    ),
    r'lastAutoEraseCompletedTime': PropertySchema(
      id: 30,
      name: r'lastAutoEraseCompletedTime',
      type: IsarType.dateTime,
    ),
    r'materialColor': PropertySchema(
      id: 31,
      name: r'materialColor',
      type: IsarType.bool,
    ),
    r'maxAutoBackups': PropertySchema(
      id: 32,
      name: r'maxAutoBackups',
      type: IsarType.long,
    ),
    r'notificationChannelsMigrated': PropertySchema(
      id: 33,
      name: r'notificationChannelsMigrated',
      type: IsarType.bool,
    ),
    r'onboard': PropertySchema(id: 34, name: r'onboard', type: IsarType.bool),
    r'screenPrivacy': PropertySchema(
      id: 35,
      name: r'screenPrivacy',
      type: IsarType.bool,
    ),
    r'settingsSchemaVersion': PropertySchema(
      id: 36,
      name: r'settingsSchemaVersion',
      type: IsarType.long,
    ),
    r'showArchivedInAllTodos': PropertySchema(
      id: 37,
      name: r'showArchivedInAllTodos',
      type: IsarType.bool,
    ),
    r'showArchivedInCalendar': PropertySchema(
      id: 38,
      name: r'showArchivedInCalendar',
      type: IsarType.bool,
    ),
    r'showArchivedInStatistics': PropertySchema(
      id: 39,
      name: r'showArchivedInStatistics',
      type: IsarType.bool,
    ),
    r'snoozeDuration': PropertySchema(
      id: 40,
      name: r'snoozeDuration',
      type: IsarType.long,
    ),
    r'theme': PropertySchema(id: 41, name: r'theme', type: IsarType.string),
    r'timeformat': PropertySchema(
      id: 42,
      name: r'timeformat',
      type: IsarType.string,
    ),
    r'todoCardLayout': PropertySchema(
      id: 43,
      name: r'todoCardLayout',
      type: IsarType.string,
    ),
  },

  estimateSize: _settingsEstimateSize,
  serialize: _settingsSerialize,
  deserialize: _settingsDeserialize,
  deserializeProp: _settingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _settingsGetId,
  getLinks: _settingsGetLinks,
  attach: _settingsAttach,
  version: '3.3.2',
);

int _settingsEstimateSize(
  Settings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.appFont.length * 3;
  {
    final value = object.autoBackupPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavCalendarHref;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavCalendarName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavCtag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavLastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.caldavPendingDeletes.length * 3;
  {
    final value = object.caldavUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavUsername;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.calendarFormat.length * 3;
  bytesCount += 3 + object.colorPalette.length * 3;
  bytesCount += 3 + object.defaultScreen.length * 3;
  {
    final value = object.deviceCalendarId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.firstDay.length * 3;
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.theme;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.timeformat.length * 3;
  bytesCount += 3 + object.todoCardLayout.length * 3;
  return bytesCount;
}

void _settingsSerialize(
  Settings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.allTodosSortOption.index);
  writer.writeBool(offsets[1], object.amoledTheme);
  writer.writeString(offsets[2], object.appFont);
  writer.writeBool(offsets[3], object.autoBackupEnabled);
  writer.writeByte(offsets[4], object.autoBackupFrequency.index);
  writer.writeString(offsets[5], object.autoBackupPath);
  writer.writeBool(offsets[6], object.autoEraseCompletedEnabled);
  writer.writeByte(offsets[7], object.autoEraseCompletedFrequency.index);
  writer.writeBool(offsets[8], object.caldavAllowInsecure);
  writer.writeString(offsets[9], object.caldavCalendarHref);
  writer.writeString(offsets[10], object.caldavCalendarName);
  writer.writeString(offsets[11], object.caldavCtag);
  writer.writeBool(offsets[12], object.caldavEnabled);
  writer.writeString(offsets[13], object.caldavLastError);
  writer.writeDateTime(offsets[14], object.caldavLastSyncTime);
  writer.writeString(offsets[15], object.caldavPendingDeletes);
  writer.writeString(offsets[16], object.caldavUrl);
  writer.writeString(offsets[17], object.caldavUsername);
  writer.writeString(offsets[18], object.calendarFormat);
  writer.writeByte(offsets[19], object.calendarSortOption.index);
  writer.writeString(offsets[20], object.colorPalette);
  writer.writeLong(offsets[21], object.defaultCategoryId);
  writer.writeBool(offsets[22], object.defaultCategorySeeded);
  writer.writeString(offsets[23], object.defaultScreen);
  writer.writeString(offsets[24], object.deviceCalendarId);
  writer.writeBool(offsets[25], object.deviceCalendarSyncEnabled);
  writer.writeString(offsets[26], object.firstDay);
  writer.writeBool(offsets[27], object.isImage);
  writer.writeString(offsets[28], object.language);
  writer.writeDateTime(offsets[29], object.lastAutoBackupTime);
  writer.writeDateTime(offsets[30], object.lastAutoEraseCompletedTime);
  writer.writeBool(offsets[31], object.materialColor);
  writer.writeLong(offsets[32], object.maxAutoBackups);
  writer.writeBool(offsets[33], object.notificationChannelsMigrated);
  writer.writeBool(offsets[34], object.onboard);
  writer.writeBool(offsets[35], object.screenPrivacy);
  writer.writeLong(offsets[36], object.settingsSchemaVersion);
  writer.writeBool(offsets[37], object.showArchivedInAllTodos);
  writer.writeBool(offsets[38], object.showArchivedInCalendar);
  writer.writeBool(offsets[39], object.showArchivedInStatistics);
  writer.writeLong(offsets[40], object.snoozeDuration);
  writer.writeString(offsets[41], object.theme);
  writer.writeString(offsets[42], object.timeformat);
  writer.writeString(offsets[43], object.todoCardLayout);
}

Settings _settingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Settings();
  object.allTodosSortOption =
      _SettingsallTodosSortOptionValueEnumMap[reader.readByteOrNull(
        offsets[0],
      )] ??
      SortOption.none;
  object.amoledTheme = reader.readBool(offsets[1]);
  object.appFont = reader.readString(offsets[2]);
  object.autoBackupEnabled = reader.readBool(offsets[3]);
  object.autoBackupFrequency =
      _SettingsautoBackupFrequencyValueEnumMap[reader.readByteOrNull(
        offsets[4],
      )] ??
      AutoBackupFrequency.daily;
  object.autoBackupPath = reader.readStringOrNull(offsets[5]);
  object.autoEraseCompletedEnabled = reader.readBool(offsets[6]);
  object.autoEraseCompletedFrequency =
      _SettingsautoEraseCompletedFrequencyValueEnumMap[reader.readByteOrNull(
        offsets[7],
      )] ??
      AutoEraseCompletedFrequency.weekly;
  object.caldavAllowInsecure = reader.readBool(offsets[8]);
  object.caldavCalendarHref = reader.readStringOrNull(offsets[9]);
  object.caldavCalendarName = reader.readStringOrNull(offsets[10]);
  object.caldavCtag = reader.readStringOrNull(offsets[11]);
  object.caldavEnabled = reader.readBool(offsets[12]);
  object.caldavLastError = reader.readStringOrNull(offsets[13]);
  object.caldavLastSyncTime = reader.readDateTimeOrNull(offsets[14]);
  object.caldavPendingDeletes = reader.readString(offsets[15]);
  object.caldavUrl = reader.readStringOrNull(offsets[16]);
  object.caldavUsername = reader.readStringOrNull(offsets[17]);
  object.calendarFormat = reader.readString(offsets[18]);
  object.calendarSortOption =
      _SettingscalendarSortOptionValueEnumMap[reader.readByteOrNull(
        offsets[19],
      )] ??
      SortOption.none;
  object.colorPalette = reader.readString(offsets[20]);
  object.defaultCategoryId = reader.readLongOrNull(offsets[21]);
  object.defaultCategorySeeded = reader.readBool(offsets[22]);
  object.defaultScreen = reader.readString(offsets[23]);
  object.deviceCalendarId = reader.readStringOrNull(offsets[24]);
  object.deviceCalendarSyncEnabled = reader.readBool(offsets[25]);
  object.firstDay = reader.readString(offsets[26]);
  object.id = id;
  object.isImage = reader.readBoolOrNull(offsets[27]);
  object.language = reader.readStringOrNull(offsets[28]);
  object.lastAutoBackupTime = reader.readDateTimeOrNull(offsets[29]);
  object.lastAutoEraseCompletedTime = reader.readDateTimeOrNull(offsets[30]);
  object.materialColor = reader.readBool(offsets[31]);
  object.maxAutoBackups = reader.readLong(offsets[32]);
  object.notificationChannelsMigrated = reader.readBool(offsets[33]);
  object.onboard = reader.readBool(offsets[34]);
  object.screenPrivacy = reader.readBoolOrNull(offsets[35]);
  object.settingsSchemaVersion = reader.readLong(offsets[36]);
  object.showArchivedInAllTodos = reader.readBool(offsets[37]);
  object.showArchivedInCalendar = reader.readBool(offsets[38]);
  object.showArchivedInStatistics = reader.readBool(offsets[39]);
  object.snoozeDuration = reader.readLong(offsets[40]);
  object.theme = reader.readStringOrNull(offsets[41]);
  object.timeformat = reader.readString(offsets[42]);
  object.todoCardLayout = reader.readString(offsets[43]);
  return object;
}

P _settingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_SettingsallTodosSortOptionValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SortOption.none)
          as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (_SettingsautoBackupFrequencyValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              AutoBackupFrequency.daily)
          as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (_SettingsautoEraseCompletedFrequencyValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              AutoEraseCompletedFrequency.weekly)
          as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (_SettingscalendarSortOptionValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SortOption.none)
          as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readLongOrNull(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readBool(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readBoolOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 30:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 31:
      return (reader.readBool(offset)) as P;
    case 32:
      return (reader.readLong(offset)) as P;
    case 33:
      return (reader.readBool(offset)) as P;
    case 34:
      return (reader.readBool(offset)) as P;
    case 35:
      return (reader.readBoolOrNull(offset)) as P;
    case 36:
      return (reader.readLong(offset)) as P;
    case 37:
      return (reader.readBool(offset)) as P;
    case 38:
      return (reader.readBool(offset)) as P;
    case 39:
      return (reader.readBool(offset)) as P;
    case 40:
      return (reader.readLong(offset)) as P;
    case 41:
      return (reader.readStringOrNull(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsallTodosSortOptionEnumValueMap = {
  'none': 0,
  'alphaAsc': 1,
  'alphaDesc': 2,
  'dateAsc': 3,
  'dateDesc': 4,
  'dateNotifAsc': 5,
  'dateNotifDesc': 6,
  'priorityAsc': 7,
  'priorityDesc': 8,
  'random': 9,
};
const _SettingsallTodosSortOptionValueEnumMap = {
  0: SortOption.none,
  1: SortOption.alphaAsc,
  2: SortOption.alphaDesc,
  3: SortOption.dateAsc,
  4: SortOption.dateDesc,
  5: SortOption.dateNotifAsc,
  6: SortOption.dateNotifDesc,
  7: SortOption.priorityAsc,
  8: SortOption.priorityDesc,
  9: SortOption.random,
};
const _SettingsautoBackupFrequencyEnumValueMap = {
  'daily': 0,
  'weekly': 1,
  'monthly': 2,
};
const _SettingsautoBackupFrequencyValueEnumMap = {
  0: AutoBackupFrequency.daily,
  1: AutoBackupFrequency.weekly,
  2: AutoBackupFrequency.monthly,
};
const _SettingsautoEraseCompletedFrequencyEnumValueMap = {
  'weekly': 0,
  'monthly': 1,
};
const _SettingsautoEraseCompletedFrequencyValueEnumMap = {
  0: AutoEraseCompletedFrequency.weekly,
  1: AutoEraseCompletedFrequency.monthly,
};
const _SettingscalendarSortOptionEnumValueMap = {
  'none': 0,
  'alphaAsc': 1,
  'alphaDesc': 2,
  'dateAsc': 3,
  'dateDesc': 4,
  'dateNotifAsc': 5,
  'dateNotifDesc': 6,
  'priorityAsc': 7,
  'priorityDesc': 8,
  'random': 9,
};
const _SettingscalendarSortOptionValueEnumMap = {
  0: SortOption.none,
  1: SortOption.alphaAsc,
  2: SortOption.alphaDesc,
  3: SortOption.dateAsc,
  4: SortOption.dateDesc,
  5: SortOption.dateNotifAsc,
  6: SortOption.dateNotifDesc,
  7: SortOption.priorityAsc,
  8: SortOption.priorityDesc,
  9: SortOption.random,
};

Id _settingsGetId(Settings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsGetLinks(Settings object) {
  return [];
}

void _settingsAttach(IsarCollection<dynamic> col, Id id, Settings object) {
  object.id = id;
}

extension SettingsQueryWhereSort on QueryBuilder<Settings, Settings, QWhere> {
  QueryBuilder<Settings, Settings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsQueryWhere on QueryBuilder<Settings, Settings, QWhereClause> {
  QueryBuilder<Settings, Settings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SettingsQueryFilter
    on QueryBuilder<Settings, Settings, QFilterCondition> {
  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  allTodosSortOptionEqualTo(SortOption value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'allTodosSortOption', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  allTodosSortOptionGreaterThan(SortOption value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'allTodosSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  allTodosSortOptionLessThan(SortOption value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'allTodosSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  allTodosSortOptionBetween(
    SortOption lower,
    SortOption upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'allTodosSortOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> amoledThemeEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'amoledTheme', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'appFont',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'appFont',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'appFont',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'appFont', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> appFontIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'appFont', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoBackupEnabled', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupFrequencyEqualTo(AutoBackupFrequency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoBackupFrequency', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupFrequencyGreaterThan(
    AutoBackupFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoBackupFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupFrequencyLessThan(
    AutoBackupFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoBackupFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupFrequencyBetween(
    AutoBackupFrequency lower,
    AutoBackupFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoBackupFrequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'autoBackupPath'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'autoBackupPath'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> autoBackupPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> autoBackupPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoBackupPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'autoBackupPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> autoBackupPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'autoBackupPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoBackupPath', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoBackupPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'autoBackupPath', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoEraseCompletedEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoEraseCompletedEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoEraseCompletedFrequencyEqualTo(AutoEraseCompletedFrequency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'autoEraseCompletedFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoEraseCompletedFrequencyGreaterThan(
    AutoEraseCompletedFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoEraseCompletedFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoEraseCompletedFrequencyLessThan(
    AutoEraseCompletedFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoEraseCompletedFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  autoEraseCompletedFrequencyBetween(
    AutoEraseCompletedFrequency lower,
    AutoEraseCompletedFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoEraseCompletedFrequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavAllowInsecureEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavAllowInsecure', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavCalendarHref'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavCalendarHref'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavCalendarHref',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavCalendarHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavCalendarHref',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavCalendarHref', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavCalendarHref', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavCalendarName'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavCalendarName'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavCalendarName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavCalendarName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavCalendarName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavCalendarName', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCalendarNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavCalendarName', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavCtag'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCtagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavCtag'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavCtag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavCtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavCtag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavCtagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavCtag', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavCtagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavCtag', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavEnabled', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavLastError'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavLastError'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavLastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavLastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavLastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavLastError', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavLastError', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavLastSyncTime'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavLastSyncTime'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavLastSyncTime', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavLastSyncTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavLastSyncTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavLastSyncTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavLastSyncTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavPendingDeletes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavPendingDeletes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavPendingDeletes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavPendingDeletes', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavPendingDeletesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'caldavPendingDeletes',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavUrl'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavUrl'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavUrl', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavUrl', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavUsername'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavUsername'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUsernameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUsernameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavUsername',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> caldavUsernameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavUsername',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavUsername', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  caldavUsernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavUsername', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> calendarFormatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> calendarFormatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calendarFormat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'calendarFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> calendarFormatMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'calendarFormat',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calendarFormat', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarFormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'calendarFormat', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarSortOptionEqualTo(SortOption value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calendarSortOption', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarSortOptionGreaterThan(SortOption value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calendarSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarSortOptionLessThan(SortOption value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calendarSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  calendarSortOptionBetween(
    SortOption lower,
    SortOption upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calendarSortOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  colorPaletteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'colorPalette',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  colorPaletteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'colorPalette',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> colorPaletteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'colorPalette',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  colorPaletteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorPalette', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  colorPaletteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'colorPalette', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'defaultCategoryId'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'defaultCategoryId'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultCategoryId', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultCategoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultCategoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultCategoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultCategorySeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'defaultCategorySeeded',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultScreenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'defaultScreen',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultScreenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'defaultScreen',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> defaultScreenMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'defaultScreen',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultScreenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'defaultScreen', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  defaultScreenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'defaultScreen', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deviceCalendarId'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deviceCalendarId'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceCalendarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceCalendarId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceCalendarId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceCalendarId', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceCalendarId', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  deviceCalendarSyncEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceCalendarSyncEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'firstDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'firstDay',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'firstDay',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'firstDay', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> firstDayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'firstDay', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> isImageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'isImage'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> isImageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'isImage'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> isImageEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isImage', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'language'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'language'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAutoBackupTime'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAutoBackupTime'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAutoBackupTime', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAutoBackupTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAutoBackupTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoBackupTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAutoBackupTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAutoEraseCompletedTime'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(
          property: r'lastAutoEraseCompletedTime',
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastAutoEraseCompletedTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAutoEraseCompletedTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAutoEraseCompletedTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  lastAutoEraseCompletedTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAutoEraseCompletedTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> materialColorEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'materialColor', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> maxAutoBackupsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maxAutoBackups', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  maxAutoBackupsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maxAutoBackups',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  maxAutoBackupsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maxAutoBackups',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> maxAutoBackupsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maxAutoBackups',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  notificationChannelsMigratedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notificationChannelsMigrated',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> onboardEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onboard', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  screenPrivacyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'screenPrivacy'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  screenPrivacyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'screenPrivacy'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> screenPrivacyEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'screenPrivacy', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  settingsSchemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'settingsSchemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  settingsSchemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'settingsSchemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  settingsSchemaVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'settingsSchemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  settingsSchemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'settingsSchemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  showArchivedInAllTodosEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'showArchivedInAllTodos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  showArchivedInCalendarEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'showArchivedInCalendar',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  showArchivedInStatisticsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'showArchivedInStatistics',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> snoozeDurationEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'snoozeDuration', value: value),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  snoozeDurationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'snoozeDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  snoozeDurationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'snoozeDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> snoozeDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'snoozeDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'theme'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'theme'),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'theme',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'theme',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'theme', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'theme', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeformat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'timeformat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'timeformat',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> timeformatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeformat', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  timeformatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'timeformat', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> todoCardLayoutEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> todoCardLayoutBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'todoCardLayout',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'todoCardLayout',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> todoCardLayoutMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'todoCardLayout',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'todoCardLayout', value: ''),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
  todoCardLayoutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'todoCardLayout', value: ''),
      );
    });
  }
}

extension SettingsQueryObject
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQueryLinks
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQuerySortBy on QueryBuilder<Settings, Settings, QSortBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAllTodosSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allTodosSortOption', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAllTodosSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allTodosSortOption', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAmoledTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amoledTheme', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAmoledThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amoledTheme', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAppFont() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appFont', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAppFontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appFont', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAutoBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAutoBackupFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupFrequency', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAutoBackupFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupFrequency', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAutoBackupPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupPath', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByAutoBackupPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupPath', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAutoEraseCompletedEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAutoEraseCompletedEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAutoEraseCompletedFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedFrequency', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByAutoEraseCompletedFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedFrequency', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavAllowInsecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavAllowInsecure', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCaldavAllowInsecureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavAllowInsecure', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavCalendarHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarHref', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCaldavCalendarHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarHref', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavCalendarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarName', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCaldavCalendarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarName', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavCtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCtag', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavCtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCtag', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastError', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastError', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCaldavLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavPendingDeletes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavPendingDeletes', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCaldavPendingDeletesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavPendingDeletes', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUrl', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUrl', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUsername', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCaldavUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUsername', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCalendarFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarFormat', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCalendarFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarFormat', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCalendarSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarSortOption', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByCalendarSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarSortOption', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByColorPalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorPalette', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByColorPaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorPalette', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategoryId', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategoryId', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultCategorySeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategorySeeded', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByDefaultCategorySeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategorySeeded', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultScreen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultScreen', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDefaultScreenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultScreen', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDeviceCalendarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarId', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDeviceCalendarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarId', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByDeviceCalendarSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByDeviceCalendarSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByFirstDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstDay', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByFirstDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstDay', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByIsImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImage', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByIsImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImage', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLastAutoBackupTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoBackupTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByLastAutoBackupTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoBackupTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByLastAutoEraseCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoEraseCompletedTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByLastAutoEraseCompletedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoEraseCompletedTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMaterialColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialColor', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMaterialColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialColor', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMaxAutoBackups() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAutoBackups', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMaxAutoBackupsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAutoBackups', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByNotificationChannelsMigrated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationChannelsMigrated', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByNotificationChannelsMigratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationChannelsMigrated', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByOnboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboard', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByOnboardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboard', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByScreenPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenPrivacy', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByScreenPrivacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenPrivacy', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortBySettingsSchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsSchemaVersion', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortBySettingsSchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsSchemaVersion', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInAllTodos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInAllTodos', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInAllTodosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInAllTodos', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInCalendar', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInCalendar', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInStatistics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInStatistics', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  sortByShowArchivedInStatisticsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInStatistics', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortBySnoozeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDuration', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortBySnoozeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDuration', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByTimeformat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeformat', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByTimeformatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeformat', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByTodoCardLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCardLayout', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByTodoCardLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCardLayout', Sort.desc);
    });
  }
}

extension SettingsQuerySortThenBy
    on QueryBuilder<Settings, Settings, QSortThenBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAllTodosSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allTodosSortOption', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAllTodosSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'allTodosSortOption', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAmoledTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amoledTheme', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAmoledThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amoledTheme', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAppFont() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appFont', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAppFontDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appFont', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAutoBackupEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAutoBackupFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupFrequency', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAutoBackupFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupFrequency', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAutoBackupPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupPath', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByAutoBackupPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoBackupPath', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAutoEraseCompletedEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAutoEraseCompletedEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAutoEraseCompletedFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedFrequency', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByAutoEraseCompletedFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoEraseCompletedFrequency', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavAllowInsecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavAllowInsecure', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCaldavAllowInsecureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavAllowInsecure', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavCalendarHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarHref', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCaldavCalendarHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarHref', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavCalendarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarName', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCaldavCalendarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCalendarName', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavCtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCtag', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavCtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavCtag', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastError', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastError', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastSyncTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCaldavLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavLastSyncTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavPendingDeletes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavPendingDeletes', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCaldavPendingDeletesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavPendingDeletes', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUrl', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUrl', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUsername', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCaldavUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUsername', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCalendarFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarFormat', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCalendarFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarFormat', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCalendarSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarSortOption', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByCalendarSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calendarSortOption', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByColorPalette() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorPalette', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByColorPaletteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorPalette', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategoryId', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategoryId', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultCategorySeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategorySeeded', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByDefaultCategorySeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategorySeeded', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultScreen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultScreen', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDefaultScreenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultScreen', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDeviceCalendarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarId', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDeviceCalendarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarId', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByDeviceCalendarSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarSyncEnabled', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByDeviceCalendarSyncEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarSyncEnabled', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByFirstDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstDay', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByFirstDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstDay', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByIsImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImage', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByIsImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isImage', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLastAutoBackupTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoBackupTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByLastAutoBackupTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoBackupTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByLastAutoEraseCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoEraseCompletedTime', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByLastAutoEraseCompletedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoEraseCompletedTime', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMaterialColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialColor', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMaterialColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'materialColor', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMaxAutoBackups() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAutoBackups', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMaxAutoBackupsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxAutoBackups', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByNotificationChannelsMigrated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationChannelsMigrated', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByNotificationChannelsMigratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationChannelsMigrated', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByOnboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboard', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByOnboardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboard', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByScreenPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenPrivacy', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByScreenPrivacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'screenPrivacy', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenBySettingsSchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsSchemaVersion', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenBySettingsSchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'settingsSchemaVersion', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInAllTodos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInAllTodos', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInAllTodosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInAllTodos', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInCalendar', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInCalendar', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInStatistics() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInStatistics', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
  thenByShowArchivedInStatisticsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showArchivedInStatistics', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenBySnoozeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDuration', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenBySnoozeDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snoozeDuration', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByTimeformat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeformat', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByTimeformatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeformat', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByTodoCardLayout() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCardLayout', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByTodoCardLayoutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCardLayout', Sort.desc);
    });
  }
}

extension SettingsQueryWhereDistinct
    on QueryBuilder<Settings, Settings, QDistinct> {
  QueryBuilder<Settings, Settings, QDistinct> distinctByAllTodosSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allTodosSortOption');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByAmoledTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amoledTheme');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByAppFont({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appFont', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByAutoBackupEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoBackupEnabled');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByAutoBackupFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoBackupFrequency');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByAutoBackupPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'autoBackupPath',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByAutoEraseCompletedEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoEraseCompletedEnabled');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByAutoEraseCompletedFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoEraseCompletedFrequency');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavAllowInsecure() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavAllowInsecure');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavCalendarHref({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caldavCalendarHref',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavCalendarName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caldavCalendarName',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavCtag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavCtag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavEnabled');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavLastError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caldavLastError',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavLastSyncTime');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavPendingDeletes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caldavPendingDeletes',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCaldavUsername({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'caldavUsername',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCalendarFormat({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'calendarFormat',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCalendarSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calendarSortOption');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByColorPalette({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorPalette', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByDefaultCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultCategoryId');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByDefaultCategorySeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultCategorySeeded');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByDefaultScreen({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'defaultScreen',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByDeviceCalendarId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'deviceCalendarId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByDeviceCalendarSyncEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceCalendarSyncEnabled');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByFirstDay({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstDay', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByIsImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isImage');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByLanguage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByLastAutoBackupTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAutoBackupTime');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByLastAutoEraseCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAutoEraseCompletedTime');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByMaterialColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'materialColor');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByMaxAutoBackups() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxAutoBackups');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByNotificationChannelsMigrated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationChannelsMigrated');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByOnboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboard');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByScreenPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'screenPrivacy');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctBySettingsSchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'settingsSchemaVersion');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByShowArchivedInAllTodos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showArchivedInAllTodos');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByShowArchivedInCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showArchivedInCalendar');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct>
  distinctByShowArchivedInStatistics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showArchivedInStatistics');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctBySnoozeDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snoozeDuration');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByTheme({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByTimeformat({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeformat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByTodoCardLayout({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'todoCardLayout',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SettingsQueryProperty
    on QueryBuilder<Settings, Settings, QQueryProperty> {
  QueryBuilder<Settings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Settings, SortOption, QQueryOperations>
  allTodosSortOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allTodosSortOption');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> amoledThemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amoledTheme');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> appFontProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appFont');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> autoBackupEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoBackupEnabled');
    });
  }

  QueryBuilder<Settings, AutoBackupFrequency, QQueryOperations>
  autoBackupFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoBackupFrequency');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> autoBackupPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoBackupPath');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  autoEraseCompletedEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoEraseCompletedEnabled');
    });
  }

  QueryBuilder<Settings, AutoEraseCompletedFrequency, QQueryOperations>
  autoEraseCompletedFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoEraseCompletedFrequency');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> caldavAllowInsecureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavAllowInsecure');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations>
  caldavCalendarHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavCalendarHref');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations>
  caldavCalendarNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavCalendarName');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> caldavCtagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavCtag');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> caldavEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavEnabled');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> caldavLastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavLastError');
    });
  }

  QueryBuilder<Settings, DateTime?, QQueryOperations>
  caldavLastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavLastSyncTime');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations>
  caldavPendingDeletesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavPendingDeletes');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> caldavUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavUrl');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> caldavUsernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavUsername');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> calendarFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calendarFormat');
    });
  }

  QueryBuilder<Settings, SortOption, QQueryOperations>
  calendarSortOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calendarSortOption');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> colorPaletteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorPalette');
    });
  }

  QueryBuilder<Settings, int?, QQueryOperations> defaultCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultCategoryId');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  defaultCategorySeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultCategorySeeded');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> defaultScreenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultScreen');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> deviceCalendarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceCalendarId');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  deviceCalendarSyncEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceCalendarSyncEnabled');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> firstDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstDay');
    });
  }

  QueryBuilder<Settings, bool?, QQueryOperations> isImageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isImage');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Settings, DateTime?, QQueryOperations>
  lastAutoBackupTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAutoBackupTime');
    });
  }

  QueryBuilder<Settings, DateTime?, QQueryOperations>
  lastAutoEraseCompletedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAutoEraseCompletedTime');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> materialColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'materialColor');
    });
  }

  QueryBuilder<Settings, int, QQueryOperations> maxAutoBackupsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxAutoBackups');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  notificationChannelsMigratedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationChannelsMigrated');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> onboardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboard');
    });
  }

  QueryBuilder<Settings, bool?, QQueryOperations> screenPrivacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'screenPrivacy');
    });
  }

  QueryBuilder<Settings, int, QQueryOperations>
  settingsSchemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'settingsSchemaVersion');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  showArchivedInAllTodosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showArchivedInAllTodos');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  showArchivedInCalendarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showArchivedInCalendar');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations>
  showArchivedInStatisticsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showArchivedInStatistics');
    });
  }

  QueryBuilder<Settings, int, QQueryOperations> snoozeDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snoozeDuration');
    });
  }

  QueryBuilder<Settings, String?, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> timeformatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeformat');
    });
  }

  QueryBuilder<Settings, String, QQueryOperations> todoCardLayoutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todoCardLayout');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTasksCollection on Isar {
  IsarCollection<Tasks> get tasks => this.collection();
}

const TasksSchema = CollectionSchema(
  name: r'Tasks',
  id: 5694065972011835967,
  properties: {
    r'archive': PropertySchema(id: 0, name: r'archive', type: IsarType.bool),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'index': PropertySchema(id: 2, name: r'index', type: IsarType.long),
    r'isSystem': PropertySchema(id: 3, name: r'isSystem', type: IsarType.bool),
    r'recurrence': PropertySchema(
      id: 4,
      name: r'recurrence',
      type: IsarType.byte,
      enumMap: _TasksrecurrenceEnumValueMap,
    ),
    r'recurrenceMinuteOfDay': PropertySchema(
      id: 5,
      name: r'recurrenceMinuteOfDay',
      type: IsarType.long,
    ),
    r'recurrenceMode': PropertySchema(
      id: 6,
      name: r'recurrenceMode',
      type: IsarType.byte,
      enumMap: _TasksrecurrenceModeEnumValueMap,
    ),
    r'recurrenceWeekdays': PropertySchema(
      id: 7,
      name: r'recurrenceWeekdays',
      type: IsarType.longList,
    ),
    r'sortOption': PropertySchema(
      id: 8,
      name: r'sortOption',
      type: IsarType.byte,
      enumMap: _TaskssortOptionEnumValueMap,
    ),
    r'taskColor': PropertySchema(
      id: 9,
      name: r'taskColor',
      type: IsarType.long,
    ),
    r'title': PropertySchema(id: 10, name: r'title', type: IsarType.string),
  },

  estimateSize: _tasksEstimateSize,
  serialize: _tasksSerialize,
  deserialize: _tasksDeserialize,
  deserializeProp: _tasksDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'todos': LinkSchema(
      id: -2841613509957218706,
      name: r'todos',
      target: r'Todos',
      single: false,
      linkName: r'task',
    ),
  },
  embeddedSchemas: {},

  getId: _tasksGetId,
  getLinks: _tasksGetLinks,
  attach: _tasksAttach,
  version: '3.3.2',
);

int _tasksEstimateSize(
  Tasks object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.recurrenceWeekdays.length * 8;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _tasksSerialize(
  Tasks object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.archive);
  writer.writeString(offsets[1], object.description);
  writer.writeLong(offsets[2], object.index);
  writer.writeBool(offsets[3], object.isSystem);
  writer.writeByte(offsets[4], object.recurrence.index);
  writer.writeLong(offsets[5], object.recurrenceMinuteOfDay);
  writer.writeByte(offsets[6], object.recurrenceMode.index);
  writer.writeLongList(offsets[7], object.recurrenceWeekdays);
  writer.writeByte(offsets[8], object.sortOption.index);
  writer.writeLong(offsets[9], object.taskColor);
  writer.writeString(offsets[10], object.title);
}

Tasks _tasksDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Tasks(
    archive: reader.readBoolOrNull(offsets[0]) ?? false,
    description: reader.readStringOrNull(offsets[1]) ?? '',
    id: id,
    index: reader.readLongOrNull(offsets[2]),
    isSystem: reader.readBoolOrNull(offsets[3]) ?? false,
    recurrence:
        _TasksrecurrenceValueEnumMap[reader.readByteOrNull(offsets[4])] ??
        RecurrenceFrequency.none,
    recurrenceMinuteOfDay: reader.readLongOrNull(offsets[5]),
    recurrenceMode:
        _TasksrecurrenceModeValueEnumMap[reader.readByteOrNull(offsets[6])] ??
        RecurrenceMode.reopen,
    recurrenceWeekdays: reader.readLongList(offsets[7]) ?? const [],
    sortOption:
        _TaskssortOptionValueEnumMap[reader.readByteOrNull(offsets[8])] ??
        SortOption.none,
    taskColor: reader.readLong(offsets[9]),
    title: reader.readString(offsets[10]),
  );
  return object;
}

P _tasksDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (_TasksrecurrenceValueEnumMap[reader.readByteOrNull(offset)] ??
              RecurrenceFrequency.none)
          as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (_TasksrecurrenceModeValueEnumMap[reader.readByteOrNull(offset)] ??
              RecurrenceMode.reopen)
          as P;
    case 7:
      return (reader.readLongList(offset) ?? const []) as P;
    case 8:
      return (_TaskssortOptionValueEnumMap[reader.readByteOrNull(offset)] ??
              SortOption.none)
          as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TasksrecurrenceEnumValueMap = {
  'none': 0,
  'daily': 1,
  'weekly': 2,
  'monthly': 3,
};
const _TasksrecurrenceValueEnumMap = {
  0: RecurrenceFrequency.none,
  1: RecurrenceFrequency.daily,
  2: RecurrenceFrequency.weekly,
  3: RecurrenceFrequency.monthly,
};
const _TasksrecurrenceModeEnumValueMap = {'clone': 0, 'reopen': 1};
const _TasksrecurrenceModeValueEnumMap = {
  0: RecurrenceMode.clone,
  1: RecurrenceMode.reopen,
};
const _TaskssortOptionEnumValueMap = {
  'none': 0,
  'alphaAsc': 1,
  'alphaDesc': 2,
  'dateAsc': 3,
  'dateDesc': 4,
  'dateNotifAsc': 5,
  'dateNotifDesc': 6,
  'priorityAsc': 7,
  'priorityDesc': 8,
  'random': 9,
};
const _TaskssortOptionValueEnumMap = {
  0: SortOption.none,
  1: SortOption.alphaAsc,
  2: SortOption.alphaDesc,
  3: SortOption.dateAsc,
  4: SortOption.dateDesc,
  5: SortOption.dateNotifAsc,
  6: SortOption.dateNotifDesc,
  7: SortOption.priorityAsc,
  8: SortOption.priorityDesc,
  9: SortOption.random,
};

Id _tasksGetId(Tasks object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tasksGetLinks(Tasks object) {
  return [object.todos];
}

void _tasksAttach(IsarCollection<dynamic> col, Id id, Tasks object) {
  object.id = id;
  object.todos.attach(col, col.isar.collection<Todos>(), r'todos', id);
}

extension TasksQueryWhereSort on QueryBuilder<Tasks, Tasks, QWhere> {
  QueryBuilder<Tasks, Tasks, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TasksQueryWhere on QueryBuilder<Tasks, Tasks, QWhereClause> {
  QueryBuilder<Tasks, Tasks, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TasksQueryFilter on QueryBuilder<Tasks, Tasks, QFilterCondition> {
  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> archiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'archive', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'index'),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'index'),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'index', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> indexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'index',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> isSystemEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSystem', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceEqualTo(
    RecurrenceFrequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrence', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceGreaterThan(
    RecurrenceFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceLessThan(
    RecurrenceFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceBetween(
    RecurrenceFrequency lower,
    RecurrenceFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recurrenceMinuteOfDay'),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recurrenceMinuteOfDay'),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceMinuteOfDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceMinuteOfDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceModeEqualTo(
    RecurrenceMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceMode', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceModeGreaterThan(
    RecurrenceMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceModeLessThan(
    RecurrenceMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> recurrenceModeBetween(
    RecurrenceMode lower,
    RecurrenceMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceWeekdays', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceWeekdays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceWeekdays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceWeekdays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, true, 0, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, false, 999999, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, true, length, include);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition>
  recurrenceWeekdaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> sortOptionEqualTo(
    SortOption value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOption', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> sortOptionGreaterThan(
    SortOption value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> sortOptionLessThan(
    SortOption value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> sortOptionBetween(
    SortOption lower,
    SortOption upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> taskColorEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'taskColor', value: value),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> taskColorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'taskColor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> taskColorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'taskColor',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> taskColorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'taskColor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension TasksQueryObject on QueryBuilder<Tasks, Tasks, QFilterCondition> {}

extension TasksQueryLinks on QueryBuilder<Tasks, Tasks, QFilterCondition> {
  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todos(
    FilterQuery<Todos> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'todos');
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todos', length, true, length, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todos', 0, true, 0, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todos', 0, false, 999999, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todos', 0, true, length, include);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'todos', length, include, 999999, true);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterFilterCondition> todosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'todos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TasksQuerySortBy on QueryBuilder<Tasks, Tasks, QSortBy> {
  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByArchive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archive', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByArchiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archive', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByIsSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrenceMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByRecurrenceModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortBySortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByTaskColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskColor', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByTaskColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskColor', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TasksQuerySortThenBy on QueryBuilder<Tasks, Tasks, QSortThenBy> {
  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByArchive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archive', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByArchiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'archive', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByIsSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrenceMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByRecurrenceModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenBySortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByTaskColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskColor', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByTaskColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskColor', Sort.desc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Tasks, Tasks, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension TasksQueryWhereDistinct on QueryBuilder<Tasks, Tasks, QDistinct> {
  QueryBuilder<Tasks, Tasks, QDistinct> distinctByArchive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'archive');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'index');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSystem');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrence');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceMinuteOfDay');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceMode');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByRecurrenceWeekdays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceWeekdays');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOption');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByTaskColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskColor');
    });
  }

  QueryBuilder<Tasks, Tasks, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension TasksQueryProperty on QueryBuilder<Tasks, Tasks, QQueryProperty> {
  QueryBuilder<Tasks, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Tasks, bool, QQueryOperations> archiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'archive');
    });
  }

  QueryBuilder<Tasks, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Tasks, int?, QQueryOperations> indexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'index');
    });
  }

  QueryBuilder<Tasks, bool, QQueryOperations> isSystemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSystem');
    });
  }

  QueryBuilder<Tasks, RecurrenceFrequency, QQueryOperations>
  recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrence');
    });
  }

  QueryBuilder<Tasks, int?, QQueryOperations> recurrenceMinuteOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceMinuteOfDay');
    });
  }

  QueryBuilder<Tasks, RecurrenceMode, QQueryOperations>
  recurrenceModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceMode');
    });
  }

  QueryBuilder<Tasks, List<int>, QQueryOperations>
  recurrenceWeekdaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceWeekdays');
    });
  }

  QueryBuilder<Tasks, SortOption, QQueryOperations> sortOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOption');
    });
  }

  QueryBuilder<Tasks, int, QQueryOperations> taskColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskColor');
    });
  }

  QueryBuilder<Tasks, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTodosCollection on Isar {
  IsarCollection<Todos> get todos => this.collection();
}

const TodosSchema = CollectionSchema(
  name: r'Todos',
  id: 6051122207432693743,
  properties: {
    r'caldavDirty': PropertySchema(
      id: 0,
      name: r'caldavDirty',
      type: IsarType.bool,
    ),
    r'caldavEtag': PropertySchema(
      id: 1,
      name: r'caldavEtag',
      type: IsarType.string,
    ),
    r'caldavHref': PropertySchema(
      id: 2,
      name: r'caldavHref',
      type: IsarType.string,
    ),
    r'caldavUid': PropertySchema(
      id: 3,
      name: r'caldavUid',
      type: IsarType.string,
    ),
    r'childrenSortOption': PropertySchema(
      id: 4,
      name: r'childrenSortOption',
      type: IsarType.byte,
      enumMap: _TodoschildrenSortOptionEnumValueMap,
    ),
    r'completedAt': PropertySchema(
      id: 5,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdTime': PropertySchema(
      id: 6,
      name: r'createdTime',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 7,
      name: r'description',
      type: IsarType.string,
    ),
    r'deviceCalendarEventId': PropertySchema(
      id: 8,
      name: r'deviceCalendarEventId',
      type: IsarType.string,
    ),
    r'done': PropertySchema(id: 9, name: r'done', type: IsarType.bool),
    r'dueAt': PropertySchema(id: 10, name: r'dueAt', type: IsarType.dateTime),
    r'fix': PropertySchema(id: 11, name: r'fix', type: IsarType.bool),
    r'index': PropertySchema(id: 12, name: r'index', type: IsarType.long),
    r'name': PropertySchema(id: 13, name: r'name', type: IsarType.string),
    r'priority': PropertySchema(
      id: 14,
      name: r'priority',
      type: IsarType.byte,
      enumMap: _TodospriorityEnumValueMap,
    ),
    r'recurrence': PropertySchema(
      id: 15,
      name: r'recurrence',
      type: IsarType.byte,
      enumMap: _TodosrecurrenceEnumValueMap,
    ),
    r'recurrenceMinuteOfDay': PropertySchema(
      id: 16,
      name: r'recurrenceMinuteOfDay',
      type: IsarType.long,
    ),
    r'recurrenceMode': PropertySchema(
      id: 17,
      name: r'recurrenceMode',
      type: IsarType.byte,
      enumMap: _TodosrecurrenceModeEnumValueMap,
    ),
    r'recurrenceWeekdays': PropertySchema(
      id: 18,
      name: r'recurrenceWeekdays',
      type: IsarType.longList,
    ),
    r'status': PropertySchema(
      id: 19,
      name: r'status',
      type: IsarType.byte,
      enumMap: _TodosstatusEnumValueMap,
    ),
    r'tags': PropertySchema(id: 20, name: r'tags', type: IsarType.stringList),
    r'todoCompletedTime': PropertySchema(
      id: 21,
      name: r'todoCompletedTime',
      type: IsarType.dateTime,
    ),
    r'todoCompletionTime': PropertySchema(
      id: 22,
      name: r'todoCompletionTime',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _todosEstimateSize,
  serialize: _todosSerialize,
  deserialize: _todosDeserialize,
  deserializeProp: _todosDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'parent': LinkSchema(
      id: 6308854949126399580,
      name: r'parent',
      target: r'Todos',
      single: true,
    ),
    r'children': LinkSchema(
      id: 7196993719779404499,
      name: r'children',
      target: r'Todos',
      single: false,
      linkName: r'parent',
    ),
    r'task': LinkSchema(
      id: 984463211636766827,
      name: r'task',
      target: r'Tasks',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _todosGetId,
  getLinks: _todosGetLinks,
  attach: _todosAttach,
  version: '3.3.2',
);

int _todosEstimateSize(
  Todos object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.caldavEtag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavHref;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.caldavUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.deviceCalendarEventId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.recurrenceWeekdays.length * 8;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _todosSerialize(
  Todos object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.caldavDirty);
  writer.writeString(offsets[1], object.caldavEtag);
  writer.writeString(offsets[2], object.caldavHref);
  writer.writeString(offsets[3], object.caldavUid);
  writer.writeByte(offsets[4], object.childrenSortOption.index);
  writer.writeDateTime(offsets[5], object.completedAt);
  writer.writeDateTime(offsets[6], object.createdTime);
  writer.writeString(offsets[7], object.description);
  writer.writeString(offsets[8], object.deviceCalendarEventId);
  writer.writeBool(offsets[9], object.done);
  writer.writeDateTime(offsets[10], object.dueAt);
  writer.writeBool(offsets[11], object.fix);
  writer.writeLong(offsets[12], object.index);
  writer.writeString(offsets[13], object.name);
  writer.writeByte(offsets[14], object.priority.index);
  writer.writeByte(offsets[15], object.recurrence.index);
  writer.writeLong(offsets[16], object.recurrenceMinuteOfDay);
  writer.writeByte(offsets[17], object.recurrenceMode.index);
  writer.writeLongList(offsets[18], object.recurrenceWeekdays);
  writer.writeByte(offsets[19], object.status.index);
  writer.writeStringList(offsets[20], object.tags);
  writer.writeDateTime(offsets[21], object.todoCompletedTime);
  writer.writeDateTime(offsets[22], object.todoCompletionTime);
}

Todos _todosDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Todos(
    createdTime: reader.readDateTime(offsets[6]),
    description: reader.readStringOrNull(offsets[7]) ?? '',
    done: reader.readBoolOrNull(offsets[9]) ?? false,
    fix: reader.readBoolOrNull(offsets[11]) ?? false,
    id: id,
    index: reader.readLongOrNull(offsets[12]),
    name: reader.readString(offsets[13]),
    priority:
        _TodospriorityValueEnumMap[reader.readByteOrNull(offsets[14])] ??
        Priority.none,
    recurrence:
        _TodosrecurrenceValueEnumMap[reader.readByteOrNull(offsets[15])] ??
        RecurrenceFrequency.none,
    recurrenceMinuteOfDay: reader.readLongOrNull(offsets[16]),
    recurrenceMode:
        _TodosrecurrenceModeValueEnumMap[reader.readByteOrNull(offsets[17])] ??
        RecurrenceMode.clone,
    recurrenceWeekdays: reader.readLongList(offsets[18]) ?? const [],
    status:
        _TodosstatusValueEnumMap[reader.readByteOrNull(offsets[19])] ??
        TodoStatus.active,
    tags: reader.readStringList(offsets[20]) ?? const [],
    todoCompletedTime: reader.readDateTimeOrNull(offsets[21]),
    todoCompletionTime: reader.readDateTimeOrNull(offsets[22]),
  );
  object.caldavDirty = reader.readBool(offsets[0]);
  object.caldavEtag = reader.readStringOrNull(offsets[1]);
  object.caldavHref = reader.readStringOrNull(offsets[2]);
  object.caldavUid = reader.readStringOrNull(offsets[3]);
  object.childrenSortOption =
      _TodoschildrenSortOptionValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      SortOption.none;
  object.completedAt = reader.readDateTimeOrNull(offsets[5]);
  object.deviceCalendarEventId = reader.readStringOrNull(offsets[8]);
  object.dueAt = reader.readDateTimeOrNull(offsets[10]);
  return object;
}

P _todosDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (_TodoschildrenSortOptionValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SortOption.none)
          as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (_TodospriorityValueEnumMap[reader.readByteOrNull(offset)] ??
              Priority.none)
          as P;
    case 15:
      return (_TodosrecurrenceValueEnumMap[reader.readByteOrNull(offset)] ??
              RecurrenceFrequency.none)
          as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (_TodosrecurrenceModeValueEnumMap[reader.readByteOrNull(offset)] ??
              RecurrenceMode.clone)
          as P;
    case 18:
      return (reader.readLongList(offset) ?? const []) as P;
    case 19:
      return (_TodosstatusValueEnumMap[reader.readByteOrNull(offset)] ??
              TodoStatus.active)
          as P;
    case 20:
      return (reader.readStringList(offset) ?? const []) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TodoschildrenSortOptionEnumValueMap = {
  'none': 0,
  'alphaAsc': 1,
  'alphaDesc': 2,
  'dateAsc': 3,
  'dateDesc': 4,
  'dateNotifAsc': 5,
  'dateNotifDesc': 6,
  'priorityAsc': 7,
  'priorityDesc': 8,
  'random': 9,
};
const _TodoschildrenSortOptionValueEnumMap = {
  0: SortOption.none,
  1: SortOption.alphaAsc,
  2: SortOption.alphaDesc,
  3: SortOption.dateAsc,
  4: SortOption.dateDesc,
  5: SortOption.dateNotifAsc,
  6: SortOption.dateNotifDesc,
  7: SortOption.priorityAsc,
  8: SortOption.priorityDesc,
  9: SortOption.random,
};
const _TodospriorityEnumValueMap = {
  'high': 0,
  'medium': 1,
  'low': 2,
  'none': 3,
};
const _TodospriorityValueEnumMap = {
  0: Priority.high,
  1: Priority.medium,
  2: Priority.low,
  3: Priority.none,
};
const _TodosrecurrenceEnumValueMap = {
  'none': 0,
  'daily': 1,
  'weekly': 2,
  'monthly': 3,
};
const _TodosrecurrenceValueEnumMap = {
  0: RecurrenceFrequency.none,
  1: RecurrenceFrequency.daily,
  2: RecurrenceFrequency.weekly,
  3: RecurrenceFrequency.monthly,
};
const _TodosrecurrenceModeEnumValueMap = {'clone': 0, 'reopen': 1};
const _TodosrecurrenceModeValueEnumMap = {
  0: RecurrenceMode.clone,
  1: RecurrenceMode.reopen,
};
const _TodosstatusEnumValueMap = {'active': 0, 'done': 1, 'cancelled': 2};
const _TodosstatusValueEnumMap = {
  0: TodoStatus.active,
  1: TodoStatus.done,
  2: TodoStatus.cancelled,
};

Id _todosGetId(Todos object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _todosGetLinks(Todos object) {
  return [object.parent, object.children, object.task];
}

void _todosAttach(IsarCollection<dynamic> col, Id id, Todos object) {
  object.id = id;
  object.parent.attach(col, col.isar.collection<Todos>(), r'parent', id);
  object.children.attach(col, col.isar.collection<Todos>(), r'children', id);
  object.task.attach(col, col.isar.collection<Tasks>(), r'task', id);
}

extension TodosQueryWhereSort on QueryBuilder<Todos, Todos, QWhere> {
  QueryBuilder<Todos, Todos, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TodosQueryWhere on QueryBuilder<Todos, Todos, QWhereClause> {
  QueryBuilder<Todos, Todos, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Todos, Todos, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Todos, Todos, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TodosQueryFilter on QueryBuilder<Todos, Todos, QFilterCondition> {
  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavDirtyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavDirty', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavEtag'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavEtag'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavEtag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavEtag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavEtag', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavEtagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavEtag', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavHref'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavHref'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavHref',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavHref',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavHref',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavHref', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavHrefIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavHref', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'caldavUid'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'caldavUid'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caldavUid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'caldavUid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'caldavUid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caldavUid', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> caldavUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'caldavUid', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenSortOptionEqualTo(
    SortOption value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'childrenSortOption', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  childrenSortOptionGreaterThan(SortOption value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'childrenSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenSortOptionLessThan(
    SortOption value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'childrenSortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenSortOptionBetween(
    SortOption lower,
    SortOption upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'childrenSortOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> createdTimeEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdTime', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> createdTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> createdTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> createdTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deviceCalendarEventId'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deviceCalendarEventId'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceCalendarEventId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceCalendarEventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceCalendarEventId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceCalendarEventId', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  deviceCalendarEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'deviceCalendarEventId',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> doneEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'done', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dueAt'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dueAt'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueAt', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> dueAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> fixEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fix', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'index'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'index'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'index', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'index',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> indexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'index',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> priorityEqualTo(
    Priority value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> priorityGreaterThan(
    Priority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> priorityLessThan(
    Priority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> priorityBetween(
    Priority lower,
    Priority upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceEqualTo(
    RecurrenceFrequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrence', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceGreaterThan(
    RecurrenceFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceLessThan(
    RecurrenceFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrence',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceBetween(
    RecurrenceFrequency lower,
    RecurrenceFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'recurrenceMinuteOfDay'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'recurrenceMinuteOfDay'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceMinuteOfDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceMinuteOfDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceMinuteOfDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceModeEqualTo(
    RecurrenceMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceMode', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceModeGreaterThan(
    RecurrenceMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceModeLessThan(
    RecurrenceMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> recurrenceModeBetween(
    RecurrenceMode lower,
    RecurrenceMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceWeekdays', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceWeekdays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceWeekdays',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceWeekdays',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, true, 0, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, false, 999999, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'recurrenceWeekdays', 0, true, length, include);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  recurrenceWeekdaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'recurrenceWeekdays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> statusEqualTo(
    TodoStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> statusGreaterThan(
    TodoStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> statusLessThan(
    TodoStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> statusBetween(
    TodoStatus lower,
    TodoStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'todoCompletedTime'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  todoCompletedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'todoCompletedTime'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletedTimeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'todoCompletedTime', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  todoCompletedTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'todoCompletedTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletedTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'todoCompletedTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletedTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'todoCompletedTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletionTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'todoCompletionTime'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  todoCompletionTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'todoCompletionTime'),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletionTimeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'todoCompletionTime', value: value),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition>
  todoCompletionTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'todoCompletionTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletionTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'todoCompletionTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> todoCompletionTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'todoCompletionTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TodosQueryObject on QueryBuilder<Todos, Todos, QFilterCondition> {}

extension TodosQueryLinks on QueryBuilder<Todos, Todos, QFilterCondition> {
  QueryBuilder<Todos, Todos, QAfterFilterCondition> parent(
    FilterQuery<Todos> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'parent');
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> parentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'parent', 0, true, 0, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> children(
    FilterQuery<Todos> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'children');
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, true, length, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, 0, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, false, 999999, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', 0, true, length, include);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'children', length, include, 999999, true);
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> childrenLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'children',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> task(FilterQuery<Tasks> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'task');
    });
  }

  QueryBuilder<Todos, Todos, QAfterFilterCondition> taskIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'task', 0, true, 0, true);
    });
  }
}

extension TodosQuerySortBy on QueryBuilder<Todos, Todos, QSortBy> {
  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavDirty', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavDirty', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEtag', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEtag', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavHref', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavHref', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUid', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCaldavUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUid', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByChildrenSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childrenSortOption', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByChildrenSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childrenSortOption', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCreatedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByCreatedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdTime', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDeviceCalendarEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarEventId', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDeviceCalendarEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarEventId', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByFix() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fix', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByFixDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fix', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrenceMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByRecurrenceModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByTodoCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletedTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByTodoCompletedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletedTime', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByTodoCompletionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletionTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> sortByTodoCompletionTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletionTime', Sort.desc);
    });
  }
}

extension TodosQuerySortThenBy on QueryBuilder<Todos, Todos, QSortThenBy> {
  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavDirty', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavDirty', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEtag', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavEtag', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavHref() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavHref', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavHrefDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavHref', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUid', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCaldavUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caldavUid', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByChildrenSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childrenSortOption', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByChildrenSortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'childrenSortOption', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCreatedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByCreatedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdTime', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDeviceCalendarEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarEventId', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDeviceCalendarEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceCalendarEventId', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByFix() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fix', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByFixDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fix', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'index', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrence', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrenceMinuteOfDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMinuteOfDay', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByRecurrenceModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceMode', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByTodoCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletedTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByTodoCompletedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletedTime', Sort.desc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByTodoCompletionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletionTime', Sort.asc);
    });
  }

  QueryBuilder<Todos, Todos, QAfterSortBy> thenByTodoCompletionTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'todoCompletionTime', Sort.desc);
    });
  }
}

extension TodosQueryWhereDistinct on QueryBuilder<Todos, Todos, QDistinct> {
  QueryBuilder<Todos, Todos, QDistinct> distinctByCaldavDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavDirty');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByCaldavEtag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavEtag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByCaldavHref({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavHref', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByCaldavUid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caldavUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByChildrenSortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'childrenSortOption');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByCreatedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdTime');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByDeviceCalendarEventId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'deviceCalendarEventId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'done');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueAt');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByFix() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fix');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'index');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByRecurrence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrence');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByRecurrenceMinuteOfDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceMinuteOfDay');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByRecurrenceMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceMode');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByRecurrenceWeekdays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceWeekdays');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByTodoCompletedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'todoCompletedTime');
    });
  }

  QueryBuilder<Todos, Todos, QDistinct> distinctByTodoCompletionTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'todoCompletionTime');
    });
  }
}

extension TodosQueryProperty on QueryBuilder<Todos, Todos, QQueryProperty> {
  QueryBuilder<Todos, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Todos, bool, QQueryOperations> caldavDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavDirty');
    });
  }

  QueryBuilder<Todos, String?, QQueryOperations> caldavEtagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavEtag');
    });
  }

  QueryBuilder<Todos, String?, QQueryOperations> caldavHrefProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavHref');
    });
  }

  QueryBuilder<Todos, String?, QQueryOperations> caldavUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caldavUid');
    });
  }

  QueryBuilder<Todos, SortOption, QQueryOperations>
  childrenSortOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'childrenSortOption');
    });
  }

  QueryBuilder<Todos, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<Todos, DateTime, QQueryOperations> createdTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdTime');
    });
  }

  QueryBuilder<Todos, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Todos, String?, QQueryOperations>
  deviceCalendarEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceCalendarEventId');
    });
  }

  QueryBuilder<Todos, bool, QQueryOperations> doneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'done');
    });
  }

  QueryBuilder<Todos, DateTime?, QQueryOperations> dueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueAt');
    });
  }

  QueryBuilder<Todos, bool, QQueryOperations> fixProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fix');
    });
  }

  QueryBuilder<Todos, int?, QQueryOperations> indexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'index');
    });
  }

  QueryBuilder<Todos, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Todos, Priority, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<Todos, RecurrenceFrequency, QQueryOperations>
  recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrence');
    });
  }

  QueryBuilder<Todos, int?, QQueryOperations> recurrenceMinuteOfDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceMinuteOfDay');
    });
  }

  QueryBuilder<Todos, RecurrenceMode, QQueryOperations>
  recurrenceModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceMode');
    });
  }

  QueryBuilder<Todos, List<int>, QQueryOperations>
  recurrenceWeekdaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceWeekdays');
    });
  }

  QueryBuilder<Todos, TodoStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Todos, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Todos, DateTime?, QQueryOperations> todoCompletedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todoCompletedTime');
    });
  }

  QueryBuilder<Todos, DateTime?, QQueryOperations>
  todoCompletionTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'todoCompletionTime');
    });
  }
}
