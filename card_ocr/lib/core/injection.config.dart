// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:card_ocr/core/di/register_module.dart' as _i1042;
import 'package:card_ocr/data/data_sources/card_local_data_sources.dart'
    as _i98;
import 'package:card_ocr/data/data_sources/ocr_remote_data_sources.dart'
    as _i584;
import 'package:card_ocr/data/repositories/card_repository_impl.dart' as _i506;
import 'package:card_ocr/data/repositories/ocr_repository_impl.dart' as _i645;
import 'package:card_ocr/data/services/crypto_services.dart' as _i37;
import 'package:card_ocr/domain/domain.dart' as _i670;
import 'package:card_ocr/domain/repositories/card_repository.dart' as _i554;
import 'package:card_ocr/presentation/cubits/camera/camera_cubit.dart' as _i55;
import 'package:card_ocr/presentation/cubits/scan_cubit.dart' as _i289;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final useCaseModule = _$UseCaseModule();
    final externalModule = _$ExternalModule();
    gh.factory<_i55.CameraCubit>(() => _i55.CameraCubit());
    gh.lazySingleton<_i670.ParseCardFields>(
      () => useCaseModule.parseCardFields(),
    );
    gh.lazySingleton<_i361.Dio>(() => externalModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => externalModule.secureStorage,
    );
    gh.factory<_i584.OcrRemoteDataSource>(
      () => _i584.OcrRemoteDataSource(dio: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i670.OcrRepository>(
      () => _i645.OcrRepositoryImpl(
        remoteDataSource: gh<_i584.OcrRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i37.CryptoServices>(
      () =>
          _i37.CryptoServices(secureStorage: gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i670.ScanCard>(
      () => useCaseModule.scanCard(gh<_i670.OcrRepository>()),
    );
    gh.lazySingleton<_i98.CardLocalDataSource>(
      () => _i98.CardLocalDataSource(cryptoService: gh<_i37.CryptoServices>()),
    );
    gh.lazySingleton<_i554.CardRepository>(
      () => _i506.CardRepositoryImpl(
        cardLocalDataSource: gh<_i98.CardLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i670.SaveCard>(
      () => useCaseModule.saveCard(gh<_i670.CardRepository>()),
    );
    gh.lazySingleton<_i670.GetSaveCards>(
      () => useCaseModule.getSaveCards(gh<_i670.CardRepository>()),
    );
    gh.lazySingleton<_i670.DeleteCard>(
      () => useCaseModule.deleteCard(gh<_i670.CardRepository>()),
    );
    gh.factory<_i289.ScanCubit>(
      () => _i289.ScanCubit(
        scanCard: gh<_i670.ScanCard>(),
        parseCardFields: gh<_i670.ParseCardFields>(),
        saveCard: gh<_i670.SaveCard>(),
      ),
    );
    return this;
  }
}

class _$UseCaseModule extends _i1042.UseCaseModule {}

class _$ExternalModule extends _i1042.ExternalModule {}
