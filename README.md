# Readme for Flutter Ski Equipment Rental App

Denne Flutter-appen fungerer som et brukergrensesnitt for en Go-basert server som administrerer utleie, innlevering, og håndtering av skiutstyr. Appen er tilgjengelig på Android og tilbyr funksjonalitet for å registrere nytt utstyr, sette utstyr som inaktivt, samt leie ut og levere inn utstyr ved hjelp av QR-koder.

## Funksjonaliteter

Appen har følgende hovedfunksjoner:

- **Registrere nytt utstyr**: Brukere kan legge inn nytt utstyr i systemet.
- **Sette utstyr som inaktivt**: Markerer utstyr som ikke lenger er tilgjengelig for utleie.
- **Leie ut utstyr**: Initier utleieprosesser ved å skanne QR-koder.
- **Levere inn utstyr**: Fullfør utleie ved å skanne utstyrets QR-kode.
- **Top View**: Gir en komplett liste og status for alt registrert utstyr.

## Installasjon

Sørg for at du har Flutter installert på din maskin. For detaljerte instruksjoner om å sette opp Flutter, besøk [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

1. Klone dette prosjektet til din lokale maskin:
   ```bash
   git clone https://github.com/dittGithubRepo/dittFlutterProsjektNavn.git
   cd dittFlutterProsjektNavn
   ```

2. Kjør følgende kommando i terminalen for å hente alle avhengigheter:
   ```bash
   flutter pub get
   ```

3. Start en Android-emulator eller koble til en Android-enhet til maskinen din.

4. Kjør appen med følgende kommando:
   ```bash
   flutter run
   ```

## Bruk av Appen

Etter oppstart, naviger gjennom appen ved å bruke navigasjonsmenyen nederst. Hvert skjermbilde har formularer og funksjonalitet for håndtering av de forskjellige oppgavene relatert til utstyret.

- **Registrering av nytt utstyr**: Tilgjengelig under 'Create Form'.
- **Innlevering og utleie**: Scan QR-koden til utstyret fra 'QR Scan' for å starte prosessen.

## Struktur

Appens kodebase er organisert som følger:

- `/models`: Definerer datastrukturene.
- `/services`: Inneholder logikken for kommunikasjon med backend-Go-serveren.
- `/views` og `/widgets`: UI-komponenter og skjermbilder.

## Lokalisering

Appen støtter per nå kun engelsk, og lokaliseringsfiler kan finnes under `lib/src/localization`.

## Sikkerhet

Sørg for å gjennomgå og håndtere tilgangskontroll og datakryptering for å beskytte sensitiv brukerinformasjon og transaksjonsdata.

## Feilsøking

Se appens loggfiler og konsolen for feilsøking under utvikling. For spesifikke feil ved bruk av spesifikke API-endepunkter, se referansedokumentasjonen eller API-manualen for Go-serveren.

## Kontakt / Support

For bistand, legg igjen en issue i GitHub-repositoriet eller kontakt systemadministratoren direkte.