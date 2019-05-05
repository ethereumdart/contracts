import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:contracts/src/writer/contract_writer.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:web3dart/contracts.dart';

final _nameExtractor = RegExp(r'^([^\.]*).*$');

class ContractsBuilder implements Builder {

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.abi.json': ['.g.dart']
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final name = _nameExtractor.firstMatch(input.pathSegments.last).group(1);

    final abi = ContractAbi.fromJson(await buildStep.readAsString(input), 'TestContract');
    final code = ContractWriter(abi).write();

    final emitter = DartEmitter(_OnlyImportWeb3Dart());
    final formatter = DartFormatter();
    final formattedCode = formatter.format(code.accept(emitter).toString());

    final target = AssetId(input.package, p.join(p.dirname(input.path), '$name.g.dart'));
    await buildStep.writeAsString(target, formattedCode);
  }

}

/// An [Allocator] for code that only imports web3dart.
class _OnlyImportWeb3Dart implements Allocator {

  @override
  String allocate(Reference reference) {
    return reference.symbol;
  }

  @override
  final Iterable<Directive> imports = [
    Directive.import('package:web3dart/web3dart.dart'),
  ];

}