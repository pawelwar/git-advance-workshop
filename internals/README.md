# GIT INTERNALS

## OBJECTS

Najważniejsze dane projektu przechowywane są jako:
- tzw. `loose objects` w katalogu `.git/objects`
- lub `pack` w `.git/objects/pack` (optymalizacja miejsca na dysku)

#### Zadanie 1

Wybierz repozytorium, na którym dawno nie wykonywany był `git gc`. Jakiego __typu__ obiekty git przechowuje w katalogu `.git/objects`?

Przydatne komendy:

* `git cat-file -t HASH` - typ obiektu
* `git cat-file -p HASH` - zawartość obiektu
* `git show HASH` - zawartość obiektu z dodatkowym formatowaniem

Identyfikator obiektu jest to "sklejka" nazwy katalogu i nazwy pliku. Przykładowo plik: `.git/objects/0d/eefd69be6687120c25f41b899a354cb1b62391` wskazuje na hash __0deefd69be6687120c25f41b899a354cb1b62391__

#### Rozwiązanie

W katalogu `.git/objects` należy wykonać: `find . -type f | grep -v "pack" | sed 's/\.\///' | sed 's/\///' | xargs -L1 git cat-file -t | sort -u`

Cztery typy obiektów:
* __blob__ - treść pliku (uwaga nie zawiera nazwy samego pliku)
* __tree__ -  zawartość katalogu (nie zawiera nazwy samego katalogu)
* __tag__ - tag typu "annotated"
* __commit__

#### Teoria

Commity wskazują na stan projektu w danym momencie (`tree e59e6e6510f65bff13f86949bd2bc90209aa41e2`). Dla porównania commit w SVN przechowuję delte (różnice).

    tree e59e6e6510f65bff13f86949bd2bc90209aa41e2
    parent 23702b361d66c9df41520fa9ea945ee134338f4f
    author guifl <fguillemot.external@lafourchette.com> 1500642873 +0200
    committer Joe Warren <Joezo@users.noreply.github.com> 1500642873 +0100

    Add five.euro() and five.dollar

Katalog `tree` składa się z podkatalogów (inne `tree`) lub plików (`blob`). Z zawartości tego obiektu nie można wyczytać jaką nazwę ma opisywany katalog.

    100644 blob 1e3b76511d02b52d500387c8d40060a57d109c79	.gitattributes
    100644 blob 942c3986a9b7a2d5fb5c66f0d404f2665fe89fc0	.gitignore
    100644 blob 85858e8d928672acc6707370c246d998cb472d32	.travis.yml
    100644 blob 8acd79c21bb287fe73323cc046ab1157cafb194a	CONTRIBUTING.md
    100644 blob 88ecb640d1a2d7af7b1b58657bb0475db0e07d77	CONTRIBUTORS
    100644 blob d645695673349e3947e8e5ae42332d0ac3164cd7	COPYING
    100644 blob 84663c378d909706e41a6567142fb042b0419467	README.md
    040000 tree 89e6680477c4570eef410f239f7d2af59c5cf38c	android
    100644 blob 363429e863b44843b256e825e77f4c4e6ad76e8d	cycle_whitelist.txt
    040000 tree cc59c9d046f31ab6f22861e1af6a21fb1da5eb75	guava-gwt
    040000 tree a46646f209282cfdeb630b5cbae3c423548fd72e	guava-testlib
    040000 tree 5650f59eb8f1326ebfab5712442b43fe932961c5	guava-tests
    040000 tree 957df56f0eafb8913b614cb3f6b775c67d8d8f9c	guava
    100644 blob 64cbb4fbc6ef079832263190e209c27cecad8fff	javadoc-stylesheet.css
    100644 blob 61e94f891b131ede62e51ae017a3d8e6f3c67f65	pom.xml
    040000 tree 121ac413ef81b5f3d80d059f024b0d4c2dde31ae	util

