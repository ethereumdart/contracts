library contracts;

import 'package:build/build.dart';
import 'package:contracts/contracts.dart';
import 'package:contracts/src/builder_config.dart';

export 'src/builder.dart';

Builder contractsBuilder(BuilderOptions options) =>
    ContractsBuilder(BuilderConfig());
