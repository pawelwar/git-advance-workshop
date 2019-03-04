# GIT TOOLS

## RERERE

Git zapamiętuje w jaki sposób został rozwiązany konflikt i automatycznie wykorzystują tą wiedze przy kolejnych podobnych konfliktach.

> The git rerere functionality is a bit of hidden feature. The name stands for "reuse recorded resolution" and, as the name implies, it allows you to ask Git to remember how you've resolved a hunk conflict so that the next time it sees the same conflict, Git can recolve it for you automatically.

#### Zadanie

  1. Dla repozytorium `five` włącz mechanizm rerere:  `git config --local rerere.enabled true`
  2. Sprawdź ostatni commit w `rerere_core_branch`. W kolejnych krokach branch ten będzie mergowany do innych branchy.

Pierwszy konflikt

  3. `rerere_feature_branch_v1`
      - Przełącz się na `rerere_feature_branch_v1`.
      - Sprawdź ostatni commit.
      - Zmerdżuj zmiany z brancha `rerere_core_branch`.
      - Pojawi się konflikt. Rozwiąż go ustawiając, że pony jest po prostu OK. W trakcie rozwiązywania konfliktu wykonaj zmianę __tylko w pierwszej lini pliku__ `README.md`.
      - Zwróc uwagę na pojawiające się komunikaty ```Recorded preimage for 'README.md'``` i ```Recorded resolution for 'README.md'```.

W kolejnych branchach

  4. `rerere_feature_branch_v2`
      - Przełącz się na `rerere_feature_branch_v2`.
      - Sprawdź ostatni commit. Plik `README.md` wygląda analogicznie do tego co było w branchu `rerere_feature_branch_v1` (krok 3).
      - Wykonaj merge `rerere_core_branch` -> `rerere_feature_branch_v2`.
      - Czy zostało użyte rozwiązanie zapamiętane przez rerere?    
      - Zwróć uwagę na pojawiający się komunikat ```Resolved 'README.md' using previous resolution.```
  5. `rerere_feature_branch_v3`
      - Przełącz się na `rerere_feature_branch_v3`.
      - Sprawdź ostatni commit. Zawiera on zmiany w dwóch __oddalonych od siebie__ liniach w pliku `README.md`.
      - Wykonaj merge `rerere_core_branch` -> `rerere_feature_branch_v3`.
      - Czy zostało użyte rozwiązanie zapamiętane przez rerere?
  6. `rerere_feature_branch_v4`
      - Przełącz się na `rerere_feature_branch_v4`.
      - Sprawdź ostatni commit. Zawiera on zmiany w dwóch __następujących po sobie__ liniach w pliku `README.md`.
      - Wykonaj merge `rerere_core_branch` -> `rerere_feature_branch_v4`.
      - Czy zostało użyte rozwiązanie zapamiętane przez rerere?

## WORKTREE (od wersji 2.5)

Umożliwia równoległą pracę na kopiach projektu bez konieczności przechowywania pełnej historii zmian kilkukrotnie. Utworzone worktree __współdzielą__ historie z głównym repozytorium.

#### Zadanie

   1. Sprawdź aktualnie istniejące worktree `git worktree list`
   2. Dodaj nowe worktree `git worktree add /tmp/workshop_copy`
   3. Sprawdź czy nowe worktree zostało poprawnie dodane: `git worktree list`

Pytania:

   4. Co znajduję się w katalogu `.git` utworzonego worktree?
   5. Co się stanie jak worktree będzie przełączone na ten sam branch co główne repozytorium? Z czego to wynika?

#### Rozwiązanie

W utworzonym worktree nie ma katalogu `.git` jest za to plik `.git`, który wskazuje na główne repozytorium.
Ograniczenie: główny katalog i worktree nie mogą być ustawione na ten sam branch. Worktree ma osobny index, HEAD, reflog ale wspólne obiekty, branche. Jeżeli worktree i główne repo ustawione było by na ten sam branch to jakakolwiek zmiana powodowała by skutki uboczne na drugim repozytorium.

## BUNDLE

Pozwala na eksport paczki commitów (i powiązanych danych) do pojedyńczego pliku. Pliki te mogą zostać np. wysłane e-maile i zaczytane w innym repozytorium.

#### Zadanie

Należy dobrać się w pary. Pierwsza osoba będzie odpowiedzialna za eksport danych, druga za import. Dane w postaci `bundle` należy przesłać za pomocą e-mail, slack, ftp...

__Pierwsza osoba__ (eksport danych)

   1. Utwórz dwa nowe commity
   2. Wykonaj eksport tylko ostatniego commita za pomocą: `git bundle create /tmp/only_last_commit HEAD~1..HEAD`
   3. Wykonaj eksport dwóch ostatnich commitów za pomocą `git bundle create /tmp/two_commits HEAD~2..HEAD`

__Druga osoba__ (import danych)

   1. Pobierz paczke z ostatnim commitem `git fetch /tmp/only_last_commit` lub `git pull /tmp/only_last_commit`. Co się stało?
   2. Pobierz paczkę z dwoma ostatnimi commitami `git fetch /tmp/two_commits` lub `git pull /tmp/two_commits`.

Skorzystanie z `git fetch ...` wymaga ręcznego przesunięcia referencji `master` na ostatni pobrany commit.   

## BISECT

Ułatwia znalezienie błędu wśród historii commitów.

#### Zadanie 1

W ramach testów regresyjnych okazało się, że w master znajduję się błąd. Mógł on zostać dodany dawno temu. Ostatni dobry commit był 100 zmian temu (HEAD~100). Chcemy znaleźć pierwszy commit, który zawiera ten błąd.

  1. Uruchom narzędzie bisect: `git bisect start`
  2. Wskaż commit, który zawiera błąd: `git bisect bad HEAD`
  3. Wskaż commit, który na pewno jest dobry: `git bisect good HEAD~100`

Jeżeli w którymkolwiek momencie pomylisz się, skorzystaj z komendy `git bisect reset`

  4. Za pomocą [scripts/validate-five.sh](scripts/validate-five.sh) sprawdź czy aktualny stan projektu zawiera błąd. Warto pamiętać o ustawieniu `chmod +x validate-five.sh`.
     - Jeżeli commit jest OK wykonaj: `git bisect good`
     - Jeżeli commit zawiera błąd wykonaj: `git bisect bad`
  5. Po kilku iterakcjach zostanie wskazany pierwszy commit który zawiera błąd.

#### Zadanie 2

Zamiast ręcznie iterować się po commitach po kroku `3.` wykonaj `git bisect run /path-to-script/validate-five.sh`

#### Rozwiązanie

Powinien zostać znaleziony commit `3b10ea7027d684a65c4658f1caea2f9a33d9e6f6`
