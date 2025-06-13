// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$doctorServiceHash() => r'86e89169e1540a59638418d77803b1ef2942d8b4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DoctorService
    extends BuildlessAutoDisposeAsyncNotifier<List<Doctor>> {
  late final String? specialty;
  late final String? searchQuery;
  late final int? page;
  late final int? limit;

  FutureOr<List<Doctor>> build({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  });
}

/// See also [DoctorService].
@ProviderFor(DoctorService)
const doctorServiceProvider = DoctorServiceFamily();

/// See also [DoctorService].
class DoctorServiceFamily extends Family<AsyncValue<List<Doctor>>> {
  /// See also [DoctorService].
  const DoctorServiceFamily();

  /// See also [DoctorService].
  DoctorServiceProvider call({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return DoctorServiceProvider(
      specialty: specialty,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    );
  }

  @override
  DoctorServiceProvider getProviderOverride(
    covariant DoctorServiceProvider provider,
  ) {
    return call(
      specialty: provider.specialty,
      searchQuery: provider.searchQuery,
      page: provider.page,
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'doctorServiceProvider';
}

/// See also [DoctorService].
class DoctorServiceProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DoctorService, List<Doctor>> {
  /// See also [DoctorService].
  DoctorServiceProvider({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  }) : this._internal(
          () => DoctorService()
            ..specialty = specialty
            ..searchQuery = searchQuery
            ..page = page
            ..limit = limit,
          from: doctorServiceProvider,
          name: r'doctorServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$doctorServiceHash,
          dependencies: DoctorServiceFamily._dependencies,
          allTransitiveDependencies:
              DoctorServiceFamily._allTransitiveDependencies,
          specialty: specialty,
          searchQuery: searchQuery,
          page: page,
          limit: limit,
        );

  DoctorServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.specialty,
    required this.searchQuery,
    required this.page,
    required this.limit,
  }) : super.internal();

  final String? specialty;
  final String? searchQuery;
  final int? page;
  final int? limit;

  @override
  FutureOr<List<Doctor>> runNotifierBuild(
    covariant DoctorService notifier,
  ) {
    return notifier.build(
      specialty: specialty,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    );
  }

  @override
  Override overrideWith(DoctorService Function() create) {
    return ProviderOverride(
      origin: this,
      override: DoctorServiceProvider._internal(
        () => create()
          ..specialty = specialty
          ..searchQuery = searchQuery
          ..page = page
          ..limit = limit,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        specialty: specialty,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DoctorService, List<Doctor>>
      createElement() {
    return _DoctorServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DoctorServiceProvider &&
        other.specialty == specialty &&
        other.searchQuery == searchQuery &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, specialty.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DoctorServiceRef on AutoDisposeAsyncNotifierProviderRef<List<Doctor>> {
  /// The parameter `specialty` of this provider.
  String? get specialty;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `page` of this provider.
  int? get page;

  /// The parameter `limit` of this provider.
  int? get limit;
}

class _DoctorServiceProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DoctorService, List<Doctor>>
    with DoctorServiceRef {
  _DoctorServiceProviderElement(super.provider);

  @override
  String? get specialty => (origin as DoctorServiceProvider).specialty;
  @override
  String? get searchQuery => (origin as DoctorServiceProvider).searchQuery;
  @override
  int? get page => (origin as DoctorServiceProvider).page;
  @override
  int? get limit => (origin as DoctorServiceProvider).limit;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
