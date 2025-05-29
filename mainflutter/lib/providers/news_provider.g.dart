// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsServiceHash() => r'024ebd5d02b0aa999504177bc44d564cb2e425dc';

/// See also [newsService].
@ProviderFor(newsService)
final newsServiceProvider = Provider<NewsService>.internal(
  newsService,
  name: r'newsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$newsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsServiceRef = ProviderRef<NewsService>;
String _$newsHash() => r'76c5c81aeab147c3fa8251d881b30c39f69b617c';

/// See also [news].
@ProviderFor(news)
final newsProvider = Provider<List<News>>.internal(
  news,
  name: r'newsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$newsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsRef = ProviderRef<List<News>>;
String _$newsLoadedHash() => r'cdbbcdbb0486c7df18b7db920119345383a6203d';

/// See also [NewsLoaded].
@ProviderFor(NewsLoaded)
final newsLoadedProvider =
    AutoDisposeNotifierProvider<NewsLoaded, bool>.internal(
      NewsLoaded.new,
      name: r'newsLoadedProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$newsLoadedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsLoaded = AutoDisposeNotifier<bool>;
String _$newsNotifierHash() => r'b9fccca4e08baa8f88adfcb25a604821575956bd';

/// See also [NewsNotifier].
@ProviderFor(NewsNotifier)
final newsNotifierProvider =
    AsyncNotifierProvider<NewsNotifier, List<News>>.internal(
      NewsNotifier.new,
      name: r'newsNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$newsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NewsNotifier = AsyncNotifier<List<News>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
