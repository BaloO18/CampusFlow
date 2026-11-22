# Séance 1 : écosystème mobile et décision pour CampusFlow

## 1. Fiche comparative Android / iOS pour une application étudiante en Afrique francophone

| # | Critère | Android | iOS | Ce que cela change pour CampusFlow (Afrique francophone) |
| --- | --- | --- | --- | --- |
| 1 | Philosophie | Système ouvert, licence libre (AOSP), nombreux fabricants. | Système fermé, un seul fabricant (Apple) qui maîtrise matériel et logiciel. | Les étudiants achètent surtout des téléphones Android d'entrée de gamme (Tecno, Itel, Infinix, Samsung série A). L'ouverture d'Android correspond au marché local. |
| 2 | Architecture | Noyau Linux, environnement d'exécution ART, services Google en option. | Noyau XNU (Darwin), frameworks Cocoa Touch. | Certains téléphones vendus localement n'ont pas tous les services Google à jour : l'application ne doit pas dépendre de services avancés pour fonctionner. |
| 3 | Langage natif | Kotlin (Java historiquement). | Swift (Objective-C historiquement). | Deux langages natifs à maîtriser pour deux plateformes : coûteux pour une petite équipe étudiante. |
| 4 | Outils de développement | Android Studio, sur Windows, macOS ou Linux. | Xcode, uniquement sur macOS. | La plupart des étudiants travaillent sur des PC Windows : développer et publier pour iOS demande un Mac, rare et cher localement. |
| 5 | Cycle de vie de l'application | Activités et processus que le système peut tuer en arrière-plan, de façon plus agressive sur les téléphones à faible mémoire. | États actif, inactif, arrière-plan, suspendu ; arrière-plan très limité. | Sur des téléphones avec 2 à 4 Go de mémoire, l'application est souvent fermée : il faut sauvegarder l'état (session, jeton) et recharger vite. |
| 6 | Permissions | Permissions demandées à l'exécution depuis Android 6, notifications depuis Android 13. | Permissions demandées à la première utilisation, avec message d'usage obligatoire. | Demander peu de permissions (notifications seulement) pour rassurer des utilisateurs méfiants envers les applications gourmandes. |
| 7 | Stockage | Stockage interne privé, Keystore pour les secrets, carte SD sur certains modèles. | Sandbox par application, Keychain pour les secrets. | Les téléphones ont peu d'espace libre : application légère, cache limité. Le jeton va dans le Keystore ou le Keychain via flutter_secure_storage. |
| 8 | Notifications | Firebase Cloud Messaging et notifications locales, canaux de notification. | APNs et notifications locales. | Les rappels d'échéance peuvent être locaux pour fonctionner sans connexion. |
| 9 | Distribution | Google Play (compte développeur payé une fois), APK installable hors magasin. | App Store uniquement (hors Union européenne), revue systématique. | Le partage d'APK par WhatsApp ou clé USB est courant : utile pour une démonstration en classe sans passer par le magasin. |
| 10 | Fragmentation | Très forte : milliers de modèles, tailles d'écran et versions d'Android. | Faible : peu de modèles, versions récentes majoritaires. | Il faut tester sur petits écrans (360 dp de large) et sur des versions d'Android anciennes, et prévoir une mise en page tablette. |
| 11 | Mises à jour du système | Dépendent du fabricant, souvent courtes sur l'entrée de gamme. | Fournies par Apple pendant de nombreuses années. | Une part importante des téléphones reste sur des versions d'Android de plusieurs années : viser une version minimale raisonnable (Android 6, API 23). |
| 12 | Sécurité | Bac à sable par application, Play Protect, risque accru avec les APK venus d'ailleurs. | Bac à sable strict, revue de l'App Store. | Ne jamais stocker un secret en clair, utiliser HTTPS en production, valider côté serveur. |
| 13 | Coût et monétisation | Compte Google Play à 25 $ une fois. Paiement par carte rarement disponible localement. | Compte Apple à 99 $ par an et un Mac. | Une application étudiante gratuite. Si un paiement arrive un jour, il passera plutôt par le Mobile Money (Orange Money, Moov Money) que par les magasins. |
| 14 | Contraintes de développement et de test | Émulateurs gratuits, tests sur de vrais téléphones peu chers. | Simulateur sur Mac, test sur iPhone avec un compte développeur. | Connexion internet chère et instable : l'application doit tolérer les erreurs réseau (message clair et bouton Réessayer) et consommer peu de données. |