Git jest zoptymalizowany pod wersjonowanie __zawartości__ plików _"the stupid content tracker"_. Obiekt `blob` przechowuje tylko i wyłącznie treść pliku. Nie zawiera informacji o jego nazwie. Dwa pliki o różnej nazwie ale tej samej zawartości korzystają z tego samego obiektu `blob`.

    (function () {

    var five = function() { return 5; };

    // Quote: Malaclypse the Younger, Principia Discordia, Page 00016
    five.law = function() { return 'The Law of Fives states simply that: All things happen in fives, or are divisible by or are multiples of five, or are somehow directly or indirectly appropriate to 5. The Law of Fives is never wrong.'; };

    five.upHigh = function() { return '⁵'; };
    five.downLow = function() { return '₅'; };
    five.roman = function() { return 'V'; };
    (...)

Obiekty są __niemutowalne__.

Dla oszczędności miejsca Git kompresuje obiekty za pomocą __gzip__. Obiekty te podlegają jeszcze jednej optymalizacji. Podczas `git gc` twrzone są z nich pliki `pack`.

#### Zadanie 2

Ile obiektów zostanie wysyłanych do remota gdy dodamy jeden plik w __pod katalogu__? Przykładowo tworzymy `some-file.txt` w katalogu `src`. Tworzymy commit i wysyłamy do remote.

#### Rozwiązanie

1. `echo "aaa" > src/some-file.txt`
2. `git add .`
3. `git commit -m "add some file"`
4. `git push`

Wynik ostatniej operacji

    Counting objects: 4, done.

Cztery obiekty: 2 x tree, 1 x blob, 1 x commit

#### Zadanie 3

Ile i jakie obiekty zostaną wysłane jeżeli zmienimy nazwę pliku w __głównym katalogu__?

#### Rozwiązanie

1. `mv LICENSE NEW_LICENSE`
2. `git add .`
3. `git commit -m "change file name"`
4. `git push`

Wynik ostatniej operacji

    Counting objects: 2, done.

Dwa obiekty: 1 x commit, 1 x tree

## REFERENCES

W katalogu `.git/refs` przechowywane są referencje. Najpopularniejsze to branch i tag. Wskazują na hash commita.

#### Zadanie refs/heads

1. `bugfix`
2. `bugfix/button-fix`
3. `feature/new-layout`
4. `feature`

Jeżeli pojawił się błąd - z czego on wynika? Sprawdź w katalogu `.git/refs/heads`.

#### Rozwiązanie

Jeżeli branche były zakładane w założonej kolejności podczas kroku 2. i 4. powinien pojawić się błąd:

    cannot create directory

Wywołując `git branch feature/new-layout` (krok 3.) został założony katalog `.git/refs/heads/feature` i w nim utworzony plik `new-layout`. Próbując potem utworzyć branch `feature` (krok 4.) git próbuje stworzyć plik o tej nazwie w katalogu `.git/refs/heads`. Ze względu na to, że istnieje już katalog o tej nazwie nie może to zrobić.

To samo dotyczy branch `bugfix` i `bugfix/button-fix`. Został utworzony plik `.git/refs/heads/bugfix` (krok 1.) co uniemożliwia potem utworzenia katalogu o tej samej nazwie (krok 2.).

#### Zadanie refs/tags

Utwórz następujące tagi
- v23 `git tag v23`
- v24 `git tag -m "This version includes..." v24`

Dlaczego tagi są jednocześnie obiektem i referencją?

W jaki sposób git przechowuje opis _"This version includes..."_ podany podczas tworzenia tag'a?

#### Rozwiązanie

https://git-scm.com/book/en/v2/Git-Basics-Tagging

> Git supports two types of tags: lightweight and annotated.
> A lightweight tag is very much like a branch that doesn’t change — it’s just a pointer to a specific commit.

__Lightweigh tag__ - jest to __bezpośrednia__ referencja na commit `git tag NAZWA HASH`. Byt bardzo podobny do brancha (ale nie modyfikowalny).

__Annotated tag__ - istnieje możliwość stworzenia tag'a zawierającego dodatkowe informacje. Nadal tworzona jest referencja ale tym razem wskazuje ona na __obiekt__ `tag`. Ten obiekt dopiero wskazuje na commita. Zawiera ona następujące dodatkowe informacje:
  - opis zmiany `git tag -m "this change introduce..." NAZWA HASH`,
  - date utworzenia,
  - autora (tzw. `tagger name`).  

## GC

Podczas Garbage Collection wykonywane są następujące operacje:

1. Czyszczenie reflog z wpisów starszych niż `gc.reflogExpire` (domyślnie 90 dni).
2. Usunięcie obiektów nieosiągalnych i starszych niż `gc.pruneExpire` (domyślnie 14 dni).
    - obiekt __osiągalny__ to taki, który jest wskazywany przez: inny obiekt, referencja (branch, tag), index, referencja w remote, reflog
    - aby samemu wylistować nieosiągalne obiekty wystarczy wywołać: `git fsck --unreachable`
    - usuwanie obiektów starszych niż `gc.pruneExpire` zabezpiecza przed równoległym pobieraniem nowych obiektów i trwającym w tym czasie `git gc`. Obiekty pobierane przez pewien czas są nieosiągalne. Trwający proces `git gc` mógłby je od razu usunąć. Cytując: _"This feature helps prevent corruption when git gc runs concurrently with another process writing to the repository"_
3. Wyliczenie nowych delt, przepakowanie plików `pack` (`.git/objects/pack/...`)
4. Spakowanie referencji do `.git/packed-refs`

Użytkownik jest zachęcany do regularnego wywoływania `git gc`. Rekomendacja ta dotyczy przede wszystkim dużych projektów, w których liczb obiektów szybko rośnie.

> Users are encouraged to run this task on a regular basis within each repository to maintain good disk space utilization and good operating performance.

Komendy takie jak: `git pull`, `git merge`, `git rebase`, `git commit` wykonywują `git gc --auto`. W trakcie jego trwania sprawdzane jest
- czy liczba  `loose objects` jest większa niż zdefiniowana `gc.auto` (domyślnie 6700),
- czy liczba plików `pack` jest większa niż `gc.autopacklimit`.
Jeżeli któryś z limitów został przekroczony następuje wykonanie normalnego GC.

Jeżeli chcemy wyłączyć automatyczny GC należy ustawić `git config gc.auto 0` i `git config gc.autopacklimit 0`. Z takiej konfiguracji korzysta przykładowo BitBucket. Zapewnia to większą przewidywalność czasów odpowiedzi serwera. Samo GC jest wywoływane ręcznie w zaplanowanych godzinach.

## PACK

Mechanizm optymalizacji zajmowanego przez repozytorium miejsca na dysku. Przechowuje różnice (delty) między obiektami. Pakowaniu podlegają wszystkie typu obiektów: commit, tree, tag, blob.

Podejrzenie zawartości paczki `git verify-pack -v PATH_TO_PACK_FILE` przykładowo`git verify-pack -v .git/objects/pack/pack-01f57bfa205611bcb811a4770ca04f6b85e58cd3.pack`

> A packed archive is an efficient way to transfer a set of objects between two repositories as well as an access efficient archival format. In a packed archive, an object is either stored as a compressed whole or as a difference from some other object. The latter is often called a delta.

> A pack index file (.idx) is generated for fast, random access to the objects in the pack.

Pobierając nowe obiekty z serwera (remote) są one wysyłane jako paczka i zapisywane w `.git/objects/pack`. W trakcie GC następuje przepakowanie danych i ułożenie delt w bardziej optymalny sposób `git repack`.

Git podczas pakowanie korzysta z algorytmu szukania tzw. wysp (_delta island_). Przechowuje blisko siebie obiekty powiązane ze sobą. Tak aby usuwanie/dodawanie nowych obiektów nie wymagało przepakowywania dużych struktur danych.

## INDEX

#### Informacja o plikach i ich zawartościach

Komenda `git ls-files -s` wyświetla uproszczone podsumowanie tego co znajduję się w indeksie.

Normalny stan indeksu:

    100644 8f2b2417591474ada1667a0338db599646e13f3f 0	README.md
    100755 90507e668727e47003f10b2ba9cbb8d54976de86 0	five.js
    100644 0209c10d29b15c8ffdd933ad4eec29bcef5b8d51 0	tests/five-test.js

Podczas konfliktu:

    100644 dc7691344c01eea8720d016f68b561fca2d7dd13 1	README.md
    100644 8f2b2417591474ada1667a0338db599646e13f3f 2	README.md
    100644 88bbc22028d8670731f1cfa96c6845fce8aa692c 3	README.md
    100755 90507e668727e47003f10b2ba9cbb8d54976de86 0	five.js
    100644 0209c10d29b15c8ffdd933ad4eec29bcef5b8d51 0	tests/five-test.js

  * `100644` wykonywalność pliku `chmod +x` (zwykły `100644`, wykonywalny `100755`)
  * `8f2b24175...` hash zawartości pliku (blob)
  * trzecia kolumna `0` stan pliku. Jeżeli jesteśmy w trakcie mergowania git przechowuje wszystkie trzy wersje pliku, gdzie `1` - wspólny przodek, `2` - nasza wersja pliku, `3` - wersja którą mergujemy, `0` - plik bez konfliktów.
  * `README.md` lub `tests/five-test.js` ścieżka do pliku

#### Wykrywanie plików, które zostały zmienione

Komenda `git ls-files --debug` wyświetla szczegółowe informacje przydatne podczas debugowania.

    index.js
      ctime: 1551775116:362297366
      mtime: 1551775116:362297366
      dev: 16777220	ino: 3752113
      uid: 953813007	gid: 0
      size: 38	flags: 0
    logo.svg
      ctime: 1551793943:991344426
      mtime: 1551793943:991344426
      dev: 16777220	ino: 3766431
      uid: 953813007	gid: 0
      size: 1501	flags: 0
    package.json
      ctime: 1551775116:362634159
      mtime: 1551775116:362634159
      dev: 16777220	ino: 3752115
      uid: 953813007	gid: 0
      size: 435	flags: 0

* `ctime` - data ostatniej zmiany (change time). Data ta jest aktualizowana przy każdej zmianie atrybutów lub zawartości pliku.
* `mtime` - data ostatniej modyfikacji (modification time). Data ta jest aktualizowana przy każdej zmianie zawartości plików.

Atrybuty te są porównywane z tym co zostanie zwrócone przez system operacyjny. W przypadku systemów Unix/Linuks `stat -x PLIK`. Jeżeli data ostatniej modyfikacji pliku jest taka sama jak w indeksie - nie ma konieczności sprawdzania jego zawartości.

Stworzony przez autorów bardzo techniczny i szczegółowy opis formatu danych w indeksie: https://github.com/git/git/blob/master/Documentation/technical/index-format.txt

## EMPTY DIRECTORY

Git nie potrafi przechowywać pustych katalogów. Propozycja takiej funkcjonalności kilkakrotnie pojawiała się w dyskusjach wśród developerów Git'a. Przykładowo: rozpoczynamy nowy projekt i chcemy zaprojektować strukturę katalogów. Aby objeść ten problem programiści do pustych katalogów dodają tymczasowo plik `.gitkeep`.

Punkt widzenia Linus Torvalds (rok 2007): http://markmail.org/message/4eqjxx73opiswfis#query:+page:1+mid:libip4vpvvxhyqbl+state:results

> Btw, don't get me wrong: I think that in order to be better at tracking
other SCM's idiotic choices, we could (and I foresee that we eventually
have to) try to track empty directories as a special case too.

> But I do want to point out that "tracking a directory" is not at all the same thing as "tracking a file", no matter how much you try to argue otherwise. The semantics are totally different, and it all boils down to the fact that when you track a file, you are always talking about the *full* content of the file, while tracking a directory is always about tracking just a *subset* of the contents of the directory.

> There is no fundamental git database reason not to allow them: it's in fact quite easy to create an empty tree object. The problems with empty directories are in the *index*, and they shouldn't be insurmountable. (...)

#### Empty tree object (ciekawostka)

Nadal istnieje możliwość stworzenia pustego obiektu `tree` (z perspektywy git'a jest to pusty katalog). Wykonanie `git hash-object -t tree /dev/null` zwraca hash pustego tree `4b825dc642cb6eb9a060e54bf8d69288fbee4904`.

Przez pewien czas dobrą praktyką w Git było stworzenie pierwszego commit'a w projekcie, który wskazuje na pustą zawartość.

1. `git init`
2. `git commit -m "first commit" --allow-empty`
3. `git show --format=raw`

Treść pierwszego `commit`, który wskazuje na puste `tree`:

    commit 1a400e376a048dc72e4c5ceaa74dff5c99278349
    tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
    author Pawel Warczynski <pawel.warczynski@allegro.pl> 1551040794 +0100
    committer Pawel Warczynski <pawel.warczynski@allegro.pl> 1551040794 +0100

    first commit

Komenda rebase wymaga wskazanie podstawy względem, której będziemy wykonywać operacje. Pusty commit na początku projektu jest idealny aby przepisywać względem niego całą historie. W  Git 1.7 (2010 rok) został wdrożony parameter `--root`, przykłądowo `git rebase --interactive --root`. Pozwala on na przepisanie historii względem początku projektu. Nie ma już konieczności posiadania pierwszego "pustego commita".

## REFSEPEC

W konfiguracji projektu `git config --list --local` przechowywana jest informacja o powiązaniu lokalnego projektu z zdalnym (remote).

Przykładowo: `fetch = +refs/heads/*:refs/remotes/origin/*`. Składnia __skąd__:__dokąd__.

Jeżeli chcemy tylko synchronizować branch `master`, wystarczy ustawić: `fetch = +refs/heads/master:refs/remotes/origin/master`

Możemy podać kilka reguł jedna pod drugą:

    fetch = +refs/heads/master:refs/remotes/origin/master
    fetch = +refs/heads/ex/*:refs/remotes/origin/ex/*

Składnia __skąd__:__dokąd__ jest wykorzystywana również w innych miejscach:

* `git fetch origin master:refs/remotes/origin/evil-master` pobranie zdalnej referencji `evil-master` lokalnie jako `master`
* `git push origin HEAD:refs/heads/new-master` wysłanie najnowszego commita do remote jako branch `new-master`

## STASH

#### Zadanie

Sprawdź w jaki sposób przechowuje dane komenda `git stash`

1. Repozytorium powinno zawierać następujące zmiany:
    * plik którego nie ma w indeksie (untracked file)
    * plik zmieniony i dodany do indeksu
    * plik zmieniony i __nie__ dodany do indeksu (tylko w working directory)
2. Wywołujemy `git stash -u`. Parametr `-u` zapisuje untracked files. Domyślnie są one ignorowane.
3. Zacznijmy zabawę. Pierwszy trop `.git/refs/stash`
    * W jaki sposób zapisywane są zmiany w stashu?
    * Dlaczego powstały aż 3 ...?
4. Dodajmy kolejne zmiany do stash'a. Gdzie zapisywane są hash'e drugiego, trzeciego stanu projektu? Trop - warto zwrócić uwagę na składnie `stash@{nta-zmiana}`. Gdzie już coś takiego widzieliśmy?

#### Rozwiązanie

Powstały 3 commity:
1. Pierwszy zawierał stan indeksu w danym momencie
2. Drugi przechowywał pliki `untracked`
3. Trzeci stan tzw. `working directory`

Komendy `git pop` `git apply` umożliwiają zdefiniowanie w jakim zakresie chcemy przywrócić zapisane wcześniej zmiany. Przykładowo: `git apply --index` przywraca stan z uwzględnieniem, że część zmian powinna być tylko zapisana w indeksie.

Operacje `pop`, `push`, `drop` sugeruje, że jest to stos. Składnia `stash@{nta-zmiana}` jest bardzo podobna do tego co widzieliśmy w reflog.

Komenda `git stash` bazuje na reflogu a dokładnie na pliku `.git/logs/refs/stash`.

## STRUCTURE

`tree .git`

```
_
│
├── COMMIT_EDITMSG   <-- Podczas tworzenia commit'a edytor otwierany jest na tym pliku.
│
├── FETCH_HEAD       <-- Wykorzystywany przez `git fetch`. Zawiera hash
│                        ostatniego (czubek grafu) zaczytanego commita.
│
├── ORIG_HEAD        <-- Operacje, które przełączają się między commitami, w tym
│                        pliku przechowują jego pierwotną wartość.
│                        Wywołując przykładowo `git rebase --abort` następuję powrót
│                        do zapisanej w tym pliku wartości.
│
├── HEAD             <-- Przechowuję a) nazwę aktualnego brancha (ref: refs/heads/branch-name)
│                        b) lub hash commita gdy jesteśmy w trybie detached head
│
├── config           <-- Konfiguracja projektu
├── description      <-- Opis repozytorium. Używany przez git-web i hooki.
├── hooks
│   ├── applypatch-msg.sample
│   │   (...)
│   └── update.sample
│
├── index            <-- Przechowuje stan projektu. Modyfikowany za pomocą np. `git add`
│                        utrwalany jako commit za pomocą `git commit`.
│
├── info
│   └── exclude      <-- Względem podanych w tym pliku reguł
│                        indeks ignoruje pliki w working directory
│                        
│
├── logs             <-- Dane wykorzystywane przez funkcjonalność reflog
│   ├── HEAD
│   └── refs
│
├── objects
│   ├── 60
│   │   └── d2f1347b4ea6214371ac1fc2e4d441c33e5c1a
│   ├── info
│   └── pack
│
├── packed-refs      <-- Spakowane referencje
│
│
└── refs            
    ├── heads        <-- Lokalne branche
    ├── remotes      <-- Informacja o branchach w podłączonych do projektu
    │                    serwerach zdalnych (remotes np. origin)
    └── tags
```
