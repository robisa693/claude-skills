# claude-skills

Mitt personliga bibliotek av [Claude Code](https://claude.com/claude-code)-skills.

En skill är en mapp med en `SKILL.md` som beskriver hur Claude ska lösa en viss
typ av uppgift. Claude läser `description` för att avgöra när skillen är
relevant, och laddar in resten av filen först när den faktiskt behövs.

## Struktur

```
skills/
  <skill-namn>/
    SKILL.md          # krävs – frontmatter + instruktioner
    references/       # valfritt – längre underlag som laddas vid behov
    scripts/          # valfritt – hjälpskript som skillen kör
```

## Installera

Symlinka hela biblioteket till din användarkonfiguration:

```bash
./install.sh            # länkar skills/* till ~/.claude/skills/
./install.sh --copy     # kopierar i stället för att länka
```

Symlink är att föredra: redigerar du en skill i repot är den aktiv direkt.

Vill du bara ha en enskild skill:

```bash
ln -s "$PWD/skills/min-skill" ~/.claude/skills/min-skill
```

Projektlokala skills lägger du i stället i `<projekt>/.claude/skills/`.

## Lägga till en ny skill

1. `mkdir skills/min-skill && $EDITOR skills/min-skill/SKILL.md`
2. Fyll i frontmatter:

```yaml
---
name: min-skill
description: Vad skillen gör och NÄR den ska användas – detta är enda texten Claude ser innan den laddar skillen, så var konkret med triggers.
---
```

3. Skriv instruktionerna i imperativ form ("Kör X", "Kontrollera Y"), inte som
   beskrivande prosa.
4. Testa i Claude Code med `/min-skill` eller genom att beskriva uppgiften och
   se om skillen plockas upp.

Se `skills/example-skill/SKILL.md` för en mall.

## Riktlinjer

- **Ett ansvar per skill.** Går den inte att sammanfatta i en mening – dela upp den.
- **Beskrivningen är viktigast.** Den avgör om skillen hittas över huvud taget.
- **Håll `SKILL.md` kort** (gärna under ~500 rader). Lägg långa referenser i
  `references/` och länka dit.
- **Inga hemligheter i repot** – det är publikt. Tokens och nycklar hör hemma i
  miljövariabler.
