import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feedz/domain/entities/connectivitystatusentity/conectivity_status_entity.dart';
import 'package:feedz/domain/repositories/connectivityrepository/connectivity_repository.dart';
import 'package:feedz/utils/networkinfo/network_info.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final NetworkInfo networkInfo;

  ConnectivityRepositoryImpl({required this.networkInfo});

  @override
  Future<ConnectivityStatus> get connectivityStatus async {
    final isConnected = await networkInfo.isConnected;
    return isConnected
        ? ConnectivityStatus.connected
        : ConnectivityStatus.disconnected;
  }

  @override
  Stream<ConnectivityStatus> get onConnectivityChanged {
    return networkInfo.onConnectivityChanged.map((result) {
      return result.contains(ConnectivityResult.none)
          ? ConnectivityStatus.disconnected
          : ConnectivityStatus.connected;
    });
  }
}
