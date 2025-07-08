part of 'connectivity_cubit.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityStatusState extends ConnectivityState {
  final ConnectivityStatus status;
  final bool isRestored;

  const ConnectivityStatusState(this.status, {this.isRestored = false});

  @override
  List<Object> get props => [status, isRestored];
}