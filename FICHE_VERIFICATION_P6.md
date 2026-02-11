# Fiche de vérification – Projet P6 (critères d’autoévaluation)

Ce document vérifie le projet **p6-oc-front** (front Angular uniquement) par rapport aux indicateurs de réussite de la fiche P6.

---

## Étape 1 – Préparez votre environnement de travail

| Critère | Statut | Détail |
|--------|--------|--------|
| Les deux applications s'exécutent localement sans erreur | ⚠️ Partiel | Ce dépôt est **front Angular uniquement**. L’app Angular tourne localement (`npm start`). Pas de back-end Spring Boot dans ce repo. |
| Les commandes de build et d'exécution des README fonctionnent | ✅ | README : `npm i`, `npm start`, `npm run build`, `npm test`, `docker compose -f docker-compose.dev.yml up --build`. |
| Les ports nécessaires sont identifiés et disponibles | ✅ | Port 4200 (dev), 80 (Docker). `.env` / `APP_PORT` documentés. |
| Les versions des outils (Node, Docker) correspondent aux prérequis | ✅ | Node 24 en CI et dans le Dockerfile ; README indique Node 20.11.0 / NPM 10.2.4. |

---

## Étape 2 – Dockerfile et Docker Compose du front-end Angular

| Critère | Statut | Détail |
|--------|--------|--------|
| Le Dockerfile utilise un build multi-stage | ✅ | Stage 1 : `node:24-alpine` (build). Stage 2 : `nginx:alpine` (service). |
| L'image finale contient uniquement les fichiers nécessaires (dist/ servi par Nginx) | ✅ | Seul `COPY --from=build /app/dist/.../browser/ /app/` + config Nginx. Pas de node_modules en image finale. |
| Un fichier .dockerignore est présent | ✅ | `.dockerignore` à la racine (node_modules, .git, coverage, etc.). |
| Le docker-compose.yml lance l'application correctement | ✅ | `compose.yaml` (image) et `docker-compose.dev.yml` (build depuis le Dockerfile). |
| L'application est accessible via http://localhost après docker compose up -d | ✅ | Avec `docker-compose.dev.yml` : `docker compose -f docker-compose.dev.yml up -d` puis `http://localhost:<APP_PORT>` (défaut 80). |

---

## Étape 3 – Dockerfile et Docker Compose du back-end Spring Boot

| Critère | Statut | Détail |
|--------|--------|--------|
| (Tous les indicateurs) | ➖ N/A | Ce dépôt ne contient **pas** de back-end Spring Boot. À évaluer dans le repo backend si vous en avez un. |

---

## Étape 1 (tests) – Script d’exécution des tests unifié

| Critère | Statut | Détail |
|--------|--------|--------|
| Le script détecte automatiquement le type de projet (Angular ou Spring Boot) | ⚠️ Partiel | Le script **s’adapte** au type via l’argument : `./run-tests.sh angular` ou `./run-tests.sh springboot`. Pas de détection automatique (ex. détection par présence de `package.json` / `build.gradle`). Variable `APP_TYPE` en CI. |
| Les tests des deux applications s'exécutent correctement | ⚠️ Partiel | Angular : ✅. Spring Boot : script présent mais **placeholder** (pas de projet Gradle dans ce repo). |
| Un rapport au format JUnit XML est généré | ✅ | Karma avec `karma-junit-reporter` ; sortie en JUnit XML. |
| Le rapport est placé dans le répertoire test-results/ | ✅ | `junitReporter.outputDir: 'test-results'` dans `karma.conf.js`. Le script nettoie puis crée `test-results/` avant les tests. |
| Le script retourne un code de sortie approprié (0 = succès, autre = échec) | ✅ | `exit 0` en succès, `exit 1` en échec dans `run-tests.sh`. |
| Les artefacts de tests précédents sont nettoyés avant l'exécution | ✅ | `clean_test_artifacts()` : `rm -rf "${RESULTS_DIR}"` puis `mkdir -p "${RESULTS_DIR}"`. |

