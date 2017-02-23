# GIT REMOTE

## Remote

Lokalne repozytorium może być podłączone do wielu zdalnych.

* `git remote -vv` wyświetla listę podłączonych zdalnie serwerów
* `git remote add KAMIL git://109.12.23.124/five` dodaje nowy serwer (remote) o nazwie KAMIL.

Podczas `git clone` serwer, z którego pobieramy repozytorium, zostanie automatycznie dodany jako `origin`.

#### Zadanie na rozgrzewkę

Wymień komendy, które wymagają __połączenia__ (łączą się do serwera(ów) dodanych jako remote)?

#### Rozwiązanie

Większość komend nie wymaga połączenia. Przykładowo, po wywołaniu `git status` uzyskujemy informacje czy nasz branch jest `behind` czy `ahead` wzlędem podłączonego zdalnie brancha. Informacja ta jest wyliczana na bazie przechowywanych lokalnie danych. Dane te są odświeżane po wywołaniu `git fetch`.

Najpopularniejsze komendy wymagające połączenia:

* `git push`
* `git fetch`
* `git pull` = `git fetch` + `git merge`
* `git clone`

## Push

Komenda `git push` wykonuje:
* __wysyła dane__ - są to tzw. obiekty, które reprezentują zawartość plików, katalogi i commit'y
* __aktualizuje referencje (branch)__ - dozwolone jest tylko "przesunięcie go do przodu", czyli strategia mergowania `fast forward`

Od Git 2.0 domyślna strategia synchronizacji to `simple`. Wywołując `git push` wypychany jest tylko i wyłącznie bieżący branch. Dodatkowo, wymagane jest aby nazwa lokalnego brancha była __taka sama__ jak nazwa brancha podpiętego jako upstream.

Polecam strategie `upstream`. Podobonie jak `simple` pushuje ona tylko aktualny branch. Nie wymaga jednak zgodności nazw branchy.

* `git config --global push.default upstream`

#### HASH:NAZWA

W każdej chwili można wysłać __dowolny__ commit do serwera i utworzyć tam z niego branch (z pominięciem tworzenia brancha lokalnie).

* Dowolny commit
  * Składania: `git push origin HASH:refs/heads/NAZWA_BRANCHA`
  * Przykład `git push origin a7e7456:refs/heads/feature/Y`

* Commit na który jesteśmy wpięci (łatwiejsza składnia)
  * Składania: `git push origin HEAD:NAZWA_BRANCHA`
  * Przykład: `git push origin HEAD:XX-small-correction`

#### Usuwanie brancha

Usunięcie brancha __po stronie serwera__

* `git push origin :NAZWA_BRANCHA`

Jest to nic innego jak wysłanie "pustej referencji" jako NAZWA_BRANCHA.

#### Send-mail

Ciekawostka: git powstał jako narzędzie do wersjonowania kernela. Historycznie kontrybutorzy zgłaszali poprawki e-mailowo. W git istnieje rozbudowana komenda `git send-email`, która nadal jest jedyną możliwością zgłaszania zmian w kernelu Linuxa (https://github.com/torvalds/linux/pull/389). Metoda https://git-scm.com/docs/git-send-email

## Push force

#### Zadanie 1
Co jest złego w komendzie `git push --force`?

#### Rozwiązanie

1. Zmieniamy historie
    - nie każdy to lubi (nadpisywanie historii!)
    - mało kto wie jak sobie poradzić gdy nasze commity bazowały na tym co zostało usunięte
2. Możemy przypadkowo usunąć czyjejś zmiany. Pomiędzy naszym `git fetch` a `git push --force` dowolny commit może zostać dodany do brancha. Ten problem można rozwiazać wykorzystując `git push --force-with-lease`.
    - Standardowy `git push --force` ustawia branch po stronie remote na wskazany przez nas commit
    - Komenda `git push --force-with-lease` przesówa branch z wskazanego przez nas commit'a startowego na docelowy. Jeżeli branch po stronie remote w międzyczasie został zaktualizowany wtedy wskazany przez nas punkt startowy będzie niepoprawny. Operacja zakończy się błędem `push rejected [stale info]`.

> --force-with-lease alone, without specifying the details, will protect all remote refs that are going to be updated by requiring their current value to be the same as the remote-tracking branch we have for them.

Szczegółowy artykuł na temat `--force-with-lease`: https://developer.atlassian.com/blog/2015/04/force-with-lease/.

#### Zadanie 2

1. Start `git clean -fd && git checkout master && git reset --hard 01541a9`
2. Dodaj dwa commity
3. Wyślij zmianę do serwera do brancha `master`

Trzy ostatnie commity zostały nadpisane: 2 x dodane przed chwilą, 1 x commit na którym oparłeś swoje zmiany

4. Napraw sytuacje! Twoje commity ponownie powinny być na górze brancha `master`.
5. Wyślij je do serwera wykorzystując `git push` bez `--force(-with-lease)`.

#### Rozwiązanie

Należy skorzystać z `git rebase --interactive` lub `git cherry-pick`.
