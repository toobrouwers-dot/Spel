# FRACTURE — Core Game Design Document

**Versie:** 0.1 — Concept  
**Datum:** 2026-04-18  
**Status:** Draft

---

## 1. Overview

FRACTURE is een mobile-first roguelite deckbuilder waarin kaarten **emoties** representeren die als ruimtelijke objecten op een 5×9 portret-grid worden geplaatst. In plaats van directe aanvallen zenden emoties **aura's** uit die vijanden, het terrein en andere emoties beïnvloeden. De speler wint door emotionele combinaties (Resonantie) te ketenen, niet door simpelweg de meeste schade te doen. Elke run muteert het deck op basis van welke emoties de speler het meest heeft gespeeld.

---

## 2. Player Fantasy

De speler voelt zich een tacticus die een slagveld van gevoel beheerst. Niet "ik sla hard" maar "ik zet de wereld in brand en stap er kalm doorheen." Elk gevecht is een emotioneel landschap dat de speler vormgeeft — soms met precisie, soms door chaos (Paniek) te omarmen. De belofte: controle opgeven kan krachtiger zijn dan controle bewaren.

---

## 3. Detailed Rules

### 3.1 Het Grid

- **Afmetingen:** 5 kolommen × 9 rijen (portret-oriëntatie)
- **Speler:** Staat altijd in rij 1–2 (onderste zone). Kan 1 stap per beurt bewegen (gratis actie).
- **Vijanden:** Spawnen in rij 5–9. Bewegen richting speler elke beurt op basis van emotie-aantrekking/-afstoting.
- **Cellen:** Elke cel kan één entiteit (speler/vijand) EN één Emotie-object bevatten.

### 3.2 Hand en Kaarten

- Starthand: 4 kaarten per gevecht.
- Per beurt: speel **exact 1 kaart** (geen keuze over aantal — dit is het kernverschil met energie-systemen).
- Na het spelen: trek 1 nieuwe kaart.
- Handlimiet: 6. Bij overflow wordt de oudste kaart **Gefragmenteerd** (onmiddellijk effect, halve kracht, verdwijnt dan).
- Kaarten gaan na gebruik **niet** naar een aflegstapel — ze worden Emotie-objecten op het grid.

### 3.3 Emotie-objecten

Na plaatsing staat een Emotie-object op het grid en doorloopt vier fases:

| Fase | Beurt | Effect |
|------|-------|--------|
| Actief | 0–1 | Volle aura-radius |
| Vervaagd | 2–3 | Halve aura-radius (afgerond omlaag) |
| Collapse | 4 | Eenmalige burst, dan verwijderd |
| Weg | 5+ | Cel is leeg |

Echo-tokens (verkregen via Hoop-kaart) verdubbelen het Collapse-effect.

### 3.4 Aura's

Elke actieve emotie zendt een aura uit naar aangrenzende cellen (straal 1–3 afhankelijk van kaart). Aura's:
- Beschadigen of vertragen vijanden die in de zone staan.
- Interageren met andere aura's (zie §5 Interacties).
- Worden elk beurt herberekend na alle bewegingen.

### 3.5 Resonantie

Als 3 identieke Emotie-objecten **aaneengesloten** op het grid staan (horizontaal, verticaal of diagonaal):
- Alle drie worden onmiddellijk verwijderd.
- Een **Resonantie-uitbarsting** triggert: gecombineerd, versterkt effect.
- Als een Verwondering-object binnen radius 2 van het middelpunt staat: effect ×2 en speler teleporteert naar het middelpunt (beschermd door 1-beurt schild).

### 3.6 Vijandgedrag

Vijanden hebben geen vaste aanvals-intent. Ze reageren op het emotionele landschap:
- Elke vijand heeft een **Emotie-respons-tabel** (aangetrokken of afgestoten per emotie-type).
- Elke beurt beweegt de vijand naar de naburige cel met de hoogste attractie-waarde.
- Aanval: als de vijand naast de speler staat, handelt hij afhankelijk van zijn type.

### 3.7 Deckprogressie (Run-mutatie)

Het deck muteert passief op basis van speelgedrag:
- Na elk gevecht telt het systeem welke emotie-typen het meest gespeeld zijn.
- De top-emotie **evolueert** één niveau (niveau 1 → 2 → 3): hogere aura-radius, sterkere effecten, nieuwe Collapse-uitbarsingen.
- De minst gespeelde emotie **degradeert** (minder effect, langzamere activatie).
- Dit vervangt het traditionele "kies een kaart na gevecht"-systeem.

