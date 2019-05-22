import 'package:contracts/src/builder_config.dart';
import 'package:contracts/src/writer/dart/abi_object_instantiation.dart';
import 'package:contracts/src/writer/api_context.dart';
import 'package:contracts/src/writer/dart/function_writer.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';
import 'package:code_builder/code_builder.dart';

class ContractWriter {
  final ContractAbi abi;
  final ApiContext context;

  ContractWriter(this.abi, BuilderConfig config) : context = ApiContext(config);

  Spec write() {
    return Library((b) {
      b.body.addAll([
        Class(
          (b) => b
            ..name = abi.name
            ..fields.addAll([
              Field((b) => b
                ..name = 'address'
                ..type = ethereumAddress
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
            ..methods
                .addAll(abi.functions.where((f) => !f.isConstructor).map((f) {
              return FunctionWriter(context, f).writeDartMethod();
            })),
        ),
      ]);
    });
  }

  Iterable<Field> _functionFields() {
    return abi.functions.map((f) {
      return Field((b) => b
        ..name = context.fieldNameForFunction(f)
        ..type = contractFunction
        ..modifier = FieldModifier.final$
        ..assignment = writeFunction(f).code);
    });
  }

  Constructor _defaultConstructor() {
    return Constructor(
      (b) => b
        ..name = '_'
        ..constant = true
        ..requiredParameters.addAll([
          Parameter((b) => b
            ..toThis = true
            ..name = 'address'),
          Parameter((b) => b
            ..toThis = true
            ..name = 'client'),
        ]),
    );
  }
}
