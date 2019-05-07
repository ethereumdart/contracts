import 'package:web3dart/web3dart.dart';

class TestContract {
  const TestContract._(this.abi, this.client);

  final ContractAbi abi;

  final Web3Client client;

  final ContractFunction _$constructor = const ContractFunction('', [],
      type: ContractFunctionType.constructor,
      mutability: StateMutability.nonPayable,
      outputs: []);

  final ContractFunction _$sendCoin = const ContractFunction(
      'sendCoin',
      [
        FunctionParameter('receiver', AddressType()),
        FunctionParameter('amount', UintType(length: 256))
      ],
      type: ContractFunctionType.function,
      mutability: StateMutability.nonPayable,
      outputs: [FunctionParameter('sufficient', BoolType())]);

  final ContractFunction _$getBalanceInEth = const ContractFunction(
      'getBalanceInEth', [FunctionParameter('addr', AddressType())],
      type: ContractFunctionType.function,
      mutability: StateMutability.view,
      outputs: [FunctionParameter('', UintType(length: 256))]);

  final ContractFunction _$getBalance = const ContractFunction(
      'getBalance', [FunctionParameter('addr', AddressType())],
      type: ContractFunctionType.function,
      mutability: StateMutability.view,
      outputs: [FunctionParameter('', UintType(length: 256))]);

  /// This function requires a transaction, so the [credentials] will
  /// be used to sign the call.
  /// Instead of the function result (if any), the transaction hash will be
  /// returned. You can use [Web3Client.getTransactionByHash] to retrieve
  /// more information about the transaction after it has been mined.
  Future<String> sendCoin(
      Credentials credentials, EthereumAddress receiver, BigInt amount) {
    final $callData = _$sendCoin.encodeCall([receiver, amount]);
  }

  Future<BigInt> getBalanceInEth(EthereumAddress addr) {
    final $callData = _$getBalanceInEth.encodeCall([addr]);
  }

  Future<BigInt> getBalance(EthereumAddress addr) {
    final $callData = _$getBalance.encodeCall([addr]);
  }
}
