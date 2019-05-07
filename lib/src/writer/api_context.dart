import 'package:code_builder/code_builder.dart';
import 'package:contracts/src/builder_config.dart';
import 'package:contracts/src/writer/utils/common_types.dart';
import 'package:web3dart/contracts.dart';

class ApiContext {

  Set<IntroducedTupleWrapper> tupleWrappers = <IntroducedTupleWrapper>{};
  final BuilderConfig config;

  ApiContext(this.config);

  String fieldNameForFunction(ContractFunction fun) {
    if (fun.isConstructor) {
      return r'_$constructor';
    } else {
      return '_\$${fun.name}';
    }
  }

  Reference dartTypeFor(AbiType type, String suggestedName) {
    if (type is UintType) {
      return type.length <= config.dartUintSize ? dartInt : bigInt;
    }
    if (type is IntType) {
      return type.length <= config.dartIntSize ? dartInt : bigInt;
    }
    if (type is AddressType)
      return ethereumAddress;
    if (type is BoolType)
      return dartBool;
    if (type is FixedBytes || type is DynamicBytes)
      return uint8List;
    if (type is StringType)
      return string;

    if (type is FixedLengthArray) {
      return listify(dartTypeFor(type.type, suggestedName));
    }
    if (type is DynamicLengthArray) {
      return listify(dartTypeFor(type.type, suggestedName));
    }

    // todo tuples

    throw ArgumentError('No suitable dart type for $type was found');
  }

  Expression prepareDartValueForAbi(Expression inner, AbiType type) {
    return inner;
  }

  Expression prepareAbiReturnForDart(Expression inner, AbiType type) {
    return inner;
  }

}

/// There are some solidity concepts which can only be turned into a nice dart
/// API by introducing further classes:
///
/// For instance:
/// - Solidity functions can return more than one value - we generate a wrapper
/// to encode that
/// - Solidity functions can take tuples or structs as arguments
class IntroducedTupleWrapper extends Reference {

  final String name;
  final List<FunctionParameter> parameters;

  const IntroducedTupleWrapper(this.name, this.parameters): super(name);

}