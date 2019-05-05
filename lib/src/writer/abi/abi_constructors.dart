import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';
import 'package:code_builder/code_builder.dart';

Expression writeFunction(ContractFunction function) {
  // todo remove. web3dart should expose the type and mutability directly
  final type = function.isConstructor
      ? ContractFunctionType.constructor
      : (function.isDefault
          ? ContractFunctionType.fallback
          : ContractFunctionType.function);
  final mutability = function.isConstant
      ? StateMutability.view
      : (function.isPayable
          ? StateMutability.payable
          : StateMutability.nonPayable);

  return contractFunction.constInstance([
    literalString(
        function.name ?? ''), // todo remove ?? check after web3dart update
    literalConstList(function.parameters.map(writeFunctionParameter).toList()),
  ], {
    'type': functionTypes[type],
    'mutability': mutabilities[mutability],
    'outputs':
        literalConstList(function.outputs.map(writeFunctionParameter).toList()),
  });
}

Expression writeFunctionParameter(FunctionParameter parameter) {
  final name = literalString(parameter.name);

  if (parameter is CompositeFunctionParameter) {
    final components = literalConstList(
        parameter.components.map(writeFunctionParameter).toList());
    final arrayLengths = literalConstList(parameter.arrayLengths);

    return compositeFunctionParameter
        .newInstance([name, components, arrayLengths]);
  } else {
    return functionParameter
        .constInstance([name, writeAbiType(parameter.type)]);
  }
}

Expression writeAbiType(AbiType type) {
  if (type is UintType)
    return uIntType.constInstance([], {'length': literalNum(type.length)});
  if (type is IntType)
    return intType.constInstance([], {'length': literalNum(type.length)});
  if (type is AddressType)
    return addressType.constInstance([]);
  if (type is BoolType)
    return boolType.constInstance([]);
  if (type is FixedBytes)
    return fixedBytes.constInstance([literalNum(type.length)]);
  if (type is DynamicBytes)
    return dynamicBytes.constInstance([]);
  if (type is StringType)
    return stringType.constInstance([]);

  if (type is FixedLengthArray) {
    return fixedLengthArray.constInstance([], {
      'type': writeAbiType(type.type),
      'length': literalNum(type.length),
    });
  }
  if (type is DynamicLengthArray) {
    return dynamicLengthArray.constInstance([], {
      'type': writeAbiType(type.type),
    });
  }
  if (type is TupleType) {
    return tupleType.constInstance([
      literalConstList(type.types.map(writeAbiType).toList()),
    ]);
  }

  throw ArgumentError('Unknown type: $type');
}
