// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get onboardingTitle1 => 'Trouvez des Services de Qualité pour Votre Maison';

  @override
  String get onboardingDescription1 => 'Connectez-vous avec des professionnels de confiance pour tous vos besoins d\'entretien et de réparation domestique';

  @override
  String get onboardingTitle2 => 'Réservez en Toute Confiance';

  @override
  String get onboardingDescription2 => 'Prestataires de services vérifiés avec des évaluations et des avis de vrais clients';

  @override
  String get onboardingTitle3 => 'Suivez Votre Service';

  @override
  String get onboardingDescription3 => 'Surveillez l\'avancement de votre service en temps réel et recevez des notifications de mises à jour';

  @override
  String get loginTitle => 'Content de Vous Revoir';

  @override
  String get loginSubtitle => 'Connectez-vous à votre compte';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get homeTitle => 'Services Domestiques';

  @override
  String get homeWelcome => 'Bienvenue sur House Service !';

  @override
  String get chooseLanguage => 'Choisissez Votre Langue';

  @override
  String get languageSelection => 'Sélection de la Langue';

  @override
  String get selectLanguagePrompt => 'Veuillez sélectionner votre langue préférée';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get continueButton => 'Continuer';

  @override
  String get language => 'Langue';

  @override
  String get settings => 'Paramètres';

  @override
  String get changeLanguage => 'Changer de Langue';

  @override
  String get languageChanged => 'Langue changée avec succès';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get logout => 'Déconnexion';

  @override
  String get resetApp => 'Réinitialiser l\'App';

  @override
  String welcomeBack(String name) {
    return 'Content de vous revoir, $name !';
  }

  @override
  String get readyToManage => 'Prêt à gérer vos services aujourd\'hui ?';

  @override
  String get walletBalance => 'Solde du Portefeuille';

  @override
  String get availableBalance => 'Solde Disponible';

  @override
  String get pending => 'En Attente';

  @override
  String get totalEarned => 'Total Gagné';

  @override
  String get withdrawMoney => 'Retirer de l\'Argent';

  @override
  String get overview => 'Aperçu';

  @override
  String get activeServices => 'Services Actifs';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get completed => 'Terminé';

  @override
  String get totalJobs => 'emplois au total';

  @override
  String get bookings => 'réservations';

  @override
  String get nextBooking => 'Prochaine Réservation';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get withText => 'avec';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get earnings => 'Revenus';

  @override
  String get locationNotSpecified => 'Emplacement non spécifié';

  @override
  String get twoThisMonth => '+2 ce mois-ci';

  @override
  String get recentActivity => 'Activité Récente';

  @override
  String get noRecentActivities => 'Aucune activité récente';

  @override
  String get activitiesWillAppear => 'Vos activités apparaîtront ici';

  @override
  String get serviceCompleted => 'Service terminé';

  @override
  String get newSessionConfirmed => 'Nouvelle session confirmée';

  @override
  String get newFiveStarReview => 'Nouveau commentaire 5 étoiles';

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String hoursAgo(int hours) {
    return 'Il y a $hours heures';
  }

  @override
  String dayAgo(int days) {
    return 'Il y a $days jour';
  }

  @override
  String daysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get amountToWithdraw => 'Montant à retirer';

  @override
  String get enterAmountHint => 'Entrez le montant en FCFA';

  @override
  String get withdrawalMethod => 'Méthode de Retrait';

  @override
  String get bankTransfer => 'Virement Bancaire';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get minimumWithdrawal => 'Retrait minimum : 5 000 FCFA';

  @override
  String get withdraw => 'Retirer';

  @override
  String get validAmountError => 'Veuillez entrer un montant valide (minimum 5 000 FCFA)';

  @override
  String get insufficientBalance => 'Solde insuffisant';

  @override
  String get withdrawalSuccess => 'Demande de retrait soumise avec succès !';

  @override
  String get withdrawalFailed => 'Échec de la soumission de la demande de retrait';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get myServices => 'Mes Services';

  @override
  String get sessions => 'Sessions';

  @override
  String get availability => 'Disponibilité';

  @override
  String get availabilityValidation => 'Validation de Disponibilité';

  @override
  String get profile => 'Profil';

  @override
  String get setupProviderProfile => 'Configurer le Profil Prestataire';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get updatePersonalInfo => 'Mettre à jour vos informations personnelles';

  @override
  String get securitySettings => 'Paramètres de Sécurité';

  @override
  String get passwordAndSecurity => 'Mot de passe et sécurité du compte';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Gérer vos préférences de notification';

  @override
  String get helpAndSupport => 'Aide et Support';

  @override
  String get getHelpOrContact => 'Obtenir de l\'aide ou contacter le support';

  @override
  String get signOut => 'Se déconnecter de votre compte';

  @override
  String featureComingSoon(String feature) {
    return 'Fonctionnalité $feature bientôt disponible !';
  }

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get loggedOutSuccessfully => 'Déconnecté avec succès';

  @override
  String networkErrorDuringLogout(String error) {
    return 'Erreur réseau lors de la déconnexion : $error';
  }

  @override
  String get fullName => 'Nom Complet';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Téléphone';

  @override
  String get memberSince => 'Membre Depuis';

  @override
  String get notProvided => 'Non fourni';

  @override
  String get user => 'Utilisateur';

  @override
  String get myAddresses => 'Mes Adresses';

  @override
  String get paymentMethods => 'Moyens de Paiement';

  @override
  String get about => 'À Propos';

  @override
  String get home => 'Accueil';

  @override
  String get search => 'Rechercher';

  @override
  String get orders => 'Commandes';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créez votre compte';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get selectRole => 'Sélectionnez Votre Rôle';

  @override
  String get selectRolePrompt => 'Choisissez comment vous souhaitez utiliser notre plateforme';

  @override
  String get serviceSeeker => 'Demandeur de Service';

  @override
  String get seekerDescription => 'J\'ai besoin de services domestiques';

  @override
  String get serviceProvider => 'Prestataire de Service';

  @override
  String get providerDescription => 'Je fournis des services domestiques';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get services => 'Services';

  @override
  String get serviceProviders => 'Prestataire de Services';

  @override
  String get specialOffers => 'Offres Spéciales';

  @override
  String get searchForServices => 'Rechercher des services...';

  @override
  String get details => 'Détails';

  @override
  String get searchProviders => 'Rechercher des prestataires...';

  @override
  String get providers => 'prestataires';

  @override
  String get results => 'résultats';

  @override
  String get available => 'Disponible';

  @override
  String get failedToLoadProviders => 'Échec du chargement des prestataires';

  @override
  String get noProvidersFound => 'Aucun prestataire trouvé';

  @override
  String get tryAdjustingSearch => 'Essayez d\'ajuster vos termes de recherche';

  @override
  String get beFirstToBook => 'Soyez le premier à réserver quand des prestataires rejoindront cette catégorie !';

  @override
  String get refresh => 'Actualiser';

  @override
  String get startingFrom => 'À partir de';

  @override
  String get viewProfileAndBook => 'Voir Profil et Réserver';

  @override
  String get moreServices => 'services supplémentaires';

  @override
  String get reviews => 'avis';

  @override
  String get failedToLoadProfile => 'Échec du chargement du profil du prestataire';

  @override
  String get networkError => 'Erreur réseau';

  @override
  String get providerProfile => 'Profil du Prestataire';

  @override
  String get shareComingSoon => 'Fonctionnalité de partage bientôt disponible !';

  @override
  String get failedToLoadProfileMsg => 'Échec du chargement du profil';

  @override
  String get providerNotFound => 'Prestataire introuvable';

  @override
  String get availableNow => 'Disponible Maintenant';

  @override
  String get calling => 'Appel en cours';

  @override
  String get openingEmail => 'Ouverture de l\'e-mail vers';

  @override
  String get rating => 'Note';

  @override
  String get fcfaBase => 'FCFA de base';

  @override
  String get noAvailabilitySchedule => 'Aucun planning de disponibilité défini';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get noTimeSlotsAvailable => 'Aucun créneau horaire disponible';

  @override
  String get reviewsAndRatings => 'Avis et Notes';

  @override
  String get addReview => 'Ajouter un Avis';

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get beFirstToReview => 'Soyez le premier à laisser un avis pour ce prestataire !';

  @override
  String get loadMoreReviews => 'Charger Plus d\'Avis';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get you => 'Vous';

  @override
  String get providerResponse => 'Réponse du Prestataire';

  @override
  String get justNow => 'À l\'instant';

  @override
  String get readyToBook => 'Prêt à réserver ?';

  @override
  String get selectServiceAndAvailability => 'Sélectionnez un service et vérifiez la disponibilité pour commencer.';

  @override
  String get bookService => 'Réserver le Service';

  @override
  String get bookWith => 'Réserver avec';

  @override
  String get selectService => 'Sélectionner le Service';

  @override
  String get selectDay => 'Sélectionner le Jour';

  @override
  String get selectAvailableTimeSlot => 'Sélectionner un Créneau Horaire Disponible';

  @override
  String get chooseYourTimeRange => 'Choisissez Votre Plage Horaire';

  @override
  String get confirmBooking => 'Confirmer la Réservation';

  @override
  String get selectTimeRange => 'Sélectionner la Plage Horaire';

  @override
  String get uniformPricing => 'Tarification Uniforme : 3 000 FCFA de base (4h)';

  @override
  String get availableForBooking => 'Disponible pour réservation';

  @override
  String availableFromTo(String start, String end) {
    return 'Disponible de $start à $end';
  }

  @override
  String get startTime => 'Heure de Début *';

  @override
  String get endTime => 'Heure de Fin :';

  @override
  String get bookingSummary => 'Résumé de la Réservation';

  @override
  String get service => 'Service :';

  @override
  String get day => 'Jour :';

  @override
  String get time => 'Heure';

  @override
  String get duration => 'Durée';

  @override
  String get sessionPricing => 'Tarification de la Session :';

  @override
  String get totalCost => 'Coût Total :';

  @override
  String get providerNotAvailable => 'Le prestataire n\'est pas disponible à l\'heure sélectionnée. Veuillez choisir un autre créneau horaire.';

  @override
  String get failedToCalculatePrice => 'Échec du calcul du prix de la session. Veuillez réessayer.';

  @override
  String get sessionBookedSuccess => 'Session Réservée !';

  @override
  String get sessionId => 'ID de Session';

  @override
  String get status => 'Statut';

  @override
  String get payment => 'Paiement';

  @override
  String get bookingFailed => 'Échec de la Réservation';

  @override
  String get ok => 'OK';

  @override
  String addReviewFor(String name) {
    return 'Pour $name';
  }

  @override
  String get serviceCategory => 'Catégorie de Service';

  @override
  String get comment => 'Commentaire';

  @override
  String get shareExperience => 'Partagez votre expérience avec ce prestataire...';

  @override
  String get pleaseEnterComment => 'Veuillez saisir votre commentaire';

  @override
  String get commentTooShort => 'Le commentaire doit contenir au moins 10 caractères';

  @override
  String get submitReview => 'Soumettre l\'Avis';

  @override
  String get reviewSubmittedSuccess => 'Avis soumis avec succès !';

  @override
  String get failedToSubmitReview => 'Échec de la soumission de l\'avis';

  @override
  String get timeSlotsAvailable => 'créneaux horaires disponibles';

  @override
  String get processingBooking => 'Traitement de votre réservation...';

  @override
  String get addService => 'Ajouter un Service';

  @override
  String get manageYourServices => 'Gérez vos services';

  @override
  String get allServices => 'Tous les Services';

  @override
  String get untitledService => 'Service sans titre';

  @override
  String get loadingYourServices => 'Chargement de vos services...';

  @override
  String get failedToLoadServicesTitle => 'Échec du chargement des services';

  @override
  String get noServicesYet => 'Aucun Service pour le moment';

  @override
  String get addFirstServiceSubtitle => 'Commencez par ajouter votre premier service pour attirer des clients et développer votre activité';

  @override
  String get pullToRefresh => 'Tirer pour actualiser';

  @override
  String get addYourFirstService => 'Ajouter votre premier service';

  @override
  String get editService => 'Modifier le Service';

  @override
  String get markUnavailable => 'Marquer comme Indisponible';

  @override
  String get markAvailable => 'Marquer comme Disponible';

  @override
  String get deleteService => 'Supprimer le Service';

  @override
  String deleteServiceConfirm(Object title) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ?\n\nCette action est irréversible et supprimera toutes les réservations associées.';
  }

  @override
  String get serviceDeletedSuccess => 'Service supprimé avec succès';

  @override
  String failedToDeleteService(Object error) {
    return 'Échec de la suppression du service : $error';
  }

  @override
  String errorDeletingService(Object error) {
    return 'Erreur lors de la suppression du service : $error';
  }

  @override
  String serviceMarkedAs(Object status) {
    return 'Service marqué comme $status';
  }

  @override
  String failedToUpdateService(Object error) {
    return 'Échec de la mise à jour du service : $error';
  }

  @override
  String errorUpdatingService(Object error) {
    return 'Erreur lors de la mise à jour du service : $error';
  }

  @override
  String navigationError(Object error) {
    return 'Erreur de navigation : $error';
  }

  @override
  String errorOpeningEditScreen(Object error) {
    return 'Erreur d\'ouverture de l\'écran de modification : $error';
  }

  @override
  String noStatusServices(Object status) {
    return 'Aucun service $status';
  }

  @override
  String noStatusServicesMessage(Object status) {
    return 'Vous n\'avez aucun service $status pour le moment.';
  }

  @override
  String get all => 'Tout';

  @override
  String get map => 'Carte';

  @override
  String get findServiceProviders => 'Trouver des Prestataires';

  @override
  String get yourLocation => 'Votre Position';

  @override
  String get providersFound => 'prestataires trouvés';

  @override
  String get inProgress => 'En cours';

  @override
  String get cancelled => 'Annulé';

  @override
  String get customer => 'Client';

  @override
  String basePlusOvertime(Object base, Object overtime) {
    return 'Base : $base + Heures sup : $overtime';
  }

  @override
  String get startService => 'Démarrer le Service';

  @override
  String get markComplete => 'Marquer Terminé';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get loadingYourBookings => 'Chargement de vos réservations...';

  @override
  String get failedToLoadSessionsTitle => 'Échec du chargement des sessions';

  @override
  String get noSessionsYet => 'Aucune Session pour le moment';

  @override
  String get noSessionsYetDescription => 'Lorsque des clients réservent vos services, ils apparaîtront ici. Commencez par ajouter des services pour attirer des réservations !';

  @override
  String noStatusSessions(Object status) {
    return 'Aucune session $status';
  }

  @override
  String noStatusSessionsMessage(Object status) {
    return 'Vous n\'avez aucune réservation $status pour le moment.';
  }

  @override
  String get sessionDeclinedSuccess => 'Session refusée avec succès';

  @override
  String failedToDeclineSession(Object error) {
    return 'Échec du refus de la session : $error';
  }

  @override
  String sessionUpdatedSuccess(Object status) {
    return 'Session $status avec succès';
  }

  @override
  String failedToUpdateSession(Object error) {
    return 'Échec de la mise à jour de la session : $error';
  }

  @override
  String errorUpdatingSession(Object error) {
    return 'Erreur lors de la mise à jour de la session : $error';
  }

  @override
  String get manageYourSessions => 'Gérez vos sessions';

  @override
  String get loadingYourSchedule => 'Chargement de votre planning...';

  @override
  String get failedToLoadAvailabilityTitle => 'Échec du chargement de la disponibilité';

  @override
  String get availabilityManager => 'Gestionnaire de Disponibilité';

  @override
  String get setWeeklySchedule => 'Définissez votre planning hebdomadaire avec des outils intelligents';

  @override
  String get totalHours => 'Heures Totales';

  @override
  String get daysSet => 'Jours Configurés';

  @override
  String get weekView => 'Vue Semaine';

  @override
  String get timeGrid => 'Grille Horaire';

  @override
  String get quickSetup => 'Configuration Rapide';

  @override
  String get copyMonday => 'Copier Lundi';

  @override
  String get clearAll => 'Tout Effacer';

  @override
  String get businessHours => 'Heures de Bureau';

  @override
  String get weekendOnly => 'Week-end Seulement';

  @override
  String get defaultNineToFive => 'Par défaut 9-17';

  @override
  String get addTimeSlot => 'Ajouter un créneau';

  @override
  String timeSlotsCount(Object count) {
    return '$count créneau(x)';
  }

  @override
  String get noAvailabilitySet => 'Aucune disponibilité définie';

  @override
  String get noTimeSlotsSet => 'Aucun créneau défini';

  @override
  String get tapToAddFirstSlot => 'Appuyez sur + pour ajouter votre premier créneau';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTimeSlot => 'Supprimer le Créneau';

  @override
  String deleteTimeSlotConfirm(Object end, Object start) {
    return 'Voulez-vous supprimer le créneau $start - $end ?';
  }

  @override
  String get deleteThisSlot => 'Supprimer ce Créneau';

  @override
  String get deleteEntireDay => 'Supprimer Toute la Journée';

  @override
  String get copyScheduleTitle => 'Copier le Planning';

  @override
  String copyScheduleConfirm(Object day) {
    return 'Copier le planning du $day vers tous les autres jours ?';
  }

  @override
  String get scheduleCopiedSuccess => 'Planning copié avec succès !';

  @override
  String failedToCopySchedule(Object error) {
    return 'Échec de la copie du planning : $error';
  }

  @override
  String get clearAllAvailabilityTitle => 'Effacer Toute la Disponibilité';

  @override
  String get clearAllAvailabilityConfirm => 'Cela supprimera tous vos paramètres de disponibilité. Êtes-vous sûr ?';

  @override
  String get setDefaultAvailabilityTitle => 'Définir la Disponibilité par Défaut';

  @override
  String get setDefaultAvailabilityConfirm => 'Cela définira une disponibilité du lundi au vendredi de 9h à 17h. Toute disponibilité existante sera remplacée.';

  @override
  String get setDefault => 'Définir par Défaut';

  @override
  String get defaultAvailabilitySetSuccess => 'Disponibilité par défaut définie avec succès !';

  @override
  String failedToSetDefaultAvailability(Object error) {
    return 'Échec de la définition de la disponibilité par défaut : $error';
  }

  @override
  String errorSettingDefaultAvailability(Object error) {
    return 'Erreur lors de la définition de la disponibilité par défaut : $error';
  }

  @override
  String get pleaseSelectAtLeastOneDay => 'Veuillez sélectionner au moins un jour';

  @override
  String get sourceDayHasNoAvailability => 'Le jour source n\'a aucune disponibilité à copier';

  @override
  String get allAvailabilityClearedSuccess => 'Toutes les disponibilités ont été effacées avec succès !';

  @override
  String failedToClearAvailability(String error) {
    return 'Échec de l\'effacement de la disponibilité : $error';
  }

  @override
  String get errorNoAvailabilityData => 'Erreur : Aucune donnée de disponibilité trouvée pour ce jour';

  @override
  String get errorCannotFindAvailabilityId => 'Erreur : Impossible de trouver l\'ID de disponibilité';

  @override
  String deleteAllAvailabilityForDay(String day) {
    return 'Supprimer toute la disponibilité pour $day ?\\n\\nCela supprimera tous les créneaux horaires pour ce jour.';
  }

  @override
  String get deleteEntireDayButton => 'Supprimer le Jour';

  @override
  String get timeSlotDeletedSuccess => 'Créneau horaire supprimé avec succès';

  @override
  String failedToDeleteTimeSlot(String error) {
    return 'Échec de la suppression du créneau horaire : $error';
  }

  @override
  String errorDeletingTimeSlot(String error) {
    return 'Erreur lors de la suppression du créneau horaire : $error';
  }

  @override
  String get dayAvailabilityDeletedSuccess => 'Disponibilité du jour supprimée avec succès';

  @override
  String failedToDeleteDay(String error) {
    return 'Échec de la suppression du jour : $error';
  }

  @override
  String errorDeletingDay(String error) {
    return 'Erreur lors de la suppression du jour : $error';
  }

  @override
  String get setViaQuickSetup => 'Défini via Configuration Rapide';

  @override
  String get quickSetupCompletedSuccess => 'Configuration rapide terminée avec succès !';

  @override
  String get default95 => 'Par Défaut 9-17h';

  @override
  String deleteTimeSlotFor(String start, String end, String day) {
    return 'Supprimer le créneau horaire $start - $end pour $day ?';
  }

  @override
  String get apply => 'Appliquer';

  @override
  String get selectDays => 'Sélectionner les Jours';

  @override
  String get quickSetupCompleted => 'Configuration rapide terminée avec succès !';

  @override
  String errorDuringSetup(Object error) {
    return 'Erreur lors de la configuration : $error';
  }

  @override
  String get enableLocation => 'Activer la Localisation';

  @override
  String get locationPermissionDescription => 'Nous avons besoin d\'accéder à votre position pour afficher les prestataires de services à proximité et activer le suivi GPS lorsque vous réservez des services.';

  @override
  String get findNearbyProviders => 'Trouver des prestataires à proximité';

  @override
  String get realTimeTracking => 'Suivi de service en temps réel';

  @override
  String get accurateDirections => 'Localisations de service précises';

  @override
  String get allowLocation => 'Autoriser l\'Accès à la Localisation';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get locationServicesDisabled => 'Services de Localisation Désactivés';

  @override
  String get enableLocationServices => 'Les services de localisation sont désactivés. Veuillez les activer dans les paramètres de votre appareil pour utiliser les fonctionnalités de localisation.';

  @override
  String get locationPermanentlyDenied => 'Accès à la localisation définitivement refusé. Veuillez l\'activer dans les paramètres de l\'application.';

  @override
  String get locationDenied => 'Accès à la localisation refusé. Certaines fonctionnalités peuvent ne pas fonctionner correctement.';

  @override
  String get openSettings => 'Ouvrir les Paramètres';

  @override
  String get welcomeTitle => 'Bienvenue !';

  @override
  String get welcomeSubtitle => 'Nous sommes là pour vous aider !';

  @override
  String get welcomeDescription => 'Trouvez des prestataires de services de confiance dans votre région';

  @override
  String get homeAideServices => 'Services HOME AIDE';

  @override
  String get iAm => 'Je suis';

  @override
  String get iOfferProfessionalServices => 'J\'offre des services professionnels.';

  @override
  String get pricingInformation => 'Informations Tarifaires';

  @override
  String get deepCleaningAllRooms => 'Nettoyage en profondeur de toutes les pièces';

  @override
  String get kitchenBathroomSanitization => 'Désinfection cuisine et salle de bain';

  @override
  String get floorMoppingVacuuming => 'Lavage et aspiration des sols';

  @override
  String get dustRemovalSurfaces => 'Élimination de la poussière des surfaces';

  @override
  String get trashRemoval => 'Enlèvement des déchets';

  @override
  String get leakDetectionRepair => 'Détection et réparation de fuites';

  @override
  String get pipeInstallationReplacement => 'Installation et remplacement de tuyaux';

  @override
  String get toiletSinkRepairs => 'Réparations toilettes et éviers';

  @override
  String get drainCleaningUnclogging => 'Nettoyage et débouchage des canalisations';

  @override
  String get waterHeaterMaintenance => 'Entretien chauffe-eau';

  @override
  String get emergencyPlumbingServices => 'Services de plomberie d\'urgence';

  @override
  String get wiringInstallationRepair => 'Installation et réparation de câblage';

  @override
  String get lightFixtureInstallation => 'Installation de luminaires';

  @override
  String get socketSwitchReplacement => 'Remplacement prises et interrupteurs';

  @override
  String get circuitBreakerMaintenance => 'Maintenance disjoncteurs';

  @override
  String get electricalSafetyInspections => 'Inspections de sécurité électrique';

  @override
  String get emergencyElectricalServices => 'Services électriques d\'urgence';

  @override
  String get surfacePreparationPriming => 'Préparation des surfaces et sous-couche';

  @override
  String get interiorExteriorPainting => 'Peinture intérieure et extérieure';

  @override
  String get wallTextureRepair => 'Réparation texture des murs';

  @override
  String get paintColorConsultation => 'Consultation couleur peinture';

  @override
  String get qualityPaintMaterials => 'Peinture et matériaux de qualité';

  @override
  String get lawnMowingTrimming => 'Tonte et taille de pelouse';

  @override
  String get plantCareMaintenance => 'Soin et entretien des plantes';

  @override
  String get gardenDesignLayout => 'Conception et aménagement de jardin';

  @override
  String get pestControlPlants => 'Lutte antiparasitaire pour plantes';

  @override
  String get seasonalPlanting => 'Plantation saisonnière';

  @override
  String get gardenCleanupMaintenance => 'Nettoyage et entretien de jardin';

  @override
  String get customFurnitureCreation => 'Création de meubles sur mesure';

  @override
  String get furnitureRepairRestoration => 'Réparation et restauration de meubles';

  @override
  String get cabinetInstallation => 'Installation d\'armoires';

  @override
  String get doorWindowFrameWork => 'Travaux cadres portes et fenêtres';

  @override
  String get shelvingStorageSolutions => 'Solutions d\'étagères et de rangement';

  @override
  String get woodFinishingStaining => 'Finition et teinture du bois';

  @override
  String get mealPlanningPreparation => 'Planification et préparation de repas';

  @override
  String get groceryShoppingShopping => 'Courses pour ingrédients';

  @override
  String get cookingPresentation => 'Cuisine et présentation';

  @override
  String get kitchenCleanupAfterService => 'Nettoyage cuisine après service';

  @override
  String get specialDietaryAccommodations => 'Accommodations alimentaires spéciales';

  @override
  String get recipeConsultation => 'Consultation de recettes';

  @override
  String get personalizedLessonPlanning => 'Planification de cours personnalisée';

  @override
  String get homeworkAssignmentHelp => 'Aide aux devoirs et travaux';

  @override
  String get examPreparation => 'Préparation aux examens';

  @override
  String get progressTrackingReports => 'Suivi des progrès et rapports';

  @override
  String get studyMaterialsResources => 'Matériaux et ressources d\'étude';

  @override
  String get hairCuttingStyling => 'Coupe et coiffage';

  @override
  String get transactionHistory => 'Historique des Transactions';

  @override
  String get noTransactions => 'Aucune transaction pour le moment';

  @override
  String get transactionHistoryEmpty => 'Votre historique de transactions apparaîtra ici';

  @override
  String availableBalanceLabel(String amount) {
    return 'Solde Disponible : $amount';
  }

  @override
  String get history => 'Historique';

  @override
  String requestService(String service) {
    return 'Demander $service';
  }

  @override
  String get serviceDetails => 'Détails du Service';

  @override
  String get serviceDate => 'Date du Service *';

  @override
  String get selectDateForService => 'Sélectionnez la date du service';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get selectStartTime => 'Sélectionnez l\'heure de début';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String durationLabel(String duration) {
    return 'Durée : $duration heures';
  }

  @override
  String get minimumMaximumHours => 'Minimum 0,5 heure, maximum 12 heures';

  @override
  String get location => 'Emplacement';

  @override
  String get province => 'Province *';

  @override
  String get pleaseSelectProvince => 'Veuillez sélectionner une province';

  @override
  String get serviceLocation => 'Lieu du Service *';

  @override
  String get locationSelected => 'Emplacement sélectionné';

  @override
  String get gettingLocation => 'Obtention de l\'emplacement...';

  @override
  String get useCurrentLocation => 'Utiliser l\'emplacement actuel';

  @override
  String get selectOnMap => 'Sélectionner sur la carte';

  @override
  String get additionalInformation => 'Informations Supplémentaires';

  @override
  String get serviceDescription => 'Description du Service';

  @override
  String get brieflyDescribe => 'Décrivez brièvement ce qui doit être fait';

  @override
  String get specialInstructions => 'Instructions Spéciales';

  @override
  String get anySpecialRequirements => 'Toute exigence ou note spéciale';

  @override
  String get couponCodeOptional => 'Code Promo (Optionnel)';

  @override
  String get enterCouponCode => 'Entrez le Code Promo';

  @override
  String get enterCouponOptional => 'Entrez le code promo (optionnel)';

  @override
  String get validate => 'Valider';

  @override
  String get enterCouponDiscount => 'Entrez un code promo pour obtenir une réduction sur votre service';

  @override
  String get estimatedCost => 'Coût Estimé';

  @override
  String get originalAmount => 'Montant Original :';

  @override
  String discount(String code) {
    return 'Réduction ($code) :';
  }

  @override
  String get finalAmount => 'Montant Final :';

  @override
  String get total => 'Total :';

  @override
  String forHoursOfService(String duration) {
    return 'Pour $duration heures de service';
  }

  @override
  String basePriceInfo(int price) {
    return 'Prix de base : $price FCFA (4 heures)';
  }

  @override
  String overtimeInfo(int amount, String hours) {
    return 'Heures supplémentaires : $amount FCFA ($hours heures en plus)';
  }

  @override
  String get noOvertimeCharges => 'Pas de frais d\'heures supplémentaires';

  @override
  String couponAppliedSuccess(String code) {
    return 'Code promo \"$code\" appliqué avec succès !';
  }

  @override
  String get submitRequest => 'Soumettre la Demande';

  @override
  String get locationPermissionsDenied => 'Les autorisations de localisation sont refusées';

  @override
  String get locationPermissionsPermanentlyDenied => 'Les autorisations de localisation sont définitivement refusées, nous ne pouvons pas demander d\'autorisations.';

  @override
  String currentLocationLabel(String lat, String lng) {
    return 'Emplacement Actuel ($lat, $lng)';
  }

  @override
  String currentLocationWithAddress(String address) {
    return 'Emplacement Actuel : $address';
  }

  @override
  String get currentLocationCaptured => 'Emplacement actuel capturé avec succès';

  @override
  String failedToGetLocation(String error) {
    return 'Échec de l\'obtention de l\'emplacement actuel : $error';
  }

  @override
  String get locationSelectedSuccess => 'Emplacement sélectionné avec succès';

  @override
  String couponSaveAmount(int amount) {
    return 'Code promo appliqué ! Vous économisez $amount FCFA';
  }

  @override
  String get invalidCouponCode => 'Code promo invalide';

  @override
  String get failedToValidateCoupon => 'Échec de la validation du code promo';

  @override
  String errorValidatingCoupon(String error) {
    return 'Erreur lors de la validation du code promo : $error';
  }

  @override
  String get requestSubmittedSuccessfully => 'Demande Soumise avec Succès';

  @override
  String requestId(String id) {
    return 'ID de Demande : $id';
  }

  @override
  String estimatedCostAmount(int amount) {
    return 'Coût Estimé : $amount FCFA';
  }

  @override
  String get adminWillAssignProvider => 'Un administrateur assignera un prestataire à votre demande.';

  @override
  String get failedToSubmitRequest => 'Échec de la soumission de la demande';

  @override
  String errorSubmitting(String error) {
    return 'Erreur : $error';
  }

  @override
  String get myServiceRequests => 'Mes Demandes de Service';

  @override
  String get rejected => 'Rejeté';

  @override
  String get noServiceRequestsFound => 'Aucune demande de service trouvée';

  @override
  String get yourServiceRequestsWillAppear => 'Vos demandes de service apparaîtront ici';

  @override
  String get date => 'Date';

  @override
  String get viewDetails => 'Voir les Détails';

  @override
  String get trackProvider => 'Suivre le Prestataire';

  @override
  String createdAt(String date) {
    return 'Créé $date';
  }

  @override
  String requestDetailsTitle(String category) {
    return 'Détails de la Demande - $category';
  }

  @override
  String get hours => 'heures';

  @override
  String get cost => 'Coût';

  @override
  String get description => 'Description';

  @override
  String get provider => 'Prestataire';

  @override
  String get created => 'Créé';

  @override
  String get updated => 'Mis à Jour';

  @override
  String get close => 'Fermer';

  @override
  String get cancelRequest => 'Annuler la Demande';

  @override
  String get cancelServiceRequest => 'Annuler la Demande de Service';

  @override
  String get cancelConfirmation => 'Êtes-vous sûr de vouloir annuler cette demande de service ?';

  @override
  String get reasonForCancellation => 'Raison de l\'annulation';

  @override
  String get keepRequest => 'Conserver la Demande';

  @override
  String get cancelledByUser => 'Annulé par l\'utilisateur';

  @override
  String get serviceRequestCancelledSuccess => 'Demande de service annulée avec succès';

  @override
  String get failedToCancelRequest => 'Échec de l\'annulation de la demande';

  @override
  String errorCancellingRequest(String error) {
    return 'Erreur lors de l\'annulation de la demande : $error';
  }

  @override
  String get unableToTrack => 'Impossible de suivre : ID de session invalide';

  @override
  String get failedToLoadServiceRequests => 'Échec du chargement des demandes de service';

  @override
  String errorLoadingServiceRequests(String error) {
    return 'Erreur lors du chargement des demandes de service : $error';
  }

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String get tomorrowLabel => 'Demain';

  @override
  String get yesterdayLabel => 'Hier';

  @override
  String get todayLowercase => 'aujourd\'hui';

  @override
  String get yesterdayLowercase => 'hier';

  @override
  String daysAgoLabel(int days) {
    return 'il y a $days jours';
  }

  @override
  String get invalidDate => 'Date Invalide';

  @override
  String get dateNotSet => 'Date non définie';

  @override
  String get na => 'N/A';

  @override
  String get cleaning => 'Nettoyage';

  @override
  String get plumbing => 'Plomberie';

  @override
  String get electrical => 'Électricité';

  @override
  String get painting => 'Peinture';

  @override
  String get gardening => 'Jardinage';

  @override
  String get carpentry => 'Menuiserie';

  @override
  String get cooking => 'Cuisine';

  @override
  String get tutoring => 'Tutorat';

  @override
  String get beauty => 'Beauté';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get pullDownToRefresh => 'Tirez vers le bas pour actualiser';
}
