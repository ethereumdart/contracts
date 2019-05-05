import 'package:contracts/src/builder_config.dart';
import 'package:contracts/src/writer/abi/abi_constructors.dart';
import 'package:contracts/src/writer/api_context.dart';
import 'package:contracts/src/writer/dart/function_writer.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';
import 'package:code_builder/code_builder.dart';

class ContractWriter {
  final ContractAbi abi;
  final ApiContext context;

  ContractWriter(this.abi, BuilderConfig config): context = ApiContext(config);

  Spec write() {
    return Library((b) {
      b.body.addAll([
        Class(
          (b) => b
            ..name = abi.name
            ..fields.addAll([
              Field((b) => b
                ..name = 'abi'
                ..type = contractAbi
                ..modifier = FieldModifier.final$),
              Field((b) => b
                ..name = 'client'
                ..type = web3Client
                ..modifier = FieldModifier.final$)
            ])
            ..fields.addAll(_functionFields())
            ..constructors.addAll([
              _defaultConstructor(),
            ])
            ..methods.addAll(
                _actualFunctions.where((f) => !f.isConstructor).map((f) {
              return FunctionWriter(context, f).writeDartMethod();
            })),
        ),
      ]);
    });
  }

  Iterable<ContractFunction> get _actualFunctions =>
      abi.functions.where(_filterActualFunctionsBecauseOfWeb3DartBug);

  Iterable<Field> _functionFields() {
    return _actualFunctions.map((f) {
      return Field((b) => b
        ..name = context.fieldNameForFunction(f)
        ..type = contractFunction
        ..modifier = FieldModifier.final$
        ..assignment = writeFunction(f).code);
    });
  }

  bool _filterActualFunctionsBecauseOfWeb3DartBug(ContractFunction f) {
    // events are also written as functions, assume uppercase function names are
    // events.
    // The bug is fixed on master, but present in 1.0.0-rc.0
    if (f.name == null) return true;

    final firstChar = f.name.substring(0, 1);
    return firstChar.toLowerCase() == firstChar;
  }

  Constructor _defaultConstructor() {
    return Constructor(
      (b) => b
        ..name = '_'
        ..constant = true
        ..requiredParameters.addAll([
          Parameter((b) => b
            ..toThis = true
            ..name = 'abi'),
          Parameter((b) => b
            ..toThis = true
            ..name = 'client'),
        ]),
    );
  }
}
