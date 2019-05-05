import 'package:code_builder/code_builder.dart';
import 'package:contracts/src/writer/api_context.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';

class FunctionWriter {
  final ApiContext context;
  final ContractFunction function;

  FunctionWriter(this.context, this.function);

  Method writeDartMethod() {
    final needsTransaction = !function.isConstant;
    final docs = <String>[];

    Reference returnType;
    if (needsTransaction) {
      // the result of non-constant methods can only be obtained by making a
      // transaction which then needs to be mined etc. That can take a very long
      // time, so we just return the transaction hash.
      returnType = string;
    } else if (function.outputs.isEmpty) {
      returnType = const Reference('void', 'dart:core');
    } else if (function.outputs.length == 1) {
      final abiType = function.outputs.single;
      returnType = context.dartTypeFor(abiType.type, null);
    } else {
      // todo better suggested name
      final wrappedTuple =
          CompositeFunctionParameter('Test_Name', function.outputs, []);
      returnType = context.dartTypeFor(wrappedTuple.type, 'Test_Name');
    }

    final parameters = function.parameters.map((param) {
      final type = context.dartTypeFor(param.type, param.name);
      return Parameter((b) => b
        ..type = type
        ..name = param.name);
    }).toList();

    if (needsTransaction) {
      parameters.insert(
        0,
        Parameter((b) => b
          ..name = 'credentials'
          ..type = credentials),
      );

      docs.addAll(const [
        'This function requires a transaction, so the [credentials] will',
        'be used to sign the call.',
        'Instead of the function result (if any), the transaction hash will be',
        'returned. You can use [Web3Client.getTransactionByHash] to retrieve',
        'more information about the transaction after it has been mined.'
      ]);
    }

    return Method((b) => b
      ..name = function.name
      ..requiredParameters.addAll(parameters)
      ..returns = futurize(returnType)
      ..docs.addAll(docs.map((line) => '/// $line'))
      ..body = const Code(''));
  }
}
