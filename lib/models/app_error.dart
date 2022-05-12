import 'package:equatable/equatable.dart';

// allows easy comparison between objects
class AppError extends Equatable {
  AppError({
    required this.message,
  }) {
    timestamp = DateTime.now().microsecondsSinceEpoch; // timestamp messages for unflawed comparison
  }

  final String message;
  late final int timestamp;

  @override
  List<Object?> get props => [message];
}
