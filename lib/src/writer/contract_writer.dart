import 'package:contracts/src/writer/abi/abi_constructors.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';
import 'package:code_builder/code_builder.dart';

class ContractWriter {
  final ContractAbi abi;

  ContractWriter(this.abi);

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
            ]),
        ),
      ]);
    });
  }

  Iterable<Field> _functionFields() {
    return abi.functions
        .where(_filterActualFunctionsBecauseOfWeb3DartBug)
        .map((f) {
      return Field((b) => b
        ..name = _fieldNameForFunction(f)
        ..type = contractFunction
        ..modifier = FieldModifier.final$
        ..assignment = writeFunction(f).code);
    });
  }

  bool _filterActualFunctionsBecauseOfWeb3DartBug(ContractFunction f) {
    // events are also written as functions, assume uppercase function names are
    // events.
    // The bug is fixed on master, but present in 1.0.0-rc.0
    if (f.name == null)
      return true;

    final firstChar = f.name.substring(0, 1);
    return firstChar.toLowerCase() == firstChar;
  }

  String _fieldNameForFunction(ContractFunction fun) {
    if (fun.isConstructor) {
      return r'_$constructor';
    } else {
      return '_\$${fun.name}';
    }
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