---

## 4. Formulas

### Aura-schade per beurt
```
aura_damage = base_damage × (1 + 0.5 × mutation_level) × echo_multiplier
echo_multiplier = 1 + (echo_tokens × 1.0)
```

### Emotie-attractie (vijandbeweging)
```
attraction_score(cell) = Σ (aura_strength(emotion) × enemy_response_weight(emotion_type))
enemy_response_weight ∈ {-2, -1, 0, 1, 2}  (negatief = afstoting)
```

### Resonantie-uitbarstingskracht
```
resonance_power = Σ collapse_power(emotion_i) × resonance_multiplier
resonance_multiplier = 2.0 indien Verwondering in radius 2, anders 1.0
```

### Deck-mutatie drempel
```
evolve_threshold = 4   # keer gespeeld in één run-segment (3 gevechten)
degrade_threshold = 1  # minder dan dit = degradatie
```

---

## 5. Edge Cases

- **Speler staat op een Collapse-cel:** Speler neemt halve Collapse-schade (eigen emoties zijn minder destructief voor de drager).
- **Resonantie en vijand op dezelfde cel:** Vijand neemt volledige Resonantie-schade, wordt 1 beurt gestund.
- **Paniek actief + handoverflow:** De willekeurige Paniek-kaart kan ook Gefragmenteerd worden als de hand vol is — dit is intentioneel (Paniek is onvoorspelbaar).
- **Alle cellen bezet door Emotie-objecten:** Nieuwe kaart wordt automatisch Gefragmenteerd (onmiddellijk effect, geen plaatsing).
- **Vijand stapt op een Leegte-object:** Vijand wordt naar het midden getrokken en kan die beurt niet bewegen.
- **Jaloezie op een stervende vijand:** Aura wordt geabsorbeerd in hetzelfde frame als de dood — dit is geldig.

---

## 6. Dependencies

| Systeem | Beschrijving |
|---------|-------------|
| `CombatGrid` | Beheert cel-staat, aura-berekening, entiteitsposities |
| `EmotionObject` | Levenscyclus (Actief → Vervaagd → Collapse), echo-tokens |
| `EmotionLibrary` | Statische definitie van alle effecten per emotie-type en mutatieniveau |
| `TurnSystem` | Spelervolgorde, vijandbeweging, Paniek-triggers |
| `EnemyAI` | Attractie-kaart berekening, aanvalslogica |
| `DeckMutationSystem` | Run-statistieken bijhouden, evolutie/degradatie toepassen |
| `HandManager` | Kaartdraw, overflow, Fragmentatie |
| `ResonanceSystem` | Aaneengesloten-detectie, uitbarstingsberekening |

---

## 7. Tuning Knobs

| Parameter | Standaard | Bereik | Effect |
|-----------|-----------|--------|--------|
| `GRID_WIDTH` | 5 | 4–7 | Breder = meer ruimte voor setup |
| `GRID_HEIGHT` | 9 | 7–12 | Hoger = meer tijd voordat vijanden bereiken |
| `EMOTION_FADE_TURN` | 2 | 1–4 | Lager = sneller tempo, minder aura-uptime |
| `EMOTION_COLLAPSE_TURN` | 4 | 3–6 | Lager = frequentere uitbarstingen |
| `RESONANCE_COUNT` | 3 | 2–4 | Lager = makkelijker te triggeren |
| `EVOLVE_THRESHOLD` | 4 | 2–6 | Lager = snellere deck-mutatie |
| `PANIC_EXTRA_CARDS` | 1 | 1–2 | Hogere waarden = meer chaos |
| `HAND_LIMIT` | 6 | 4–8 | Lager = meer Fragmentatie-druk |
| `PLAYER_MOVE_RANGE` | 1 | 1–2 | Hoger = meer mobiliteit |

---

## 8. Acceptance Criteria

