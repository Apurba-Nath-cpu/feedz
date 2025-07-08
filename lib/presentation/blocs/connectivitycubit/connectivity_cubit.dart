import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:feedz/domain/entities/connectivitystatusentity/conectivity_status_entity.dart';
import 'package:feedz/domain/repositories/connectivityrepository/connectivity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityRepository _connectivityRepository;
  StreamSubscription? _connectivitySubscription;
  ConnectivityStatus? _lastStatus;

  ConnectivityCubit({required ConnectivityRepository connectivityRepository})
      : _connectivityRepository = connectivityRepository,
        super(ConnectivityInitial());

  void monitorConnectivity() {
    _connectivityRepository.connectivityStatus.then(_updateStatus);

    _connectivitySubscription =
        _connectivityRepository.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityStatus status) {
    if (state is ConnectivityInitial || status != _lastStatus) {
      if (status == ConnectivityStatus.connected &&
          _lastStatus == ConnectivityStatus.disconnected) {
        emit(const ConnectivityStatusState(ConnectivityStatus.connected,
            isRestored: true));
        Future.delayed(const Duration(seconds: 3), () {
          if (state is ConnectivityStatusState &&
              (state as ConnectivityStatusState).isRestored) {
            emit(const ConnectivityStatusState(ConnectivityStatus.connected));
          }
        });
      } else {
        emit(ConnectivityStatusState(status));
      }
      _lastStatus = status;
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}