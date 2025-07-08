import 'package:feedz/domain/entities/connectivitystatusentity/conectivity_status_entity.dart';

abstract class ConnectivityRepository {
  Future<ConnectivityStatus> get connectivityStatus;
  Stream<ConnectivityStatus> get onConnectivityChanged;
}
