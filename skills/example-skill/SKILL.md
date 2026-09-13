---
name: example-skill
description: Mall och referensexempel för hur en skill i det här repot ser ut. Använd när du ska skapa en ny skill och vill ha strukturen framför dig - inte för riktiga uppgifter.
---

# Example skill

Kopiera den här mappen som utgångspunkt för en ny skill:

```bash
cp -r skills/example-skill skills/min-nya-skill
```

Byt sedan ut `name` och `description` i frontmatter ovan, och ersätt allt nedan.

## Frontmatter

| Fält | Krävs | Kommentar |
| --- | --- | --- |
| `name` | ja | kebab-case, måste matcha mappnamnet |
| `description` | ja | vad skillen gör **och när den ska användas** |
| `allowed-tools` | nej | begränsar vilka verktyg skillen får använda |

`description` är det enda Claude ser innan skillen laddas. Skriv den så att
triggerorden finns med, t.ex. "Använd när användaren nämner deploy, release
eller staging."

## Instruktioner

Skriv stegen i imperativ form och i den ordning de ska utföras:

1. Kontrollera förutsättningarna (verktyg som måste finnas, filer som måste läsas).
2. Utför arbetet, ett konkret steg per punkt.
3. Verifiera resultatet innan du rapporterar klart.

## Extra filer

- `references/` – längre underlag (API-scheman, checklistor). Länka hit från
  `SKILL.md` i stället för att klistra in allt: `Se [checklistan](references/checklist.md).`
- `scripts/` – körbara hjälpskript. Beskriv exakt hur de ska anropas.

Filerna laddas bara när Claude faktiskt öppnar dem, så de kostar inget i
kontext förrän de behövs.
