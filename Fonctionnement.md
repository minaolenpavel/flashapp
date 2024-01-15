# FlashApp™ fonctionnement
L'application se découpe en plusieurs fonctions qui remplissent chacune le rôle d'un script à part. Le but de diviser l'application en fonctions est de permettre à l'application de pouvoir fonctionner par elle-même, il n'y a besoin de télécharger qu'un seul script et il est possible d'utiliser son propre fichier en .csv.

L'arborescence du programme fonctionne avec un dossier parent `FlashApp` dans le dossier utilisateur, un sous dossier `data`, un sous-dossier `sets` du dossier `data` dans lequel on retrouve chacun des sets de cartes créés.

Chaque set est divisé en deux sous-dossiers, `levels` qui contient toutes les cartes crées et organisées par niveau et `session` qui contient les cartes lorsqu'elles sont utilisées par la fonction `session`.

```
FlashApp
   └── data
       ├── at_stats.csv
       ├── date.txt
       ├── periodic_stats.txt
       └── sets
           ├── Japonais
           │   ├── corpus.csv
           │   ├── levels
           │   │   ├── 1
           │   │   │   ├── pair1.md
           │   │   │   ├── pair2.md
           │   │   │   ├── pair3.md
           │   │   │   ├── pair4.md
           │   │   │   └── pair5.md
           │   │   ├── 2
           │   │   ├── 3
           │   │   └── 4
           │   └── session
           │       ├── 1
           │       ├── 2
           │       ├── 3
           │       └── 4
           └── Russe
               ├── Russe.csv
               ├── levels
               │   ├── 1
               │   │   ├── pair1.md
               │   │   ├── pair2.md
               │   │   ├── pair3.md
               │   │   ├── pair4.md
               │   │   └── pair5.md
               │   ├── 2
               │   ├── 3
               │   └── 4
               └── session
                   ├── 1
                   ├── 2
                   ├── 3
                   └── 4
```
## Démarrage du programme
Lorsque le script est lancé, le programme regarde si le dossier `FlashApp` et le sous-dossier `data` sont présents dans le dossier utilisateur. 
```
if [[ -e ~/FlashApp/data ]]
then 
    main
else 
    installer
fi
```
Si ces dossiers sont présents, alors le programme se lance, sinon on vous propose d'installer FlashApp™.

## installer
La fonction `installer` comme son nom l'indique permet d'installer le programme dans le dossier utilisateur, l'utilisateur n'a pas le choix, pour des raisons de facilité à manipuler les chemins avec les autres fonctions. 
Cette fonction en plus de créer le dossier `FlashApp` et le sous-dossier `data` crée le sous-dossier `sets` qui va être utilisé pour contenir les différents sets de cartes qu'on va pouvoir utiliser. Elle crée également les fichiers de stockage de statistiques, et un fichier `date.txt` qui contient la date d'installation, utilisée lorsqu'on consulte les statistiques.

## main
Cette fonction affiche le menu, mais avant de se lancer elle regarde les dossier de session des sets installés pour savoir si l'utilisateur a quitté avant de finir sa session, si c'est le cas, la fonction va sermoner l'utilisateur et faire le ménage avec la fonction `cleaning`.
````
Bienvenue dans FlashApp™
Veuillez faire un choix :
1 - Session du jour
2 - Créer un set de carte
3 - Voir mes statistiques
4 - Quitter le programme
````

## cleaning
Cette fonction "nettoie" le dossier `session` de chaque set pour permettre au programme de fonctionner proprement et de lancer des sessions de 10 cartes.

## create_cards
Cette fonction crée les sets pour l'utilisateur, elle demande le nom du set au début, ce sera son nom dans l'arborescence et un repère pour l'utilisateur lorsqu'il voudra lancer une session. 

Un rappel du fonctionnement est effectué, puis l'utilisateur est demandé d'indiquer le nom de son fichier, la fonction procedera à une vérification de la présence du fichier dans le dossier utilisateur.
````
Quel nom voulez-vous donner à votre set de cartes ?
Japonais
Assurez vous d'avoir bien placé votre fichier .csv dans le dossier utilisateur
Rappel : Selon le programme, la première ligne de votre fichier .csv correspond aux catégories du contenu de votre fichier
````
```` 
Veuillez écrire le nom du fichier
rus
Fichier introuvable
````

## session
La fonction `session` est la plus longue, une fois qu'elle est lancée, elle demande à l'utilisateur, quelle set veut-il pratiquer. Si l'utilisateur rentre le nom d'un set qui n'existe pas, alors le programe demande à l'utilisateur de rentrer le nom d'un set qui figure parmi la liste des sets créés.
Pour créer la session, la fonctio s'appuie sur une boucle qui itère de 1 à 4 et qui régresse son amplitude de 4 à 1, c'est à dire, plus haut est le niveau, le moins de cartes le programme va sélectionner. Si le programme ne parvient pas à remplir ses quotas (4 cartes de niveau 1, 3 cartes de niveau 2, 2 cartes de niveau 3 et 1 carte de niveau 4), alors, il comble les places restantes avec des cartes choisies au hasard dans tous les niveaux, afin de permettre d'avoir questions par session.
lorsque la session débute, l'utilisateur voit les cartes au format .md, et est demandé, si il a trouvé la réponse, si oui alors la carte va au niveau supérieur, si non elle va au niveau inférieur. Dans le cas où l'utilisateur trouve une bonne réponse à une question de niveau 4, la carte ne monte pas de niveau, de même si l'utilisateur ne trouve pas la réponse à une question de niveau 1, la carte reste à ce niveau.
Lorsque les réponses sont données, la fonction compte les bonnes et les mauvaises réponses, à la fin de celle-ci, les statistiques sont envoyées à la fonction `write_statistics`

## write_statistics
Cette fonction écrit les statistiques de la session qui vient d'être effectuée, qui ont été passés en argument à celle-ci. Il y a un fichier de statistiques par session, avec la date et l'heure de la fin de la session, le total des questions ainsi que les bonnes et les mauvaises réponses. Il y a également un fichier de statistiques qui conserve les statistiques depuis l'installation du programme.

## statistics
Cette fonction affiche les statistiques par session et les statistiques depuis l'installation du programme.
```` 
Au total depuis la date d'installation au Mon Jan 15 19:15:15 CET 2024, vous avez 13 réponses correctes, 7 réponses incorrectes, pour un total de 20 consultations de cartes. Continuez comme ça !
```` 
