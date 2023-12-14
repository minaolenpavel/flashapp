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

#ls session/*/*.md | shuf
#fait un échantillon de fichiers aléatoire parmi les boites

#echo "$f" | cut -d '/' -f 3 
#commande qui va analyser le path du fichier pour avoir 