---

## Étape 2 (CI) – Template de pipeline (GitHub Actions)

| Critère | Statut | Détail |
|--------|--------|--------|
| Le fichier .github/workflows/ci.yml contient un stage test | ✅ | Job `test` avec checkout, Node, `./run-tests.sh`, upload d’artefacts. |
| Le job de test s'adapte aux deux projets (via variables ou conditions) | ✅ | `APP_TYPE` (vars/inputs), `./run-tests.sh ${{ env.APP_TYPE }}`, étapes Sonar conditionnées `if: env.APP_TYPE == 'angular'`. |
| Le rapport de test est intégré au pipeline GitHub | ✅ | `actions/upload-artifact@v4` avec `path: test-results`. |
| Les dépendances sont mises en cache pour accélérer les builds | ✅ | `actions/setup-node` avec `cache: 'npm'`. |
| Le pipeline se déclenche sur les push/MR | ✅ | `on: push: branches: ['**']` et `pull_request: branches: ['**']`. |

---

## Étape 3 – Stage build

| Critère | Statut | Détail |
|--------|--------|--------|
| Un stage build est ajouté au pipeline | ✅ | Job `build` (après `test`). |
| Le job construit l'image Docker de l'application | ✅ | `docker/build-push-action` : build sans push, sortie en `type=docker,dest=/tmp/image.tar`. |
| L'image est poussée vers la GitHub Container Registry ou la GitLab Container Registry | ⚠️ Partiel | L’image est poussée vers **Docker Hub** (secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`), pas GHCR ni GitLab CR. Acceptable si la fiche autorise “un registry”. |
| L'image est taguée avec le SHA du commit et le nom de la branche | ✅ | Tags : SHA, `latest`, **nom de branche** (`github.ref_name`), version sémantique si release. |
| Le pipeline fonctionne sur les deux applications | ➖ | Un seul type d’app dans ce repo (front). Build Docker unique. |

---

## Étape 4 – semantic-release

| Critère | Statut | Détail |
|--------|--------|--------|
| semantic-release est installé et configuré pour GitHub | ✅ | `release.config.js` + job `release` avec `cycjimmy/semantic-release-action`, plugins npm/git/github. |
| Un stage est ajouté aux pipelines pour la release | ✅ | Job `release` (dépend de `build`), déclenché sur push `master`. |
| La convention Conventional Commits est adoptée | ✅ | `release.config.js` : feat → minor, fix/perf → patch, BREAKING → major. |
| Les releases GitHub sont générées automatiquement avec changelog | ✅ | Plugin `@semantic-release/github`. |
| Les images Docker sont taguées avec la version sémantique (ex. 1.2.3) | ✅ | Job `publish` : tags avec `new_release_version` et `v${version}`. |
| Le job de release se déclenche selon la stratégie choisie | ✅ | Déclenchement automatique sur push vers `master`. |
| La version est synchronisée dans les fichiers du projet (package.json) | ✅ | `@semantic-release/npm` (npmPublish: false) + `@semantic-release/git` avec `assets: ['package.json']`. |

---

## Synthèse

- **Entièrement OK** pour : environnement (sous réserve front seul), Dockerfile/compose front, rapport JUnit dans `test-results/`, pipeline test/build/release, semantic-release et version dans `package.json`.
- **À compléter ou à noter** :
  - Détection **automatique** du type de projet (Angular/Spring Boot) dans le script si la fiche l’exige.
  - Étape 3 (backend Spring Boot) : à évaluer dans le repo backend.
  - Registry : Docker Hub utilisé au lieu de GHCR/GitLab CR ; à valider avec la fiche.
  - Tag “nom de la branche” sur l’image : ajouté dans le job `publish` (SHA + latest + branche + version).

**Correction appliquée** : le rapport JUnit est maintenant généré dans `test-results/` (au lieu de `reports/`) pour respecter le critère « Le rapport est placé dans le répertoire test-results/ ».
