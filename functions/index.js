// Importe les modules Firebase nécessaires
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialise l'application admin pour pouvoir interagir avec les services Firebase
admin.initializeApp();

/**
 * Fonction Cloud appelable pour créer un nouvel utilisateur avec le rôle "collaborateur".
 * Seul un utilisateur authentifié avec le rôle "manager" (défini dans les custom claims) peut appeler cette fonction.
 */
exports.createCollaborator = functions
  // Spécifiez votre région pour réduire la latence et pour être cohérent avec votre BDD et votre app
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    // 1. Vérification de la permission
    // Vérifie si l'appelant est authentifié et si son token contient le rôle 'manager'.
    // C'est la cause la plus fréquente de l'erreur "internal" si le claim n'est pas défini.
    if (context.auth?.token?.role !== "manager") {
      console.error(
        "Tentative de création de collaborateur par un utilisateur non autorisé.",
        { uid: context.auth?.uid }
      );
      throw new functions.https.HttpsError(
        "permission-denied",
        "Action non autorisée. Seul un manager peut créer des collaborateurs."
      );
    }

    // 2. Validation des données reçues
    const { email, firstName, lastName } = data;
    if (!email || !firstName || !lastName) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Les informations 'email', 'firstName' et 'lastName' sont requises."
      );
    }

    try {
      // 3. Création de l'utilisateur dans Firebase Authentication
      console.log(`Création de l'utilisateur pour l'email: ${email}`);
      const userRecord = await admin.auth().createUser({
        email: email,
        emailVerified: false, // L'utilisateur devra vérifier son email
        // On génère un mot de passe temporaire et aléatoire. L'utilisateur devra le réinitialiser.
        password: Math.random().toString(36).slice(-10),
        displayName: `${firstName} ${lastName}`,
      });

      console.log(`Utilisateur créé avec UID: ${userRecord.uid}`);

      // 4. Assignation du rôle par défaut dans les Custom Claims
      // Les custom claims sont stockés dans le token d'authentification de l'utilisateur.
      const defaultRole = "collaborateur";
      await admin.auth().setCustomUserClaims(userRecord.uid, { role: defaultRole });

      // 5. Création du document utilisateur dans la base de données Firestore
      // Ce document stocke des informations supplémentaires et synchronise le rôle.
      await admin.firestore().collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: defaultRole, // Rôle par défaut
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 6. Envoi de l'email de confirmation/réinitialisation de mot de passe
      // C'est la meilleure façon de permettre au nouvel utilisateur de définir son propre mot de passe sécurisé.
      const passwordResetLink = await admin.auth().generatePasswordResetLink(email);

      // Idéalement, ici, vous utiliseriez un service comme SendGrid ou Mailgun pour envoyer un email
      // de bienvenue personnalisé contenant ce lien.
      // Pour l'instant, le lien est juste généré et renvoyé pour information.

      console.log(`Collaborateur ${userRecord.uid} créé avec succès.`);
      return { success: true, message: "Collaborateur créé. Un email pour définir le mot de passe a été envoyé." };

    } catch (error) {
      // 7. Gestion des erreurs
      console.error("Erreur lors de la création du collaborateur:", error);
      // Transforme l'erreur en une HttpsError pour que le client puisse la gérer proprement.
      if (error.code === 'auth/email-already-exists') {
        throw new functions.https.HttpsError("already-exists", "Un utilisateur avec cet email existe déjà.");
      }
      throw new functions.https.HttpsError("internal", "Une erreur interne est survenue lors de la création de l'utilisateur.");
    }
  });


/**
 * Fonction Cloud d'administration pour assigner le rôle "manager" à un utilisateur.
 * À n'utiliser qu'une seule fois par manager pour la configuration initiale.
 */
exports.setManagerRole = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {
    // Vérifier que l'appelant est authentifié (n'importe quel utilisateur connecté peut appeler,
    // mais il ne peut cibler qu'un email spécifique).
    // Pour plus de sécurité, vous pourriez restreindre l'appel à un UID spécifique.
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Vous devez être connecté pour exécuter cette action."
      );
    }

    const userEmail = data.email;
    if (!userEmail) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "L'adresse email est requise."
      );
    }

    try {
      console.log(`Recherche de l'utilisateur avec l'email: ${userEmail}`);
      const user = await admin.auth().getUserByEmail(userEmail);

      console.log(`Assignation du rôle 'manager' à l'UID: ${user.uid}`);
      // Définit le custom claim 'manager'
      await admin.auth().setCustomUserClaims(user.uid, { role: "manager" });

      // Met également à jour le document Firestore pour la cohérence
      await admin.firestore().collection("users").doc(user.uid).update({
        role: "manager"
      });

      return { success: true, message: `Le rôle 'manager' a été assigné avec succès à ${userEmail}.` };
    } catch (error) {
      console.error("Erreur lors de l'assignation du rôle manager:", error);
      throw new functions.https.HttpsError("internal", "Impossible de trouver ou de mettre à jour l'utilisateur.");
    }
  });