- [ ] Speler kan een kaart drag-and-droppen naar een geldige gridcel binnen 200ms feedback
- [ ] Emotie-objecten doorlopen Actief → Vervaagd → Collapse correct over 4 beurten
- [ ] Aura's worden herberekend na elke beurt (inclusief na vijandbeweging)
- [ ] Resonantie triggert correct bij 3 aaneengesloten identieke objecten
- [ ] Paniek-kaart speelt elke beurt 1 willekeurige extra kaart op willekeurige geldige cel
- [ ] Vijanden bewegen naar de cel met hoogste attractie-score (niet willekeurig)
- [ ] Deck-mutatie past na elk run-segment de evolutie/degradatie correct toe
- [ ] Jaloezie absorbeert vijandaura permanent bij vijandsdood
- [ ] Trots plaatst zichzelf op de slechtste cel als speler geen schade heeft genomen
- [ ] Alle gevechten spelen in portret-modus zonder horizontale scroll
- [ ] Één-handige bediening: tap-selecteer + tap-plaats werkt zonder drag vereist

---

## Emotie-kaart Referentie (volledig)

### WOEDE
- **Aura:** 3 schade/beurt aan vijanden in radius 1
- **Radius groei:** +1 cel per extra Woede-object op het veld
- **Mutatie niveau 2:** Evolueert naar RAZERNIJ — radius 2, maar speler beweegt 1 cel achteruit bij elke activatie
- **Mutatie niveau 3:** INFERNO — radius 3, Collapse-schade treft het hele veld

### VERDRIET
- **Aura:** Vijanden die door de cel bewegen worden 1 beurt VERTRAAGD
- **Interactie:** Naast Paniek = permanente plasjes (nooit Collapse)
- **Mutatie niveau 2:** Vertraagt ook vijandaanvallen (elke 2 beurten ipv 1)

### PANIEK
- **Plaatsing:** Altijd op de spelercel (niet verplaatsbaar)
- **Effect:** Speelt elke beurt 1 willekeurige handkaart op willekeurige cel (gratis, telt niet als beurt)
- **Verwijdering:** Verdwijnt alleen bij KALMTE-kaart of voltooide Resonantie
- **Geen Fade/Collapse:** Permanent totdat verwijderd
- **Fout design mechanic:** Verlies van controle + extra acties = hoogste vaardigheidsceiling

### VERWONDERING
- **Plaatsing:** Willekeurige lege cel (speler kiest niet)
- **Aura:** Kaarten gespeeld in radius 2 deze beurt krijgen ×1.5 effect
- **Resonantie-bonus:** Als deel van Resonantie → speler teleporteert naar middelpunt + 1-beurt schild

### LEEGTE
- **Plaatsing:** Doelcel wordt Zwart Gat voor 3 beurten
- **Effect:** Trekt alle aura-kracht (niet entiteiten) naar dit punt
- **Collapse:** Explodeert met gecumuleerde kracht van alle geabsorbeerde aura's

### HOOP
- **Plaatsing:** Altijd op spelercel
- **Effect:** Geneest 2 HP + geeft Echo-token aan alle huidige Emotie-objecten op het veld
- **Interactie:** Naast Woede → BITTERHEID spawnt spontaan (2 HP/beurt schade aan speler, hoge aura-schade)

### VERWARRING
- **Plaatsing:** Op doelvijaandcel
- **Effect:** Die vijand handelt gespiegeld (bewegingsrichtingen omgekeerd) voor 2 beurten
- **Mutatie niveau 3:** CHAOS — treft alle vijanden tegelijk, maar teleporteert speler willekeurig

### TROTS
- **Plaatsing:** Willekeurig (AI kiest slechtste cel voor speler)
- **Uitzondering:** Als speler dit gevecht al schade heeft gekregen, kiest speler zelf de cel
- **Aura:** Grote schade, radius 3
- **Design intentie:** Spelers leren bewust HP te offeren voor plaatsingscontrole

### JALOEZIE
- **Plaatsing:** Kopieert een actieve vijandaura naar een cel naast de speler
- **Permanente absorptie:** Als de vijand sterft terwijl de kopie actief is → aura wordt deck-kaart voor de rest van de run

### NOSTALGIE
- **Effect:** Speelt de vorige gespeelde kaart opnieuw op dezelfde cel (of 2 beurten geleden indien gewenst)
- **Collapse herspelen:** Als de originele kaart al Collapsed was, triggert de Collapse nogmaals

---

*Volgende stap: Engine-configuratie (.claude/docs/technical-preferences.md)*
