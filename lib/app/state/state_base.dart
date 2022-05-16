import 'package:equatable/equatable.dart';

import '../../models/models.dart';

// deep comparison of errors for states
class StateBase extends Equatable {
  final AppError? error;

  const StateBase({this.error});

  @override
  List<Object?> get props => [error];
}
