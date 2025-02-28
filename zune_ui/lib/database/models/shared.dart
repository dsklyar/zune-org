part of database;

abstract class InteractiveItem {
  Future<void> addToQuickplay();
  Future<void> removeFromQuickplay();
}

abstract class PlayableItem extends InteractiveItem {
  Future<void> addToNowPlaying();
}

enum Operator {
  andOp("AND"),
  inOp("IN");

  final String sqlName;
  const Operator(this.sqlName);
}

class WhereClauseValue {
  final Operator op;
  final dynamic value;

  WhereClauseValue({required this.op, required this.value});
}

typedef WhereClause = Map<String, WhereClauseValue>;
typedef TransformResult<T, R> = R Function(T);

abstract class BaseModelColumns {
  List<String> get values;

  const BaseModelColumns();

  String toSqlClause(WhereClause where) {
    final conditions = <String>[];

    for (var key in values) {
      if (where.containsKey(key)) {
        final op = where[key]!.op;
        final value = where[key]!.value;

        switch (op) {
          case Operator.inOp:
            {
              String inValues;
              if (value is List<int>) {
                inValues = value.map((v) => "$v").join(', ');
              }
              if (value is List<String> || value is List<int>) {
                inValues = value.map((v) => "'$v'").join(', ');
              } else {
                throw ArgumentError(
                    'Value for IN operator must be a list of strings/ints');
              }
              conditions.add('$key ${op.sqlName} ($inValues)');
            }
            break;
          case Operator.andOp:
            {
              if (value is String) {
                conditions.add('$key = "$value"');
              } else {
                throw ArgumentError('Value for AND operator must be a string');
              }
            }
            break;
        }
      }
    }

    return conditions.join(' AND ');
  }
}
