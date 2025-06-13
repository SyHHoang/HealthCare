// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drugsHash() => r'5de9b20627e152abbf02c86760744fab0888a44c';

/// See also [drugs].
@ProviderFor(drugs)
final drugsProvider = Provider<List<Drug>>.internal(
  drugs,
  name: r'drugsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drugsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DrugsRef = ProviderRef<List<Drug>>;
String _$drugLoadedHash() => r'5203211c0f02251f6feccc2f636e4f8f6945560c';

/// See also [DrugLoaded].
@ProviderFor(DrugLoaded)
final drugLoadedProvider =
    AutoDisposeNotifierProvider<DrugLoaded, bool>.internal(
  DrugLoaded.new,
  name: r'drugLoadedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drugLoadedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrugLoaded = AutoDisposeNotifier<bool>;
String _$drugSearchHash() => r'9cd9d4ccb4e7fd00e23f3b772c1e56af8bd722c4';

/// See also [DrugSearch].
@ProviderFor(DrugSearch)
final drugSearchProvider =
    AsyncNotifierProvider<DrugSearch, List<Drug>>.internal(
  DrugSearch.new,
  name: r'drugSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$drugSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrugSearch = AsyncNotifier<List<Drug>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
