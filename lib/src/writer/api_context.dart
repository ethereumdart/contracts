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

  AtomicFunctionType resolveAbiType(AbiType type, String suggestedName) {
    if (type is UintType) {
      final dartType = type.length <= config.dartUintSize ? dartInt : bigInt;
      return AtomicFunctionType(type, dartType);
    }
    if (type is IntType) {
      final dartType = type.length <= config.dartIntSize ? dartInt : bigInt;
      return AtomicFunctionType(type, dartType);
    }
    if (type is AddressType) return AtomicFunctionType(type, ethereumAddress);
    if (type is BoolType) return AtomicFunctionType(type, dartBool);
    if (type is FixedBytes || type is DynamicBytes)
      return AtomicFunctionType(type, uint8List);
    if (type is StringType) return AtomicFunctionType(type, string);

    if (type is FixedLengthArray) {
      final inner = resolveAbiType(type.type, suggestedName);
      return AtomicFunctionType(type, listify(inner.dartType));
    }
    if (type is DynamicLengthArray) {
      final inner = resolveAbiType(type.type, suggestedName);
      return AtomicFunctionType(type, listify(inner.dartType));
    }

    // todo tuples

    throw ArgumentError('No suitable dart type for $type was found');
  }

  /// Generates an [Expression] that turns the [inner] expression into something
  /// that can be passed to [ContractFunction.encodeCall]. This is not just the
  /// identity function: We introduce dart classes for tuples and might need to
  /// map from native dart ints to big ints.
  Expression prepareDartValueForAbi(
      Expression inner, ResolvedFunctionType type) {
    if (type is AtomicFunctionType) {
      // We let some APIs use a "int" as parameter while the underlying abi type
      // would expect a "BigInt".
      final abiType = type.type;
      final needsMapping = (abiType is UintType || abiType is IntType) &&
          type.dartType == dartInt;

      if (needsMapping) {
        return bigInt.newInstanceNamed('from', [inner]);
      }
    }

    // todo also support tuples here

    return inner;
  }

  Expression prepareAbiReturnForDart(
      Expression inner, ResolvedFunctionType type) {
    if (type is AtomicFunctionType) {
      // ContractFunction.decodeReturnValues returns a list, but as we have an
      // atomic type there will only be one entry
      final value = inner.property('single');
      final abiType = type.type;

      // same as prepareDartValueForAbi, but in reverse: Some types that emit a
      // BigInt need to be converted to a simple dart int.
      final needsMapping = (abiType is UintType || abiType is IntType) &&
          type.dartType == dartInt;

      if (needsMapping) {
        return value.asA(bigInt).property('toInt').call([]);
      }

      return value.asA(type.dartType);
    }

    // todo also support tuples here

    return inner;
  }
}

abstract class ResolvedFunctionType {
  Reference get dartType;
}

class AtomicFunctionType implements ResolvedFunctionType {
  final AbiType type;
  @override
  final Reference dartType;

  const AtomicFunctionType(this.type, this.dartType);
}

/// There are some solidity concepts which can only be turned into a nice dart
/// API by introducing further classes:
///
/// For instance:
/// - Solidity functions can return more than one value - we generate a wrapper
/// to encode that
/// - Solidity functions can take tuples or structs as arguments
class IntroducedTupleWrapper extends Reference implements ResolvedFunctionType {
  final String name;
  final List<FunctionParameter> parameters;

  @override
  Reference get dartType => this;

  const IntroducedTupleWrapper(this.name, this.parameters) : super(name);
}
