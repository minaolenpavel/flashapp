#!/bin/bash
FILE="Russe.csv"

#expr interprete les chaines de caractères comme des int
#cut -f 2,3 prend en compte les colonnes 2 et 3 | cut -d; indique le délimiteur
#mkdir xdg-user-dir DOCUMENTS/dirname to create a directory in the user's documents folder
#mdp pouvr ouvrir en md, sinon le md est un format de texte presque brut 

count=0
while IFS=";" read -r col1 col2 
do
    #solution qui PEUT etre trop récente, vaut mieux utiliser 
    #count=$(expr $count + 1)
    ((count++))
    echo "
-> # $col1

---
-> # $col2" > ./data/cards/pair$count.md
done < "$FILE"

echo "Préparation de la session" 
cards=$(ls ./data/cards/*.md | shuf -n 10) 
for c in $cards
do 
    mv "$c" ./data/levels/1/
done

echo "Début de la session"
for c in $(ls ./data/levels/1/*.md | shuf)
do 
    level=$(echo "$c" | cut -d '/' -f 4)
    echo "$level"
    mdp "$c"
    echo "Avez vous trouvé la réponse ? (y/n)"
    read answer
    if [[ "$answer" == "y" ]] 
    then 
        if [[ $level != 4 ]]
        then 
            level=$(expr $level + 1)
            mv "$c" "./data/levels/$level/"
            echo "carte $c dans la boite $level"
        fi
    fi

done

#ls session/*/*.md | shuf
#fait un échantillon de fichiers aléatoire parmi les boites

#echo "$f" | cut -d '/' -f 3 
#commande qui va analyser le path du fichier pour avoir 
