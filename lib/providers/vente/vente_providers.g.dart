// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vente_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$venteRepositoryHash() => r'eb8ceda8b53214e2b87fb61e23b7fed50d34442f';

/// See also [venteRepository].
@ProviderFor(venteRepository)
final venteRepositoryProvider = AutoDisposeProvider<VenteRepository>.internal(
  venteRepository,
  name: r'venteRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$venteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VenteRepositoryRef = AutoDisposeProviderRef<VenteRepository>;
String _$produitRepositoryHash() => r'dac7ef4e462aacac158f81136eed33b323980d73';

/// See also [produitRepository].
@ProviderFor(produitRepository)
final produitRepositoryProvider =
    AutoDisposeProvider<ProduitRepository>.internal(
      produitRepository,
      name: r'produitRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$produitRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProduitRepositoryRef = AutoDisposeProviderRef<ProduitRepository>;
String _$totalHTHash() => r'96861aba90b0d70397df71c84541188eeaccabf2';

/// See also [totalHT].
@ProviderFor(totalHT)
final totalHTProvider = AutoDisposeProvider<double>.internal(
  totalHT,
  name: r'totalHTProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalHTHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalHTRef = AutoDisposeProviderRef<double>;
String _$totalTVAHash() => r'ab202e437fcae87350608a2c3079b96a85cb4c4a';

/// See also [totalTVA].
@ProviderFor(totalTVA)
final totalTVAProvider = AutoDisposeProvider<double>.internal(
  totalTVA,
  name: r'totalTVAProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalTVAHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalTVARef = AutoDisposeProviderRef<double>;
String _$totalTTCHash() => r'b28e47e4e24f40bb02f127559e0848735e28e16e';

/// See also [totalTTC].
@ProviderFor(totalTTC)
final totalTTCProvider = AutoDisposeProvider<double>.internal(
  totalTTC,
  name: r'totalTTCProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalTTCHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalTTCRef = AutoDisposeProviderRef<double>;
String _$nombreArticlesHash() => r'c89900aab4f8d098579ebacbd70c951efb9642b4';

/// See also [nombreArticles].
@ProviderFor(nombreArticles)
final nombreArticlesProvider = AutoDisposeProvider<int>.internal(
  nombreArticles,
  name: r'nombreArticlesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nombreArticlesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NombreArticlesRef = AutoDisposeProviderRef<int>;
String _$statsJourHash() => r'0f74763751f8e675a628181d366472142f9542ad';

/// See also [statsJour].
@ProviderFor(statsJour)
final statsJourProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      statsJour,
      name: r'statsJourProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$statsJourHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatsJourRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$ventesEnAttenteHash() => r'3526afa00e80e9eb829854b0167be985961c63ae';

/// See also [ventesEnAttente].
@ProviderFor(ventesEnAttente)
final ventesEnAttenteProvider = AutoDisposeFutureProvider<List<Vente>>.internal(
  ventesEnAttente,
  name: r'ventesEnAttenteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ventesEnAttenteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VentesEnAttenteRef = AutoDisposeFutureProviderRef<List<Vente>>;
String _$detailVenteHash() => r'23a9dddca9f246a5e4f92709511497c20a425715';

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

/// See also [detailVente].
@ProviderFor(detailVente)
const detailVenteProvider = DetailVenteFamily();

/// See also [detailVente].
class DetailVenteFamily extends Family<AsyncValue<Vente?>> {
  /// See also [detailVente].
  const DetailVenteFamily();

  /// See also [detailVente].
  DetailVenteProvider call(int venteId) {
    return DetailVenteProvider(venteId);
  }

  @override
  DetailVenteProvider getProviderOverride(
    covariant DetailVenteProvider provider,
  ) {
    return call(provider.venteId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'detailVenteProvider';
}

/// See also [detailVente].
class DetailVenteProvider extends AutoDisposeFutureProvider<Vente?> {
  /// See also [detailVente].
  DetailVenteProvider(int venteId)
    : this._internal(
        (ref) => detailVente(ref as DetailVenteRef, venteId),
        from: detailVenteProvider,
        name: r'detailVenteProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$detailVenteHash,
        dependencies: DetailVenteFamily._dependencies,
        allTransitiveDependencies: DetailVenteFamily._allTransitiveDependencies,
        venteId: venteId,
      );

  DetailVenteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.venteId,
  }) : super.internal();

  final int venteId;

  @override
  Override overrideWith(
    FutureOr<Vente?> Function(DetailVenteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetailVenteProvider._internal(
        (ref) => create(ref as DetailVenteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        venteId: venteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Vente?> createElement() {
    return _DetailVenteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailVenteProvider && other.venteId == venteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, venteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetailVenteRef on AutoDisposeFutureProviderRef<Vente?> {
  /// The parameter `venteId` of this provider.
  int get venteId;
}

class _DetailVenteProviderElement
    extends AutoDisposeFutureProviderElement<Vente?>
    with DetailVenteRef {
  _DetailVenteProviderElement(super.provider);

  @override
  int get venteId => (origin as DetailVenteProvider).venteId;
}

String _$panierHash() => r'54a42781ed3ae083df208b72f276ee1ee89e3f7f';

/// See also [Panier].
@ProviderFor(Panier)
final panierProvider =
    AutoDisposeNotifierProvider<Panier, List<LigneVente>>.internal(
      Panier.new,
      name: r'panierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product') ? null : _$panierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Panier = AutoDisposeNotifier<List<LigneVente>>;
String _$remiseGlobaleHash() => r'4b08ccb5bb3665ef23c505f5e89a8cbd8c8648f1';

/// See also [RemiseGlobale].
@ProviderFor(RemiseGlobale)
final remiseGlobaleProvider =
    AutoDisposeNotifierProvider<RemiseGlobale, double>.internal(
      RemiseGlobale.new,
      name: r'remiseGlobaleProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$remiseGlobaleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RemiseGlobale = AutoDisposeNotifier<double>;
String _$venteFinalisationHash() => r'dcf49c3b74c3cece02ed88d5a1e1adea884a5d0f';

/// See also [VenteFinalisation].
@ProviderFor(VenteFinalisation)
final venteFinalisationProvider =
    AutoDisposeAsyncNotifierProvider<VenteFinalisation, Vente?>.internal(
      VenteFinalisation.new,
      name: r'venteFinalisationProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$venteFinalisationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VenteFinalisation = AutoDisposeAsyncNotifier<Vente?>;
String _$venteAttenteHash() => r'142949b6acd05ed6fa7fc6535cd69085cab813cf';

/// See also [VenteAttente].
@ProviderFor(VenteAttente)
final venteAttenteProvider =
    AutoDisposeAsyncNotifierProvider<VenteAttente, void>.internal(
      VenteAttente.new,
      name: r'venteAttenteProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$venteAttenteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VenteAttente = AutoDisposeAsyncNotifier<void>;
String _$historiqueVentesHash() => r'3ba0ee40285a909d5b2f9f296779249237c6259a';

abstract class _$HistoriqueVentes
    extends BuildlessAutoDisposeAsyncNotifier<List<Vente>> {
  late final DateTime? dateDebut;
  late final DateTime? dateFin;
  late final String? statut;

  FutureOr<List<Vente>> build({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
  });
}

/// See also [HistoriqueVentes].
@ProviderFor(HistoriqueVentes)
const historiqueVentesProvider = HistoriqueVentesFamily();

/// See also [HistoriqueVentes].
class HistoriqueVentesFamily extends Family<AsyncValue<List<Vente>>> {
  /// See also [HistoriqueVentes].
  const HistoriqueVentesFamily();

  /// See also [HistoriqueVentes].
  HistoriqueVentesProvider call({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
  }) {
    return HistoriqueVentesProvider(
      dateDebut: dateDebut,
      dateFin: dateFin,
      statut: statut,
    );
  }

  @override
  HistoriqueVentesProvider getProviderOverride(
    covariant HistoriqueVentesProvider provider,
  ) {
    return call(
      dateDebut: provider.dateDebut,
      dateFin: provider.dateFin,
      statut: provider.statut,
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
  String? get name => r'historiqueVentesProvider';
}

/// See also [HistoriqueVentes].
class HistoriqueVentesProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<HistoriqueVentes, List<Vente>> {
  /// See also [HistoriqueVentes].
  HistoriqueVentesProvider({
    DateTime? dateDebut,
    DateTime? dateFin,
    String? statut,
  }) : this._internal(
         () =>
             HistoriqueVentes()
               ..dateDebut = dateDebut
               ..dateFin = dateFin
               ..statut = statut,
         from: historiqueVentesProvider,
         name: r'historiqueVentesProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$historiqueVentesHash,
         dependencies: HistoriqueVentesFamily._dependencies,
         allTransitiveDependencies:
             HistoriqueVentesFamily._allTransitiveDependencies,
         dateDebut: dateDebut,
         dateFin: dateFin,
         statut: statut,
       );

  HistoriqueVentesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
  }) : super.internal();

  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? statut;

  @override
  FutureOr<List<Vente>> runNotifierBuild(covariant HistoriqueVentes notifier) {
    return notifier.build(
      dateDebut: dateDebut,
      dateFin: dateFin,
      statut: statut,
    );
  }

  @override
  Override overrideWith(HistoriqueVentes Function() create) {
    return ProviderOverride(
      origin: this,
      override: HistoriqueVentesProvider._internal(
        () =>
            create()
              ..dateDebut = dateDebut
              ..dateFin = dateFin
              ..statut = statut,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dateDebut: dateDebut,
        dateFin: dateFin,
        statut: statut,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HistoriqueVentes, List<Vente>>
  createElement() {
    return _HistoriqueVentesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoriqueVentesProvider &&
        other.dateDebut == dateDebut &&
        other.dateFin == dateFin &&
        other.statut == statut;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dateDebut.hashCode);
    hash = _SystemHash.combine(hash, dateFin.hashCode);
    hash = _SystemHash.combine(hash, statut.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HistoriqueVentesRef on AutoDisposeAsyncNotifierProviderRef<List<Vente>> {
  /// The parameter `dateDebut` of this provider.
  DateTime? get dateDebut;

  /// The parameter `dateFin` of this provider.
  DateTime? get dateFin;

  /// The parameter `statut` of this provider.
  String? get statut;
}

class _HistoriqueVentesProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<HistoriqueVentes, List<Vente>>
    with HistoriqueVentesRef {
  _HistoriqueVentesProviderElement(super.provider);

  @override
  DateTime? get dateDebut => (origin as HistoriqueVentesProvider).dateDebut;
  @override
  DateTime? get dateFin => (origin as HistoriqueVentesProvider).dateFin;
  @override
  String? get statut => (origin as HistoriqueVentesProvider).statut;
}

String _$annulationVenteHash() => r'7f4c70968eb7ef2e859af942e71a411ae46190ec';

/// See also [AnnulationVente].
@ProviderFor(AnnulationVente)
final annulationVenteProvider =
    AutoDisposeAsyncNotifierProvider<AnnulationVente, void>.internal(
      AnnulationVente.new,
      name: r'annulationVenteProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$annulationVenteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnnulationVente = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
