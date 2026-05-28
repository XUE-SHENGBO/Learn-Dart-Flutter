import '../command_runner.dart';
import 'dart:collection';
import 'dart:async';
enum OptionType { flag, option }

abstract class Argument {//参数的抽象类,Option和Command都继承自Argument
  String get name;//参数名,如--help, --version, -h, -v等
  String? get help;

  // In the case of flags, the default value is a bool.
  // In other options and commands, the default value is a String.
  // NB: flags are just Option objects that don't take arguments
  Object? get defaultValue;
  String? get valueHelp;

  String get usage;
}
class Option extends Argument {//选项类,如--help, --version, -h, -v等
  Option(
    this.name, {
    required this.type,
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });//构造函数,接收参数名,选项类型,帮助信息,缩写,默认值和值的帮助信息

  @override
  final String name;

  final OptionType type;

  @override
  final String? help;

  final String? abbr;

  @override
  final Object? defaultValue;

  @override
  final String? valueHelp;

  @override
  String get usage {
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }

    return '--$name: $help';
  }
}

abstract class Command extends Argument {//命令类,如help, version等
  @override
  String get name;

  String get description;

  bool get requiresArgument => false;//命令是否需要参数,默认为false,如果需要参数则在解析命令行参数时会将命令参数存储在ArgResults的commandArg字段中

  late CommandRunner runner;//命令所属的命令运行器,在添加命令时会将命令运行器赋值给命令的runner字段

  @override
  String? help;

  @override
  String? defaultValue;

  @override
  String? valueHelp;

  final List<Option> _options = [];//每个指令都有一串选项,并且私有保证外部无法直接修改选项列表,只能通过addFlag和addOption方法添加选项

  UnmodifiableSetView<Option> get options =>//
      UnmodifiableSetView(_options.toSet());//

  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  // An option is an [Option] that takes a value.
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage {
    return '$name:  $description';
  }
}

// Add this class to the end of the file
class ArgResults {//解析命令行参数的结果类,包含命令,命令参数和选项
  Command? command;
  String? commandArg;
  Map<Option, Object?> options = {};//选项和选项值的映射,如--help: true, --version: false等

  // Returns true if the flag exists.
  bool flag(String name) {//检查选项中是否存在指定名称的标志,如果存在则返回其值,否则返回false
    // Only check flags, because we're sure that flags are booleans.
    for (var option in options.keys.where(
      (option) => option.type == OptionType.flag,
    )) {//遍历选项中所有类型为flag的选项,如果存在名称为name的选项则返回其值,否则返回false
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  bool hasOption(String name) {//检查选项中是否存在指定名称的选项,如果存在则返回true,否则返回false
    return options.keys.any((option) => option.name == name);
  }

  ({Option option, Object? input}) getOption(String name) {//获取指定名称的选项和选项值,如果存在则返回选项和选项值的元组,否则抛出异常
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );

    return (option: mapEntry.key, input: mapEntry.value);
  }
}
