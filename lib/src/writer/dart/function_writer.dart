import 'package:code_builder/code_builder.dart';
import 'package:contracts/src/writer/api_context.dart';
import 'package:contracts/src/writer/utils/common_expressions.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';

class FunctionWriter {
  final ApiContext context;
  final ContractFunction function;

  FunctionWriter(this.context, this.function);

  bool get needsTransaction => !function.isConstant;

  Method writeDartMethod() {
    final docs = <String>[];

    ResolvedFunctionType solidityReturnType;
    Reference dartReturnType;

    if (needsTransaction) {
      // the result of non-constant methods can only be obtained by making a
      // transaction which then needs to be mined etc. That can take a very long
      // time, so we just return the transaction hash.
      dartReturnType = string;
    } else if (function.outputs.isEmpty) {
      dartReturnType = const Reference('void', 'dart:core');
    } else if (function.outputs.length == 1) {
      final abiType = function.outputs.single;
      solidityReturnType = context.resolveAbiType(abiType.type, null);
    } else {
      // todo better suggested name
      final wrappedTuple =
          CompositeFunctionParameter('Test_Name', function.outputs, []);
      solidityReturnType =
          context.resolveAbiType(wrappedTuple.type, 'Test_Name');
    }

    dartReturnType ??= solidityReturnType.dartType;

    final parameterTypes = <ResolvedFunctionType>[];
    final dartParams = <Parameter>[];

    for (var param in function.parameters) {
      final type = context.resolveAbiType(param.type, param.name);
      parameterTypes.add(type);
      dartParams.add(
        Parameter((b) => b
          ..type = type.dartType
          ..name = param.name),
      );
    }

    if (needsTransaction) {
      // todo handle payable functions (this assumes nonPayable). Payable functions
      // would need another parameter for the amount to send
      dartParams.insert(
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
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll(dartParams)
      ..returns = futurize(dartReturnType)
      ..docs.addAll(docs.map((line) => '/// $line'))
      ..body = _writeBody(parameterTypes, solidityReturnType));
  }

  Code _writeBody(
      List<ResolvedFunctionType> parameters, ResolvedFunctionType returnType) {
    final field = context.fieldNameForFunction(function);
    final encodedArgs = <Expression>[];

    for (var i = 0; i < parameters.length; i++) {
      final parameter = function.parameters[i];
      final resolvedType = parameters[i];

      encodedArgs.add(context.prepareDartValueForAbi(
          CodeExpression(Code(parameter.name)), resolvedType));
    }

    return Block((b) {
      // final callData = _$impl.encodeCall(p1, ..., pn);
      b.addExpression(
        this$.property(field).property('encodeCall').call(
          [literalList(encodedArgs)],
        ).assignFinal('\$callData'),
      );

      if (needsTransaction) {
        b.statements.add(const Code('return client.sendTransaction('
            r'credentials, Transaction(to: address, data: $callData));'));
      } else {
        if (function.outputs.isEmpty) {
        } else {
          b.statements.add(const Code('final \$encodedResults = await '
              'this.client.callRaw(contract: this.address, data: \$callData);'));

          b.statements.add(Code('final \$decoded = '
              'this.$field.decodeReturnValues(\$encodedResults);'));

          b.addExpression(context
              .prepareAbiReturnForDart(refer('\$decoded'), returnType)
              .returned);
        }
      }
    });
  }
}
