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
    first_line=$(head -n 1 $FILE)
    IFS='; ' read -r -a keys <<< "$first_line"
    while IFS=";" read -r col1 col2 col3 col4 col5
    do
        ((count++))
        {
            echo "# ${keys[0]} : $col1"
            echo
            echo "---"
            [[ -n $col2 ]] && echo "# ${keys[1]} : $col2"
            echo
            [[ -n $col3 ]] && echo "# ${keys[2]} : $col3"
            [[ -n $col4 ]] && echo "# ${keys[3]} : $col4"
            [[ -n $col5 ]] && echo "# ${keys[4]} : $col5"
        } > "./data/levels/1/pair$count.md"
    done < "$FILE"
    echo "Cartes crées ! Vous pouvez commencer la session."

}

test()
{
    echo
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
    nb_cards=$(ls ./data/session/*/*.md | wc -l)
    if [[ $nb_cards -lt 10 ]]
    then 
        gap=$(expr 10 - "$nb_cards")
        for c in $(ls ./data/levels/*/*.md | shuf -n "$gap")
        do 
            level=$(echo "$c" | cut -d '/' -f 4)
            mv "$c" ./data/session/"$level"/
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
    nb_cards=$(ls ./data/session/*/*.md 2>/dev/null | wc -l)
    if [[ $nb_cards -ge 1 ]]
    then 
        echo "Vous n'avez pas fini votre session la dernière fois !"
        echo "Vous voulez que le programme ait des problèmes ? Non ce n'est pas bien, je vais nettoyer tout ça mais ne le faites plus"
        echo "En plus ce n'est pas bon pour votre apprentissage"
        echo "Je vais m'assurer que vous ne le fassiez plus"
        phrase="Oh, comme je suis navré(e) cher programme, je ne recommencerai plus jamais ! je te le promets !"
        echo "Recopiez la phrase suivante, et je vous pardonne :"
        echo "$phrase"
        correct="false"
        while [[ $correct == "false" ]]
        do
            read reponse
            if [[ $reponse == $phrase ]]
            then
                echo "Je sais que vous avez fait un copier-coller, mais je vous pardonne quand même, ne faites plus jamais ça !"
                correct="true"
                echo
            else
                echo "J'ai pas compris"
            fi
        done
        cleaning
    fi
    
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

main


#ls session/*/*.md | shuf
#fait un échantillon de fichiers aléatoire parmi les boites

#echo "$f" | cut -d '/' -f 3 
#commande qui va analyser le path du fichier pour avoir 

