import 'package:code_builder/code_builder.dart' hide FunctionType;
import 'package:web3dart/web3dart.dart';

const package = 'package:web3dart/web3dart.dart';

/// Refers to the [EthereumAddress] type.
final ethereumAddress = refer('EthereumAddress', package);

final dartInt = refer('int', 'dart:core');
final dartBool = refer('bool', 'dart:core');
final string = refer('String', 'dart:core');
final bigInt = refer('BigInt', 'dart:core');
final uint8List = refer('Uint8List', 'dart:typed_data');

/// [Web3Client]
final web3Client = refer('Web3Client', package);

/// [Credentials].
final credentials = refer('Credentials', package);

/// [ContractAbi]
final contractAbi = refer('ContractAbi', package);

/// [ContractFunction]
final contractFunction = refer('ContractFunction', package);

/// [FunctionParameter]
final functionParameter = refer('FunctionParameter', package);

/// [CompositeFunctionParameter]
final compositeFunctionParameter = refer('CompositeFunctionParameter', package);

/// [UintType]
final uIntType = refer('UintType', package);

/// [IntType]
final intType = refer('IntType', package);

/// [BoolType]
final boolType = refer('BoolType', package);

/// [AddressType]
final addressType = refer('AddressType', package);

/// [FixedBytes]
final fixedBytes = refer('FixedBytes', package);

/// [FunctionType]
final functionType = refer('FunctionType', package);

/// [DynamicBytes]
final dynamicBytes = refer('dynamicBytes', package);

/// [StringType]
final stringType = refer('StringType', package);

/// [FixedLengthArray]
final fixedLengthArray = refer('FixedLengthArray', package);

/// [DynamicLengthArray]
final dynamicLengthArray = refer('DynamicLengthArray', package);

/// [TupleType]
final tupleType = refer('TupleType', package);

final mutabilities = {
  StateMutability.pure: refer('StateMutability.pure', package),
  StateMutability.view: refer('StateMutability.view', package),
  StateMutability.nonPayable: refer('StateMutability.nonPayable', package),
  StateMutability.payable: refer('StateMutability.payable', package),
};

final functionTypes = {
  ContractFunctionType.function:
      refer('ContractFunctionType.function', package),
  ContractFunctionType.fallback:
      refer('ContractFunctionType.fallback', package),
  ContractFunctionType.constructor:
      refer('ContractFunctionType.constructor', package),
};

Reference futurize(Reference r) {
  return TypeReference((b) => b
    ..symbol = 'Future'
    ..types.add(r));
}

Reference listify(Reference r) {
  return TypeReference((b) => b
    ..symbol = 'List'
    ..types.add(r));
}