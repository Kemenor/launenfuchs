// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MoodLabelsTable extends MoodLabels
    with TableInfo<$MoodLabelsTable, MoodLabelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    check: () => ComparableExpr(value).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [value, label, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodLabelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {value};
  @override
  MoodLabelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodLabelRow(
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $MoodLabelsTable createAlias(String alias) {
    return $MoodLabelsTable(attachedDatabase, alias);
  }
}

class MoodLabelRow extends DataClass implements Insertable<MoodLabelRow> {
  final int value;
  final String? label;
  final String? icon;
  const MoodLabelRow({required this.value, this.label, this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  MoodLabelsCompanion toCompanion(bool nullToAbsent) {
    return MoodLabelsCompanion(
      value: Value(value),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory MoodLabelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodLabelRow(
      value: serializer.fromJson<int>(json['value']),
      label: serializer.fromJson<String?>(json['label']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'value': serializer.toJson<int>(value),
      'label': serializer.toJson<String?>(label),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  MoodLabelRow copyWith({
    int? value,
    Value<String?> label = const Value.absent(),
    Value<String?> icon = const Value.absent(),
  }) => MoodLabelRow(
    value: value ?? this.value,
    label: label.present ? label.value : this.label,
    icon: icon.present ? icon.value : this.icon,
  );
  MoodLabelRow copyWithCompanion(MoodLabelsCompanion data) {
    return MoodLabelRow(
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodLabelRow(')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(value, label, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodLabelRow &&
          other.value == this.value &&
          other.label == this.label &&
          other.icon == this.icon);
}

class MoodLabelsCompanion extends UpdateCompanion<MoodLabelRow> {
  final Value<int> value;
  final Value<String?> label;
  final Value<String?> icon;
  const MoodLabelsCompanion({
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.icon = const Value.absent(),
  });
  MoodLabelsCompanion.insert({
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.icon = const Value.absent(),
  });
  static Insertable<MoodLabelRow> custom({
    Expression<int>? value,
    Expression<String>? label,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (icon != null) 'icon': icon,
    });
  }

  MoodLabelsCompanion copyWith({
    Value<int>? value,
    Value<String?>? label,
    Value<String?>? icon,
  }) {
    return MoodLabelsCompanion(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodLabelsCompanion(')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $CategoryOptionsTable extends CategoryOptions
    with TableInfo<$CategoryOptionsTable, OptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    icon,
    sort,
    hidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<OptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
    );
  }

  @override
  $CategoryOptionsTable createAlias(String alias) {
    return $CategoryOptionsTable(attachedDatabase, alias);
  }
}

class OptionRow extends DataClass implements Insertable<OptionRow> {
  final int id;
  final int categoryId;
  final String name;
  final String icon;
  final int sort;
  final bool hidden;
  const OptionRow({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.sort,
    required this.hidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['sort'] = Variable<int>(sort);
    map['hidden'] = Variable<bool>(hidden);
    return map;
  }

  CategoryOptionsCompanion toCompanion(bool nullToAbsent) {
    return CategoryOptionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      icon: Value(icon),
      sort: Value(sort),
      hidden: Value(hidden),
    );
  }

  factory OptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OptionRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      sort: serializer.fromJson<int>(json['sort']),
      hidden: serializer.fromJson<bool>(json['hidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'sort': serializer.toJson<int>(sort),
      'hidden': serializer.toJson<bool>(hidden),
    };
  }

  OptionRow copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? icon,
    int? sort,
    bool? hidden,
  }) => OptionRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    sort: sort ?? this.sort,
    hidden: hidden ?? this.hidden,
  );
  OptionRow copyWithCompanion(CategoryOptionsCompanion data) {
    return OptionRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      sort: data.sort.present ? data.sort.value : this.sort,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OptionRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sort: $sort, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, icon, sort, hidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OptionRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.sort == this.sort &&
          other.hidden == this.hidden);
}

class CategoryOptionsCompanion extends UpdateCompanion<OptionRow> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> sort;
  final Value<bool> hidden;
  const CategoryOptionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.sort = const Value.absent(),
    this.hidden = const Value.absent(),
  });
  CategoryOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    required String icon,
    this.sort = const Value.absent(),
    this.hidden = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       icon = Value(icon);
  static Insertable<OptionRow> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? sort,
    Expression<bool>? hidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (sort != null) 'sort': sort,
      if (hidden != null) 'hidden': hidden,
    });
  }

  CategoryOptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? sort,
    Value<bool>? hidden,
  }) {
    return CategoryOptionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sort: sort ?? this.sort,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryOptionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('sort: $sort, ')
          ..write('hidden: $hidden')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryMode>($CategoriesTable.$convertermode);
  @override
  late final GeneratedColumnWithTypeConverter<CategoryDisplay, String> display =
      GeneratedColumn<String>(
        'display',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(CategoryDisplay.chips.name),
      ).withConverter<CategoryDisplay>($CategoriesTable.$converterdisplay);
  static const VerificationMeta _defaultOptionIdMeta = const VerificationMeta(
    'defaultOptionId',
  );
  @override
  late final GeneratedColumn<int> defaultOptionId = GeneratedColumn<int>(
    'default_option_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES category_options (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    mode,
    display,
    defaultOptionId,
    sort,
    hidden,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('default_option_id')) {
      context.handle(
        _defaultOptionIdMeta,
        defaultOptionId.isAcceptableOrUnknown(
          data['default_option_id']!,
          _defaultOptionIdMeta,
        ),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      mode: $CategoriesTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      display: $CategoriesTable.$converterdisplay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}display'],
        )!,
      ),
      defaultOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_option_id'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryMode, String, String> $convertermode =
      const EnumNameConverter<CategoryMode>(CategoryMode.values);
  static JsonTypeConverter2<CategoryDisplay, String, String> $converterdisplay =
      const EnumNameConverter<CategoryDisplay>(CategoryDisplay.values);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;
  final String icon;
  final CategoryMode mode;
  final CategoryDisplay display;

  /// Pre-selected on **new** entries only. Never read by stats — a saved
  /// default is an ordinary `entry_options` row (CLAUDE.md "saved means saved").
  final int? defaultOptionId;
  final int sort;

  /// Hidden from the entry sheet; data kept (§2.3 "Hide").
  final bool hidden;
  final DateTime createdAt;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.icon,
    required this.mode,
    required this.display,
    this.defaultOptionId,
    required this.sort,
    required this.hidden,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    {
      map['mode'] = Variable<String>(
        $CategoriesTable.$convertermode.toSql(mode),
      );
    }
    {
      map['display'] = Variable<String>(
        $CategoriesTable.$converterdisplay.toSql(display),
      );
    }
    if (!nullToAbsent || defaultOptionId != null) {
      map['default_option_id'] = Variable<int>(defaultOptionId);
    }
    map['sort'] = Variable<int>(sort);
    map['hidden'] = Variable<bool>(hidden);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      mode: Value(mode),
      display: Value(display),
      defaultOptionId: defaultOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultOptionId),
      sort: Value(sort),
      hidden: Value(hidden),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      mode: $CategoriesTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      display: $CategoriesTable.$converterdisplay.fromJson(
        serializer.fromJson<String>(json['display']),
      ),
      defaultOptionId: serializer.fromJson<int?>(json['defaultOptionId']),
      sort: serializer.fromJson<int>(json['sort']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'mode': serializer.toJson<String>(
        $CategoriesTable.$convertermode.toJson(mode),
      ),
      'display': serializer.toJson<String>(
        $CategoriesTable.$converterdisplay.toJson(display),
      ),
      'defaultOptionId': serializer.toJson<int?>(defaultOptionId),
      'sort': serializer.toJson<int>(sort),
      'hidden': serializer.toJson<bool>(hidden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? name,
    String? icon,
    CategoryMode? mode,
    CategoryDisplay? display,
    Value<int?> defaultOptionId = const Value.absent(),
    int? sort,
    bool? hidden,
    DateTime? createdAt,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    mode: mode ?? this.mode,
    display: display ?? this.display,
    defaultOptionId: defaultOptionId.present
        ? defaultOptionId.value
        : this.defaultOptionId,
    sort: sort ?? this.sort,
    hidden: hidden ?? this.hidden,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      mode: data.mode.present ? data.mode.value : this.mode,
      display: data.display.present ? data.display.value : this.display,
      defaultOptionId: data.defaultOptionId.present
          ? data.defaultOptionId.value
          : this.defaultOptionId,
      sort: data.sort.present ? data.sort.value : this.sort,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('mode: $mode, ')
          ..write('display: $display, ')
          ..write('defaultOptionId: $defaultOptionId, ')
          ..write('sort: $sort, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    mode,
    display,
    defaultOptionId,
    sort,
    hidden,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.mode == this.mode &&
          other.display == this.display &&
          other.defaultOptionId == this.defaultOptionId &&
          other.sort == this.sort &&
          other.hidden == this.hidden &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<CategoryMode> mode;
  final Value<CategoryDisplay> display;
  final Value<int?> defaultOptionId;
  final Value<int> sort;
  final Value<bool> hidden;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.mode = const Value.absent(),
    this.display = const Value.absent(),
    this.defaultOptionId = const Value.absent(),
    this.sort = const Value.absent(),
    this.hidden = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String icon,
    required CategoryMode mode,
    this.display = const Value.absent(),
    this.defaultOptionId = const Value.absent(),
    this.sort = const Value.absent(),
    this.hidden = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       icon = Value(icon),
       mode = Value(mode),
       createdAt = Value(createdAt);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? mode,
    Expression<String>? display,
    Expression<int>? defaultOptionId,
    Expression<int>? sort,
    Expression<bool>? hidden,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (mode != null) 'mode': mode,
      if (display != null) 'display': display,
      if (defaultOptionId != null) 'default_option_id': defaultOptionId,
      if (sort != null) 'sort': sort,
      if (hidden != null) 'hidden': hidden,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<CategoryMode>? mode,
    Value<CategoryDisplay>? display,
    Value<int?>? defaultOptionId,
    Value<int>? sort,
    Value<bool>? hidden,
    Value<DateTime>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      mode: mode ?? this.mode,
      display: display ?? this.display,
      defaultOptionId: defaultOptionId ?? this.defaultOptionId,
      sort: sort ?? this.sort,
      hidden: hidden ?? this.hidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $CategoriesTable.$convertermode.toSql(mode.value),
      );
    }
    if (display.present) {
      map['display'] = Variable<String>(
        $CategoriesTable.$converterdisplay.toSql(display.value),
      );
    }
    if (defaultOptionId.present) {
      map['default_option_id'] = Variable<int>(defaultOptionId.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('mode: $mode, ')
          ..write('display: $display, ')
          ..write('defaultOptionId: $defaultOptionId, ')
          ..write('sort: $sort, ')
          ..write('hidden: $hidden, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategorySpansTable extends CategorySpans
    with TableInfo<$CategorySpansTable, CategorySpanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategorySpansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fromDayMeta = const VerificationMeta(
    'fromDay',
  );
  @override
  late final GeneratedColumn<String> fromDay = GeneratedColumn<String>(
    'from_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toDayMeta = const VerificationMeta('toDay');
  @override
  late final GeneratedColumn<String> toDay = GeneratedColumn<String>(
    'to_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, fromDay, toDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_spans';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategorySpanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('from_day')) {
      context.handle(
        _fromDayMeta,
        fromDay.isAcceptableOrUnknown(data['from_day']!, _fromDayMeta),
      );
    } else if (isInserting) {
      context.missing(_fromDayMeta);
    }
    if (data.containsKey('to_day')) {
      context.handle(
        _toDayMeta,
        toDay.isAcceptableOrUnknown(data['to_day']!, _toDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategorySpanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategorySpanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      fromDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_day'],
      )!,
      toDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_day'],
      ),
    );
  }

  @override
  $CategorySpansTable createAlias(String alias) {
    return $CategorySpansTable(attachedDatabase, alias);
  }
}

class CategorySpanRow extends DataClass implements Insertable<CategorySpanRow> {
  final int id;
  final int categoryId;
  final String fromDay;
  final String? toDay;
  const CategorySpanRow({
    required this.id,
    required this.categoryId,
    required this.fromDay,
    this.toDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['from_day'] = Variable<String>(fromDay);
    if (!nullToAbsent || toDay != null) {
      map['to_day'] = Variable<String>(toDay);
    }
    return map;
  }

  CategorySpansCompanion toCompanion(bool nullToAbsent) {
    return CategorySpansCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      fromDay: Value(fromDay),
      toDay: toDay == null && nullToAbsent
          ? const Value.absent()
          : Value(toDay),
    );
  }

  factory CategorySpanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategorySpanRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      fromDay: serializer.fromJson<String>(json['fromDay']),
      toDay: serializer.fromJson<String?>(json['toDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'fromDay': serializer.toJson<String>(fromDay),
      'toDay': serializer.toJson<String?>(toDay),
    };
  }

  CategorySpanRow copyWith({
    int? id,
    int? categoryId,
    String? fromDay,
    Value<String?> toDay = const Value.absent(),
  }) => CategorySpanRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    fromDay: fromDay ?? this.fromDay,
    toDay: toDay.present ? toDay.value : this.toDay,
  );
  CategorySpanRow copyWithCompanion(CategorySpansCompanion data) {
    return CategorySpanRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      fromDay: data.fromDay.present ? data.fromDay.value : this.fromDay,
      toDay: data.toDay.present ? data.toDay.value : this.toDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategorySpanRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('fromDay: $fromDay, ')
          ..write('toDay: $toDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, fromDay, toDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategorySpanRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.fromDay == this.fromDay &&
          other.toDay == this.toDay);
}

class CategorySpansCompanion extends UpdateCompanion<CategorySpanRow> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> fromDay;
  final Value<String?> toDay;
  const CategorySpansCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.fromDay = const Value.absent(),
    this.toDay = const Value.absent(),
  });
  CategorySpansCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String fromDay,
    this.toDay = const Value.absent(),
  }) : categoryId = Value(categoryId),
       fromDay = Value(fromDay);
  static Insertable<CategorySpanRow> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? fromDay,
    Expression<String>? toDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (fromDay != null) 'from_day': fromDay,
      if (toDay != null) 'to_day': toDay,
    });
  }

  CategorySpansCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? fromDay,
    Value<String?>? toDay,
  }) {
    return CategorySpansCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      fromDay: fromDay ?? this.fromDay,
      toDay: toDay ?? this.toDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (fromDay.present) {
      map['from_day'] = Variable<String>(fromDay.value);
    }
    if (toDay.present) {
      map['to_day'] = Variable<String>(toDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategorySpansCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('fromDay: $fromDay, ')
          ..write('toDay: $toDay')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    check: () => ComparableExpr(mood).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    loggedAt,
    mood,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final int id;
  final String day;

  /// When it was logged — display only; the day is what counts.
  final DateTime loggedAt;
  final int mood;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryRow({
    required this.id,
    required this.day,
    required this.loggedAt,
    required this.mood,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['mood'] = Variable<int>(mood);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      day: Value(day),
      loggedAt: Value(loggedAt),
      mood: Value(mood),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      mood: serializer.fromJson<int>(json['mood']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'mood': serializer.toJson<int>(mood),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryRow copyWith({
    int? id,
    String? day,
    DateTime? loggedAt,
    int? mood,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntryRow(
    id: id ?? this.id,
    day: day ?? this.day,
    loggedAt: loggedAt ?? this.loggedAt,
    mood: mood ?? this.mood,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      mood: data.mood.present ? data.mood.value : this.mood,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, loggedAt, mood, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.loggedAt == this.loggedAt &&
          other.mood == this.mood &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<int> id;
  final Value<String> day;
  final Value<DateTime> loggedAt;
  final Value<int> mood;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required DateTime loggedAt,
    required int mood,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : day = Value(day),
       loggedAt = Value(loggedAt),
       mood = Value(mood),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EntryRow> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<DateTime>? loggedAt,
    Expression<int>? mood,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (mood != null) 'mood': mood,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<DateTime>? loggedAt,
    Value<int>? mood,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      loggedAt: loggedAt ?? this.loggedAt,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntryOptionsTable extends EntryOptions
    with TableInfo<$EntryOptionsTable, EntryOptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _optionIdMeta = const VerificationMeta(
    'optionId',
  );
  @override
  late final GeneratedColumn<int> optionId = GeneratedColumn<int>(
    'option_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES category_options (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, optionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryOptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('option_id')) {
      context.handle(
        _optionIdMeta,
        optionId.isAcceptableOrUnknown(data['option_id']!, _optionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_optionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, optionId};
  @override
  EntryOptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryOptionRow(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      optionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}option_id'],
      )!,
    );
  }

  @override
  $EntryOptionsTable createAlias(String alias) {
    return $EntryOptionsTable(attachedDatabase, alias);
  }
}

class EntryOptionRow extends DataClass implements Insertable<EntryOptionRow> {
  final int entryId;
  final int optionId;
  const EntryOptionRow({required this.entryId, required this.optionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<int>(entryId);
    map['option_id'] = Variable<int>(optionId);
    return map;
  }

  EntryOptionsCompanion toCompanion(bool nullToAbsent) {
    return EntryOptionsCompanion(
      entryId: Value(entryId),
      optionId: Value(optionId),
    );
  }

  factory EntryOptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryOptionRow(
      entryId: serializer.fromJson<int>(json['entryId']),
      optionId: serializer.fromJson<int>(json['optionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<int>(entryId),
      'optionId': serializer.toJson<int>(optionId),
    };
  }

  EntryOptionRow copyWith({int? entryId, int? optionId}) => EntryOptionRow(
    entryId: entryId ?? this.entryId,
    optionId: optionId ?? this.optionId,
  );
  EntryOptionRow copyWithCompanion(EntryOptionsCompanion data) {
    return EntryOptionRow(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      optionId: data.optionId.present ? data.optionId.value : this.optionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryOptionRow(')
          ..write('entryId: $entryId, ')
          ..write('optionId: $optionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, optionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryOptionRow &&
          other.entryId == this.entryId &&
          other.optionId == this.optionId);
}

class EntryOptionsCompanion extends UpdateCompanion<EntryOptionRow> {
  final Value<int> entryId;
  final Value<int> optionId;
  final Value<int> rowid;
  const EntryOptionsCompanion({
    this.entryId = const Value.absent(),
    this.optionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryOptionsCompanion.insert({
    required int entryId,
    required int optionId,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       optionId = Value(optionId);
  static Insertable<EntryOptionRow> custom({
    Expression<int>? entryId,
    Expression<int>? optionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (optionId != null) 'option_id': optionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryOptionsCompanion copyWith({
    Value<int>? entryId,
    Value<int>? optionId,
    Value<int>? rowid,
  }) {
    return EntryOptionsCompanion(
      entryId: entryId ?? this.entryId,
      optionId: optionId ?? this.optionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (optionId.present) {
      map['option_id'] = Variable<int>(optionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryOptionsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('optionId: $optionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeriodsTable extends Periods with TableInfo<$PeriodsTable, PeriodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<String> startDay = GeneratedColumn<String>(
    'start_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<String> endDay = GeneratedColumn<String>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awayMeta = const VerificationMeta('away');
  @override
  late final GeneratedColumn<bool> away = GeneratedColumn<bool>(
    'away',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("away" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startDay,
    endDay,
    away,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    } else if (isInserting) {
      context.missing(_startDayMeta);
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    }
    if (data.containsKey('away')) {
      context.handle(
        _awayMeta,
        away.isAcceptableOrUnknown(data['away']!, _awayMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_day'],
      )!,
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_day'],
      ),
      away: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}away'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $PeriodsTable createAlias(String alias) {
    return $PeriodsTable(attachedDatabase, alias);
  }
}

class PeriodRow extends DataClass implements Insertable<PeriodRow> {
  final int id;
  final String name;
  final String startDay;

  /// Null = ongoing.
  final String? endDay;

  /// Shaded on charts and the calendar, like a holiday.
  final bool away;
  final String? icon;
  const PeriodRow({
    required this.id,
    required this.name,
    required this.startDay,
    this.endDay,
    required this.away,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['start_day'] = Variable<String>(startDay);
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<String>(endDay);
    }
    map['away'] = Variable<bool>(away);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  PeriodsCompanion toCompanion(bool nullToAbsent) {
    return PeriodsCompanion(
      id: Value(id),
      name: Value(name),
      startDay: Value(startDay),
      endDay: endDay == null && nullToAbsent
          ? const Value.absent()
          : Value(endDay),
      away: Value(away),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory PeriodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startDay: serializer.fromJson<String>(json['startDay']),
      endDay: serializer.fromJson<String?>(json['endDay']),
      away: serializer.fromJson<bool>(json['away']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startDay': serializer.toJson<String>(startDay),
      'endDay': serializer.toJson<String?>(endDay),
      'away': serializer.toJson<bool>(away),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  PeriodRow copyWith({
    int? id,
    String? name,
    String? startDay,
    Value<String?> endDay = const Value.absent(),
    bool? away,
    Value<String?> icon = const Value.absent(),
  }) => PeriodRow(
    id: id ?? this.id,
    name: name ?? this.name,
    startDay: startDay ?? this.startDay,
    endDay: endDay.present ? endDay.value : this.endDay,
    away: away ?? this.away,
    icon: icon.present ? icon.value : this.icon,
  );
  PeriodRow copyWithCompanion(PeriodsCompanion data) {
    return PeriodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      away: data.away.present ? data.away.value : this.away,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('away: $away, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, startDay, endDay, away, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.startDay == this.startDay &&
          other.endDay == this.endDay &&
          other.away == this.away &&
          other.icon == this.icon);
}

class PeriodsCompanion extends UpdateCompanion<PeriodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> startDay;
  final Value<String?> endDay;
  final Value<bool> away;
  final Value<String?> icon;
  const PeriodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.away = const Value.absent(),
    this.icon = const Value.absent(),
  });
  PeriodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String startDay,
    this.endDay = const Value.absent(),
    this.away = const Value.absent(),
    this.icon = const Value.absent(),
  }) : name = Value(name),
       startDay = Value(startDay);
  static Insertable<PeriodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? startDay,
    Expression<String>? endDay,
    Expression<bool>? away,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startDay != null) 'start_day': startDay,
      if (endDay != null) 'end_day': endDay,
      if (away != null) 'away': away,
      if (icon != null) 'icon': icon,
    });
  }

  PeriodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? startDay,
    Value<String?>? endDay,
    Value<bool>? away,
    Value<String?>? icon,
  }) {
    return PeriodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      away: away ?? this.away,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<String>(startDay.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<String>(endDay.value);
    }
    if (away.present) {
      map['away'] = Variable<bool>(away.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('away: $away, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $ImportMapsTable extends ImportMaps
    with TableInfo<$ImportMapsTable, ImportMapRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportMapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    kind,
    sourceId,
    action,
    targetId,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_maps';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportMapRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, kind, sourceId};
  @override
  ImportMapRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportMapRow(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
    );
  }

  @override
  $ImportMapsTable createAlias(String alias) {
    return $ImportMapsTable(attachedDatabase, alias);
  }
}

class ImportMapRow extends DataClass implements Insertable<ImportMapRow> {
  final String source;
  final String kind;
  final int sourceId;
  final String action;
  final int? targetId;
  final String? name;
  const ImportMapRow({
    required this.source,
    required this.kind,
    required this.sourceId,
    required this.action,
    this.targetId,
    this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['kind'] = Variable<String>(kind);
    map['source_id'] = Variable<int>(sourceId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<int>(targetId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  ImportMapsCompanion toCompanion(bool nullToAbsent) {
    return ImportMapsCompanion(
      source: Value(source),
      kind: Value(kind),
      sourceId: Value(sourceId),
      action: Value(action),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory ImportMapRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportMapRow(
      source: serializer.fromJson<String>(json['source']),
      kind: serializer.fromJson<String>(json['kind']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      action: serializer.fromJson<String>(json['action']),
      targetId: serializer.fromJson<int?>(json['targetId']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'kind': serializer.toJson<String>(kind),
      'sourceId': serializer.toJson<int>(sourceId),
      'action': serializer.toJson<String>(action),
      'targetId': serializer.toJson<int?>(targetId),
      'name': serializer.toJson<String?>(name),
    };
  }

  ImportMapRow copyWith({
    String? source,
    String? kind,
    int? sourceId,
    String? action,
    Value<int?> targetId = const Value.absent(),
    Value<String?> name = const Value.absent(),
  }) => ImportMapRow(
    source: source ?? this.source,
    kind: kind ?? this.kind,
    sourceId: sourceId ?? this.sourceId,
    action: action ?? this.action,
    targetId: targetId.present ? targetId.value : this.targetId,
    name: name.present ? name.value : this.name,
  );
  ImportMapRow copyWithCompanion(ImportMapsCompanion data) {
    return ImportMapRow(
      source: data.source.present ? data.source.value : this.source,
      kind: data.kind.present ? data.kind.value : this.kind,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      action: data.action.present ? data.action.value : this.action,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportMapRow(')
          ..write('source: $source, ')
          ..write('kind: $kind, ')
          ..write('sourceId: $sourceId, ')
          ..write('action: $action, ')
          ..write('targetId: $targetId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(source, kind, sourceId, action, targetId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportMapRow &&
          other.source == this.source &&
          other.kind == this.kind &&
          other.sourceId == this.sourceId &&
          other.action == this.action &&
          other.targetId == this.targetId &&
          other.name == this.name);
}

class ImportMapsCompanion extends UpdateCompanion<ImportMapRow> {
  final Value<String> source;
  final Value<String> kind;
  final Value<int> sourceId;
  final Value<String> action;
  final Value<int?> targetId;
  final Value<String?> name;
  final Value<int> rowid;
  const ImportMapsCompanion({
    this.source = const Value.absent(),
    this.kind = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.action = const Value.absent(),
    this.targetId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportMapsCompanion.insert({
    required String source,
    required String kind,
    required int sourceId,
    required String action,
    this.targetId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       kind = Value(kind),
       sourceId = Value(sourceId),
       action = Value(action);
  static Insertable<ImportMapRow> custom({
    Expression<String>? source,
    Expression<String>? kind,
    Expression<int>? sourceId,
    Expression<String>? action,
    Expression<int>? targetId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (kind != null) 'kind': kind,
      if (sourceId != null) 'source_id': sourceId,
      if (action != null) 'action': action,
      if (targetId != null) 'target_id': targetId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportMapsCompanion copyWith({
    Value<String>? source,
    Value<String>? kind,
    Value<int>? sourceId,
    Value<String>? action,
    Value<int?>? targetId,
    Value<String?>? name,
    Value<int>? rowid,
  }) {
    return ImportMapsCompanion(
      source: source ?? this.source,
      kind: kind ?? this.kind,
      sourceId: sourceId ?? this.sourceId,
      action: action ?? this.action,
      targetId: targetId ?? this.targetId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
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
    return (StringBuffer('ImportMapsCompanion(')
          ..write('source: $source, ')
          ..write('kind: $kind, ')
          ..write('sourceId: $sourceId, ')
          ..write('action: $action, ')
          ..write('targetId: $targetId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeIndexMeta = const VerificationMeta(
    'themeModeIndex',
  );
  @override
  late final GeneratedColumn<int> themeModeIndex = GeneratedColumn<int>(
    'theme_mode_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fontIndexMeta = const VerificationMeta(
    'fontIndex',
  );
  @override
  late final GeneratedColumn<int> fontIndex = GeneratedColumn<int>(
    'font_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _dayCutoffHourMeta = const VerificationMeta(
    'dayCutoffHour',
  );
  @override
  late final GeneratedColumn<int> dayCutoffHour = GeneratedColumn<int>(
    'day_cutoff_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _statsTilesMeta = const VerificationMeta(
    'statsTiles',
  );
  @override
  late final GeneratedColumn<String> statsTiles = GeneratedColumn<String>(
    'stats_tiles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appLockMeta = const VerificationMeta(
    'appLock',
  );
  @override
  late final GeneratedColumn<bool> appLock = GeneratedColumn<bool>(
    'app_lock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _appLockDelaySecondsMeta =
      const VerificationMeta('appLockDelaySeconds');
  @override
  late final GeneratedColumn<int> appLockDelaySeconds = GeneratedColumn<int>(
    'app_lock_delay_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeModeIndex,
    fontIndex,
    localeCode,
    dayCutoffHour,
    statsTiles,
    appLock,
    appLockDelaySeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode_index')) {
      context.handle(
        _themeModeIndexMeta,
        themeModeIndex.isAcceptableOrUnknown(
          data['theme_mode_index']!,
          _themeModeIndexMeta,
        ),
      );
    }
    if (data.containsKey('font_index')) {
      context.handle(
        _fontIndexMeta,
        fontIndex.isAcceptableOrUnknown(data['font_index']!, _fontIndexMeta),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('day_cutoff_hour')) {
      context.handle(
        _dayCutoffHourMeta,
        dayCutoffHour.isAcceptableOrUnknown(
          data['day_cutoff_hour']!,
          _dayCutoffHourMeta,
        ),
      );
    }
    if (data.containsKey('stats_tiles')) {
      context.handle(
        _statsTilesMeta,
        statsTiles.isAcceptableOrUnknown(data['stats_tiles']!, _statsTilesMeta),
      );
    }
    if (data.containsKey('app_lock')) {
      context.handle(
        _appLockMeta,
        appLock.isAcceptableOrUnknown(data['app_lock']!, _appLockMeta),
      );
    }
    if (data.containsKey('app_lock_delay_seconds')) {
      context.handle(
        _appLockDelaySecondsMeta,
        appLockDelaySeconds.isAcceptableOrUnknown(
          data['app_lock_delay_seconds']!,
          _appLockDelaySecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeModeIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theme_mode_index'],
      )!,
      fontIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}font_index'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      dayCutoffHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_cutoff_hour'],
      )!,
      statsTiles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_tiles'],
      ),
      appLock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock'],
      )!,
      appLockDelaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}app_lock_delay_seconds'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final int id;
  final int themeModeIndex;
  final int fontIndex;

  /// App-language override ('system' = follow the OS locale).
  final String localeCode;

  /// The hour a new day starts (§2.2), default 04:00.
  final int dayCutoffHour;

  /// Enabled Stats tiles in display order, JSON list. Null = the default set.
  final String? statsTiles;

  /// App lock (§2.6): off by default; delay before re-locking, in seconds.
  final bool appLock;
  final int appLockDelaySeconds;
  const AppSettingsRow({
    required this.id,
    required this.themeModeIndex,
    required this.fontIndex,
    required this.localeCode,
    required this.dayCutoffHour,
    this.statsTiles,
    required this.appLock,
    required this.appLockDelaySeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode_index'] = Variable<int>(themeModeIndex);
    map['font_index'] = Variable<int>(fontIndex);
    map['locale_code'] = Variable<String>(localeCode);
    map['day_cutoff_hour'] = Variable<int>(dayCutoffHour);
    if (!nullToAbsent || statsTiles != null) {
      map['stats_tiles'] = Variable<String>(statsTiles);
    }
    map['app_lock'] = Variable<bool>(appLock);
    map['app_lock_delay_seconds'] = Variable<int>(appLockDelaySeconds);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeModeIndex: Value(themeModeIndex),
      fontIndex: Value(fontIndex),
      localeCode: Value(localeCode),
      dayCutoffHour: Value(dayCutoffHour),
      statsTiles: statsTiles == null && nullToAbsent
          ? const Value.absent()
          : Value(statsTiles),
      appLock: Value(appLock),
      appLockDelaySeconds: Value(appLockDelaySeconds),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themeModeIndex: serializer.fromJson<int>(json['themeModeIndex']),
      fontIndex: serializer.fromJson<int>(json['fontIndex']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      dayCutoffHour: serializer.fromJson<int>(json['dayCutoffHour']),
      statsTiles: serializer.fromJson<String?>(json['statsTiles']),
      appLock: serializer.fromJson<bool>(json['appLock']),
      appLockDelaySeconds: serializer.fromJson<int>(
        json['appLockDelaySeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeModeIndex': serializer.toJson<int>(themeModeIndex),
      'fontIndex': serializer.toJson<int>(fontIndex),
      'localeCode': serializer.toJson<String>(localeCode),
      'dayCutoffHour': serializer.toJson<int>(dayCutoffHour),
      'statsTiles': serializer.toJson<String?>(statsTiles),
      'appLock': serializer.toJson<bool>(appLock),
      'appLockDelaySeconds': serializer.toJson<int>(appLockDelaySeconds),
    };
  }

  AppSettingsRow copyWith({
    int? id,
    int? themeModeIndex,
    int? fontIndex,
    String? localeCode,
    int? dayCutoffHour,
    Value<String?> statsTiles = const Value.absent(),
    bool? appLock,
    int? appLockDelaySeconds,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeModeIndex: themeModeIndex ?? this.themeModeIndex,
    fontIndex: fontIndex ?? this.fontIndex,
    localeCode: localeCode ?? this.localeCode,
    dayCutoffHour: dayCutoffHour ?? this.dayCutoffHour,
    statsTiles: statsTiles.present ? statsTiles.value : this.statsTiles,
    appLock: appLock ?? this.appLock,
    appLockDelaySeconds: appLockDelaySeconds ?? this.appLockDelaySeconds,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeModeIndex: data.themeModeIndex.present
          ? data.themeModeIndex.value
          : this.themeModeIndex,
      fontIndex: data.fontIndex.present ? data.fontIndex.value : this.fontIndex,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      dayCutoffHour: data.dayCutoffHour.present
          ? data.dayCutoffHour.value
          : this.dayCutoffHour,
      statsTiles: data.statsTiles.present
          ? data.statsTiles.value
          : this.statsTiles,
      appLock: data.appLock.present ? data.appLock.value : this.appLock,
      appLockDelaySeconds: data.appLockDelaySeconds.present
          ? data.appLockDelaySeconds.value
          : this.appLockDelaySeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeModeIndex: $themeModeIndex, ')
          ..write('fontIndex: $fontIndex, ')
          ..write('localeCode: $localeCode, ')
          ..write('dayCutoffHour: $dayCutoffHour, ')
          ..write('statsTiles: $statsTiles, ')
          ..write('appLock: $appLock, ')
          ..write('appLockDelaySeconds: $appLockDelaySeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeModeIndex,
    fontIndex,
    localeCode,
    dayCutoffHour,
    statsTiles,
    appLock,
    appLockDelaySeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeModeIndex == this.themeModeIndex &&
          other.fontIndex == this.fontIndex &&
          other.localeCode == this.localeCode &&
          other.dayCutoffHour == this.dayCutoffHour &&
          other.statsTiles == this.statsTiles &&
          other.appLock == this.appLock &&
          other.appLockDelaySeconds == this.appLockDelaySeconds);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<int> id;
  final Value<int> themeModeIndex;
  final Value<int> fontIndex;
  final Value<String> localeCode;
  final Value<int> dayCutoffHour;
  final Value<String?> statsTiles;
  final Value<bool> appLock;
  final Value<int> appLockDelaySeconds;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeModeIndex = const Value.absent(),
    this.fontIndex = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.dayCutoffHour = const Value.absent(),
    this.statsTiles = const Value.absent(),
    this.appLock = const Value.absent(),
    this.appLockDelaySeconds = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeModeIndex = const Value.absent(),
    this.fontIndex = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.dayCutoffHour = const Value.absent(),
    this.statsTiles = const Value.absent(),
    this.appLock = const Value.absent(),
    this.appLockDelaySeconds = const Value.absent(),
  });
  static Insertable<AppSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? themeModeIndex,
    Expression<int>? fontIndex,
    Expression<String>? localeCode,
    Expression<int>? dayCutoffHour,
    Expression<String>? statsTiles,
    Expression<bool>? appLock,
    Expression<int>? appLockDelaySeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeModeIndex != null) 'theme_mode_index': themeModeIndex,
      if (fontIndex != null) 'font_index': fontIndex,
      if (localeCode != null) 'locale_code': localeCode,
      if (dayCutoffHour != null) 'day_cutoff_hour': dayCutoffHour,
      if (statsTiles != null) 'stats_tiles': statsTiles,
      if (appLock != null) 'app_lock': appLock,
      if (appLockDelaySeconds != null)
        'app_lock_delay_seconds': appLockDelaySeconds,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? themeModeIndex,
    Value<int>? fontIndex,
    Value<String>? localeCode,
    Value<int>? dayCutoffHour,
    Value<String?>? statsTiles,
    Value<bool>? appLock,
    Value<int>? appLockDelaySeconds,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      fontIndex: fontIndex ?? this.fontIndex,
      localeCode: localeCode ?? this.localeCode,
      dayCutoffHour: dayCutoffHour ?? this.dayCutoffHour,
      statsTiles: statsTiles ?? this.statsTiles,
      appLock: appLock ?? this.appLock,
      appLockDelaySeconds: appLockDelaySeconds ?? this.appLockDelaySeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeModeIndex.present) {
      map['theme_mode_index'] = Variable<int>(themeModeIndex.value);
    }
    if (fontIndex.present) {
      map['font_index'] = Variable<int>(fontIndex.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (dayCutoffHour.present) {
      map['day_cutoff_hour'] = Variable<int>(dayCutoffHour.value);
    }
    if (statsTiles.present) {
      map['stats_tiles'] = Variable<String>(statsTiles.value);
    }
    if (appLock.present) {
      map['app_lock'] = Variable<bool>(appLock.value);
    }
    if (appLockDelaySeconds.present) {
      map['app_lock_delay_seconds'] = Variable<int>(appLockDelaySeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeModeIndex: $themeModeIndex, ')
          ..write('fontIndex: $fontIndex, ')
          ..write('localeCode: $localeCode, ')
          ..write('dayCutoffHour: $dayCutoffHour, ')
          ..write('statsTiles: $statsTiles, ')
          ..write('appLock: $appLock, ')
          ..write('appLockDelaySeconds: $appLockDelaySeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MoodLabelsTable moodLabels = $MoodLabelsTable(this);
  late final $CategoryOptionsTable categoryOptions = $CategoryOptionsTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CategorySpansTable categorySpans = $CategorySpansTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $EntryOptionsTable entryOptions = $EntryOptionsTable(this);
  late final $PeriodsTable periods = $PeriodsTable(this);
  late final $ImportMapsTable importMaps = $ImportMapsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    moodLabels,
    categoryOptions,
    categories,
    categorySpans,
    entries,
    entryOptions,
    periods,
    importMaps,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('category_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'category_options',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('categories', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('category_spans', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'category_options',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_options', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MoodLabelsTableCreateCompanionBuilder =
    MoodLabelsCompanion Function({
      Value<int> value,
      Value<String?> label,
      Value<String?> icon,
    });
typedef $$MoodLabelsTableUpdateCompanionBuilder =
    MoodLabelsCompanion Function({
      Value<int> value,
      Value<String?> label,
      Value<String?> icon,
    });

class $$MoodLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $MoodLabelsTable> {
  $$MoodLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoodLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodLabelsTable> {
  $$MoodLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodLabelsTable> {
  $$MoodLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$MoodLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodLabelsTable,
          MoodLabelRow,
          $$MoodLabelsTableFilterComposer,
          $$MoodLabelsTableOrderingComposer,
          $$MoodLabelsTableAnnotationComposer,
          $$MoodLabelsTableCreateCompanionBuilder,
          $$MoodLabelsTableUpdateCompanionBuilder,
          (
            MoodLabelRow,
            BaseReferences<_$AppDatabase, $MoodLabelsTable, MoodLabelRow>,
          ),
          MoodLabelRow,
          PrefetchHooks Function()
        > {
  $$MoodLabelsTableTableManager(_$AppDatabase db, $MoodLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> value = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => MoodLabelsCompanion(value: value, label: label, icon: icon),
          createCompanionCallback:
              ({
                Value<int> value = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => MoodLabelsCompanion.insert(
                value: value,
                label: label,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoodLabelsTable, MoodLabelRow>(table),
                  BaseReferences<_$AppDatabase, $MoodLabelsTable, MoodLabelRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodLabelsTable,
      MoodLabelRow,
      $$MoodLabelsTableFilterComposer,
      $$MoodLabelsTableOrderingComposer,
      $$MoodLabelsTableAnnotationComposer,
      $$MoodLabelsTableCreateCompanionBuilder,
      $$MoodLabelsTableUpdateCompanionBuilder,
      (
        MoodLabelRow,
        BaseReferences<_$AppDatabase, $MoodLabelsTable, MoodLabelRow>,
      ),
      MoodLabelRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryOptionsTableCreateCompanionBuilder =
    CategoryOptionsCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      required String icon,
      Value<int> sort,
      Value<bool> hidden,
    });
typedef $$CategoryOptionsTableUpdateCompanionBuilder =
    CategoryOptionsCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<String> icon,
      Value<int> sort,
      Value<bool> hidden,
    });

final class $$CategoryOptionsTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryOptionsTable, OptionRow> {
  $$CategoryOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('category_options__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CategoriesTable, List<CategoryRow>>
  _categoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'category_options__id__categories__default_option_id',
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.defaultOptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntryOptionsTable, List<EntryOptionRow>>
  _entryOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryOptions,
    aliasName: 'category_options__id__entry_options__option_id',
  );

  $$EntryOptionsTableProcessedTableManager get entryOptionsRefs {
    final manager = $$EntryOptionsTableTableManager(
      $_db,
      $_db.entryOptions,
    ).filter((f) => f.optionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoryOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryOptionsTable> {
  $$CategoryOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.defaultOptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entryOptionsRefs(
    Expression<bool> Function($$EntryOptionsTableFilterComposer f) f,
  ) {
    final $$EntryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.optionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryOptionsTable> {
  $$CategoryOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryOptionsTable> {
  $$CategoryOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.defaultOptionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entryOptionsRefs<T extends Object>(
    Expression<T> Function($$EntryOptionsTableAnnotationComposer a) f,
  ) {
    final $$EntryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.optionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryOptionsTable,
          OptionRow,
          $$CategoryOptionsTableFilterComposer,
          $$CategoryOptionsTableOrderingComposer,
          $$CategoryOptionsTableAnnotationComposer,
          $$CategoryOptionsTableCreateCompanionBuilder,
          $$CategoryOptionsTableUpdateCompanionBuilder,
          (OptionRow, $$CategoryOptionsTableReferences),
          OptionRow,
          PrefetchHooks Function({
            bool categoryId,
            bool categoriesRefs,
            bool entryOptionsRefs,
          })
        > {
  $$CategoryOptionsTableTableManager(
    _$AppDatabase db,
    $CategoryOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => CategoryOptionsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                icon: icon,
                sort: sort,
                hidden: hidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                required String icon,
                Value<int> sort = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
              }) => CategoryOptionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                icon: icon,
                sort: sort,
                hidden: hidden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryOptionsTable, OptionRow>(table),
                  $$CategoryOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                categoriesRefs = false,
                entryOptionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoriesRefs) db.categories,
                    if (entryOptionsRefs) db.entryOptions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$CategoryOptionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$CategoryOptionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          OptionRow,
                          $CategoryOptionsTable,
                          CategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryOptionsTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryOptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.defaultOptionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entryOptionsRefs)
                        await $_getPrefetchedData<
                          OptionRow,
                          $CategoryOptionsTable,
                          EntryOptionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoryOptionsTableReferences
                              ._entryOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoryOptionsTableReferences(
                                db,
                                table,
                                p0,
                              ).entryOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.optionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoryOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryOptionsTable,
      OptionRow,
      $$CategoryOptionsTableFilterComposer,
      $$CategoryOptionsTableOrderingComposer,
      $$CategoryOptionsTableAnnotationComposer,
      $$CategoryOptionsTableCreateCompanionBuilder,
      $$CategoryOptionsTableUpdateCompanionBuilder,
      (OptionRow, $$CategoryOptionsTableReferences),
      OptionRow,
      PrefetchHooks Function({
        bool categoryId,
        bool categoriesRefs,
        bool entryOptionsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String icon,
      required CategoryMode mode,
      Value<CategoryDisplay> display,
      Value<int?> defaultOptionId,
      Value<int> sort,
      Value<bool> hidden,
      required DateTime createdAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<CategoryMode> mode,
      Value<CategoryDisplay> display,
      Value<int?> defaultOptionId,
      Value<int> sort,
      Value<bool> hidden,
      Value<DateTime> createdAt,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoryOptionsTable _defaultOptionIdTable(_$AppDatabase db) => db
      .categoryOptions
      .createAlias('categories__default_option_id__category_options__id');

  $$CategoryOptionsTableProcessedTableManager? get defaultOptionId {
    final $_column = $_itemColumn<int>('default_option_id');
    if ($_column == null) return null;
    final manager = $$CategoryOptionsTableTableManager(
      $_db,
      $_db.categoryOptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultOptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CategoryOptionsTable, List<OptionRow>>
  _categoryOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categoryOptions,
    aliasName: 'categories__id__category_options__category_id',
  );

  $$CategoryOptionsTableProcessedTableManager get categoryOptionsRefs {
    final manager = $$CategoryOptionsTableTableManager(
      $_db,
      $_db.categoryOptions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _categoryOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategorySpansTable, List<CategorySpanRow>>
  _categorySpansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categorySpans,
    aliasName: 'categories__id__category_spans__category_id',
  );

  $$CategorySpansTableProcessedTableManager get categorySpansRefs {
    final manager = $$CategorySpansTableTableManager(
      $_db,
      $_db.categorySpans,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categorySpansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryMode, CategoryMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CategoryDisplay, CategoryDisplay, String>
  get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryOptionsTableFilterComposer get defaultOptionId {
    final $$CategoryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultOptionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> categoryOptionsRefs(
    Expression<bool> Function($$CategoryOptionsTableFilterComposer f) f,
  ) {
    final $$CategoryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categorySpansRefs(
    Expression<bool> Function($$CategorySpansTableFilterComposer f) f,
  ) {
    final $$CategorySpansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categorySpans,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategorySpansTableFilterComposer(
            $db: $db,
            $table: $db.categorySpans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryOptionsTableOrderingComposer get defaultOptionId {
    final $$CategoryOptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultOptionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryDisplay, String> get display =>
      $composableBuilder(column: $table.display, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoryOptionsTableAnnotationComposer get defaultOptionId {
    final $$CategoryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultOptionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> categoryOptionsRefs<T extends Object>(
    Expression<T> Function($$CategoryOptionsTableAnnotationComposer a) f,
  ) {
    final $$CategoryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categorySpansRefs<T extends Object>(
    Expression<T> Function($$CategorySpansTableAnnotationComposer a) f,
  ) {
    final $$CategorySpansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categorySpans,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategorySpansTableAnnotationComposer(
            $db: $db,
            $table: $db.categorySpans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool defaultOptionId,
            bool categoryOptionsRefs,
            bool categorySpansRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<CategoryMode> mode = const Value.absent(),
                Value<CategoryDisplay> display = const Value.absent(),
                Value<int?> defaultOptionId = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                mode: mode,
                display: display,
                defaultOptionId: defaultOptionId,
                sort: sort,
                hidden: hidden,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String icon,
                required CategoryMode mode,
                Value<CategoryDisplay> display = const Value.absent(),
                Value<int?> defaultOptionId = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                required DateTime createdAt,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                mode: mode,
                display: display,
                defaultOptionId: defaultOptionId,
                sort: sort,
                hidden: hidden,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                defaultOptionId = false,
                categoryOptionsRefs = false,
                categorySpansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoryOptionsRefs) db.categoryOptions,
                    if (categorySpansRefs) db.categorySpans,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (defaultOptionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.defaultOptionId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._defaultOptionIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._defaultOptionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (categoryOptionsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          OptionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._categoryOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categorySpansRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CategorySpanRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._categorySpansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).categorySpansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool defaultOptionId,
        bool categoryOptionsRefs,
        bool categorySpansRefs,
      })
    >;
typedef $$CategorySpansTableCreateCompanionBuilder =
    CategorySpansCompanion Function({
      Value<int> id,
      required int categoryId,
      required String fromDay,
      Value<String?> toDay,
    });
typedef $$CategorySpansTableUpdateCompanionBuilder =
    CategorySpansCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> fromDay,
      Value<String?> toDay,
    });

final class $$CategorySpansTableReferences
    extends
        BaseReferences<_$AppDatabase, $CategorySpansTable, CategorySpanRow> {
  $$CategorySpansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('category_spans__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategorySpansTableFilterComposer
    extends Composer<_$AppDatabase, $CategorySpansTable> {
  $$CategorySpansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromDay => $composableBuilder(
    column: $table.fromDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toDay => $composableBuilder(
    column: $table.toDay,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategorySpansTableOrderingComposer
    extends Composer<_$AppDatabase, $CategorySpansTable> {
  $$CategorySpansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromDay => $composableBuilder(
    column: $table.fromDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toDay => $composableBuilder(
    column: $table.toDay,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategorySpansTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategorySpansTable> {
  $$CategorySpansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromDay =>
      $composableBuilder(column: $table.fromDay, builder: (column) => column);

  GeneratedColumn<String> get toDay =>
      $composableBuilder(column: $table.toDay, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategorySpansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategorySpansTable,
          CategorySpanRow,
          $$CategorySpansTableFilterComposer,
          $$CategorySpansTableOrderingComposer,
          $$CategorySpansTableAnnotationComposer,
          $$CategorySpansTableCreateCompanionBuilder,
          $$CategorySpansTableUpdateCompanionBuilder,
          (CategorySpanRow, $$CategorySpansTableReferences),
          CategorySpanRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$CategorySpansTableTableManager(_$AppDatabase db, $CategorySpansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategorySpansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategorySpansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategorySpansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> fromDay = const Value.absent(),
                Value<String?> toDay = const Value.absent(),
              }) => CategorySpansCompanion(
                id: id,
                categoryId: categoryId,
                fromDay: fromDay,
                toDay: toDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String fromDay,
                Value<String?> toDay = const Value.absent(),
              }) => CategorySpansCompanion.insert(
                id: id,
                categoryId: categoryId,
                fromDay: fromDay,
                toDay: toDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategorySpansTable, CategorySpanRow>(table),
                  $$CategorySpansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$CategorySpansTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$CategorySpansTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategorySpansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategorySpansTable,
      CategorySpanRow,
      $$CategorySpansTableFilterComposer,
      $$CategorySpansTableOrderingComposer,
      $$CategorySpansTableAnnotationComposer,
      $$CategorySpansTableCreateCompanionBuilder,
      $$CategorySpansTableUpdateCompanionBuilder,
      (CategorySpanRow, $$CategorySpansTableReferences),
      CategorySpanRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required String day,
      required DateTime loggedAt,
      required int mood,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<DateTime> loggedAt,
      Value<int> mood,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, EntryRow> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntryOptionsTable, List<EntryOptionRow>>
  _entryOptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entryOptions,
    aliasName: 'entries__id__entry_options__entry_id',
  );

  $$EntryOptionsTableProcessedTableManager get entryOptionsRefs {
    final manager = $$EntryOptionsTableTableManager(
      $_db,
      $_db.entryOptions,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entryOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entryOptionsRefs(
    Expression<bool> Function($$EntryOptionsTableFilterComposer f) f,
  ) {
    final $$EntryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> entryOptionsRefs<T extends Object>(
    Expression<T> Function($$EntryOptionsTableAnnotationComposer a) f,
  ) {
    final $$EntryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryOptions,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.entryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, $$EntriesTableReferences),
          EntryRow,
          PrefetchHooks Function({bool entryOptionsRefs})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                day: day,
                loggedAt: loggedAt,
                mood: mood,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required DateTime loggedAt,
                required int mood,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => EntriesCompanion.insert(
                id: id,
                day: day,
                loggedAt: loggedAt,
                mood: mood,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryOptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entryOptionsRefs) db.entryOptions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entryOptionsRefs)
                    await $_getPrefetchedData<
                      EntryRow,
                      $EntriesTable,
                      EntryOptionRow
                    >(
                      currentTable: table,
                      referencedTable: $$EntriesTableReferences
                          ._entryOptionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$EntriesTableReferences(
                        db,
                        table,
                        p0,
                      ).entryOptionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.entryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, $$EntriesTableReferences),
      EntryRow,
      PrefetchHooks Function({bool entryOptionsRefs})
    >;
typedef $$EntryOptionsTableCreateCompanionBuilder =
    EntryOptionsCompanion Function({
      required int entryId,
      required int optionId,
      Value<int> rowid,
    });
typedef $$EntryOptionsTableUpdateCompanionBuilder =
    EntryOptionsCompanion Function({
      Value<int> entryId,
      Value<int> optionId,
      Value<int> rowid,
    });

final class $$EntryOptionsTableReferences
    extends BaseReferences<_$AppDatabase, $EntryOptionsTable, EntryOptionRow> {
  $$EntryOptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) =>
      db.entries.createAlias('entry_options__entry_id__entries__id');

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoryOptionsTable _optionIdTable(_$AppDatabase db) => db
      .categoryOptions
      .createAlias('entry_options__option_id__category_options__id');

  $$CategoryOptionsTableProcessedTableManager get optionId {
    final $_column = $_itemColumn<int>('option_id')!;

    final manager = $$CategoryOptionsTableTableManager(
      $_db,
      $_db.categoryOptions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_optionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntryOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryOptionsTableFilterComposer get optionId {
    final $$CategoryOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableFilterComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryOptionsTableOrderingComposer get optionId {
    final $$CategoryOptionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryOptionsTable> {
  $$EntryOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoryOptionsTableAnnotationComposer get optionId {
    final $$CategoryOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.optionId,
      referencedTable: $db.categoryOptions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntryOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryOptionsTable,
          EntryOptionRow,
          $$EntryOptionsTableFilterComposer,
          $$EntryOptionsTableOrderingComposer,
          $$EntryOptionsTableAnnotationComposer,
          $$EntryOptionsTableCreateCompanionBuilder,
          $$EntryOptionsTableUpdateCompanionBuilder,
          (EntryOptionRow, $$EntryOptionsTableReferences),
          EntryOptionRow,
          PrefetchHooks Function({bool entryId, bool optionId})
        > {
  $$EntryOptionsTableTableManager(_$AppDatabase db, $EntryOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> entryId = const Value.absent(),
                Value<int> optionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryOptionsCompanion(
                entryId: entryId,
                optionId: optionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int entryId,
                required int optionId,
                Value<int> rowid = const Value.absent(),
              }) => EntryOptionsCompanion.insert(
                entryId: entryId,
                optionId: optionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntryOptionsTable, EntryOptionRow>(table),
                  $$EntryOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, optionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntryOptionsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntryOptionsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (optionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.optionId,
                                referencedTable: $$EntryOptionsTableReferences
                                    ._optionIdTable(db),
                                referencedColumn: $$EntryOptionsTableReferences
                                    ._optionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntryOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryOptionsTable,
      EntryOptionRow,
      $$EntryOptionsTableFilterComposer,
      $$EntryOptionsTableOrderingComposer,
      $$EntryOptionsTableAnnotationComposer,
      $$EntryOptionsTableCreateCompanionBuilder,
      $$EntryOptionsTableUpdateCompanionBuilder,
      (EntryOptionRow, $$EntryOptionsTableReferences),
      EntryOptionRow,
      PrefetchHooks Function({bool entryId, bool optionId})
    >;
typedef $$PeriodsTableCreateCompanionBuilder =
    PeriodsCompanion Function({
      Value<int> id,
      required String name,
      required String startDay,
      Value<String?> endDay,
      Value<bool> away,
      Value<String?> icon,
    });
typedef $$PeriodsTableUpdateCompanionBuilder =
    PeriodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> startDay,
      Value<String?> endDay,
      Value<bool> away,
      Value<String?> icon,
    });

class $$PeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get away => $composableBuilder(
    column: $table.away,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get away => $composableBuilder(
    column: $table.away,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<bool> get away =>
      $composableBuilder(column: $table.away, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$PeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodsTable,
          PeriodRow,
          $$PeriodsTableFilterComposer,
          $$PeriodsTableOrderingComposer,
          $$PeriodsTableAnnotationComposer,
          $$PeriodsTableCreateCompanionBuilder,
          $$PeriodsTableUpdateCompanionBuilder,
          (PeriodRow, BaseReferences<_$AppDatabase, $PeriodsTable, PeriodRow>),
          PeriodRow,
          PrefetchHooks Function()
        > {
  $$PeriodsTableTableManager(_$AppDatabase db, $PeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> startDay = const Value.absent(),
                Value<String?> endDay = const Value.absent(),
                Value<bool> away = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => PeriodsCompanion(
                id: id,
                name: name,
                startDay: startDay,
                endDay: endDay,
                away: away,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String startDay,
                Value<String?> endDay = const Value.absent(),
                Value<bool> away = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => PeriodsCompanion.insert(
                id: id,
                name: name,
                startDay: startDay,
                endDay: endDay,
                away: away,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeriodsTable, PeriodRow>(table),
                  BaseReferences<_$AppDatabase, $PeriodsTable, PeriodRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodsTable,
      PeriodRow,
      $$PeriodsTableFilterComposer,
      $$PeriodsTableOrderingComposer,
      $$PeriodsTableAnnotationComposer,
      $$PeriodsTableCreateCompanionBuilder,
      $$PeriodsTableUpdateCompanionBuilder,
      (PeriodRow, BaseReferences<_$AppDatabase, $PeriodsTable, PeriodRow>),
      PeriodRow,
      PrefetchHooks Function()
    >;
typedef $$ImportMapsTableCreateCompanionBuilder =
    ImportMapsCompanion Function({
      required String source,
      required String kind,
      required int sourceId,
      required String action,
      Value<int?> targetId,
      Value<String?> name,
      Value<int> rowid,
    });
typedef $$ImportMapsTableUpdateCompanionBuilder =
    ImportMapsCompanion Function({
      Value<String> source,
      Value<String> kind,
      Value<int> sourceId,
      Value<String> action,
      Value<int?> targetId,
      Value<String?> name,
      Value<int> rowid,
    });

class $$ImportMapsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportMapsTable> {
  $$ImportMapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportMapsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportMapsTable> {
  $$ImportMapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportMapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportMapsTable> {
  $$ImportMapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ImportMapsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportMapsTable,
          ImportMapRow,
          $$ImportMapsTableFilterComposer,
          $$ImportMapsTableOrderingComposer,
          $$ImportMapsTableAnnotationComposer,
          $$ImportMapsTableCreateCompanionBuilder,
          $$ImportMapsTableUpdateCompanionBuilder,
          (
            ImportMapRow,
            BaseReferences<_$AppDatabase, $ImportMapsTable, ImportMapRow>,
          ),
          ImportMapRow,
          PrefetchHooks Function()
        > {
  $$ImportMapsTableTableManager(_$AppDatabase db, $ImportMapsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportMapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportMapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportMapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int?> targetId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportMapsCompanion(
                source: source,
                kind: kind,
                sourceId: sourceId,
                action: action,
                targetId: targetId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required String kind,
                required int sourceId,
                required String action,
                Value<int?> targetId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportMapsCompanion.insert(
                source: source,
                kind: kind,
                sourceId: sourceId,
                action: action,
                targetId: targetId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportMapsTable, ImportMapRow>(table),
                  BaseReferences<_$AppDatabase, $ImportMapsTable, ImportMapRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportMapsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportMapsTable,
      ImportMapRow,
      $$ImportMapsTableFilterComposer,
      $$ImportMapsTableOrderingComposer,
      $$ImportMapsTableAnnotationComposer,
      $$ImportMapsTableCreateCompanionBuilder,
      $$ImportMapsTableUpdateCompanionBuilder,
      (
        ImportMapRow,
        BaseReferences<_$AppDatabase, $ImportMapsTable, ImportMapRow>,
      ),
      ImportMapRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> themeModeIndex,
      Value<int> fontIndex,
      Value<String> localeCode,
      Value<int> dayCutoffHour,
      Value<String?> statsTiles,
      Value<bool> appLock,
      Value<int> appLockDelaySeconds,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> themeModeIndex,
      Value<int> fontIndex,
      Value<String> localeCode,
      Value<int> dayCutoffHour,
      Value<String?> statsTiles,
      Value<bool> appLock,
      Value<int> appLockDelaySeconds,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get themeModeIndex => $composableBuilder(
    column: $table.themeModeIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fontIndex => $composableBuilder(
    column: $table.fontIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayCutoffHour => $composableBuilder(
    column: $table.dayCutoffHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsTiles => $composableBuilder(
    column: $table.statsTiles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLock => $composableBuilder(
    column: $table.appLock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appLockDelaySeconds => $composableBuilder(
    column: $table.appLockDelaySeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeModeIndex => $composableBuilder(
    column: $table.themeModeIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fontIndex => $composableBuilder(
    column: $table.fontIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayCutoffHour => $composableBuilder(
    column: $table.dayCutoffHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsTiles => $composableBuilder(
    column: $table.statsTiles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLock => $composableBuilder(
    column: $table.appLock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appLockDelaySeconds => $composableBuilder(
    column: $table.appLockDelaySeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get themeModeIndex => $composableBuilder(
    column: $table.themeModeIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fontIndex =>
      $composableBuilder(column: $table.fontIndex, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayCutoffHour => $composableBuilder(
    column: $table.dayCutoffHour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statsTiles => $composableBuilder(
    column: $table.statsTiles,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLock =>
      $composableBuilder(column: $table.appLock, builder: (column) => column);

  GeneratedColumn<int> get appLockDelaySeconds => $composableBuilder(
    column: $table.appLockDelaySeconds,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> themeModeIndex = const Value.absent(),
                Value<int> fontIndex = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<int> dayCutoffHour = const Value.absent(),
                Value<String?> statsTiles = const Value.absent(),
                Value<bool> appLock = const Value.absent(),
                Value<int> appLockDelaySeconds = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeModeIndex: themeModeIndex,
                fontIndex: fontIndex,
                localeCode: localeCode,
                dayCutoffHour: dayCutoffHour,
                statsTiles: statsTiles,
                appLock: appLock,
                appLockDelaySeconds: appLockDelaySeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> themeModeIndex = const Value.absent(),
                Value<int> fontIndex = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<int> dayCutoffHour = const Value.absent(),
                Value<String?> statsTiles = const Value.absent(),
                Value<bool> appLock = const Value.absent(),
                Value<int> appLockDelaySeconds = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeModeIndex: themeModeIndex,
                fontIndex: fontIndex,
                localeCode: localeCode,
                dayCutoffHour: dayCutoffHour,
                statsTiles: statsTiles,
                appLock: appLock,
                appLockDelaySeconds: appLockDelaySeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MoodLabelsTableTableManager get moodLabels =>
      $$MoodLabelsTableTableManager(_db, _db.moodLabels);
  $$CategoryOptionsTableTableManager get categoryOptions =>
      $$CategoryOptionsTableTableManager(_db, _db.categoryOptions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CategorySpansTableTableManager get categorySpans =>
      $$CategorySpansTableTableManager(_db, _db.categorySpans);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$EntryOptionsTableTableManager get entryOptions =>
      $$EntryOptionsTableTableManager(_db, _db.entryOptions);
  $$PeriodsTableTableManager get periods =>
      $$PeriodsTableTableManager(_db, _db.periods);
  $$ImportMapsTableTableManager get importMaps =>
      $$ImportMapsTableTableManager(_db, _db.importMaps);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