## 2. Autopsie d'un système : Windows Phone

Windows Phone est lancé par Microsoft en octobre 2010 et son successeur Windows 10 Mobile n'est plus pris en charge depuis le 10 décembre 2019. Parmi les familles de causes vues en cours, voici les trois que je retiens, classées par poids.

1. **Écosystème d'applications (cause principale).** Les utilisateurs n'adoptaient pas la plateforme parce que les applications manquaient, et les développeurs ne venaient pas parce qu'il n'y avait pas d'utilisateurs. Plusieurs applications majeures sont arrivées tard ou jamais (Google n'a jamais publié d'application YouTube officielle). En octobre 2017, Joe Belfiore, responsable de Windows chez Microsoft, a expliqué que la société avait payé et même écrit des applications pour des éditeurs, sans réussir à atteindre une base d'utilisateurs suffisante pour attirer les développeurs.
2. **Ruptures de plateforme.** Windows Phone 8 (2012) change de noyau et les téléphones Windows Phone 7, dont certains venaient d'être vendus, ne peuvent pas passer à Windows Phone 8. Le passage à Windows 10 Mobile n'est proposé qu'à une partie des appareils. Chaque rupture a fait perdre la confiance des acheteurs et des développeurs.
3. **Stratégie et timing.** La plateforme arrive plus de trois ans après l'iPhone et deux ans après les premiers téléphones Android, quand les deux écosystèmes sont déjà installés. Le rachat de la division téléphones de Nokia (finalisé en 2014) est suivi dès juillet 2015 d'une dépréciation d'environ 7,6 milliards de dollars et de milliers de suppressions de postes.

Leçon pour CampusFlow : ne pas parier sur une plateforme minoritaire, et ne pas casser la compatibilité entre deux versions de l'application.

**Sources** (à vérifier et compléter avant le rendu) :

- Microsoft, « Windows 10 Mobile end of support: FAQ », support.microsoft.com (fin de prise en charge le 10 décembre 2019).
- Joe Belfiore, messages publiés sur Twitter le 8 octobre 2017 au sujet de l'arrêt des nouvelles fonctionnalités de Windows 10 Mobile.
- Microsoft, communiqué du 8 juillet 2015 annonçant la restructuration de l'activité téléphones et la dépréciation liée à Nokia (news.microsoft.com).
- The Verge, article du 20 juin 2012 sur l'absence de mise à jour vers Windows Phone 8 pour les appareils Windows Phone 7.

## 3. Décision pour CampusFlow

CampusFlow vise les étudiants de licence et de master d'Afrique francophone, en premier lieu ceux de l'Université Aube Nouvelle, qui utilisent majoritairement des téléphones Android d'entrée et de milieu de gamme avec une connexion mobile chère et irrégulière. La plateforme prioritaire est donc Android (version 6 et plus), avec une mise en page adaptée aux petits écrans comme aux tablettes. iOS reste une cible secondaire, car une partie des étudiants et des enseignants utilise un iPhone. Pour couvrir les deux sans doubler le travail, nous retenons une approche cross-platform avec Flutter : un seul code Dart, une interface Material 3 identique sur Android, iOS et le web (pratique pour les démonstrations en classe), et de bonnes performances sur des téléphones modestes. L'autopsie de Windows Phone montre qu'il vaut mieux suivre les plateformes dominantes et garder une application stable d'une version à l'autre. La fiche comparative impose aussi trois exigences au projet : une application légère, une gestion propre des erreurs réseau et un jeton de connexion rangé dans le stockage sécurisé du téléphone.
