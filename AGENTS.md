# Reguli custom pentru agenți AI

- Răspunde clar, în limba română.
- Livrează toate fișierele `.sql` în UTF-8, cu terminatori Windows CRLF, fără LF izolat sau CR izolat. Înainte de livrare, verifică automat fișierele SQL aferente lucrării și normalizează-le la CRLF.
- Pentru SQL Server local Hidroconstructia, preferă conexiunea .NET SqlClient în loc de `sqlcmd`. Nu salva parole sau șiruri de conexiune cu credențiale în repository.
- După finalizarea și verificarea lucrării, salvează fișierele local, creează un commit și fă push în repository-ul GitHub al proiectului, fără confirmare suplimentară.
- Include în commit doar modificările aferente lucrării. Nu include parole, credențiale sau backupuri de baze de date. Păstrează modificările existente ale utilizatorului.
- Nu suprascrie modificările remote și nu folosi force push. Dacă push-ul este respins, păstrează lucrul local și explică problema.
- Confirmă sincronizarea doar după reușita push-ului.

## Verificarea fișierelor SQL

Pentru fișierele SQL create sau modificate în lucrarea curentă, rulează din rădăcina repository-ului:

```powershell
./tools/Test-SqlText.ps1 -Path @('cale/script.sql') -Fix
./tools/Test-SqlText.ps1 -Path @('cale/script.sql')
```

Folosește căile reale ale fișierelor livrate. Dacă lucrarea nu include SQL, această verificare nu este necesară. Scriptul refuză codificările nevalide sau ambigue; nu ghici encoding-ul fișierelor vechi. Nu executa scripturile SQL pe baza de date pentru a verifica encoding-ul.

Setările `.editorconfig` ajută editorul să salveze SQL în UTF-8/CRLF. Regula `*.sql -text` din `.gitattributes` păstrează octeții SQL în Git; verificarea de mai sus rămâne obligatorie înainte de livrare.
