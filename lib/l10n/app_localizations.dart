class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String language) {
    return AppLocalizations(language);
  }

  // Navigation
  String get home => _translate('Accueil', 'Home', 'الرئيسية');
  String get orders => _translate('Commandes', 'Orders', 'الطلبات');
  String get cart => _translate('Panier', 'Cart', 'السلة');
  String get map => _translate('Carte', 'Map', 'الخريطة');
  String get management => _translate('Gestion', 'Management', 'الإدارة');
  String get profile => _translate('Profil', 'Profile', 'الملف الشخصي');

  // Profile
  String get myProfile => _translate('Mon Profil', 'My Profile', 'ملفي الشخصي');
  String get myOrders => _translate('Mes Commandes', 'My Orders', 'طلباتي');
  String get myAddresses => _translate('Mes Adresses', 'My Addresses', 'عناويني');
  String get paymentMethods => _translate('Moyens de Paiement', 'Payment Methods', 'طرق الدفع');
  String get settings => _translate('Paramètres', 'Settings', 'الإعدادات');
  String get helpSupport => _translate('Aide & Support', 'Help & Support', 'المساعدة والدعم');
  String get logout => _translate('Se déconnecter', 'Logout', 'تسجيل الخروج');

  // Settings
  String get notifications => _translate('Notifications', 'Notifications', 'الإشعارات');
  String get pushNotifications => _translate('Notifications push', 'Push Notifications', 'الإشعارات الفورية');
  String get emailNotifications => _translate('Notifications par email', 'Email Notifications', 'إشعارات البريد الإلكتروني');
  String get appearance => _translate('Apparence', 'Appearance', 'المظهر');
  String get darkMode => _translate('Mode sombre', 'Dark Mode', 'الوضع الداكن');
  String get language => _translate('Langue', 'Language', 'اللغة');
  String get about => _translate('À propos', 'About', 'حول');
  String get version => _translate('Version de l\'application', 'App Version', 'إصدار التطبيق');
  String get termsOfService => _translate('Conditions d\'utilisation', 'Terms of Service', 'شروط الخدمة');
  String get privacyPolicy => _translate('Politique de confidentialité', 'Privacy Policy', 'سياسة الخصوصية');
  String get contactUs => _translate('Nous contacter', 'Contact Us', 'اتصل بنا');

  // Auth
  String get login => _translate('Se connecter', 'Login', 'تسجيل الدخول');
  String get register => _translate('Créer un compte', 'Register', 'إنشاء حساب');
  String get email => _translate('Email', 'Email', 'البريد الإلكتروني');
  String get password => _translate('Mot de passe', 'Password', 'كلمة المرور');
  String get confirmPassword => _translate('Confirmer le mot de passe', 'Confirm Password', 'تأكيد كلمة المرور');
  String get fullName => _translate('Nom complet', 'Full Name', 'الاسم الكامل');
  String get phone => _translate('Téléphone', 'Phone', 'الهاتف');

  // Cart & Checkout
  String get addToCart => _translate('Ajouter au panier', 'Add to Cart', 'أضف إلى السلة');
  String get checkout => _translate('Commander', 'Checkout', 'الطلب');
  String get total => _translate('Total', 'Total', 'المجموع');
  String get subtotal => _translate('Sous-total', 'Subtotal', 'المجموع الفرعي');
  String get delivery => _translate('Livraison', 'Delivery', 'التوصيل');
  String get emptyCart => _translate('Votre panier est vide', 'Your cart is empty', 'سلتك فارغة');

  // Common
  String get save => _translate('Enregistrer', 'Save', 'حفظ');
  String get cancel => _translate('Annuler', 'Cancel', 'إلغاء');
  String get close => _translate('Fermer', 'Close', 'إغلاق');
  String get search => _translate('Rechercher', 'Search', 'بحث');
  String get loading => _translate('Chargement...', 'Loading...', 'جار التحميل...');
  String get error => _translate('Erreur', 'Error', 'خطأ');
  String get success => _translate('Succès', 'Success', 'نجح');

  get loginToSeeOrders => null;

  // Helper method
  String _translate(String fr, String en, String ar) {
    switch (languageCode) {
      case 'Français':
        return fr;
      case 'English':
        return en;
      case 'العربية':
        return ar;
      default:
        return fr;
    }
  }
}
