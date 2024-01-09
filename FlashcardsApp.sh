#!/bin/bash
FILE="Russe.csv"

#expr interprete les chaines de caractères comme des int
#cut -f 2,3 prend en compte les colonnes 2 et 3 | cut -d; indique le délimiteur
#mkdir xdg-user-dir DOCUMENTS/dirname to create a directory in the user's documents folder
#pour faire l'installer, il pourrait être judicieux de detecter si les fichiers sont bien présents au démarrage du programme
#si il ne sont pas présent, le programme commence avec main, autrement il suggère l'installation du programme. 
#ajouter un onglet statistiques
#ne pas oublier de faire un vide dans la création de la session après la session, créer une boite session ?

create_cards()
{
    count=0
    while IFS=";" read -r col1 col2 
    do
        #solution qui PEUT etre trop récente, vaut mieux utiliser 
        #count=$(expr $count + 1)
        ((count++))
        echo "


# $col1

---


# $col2" > ./data/levels/1/pair$count.md
    done < "$FILE"
    echo "Cartes crées ! Vous pouvez commencer la session."

}

test()
{
    mv_amount=4
    for i in $(seq 1 4)
    do
        echo $mv_amount
        if [[ $(ls ./data/levels/$i | wc -l) -ge $mv_amount ]]
        then 
            for c in $(ls ./data/levels/$i/*.md | shuf -n $mv_amount)
            do 
                mv $c ./data/session/$i/
            done
        elif [[ $(ls ./data/levels/$i | wc -l) -ge 1 && $(ls ./data/levels/$i | wc -l) -lt $mv_amount ]]
        then 
            for c in $(ls ./data/levels/$i/*.md)
            do 
                mv $c ./data/session/$i/
            done
        fi
        ((mv_amount--))
    done
    
    
    
}

cleaning()
{
    for c in $(ls ./data/session/*/*.md)
    do 
        level=$(echo "$c" | cut -d '/' -f 4)
        mv $c ./data/levels/$level/
    done
}

session()
{
    echo "Préparation de la session" 

    if [[ $(ls ./data/levels/1/ | wc -l)  -ge 4 && $(ls ./data/levels/2/ | wc -l)  == 3 && $(ls ./data/levels/3/ | wc -l)  == 2 && $(ls ./data/levels/4/ | wc -l)  == 1  ]]
    then
        for c in $(ls ./data/levels/1/*.md | shuf -n 4)
        do 
            mv $c ./data/session/1/
        done

        for c in $(ls ./data/levels/2/*.md | shuf -n 3)
        do 
            mv $c ./data/session/2/
        done

        for c in $(ls ./data/levels/3/*.md | shuf -n 2)
        do 
            mv $c ./data/session/3/
        done

        for c in $(ls ./data/levels/4/*.md | shuf -n 1)
        do 
            mv $c ./data/session/4/
        done 
    else 
        cards=$(ls ./data/levels/*/*.md | shuf -n 10)
        for c in $cards
        do 
            mv_amount=$(echo "$c" | cut -d '/' -f 4)
            mv $c ./data/session/$mv_amount/
        done
    fi
    
    #####
    echo "Début de la session"
    for c in $(ls ./data/session/*/*.md | shuf)
    do 
        level=$(echo "$c" | cut -d '/' -f 4)
        echo "$level"
        mdp "$c"
        echo "Avez vous trouvé la réponse ? (y/n)"
        answered="false"
        while [ "$answered" != "true" ]
        do
            read answer
            if [[ "$answer" == "y" ]] 
            then 
                if [[ $level != 4 ]]
                then 
                    level=$(expr $level + 1)
                    mv "$c" "./data/levels/$level/"
                    echo "carte $c dans la boite $level"
                fi
                answered="true"

            elif [[ "$answer" == "n" ]]
            then 
                if [[ $level != 1 ]]
                then 
                    level=$(expr $level - 1)
                    mv "$c" "./data/levels/$level/"
                    echo "carte $c dans la boite $level"
                else 
                    mv "$c" "./data/levels/$level"
                fi
                answered="true"
            else 
                echo "Je n'ai pas compris utilisez uniquement les commandes y et n, essayez à nouveau"
            fi
        done
    done
}

main()
{
    echo "Bienvenue dans FlashApp™"
    answered="false"
    while [ "$answered" == "false" ]
    do
        echo "Veuillez faire un choix :"
        echo "1 - Session du jour"
        echo "2 - Créer un set de carte"
        read answer
        if [[ "$answer" == "1" ]]
        then 
            answered="true"
            session
        elif [[ "$answer" == "2" ]]
        then 
            create_cards
        else
            echo "Je n'ai pas compris votre demande, veuillez insérer une commande correcte."
        fi 
    done
}

test


#ls session/*/*.md | shuf
#fait un échantillon de fichiers aléatoire parmi les boites

#echo "$f" | cut -d '/' -f 3 
#commande qui va analyser le path du fichier pour avoir 

