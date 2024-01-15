#!/bin/bash

statistics()
{
    cat $HOME/FlashApp/data/periodic_stats.txt
    right=0
    wrong=0
    total=0

    while IFS=";" read -r col1 col2 col3
    do
        right=$col1
        wrong=$col2
        total=$col3
    done < "$HOME/FlashApp/data/at_stats.csv"
    install_date=$(cat "$HOME"/FlashApp/data/date.txt)
    echo "Au total depuis la date d'installation au $install_date, vous avez $right réponses correctes, $wrong réponses incorrectes, pour un total de $total consultations de cartes. Continuez comme ça !" 
}

installer()
{
    echo "Bienvenue dans FlashApp™"
    echo "FlashApp n'est pas installé sur votre ordinateur"
    echo "Voulez vous l'installer ? (y/n)"
    answered="false"
    while [ $answered != "true" ]
    do 
        read answer
        if [[ $answer == "y" ]]
        then
            mkdir -p ~/FlashApp/data/
            echo -ne '#####                     (33%)\r'
            sleep 1
            touch ~/FlashApp/data/periodic_stats.txt
            touch ~/FlashApp/data/at_stats.csv
            echo "0;0;0" >> ~/FlashApp/data/at_stats.csv
            echo -ne '#############             (66%)\r'
            sleep 1
            mkdir ~/FlashApp/data/sets
            date > ~/FlashApp/data/date.txt
            echo -ne '#######################   (100%)\r'
            echo -ne '\n'
            echo "FlashApp est désormais installé sur votre ordinateur"
            echo "Vous pouvez lancer le même programme pour l'utiliser"
            answered="true"
        elif [[ $answer == "n" ]]
        then
            echo "Au revoir !"
            answered="true"
        else
            echo "Je n'ai pas compris, veuillez utiliser y/n pour répondre"
        fi
    done
}

check_install()
{
    folders=(levels session)
    for folder in "${folders[@]}"
    do 
        END=5
        for (( i=1; i<$END; i++));
        do
            path="$HOME/FlashApp/data/$folder/$i"
            echo "$path"
            if [[ -d "$path" ]]
            then
                echo "alright"
            else 
                echo "wrong"
            
            fi
        done
    done
}

create_cards()
{
    echo "Quel nom voulez-vous donner à votre set de cartes ?"
    echo "Si vous donner à votre nouveau set le même nom qu'un set existant, le nouveau set écrasera l'ancien"
    read name
    mkdir -p "$HOME"/FlashApp/data/sets/"$name"/{levels,session}/
    mkdir -p "$HOME"/FlashApp/data/sets/"$name"/levels/{1,2,3,4}/
    mkdir -p "$HOME"/FlashApp/data/sets/"$name"/session/{1,2,3,4}/
    echo "Assurez vous d'avoir bien placé votre fichier .csv dans le dossier utilisateur"
    echo "Rappel : Selon le programme, la première ligne de votre fichier .csv correspond aux catégories du contenu de votre fichier"
    echo "Veuillez écrire le nom du fichier"
    answered="false"
    while [ $answered == "false" ]
    do 
        read file
        if [[ -e ~/$file ]]
        then
            echo -ne '#####                     (33%)\r'
            sleep 1
            cp "$HOME""/$file" "$HOME"/FlashApp/data/sets/"$name"
            FILE="$HOME/FlashApp/data/sets/$name/$file" 
            count=0
            first_line=$(head -n 1 "$FILE")
            echo -ne '#############             (66%)\r'
            sleep 1
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
                } > "$HOME/FlashApp/data/sets/$name/levels/1/pair$count.md"
            done < <(tail -n +2 "$FILE")
            echo -ne '#######################   (100%)\r'
            echo -ne '\n'
            echo "Cartes crées ! Vous pouvez commencer la session."
            answered="true"
        else
            echo "Fichier introuvable"
        fi
    done
}

cleaning()
{
    for c in $(ls $HOME/FlashApp/data/sets/*/session/*/*.md)
    do 
        set_name=$(echo "$c" | cut -d '/' -f 7)
        level=$(echo "$c" | cut -d '/' -f 9)
        mv "$c" "$HOME"/FlashApp/data/sets/"$set_name"/levels/"$level"/
    done
}

session()
{
    echo "Quel set de carte voulez-vous pratiquer ?"
    answered="false"
    while [ $answered != "true" ]
    do 
        for set in $(ls "$HOME"/FlashApp/data/sets)
        do  
            echo "$set"
        done
        read chosen_set
        if [ -e ~/FlashApp/data/sets/"$chosen_set" ]
        then 
            answered="true"
        else
            echo "Ce set est inexistant, veuillez choisir parmi les sets que vous avez créés"
        fi
    done
    echo "Préparation de la session" 
    mv_amount=4
    for i in $(seq 1 4)
    do
        if [[ $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/"$i"/ | wc -l) -ge $mv_amount ]]
        then 
            for c in $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/$i/*.md | shuf -n $mv_amount)
            do 
                mv $c "$HOME"/FlashApp/data/sets/"$chosen_set"/session/$i/
            done
        elif [[ $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/$i | wc -l) -ge 1 && $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/$i | wc -l) -lt $mv_amount ]]
        then 
            for c in $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/$i/*.md)
            do 
                mv $c "$HOME"/FlashApp/data/sets/"$chosen_set"/session/$i/
            done
        fi
        ((mv_amount--))
    done
    nb_cards=$(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/session/*/*.md | wc -l)
    echo $nb_cards
    if [[ $nb_cards -lt 10 ]]
    then 
        gap=$(expr 10 - "$nb_cards")
        for c in $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/*/*.md | shuf -n "$gap")
        do 
            level=$(echo "$c" | cut -d '/' -f 9)
            mv "$c" "$HOME"/FlashApp/data/sets/"$chosen_set"/session/"$level"/
        done
    fi
    
    #####
    echo "Début de la session"
    right=0
    wrong=0
    total=0
    for c in $(ls "$HOME"/FlashApp/data/sets/"$chosen_set"/session/*/*.md | shuf)
    do 
        level=$(echo "$c" | cut -d '/' -f 9)
        mdp "$c"
        echo "Avez vous trouvé la réponse ? (y/n)"
        answered="false"
        while [ "$answered" != "true" ]
        do
            read answer
            if [[ "$answer" == "y" ]] 
            then 
                ((total++))
                ((right++))
                if [[ $level != 4 ]]
                then 
                    ((level++ ))
                    mv "$c" "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/"$level"/
                    echo "carte $c au niveau $level"
                fi
                answered="true"

            elif [[ "$answer" == "n" ]]
            then 
                ((total++))
                ((wrong++))
                if [[ $level != 1 ]]
                then 
                    ((level-- ))
                    mv "$c" "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/"$level"/
                    echo "carte $c au niveau $level"
                else 
                    mv "$c" "$HOME"/FlashApp/data/sets/"$chosen_set"/levels/"$level"
                fi
                answered="true"
            else 
                echo "Je n'ai pas compris utilisez uniquement les commandes y et n, essayez à nouveau"
            fi
        done
    done
    write_statistics $right $wrong $total
}

main()
{
    nb_cards=$(ls "$HOME"/FlashApp/data/sets/*/session/*/*.md 2>/dev/null | wc -l)
    if [[ $nb_cards -ge 1 ]]
    then 
        echo "Vous n'avez pas fini votre session la dernière fois !"
        echo "Vous voulez que le programme ait des problèmes ? Non ce n'est pas bien, je vais nettoyer tout ça mais ne le faites plus"
        echo "En plus ce n'est pas bon pour votre apprentissage, de plus, les sessions non finies ne comptent pas dans les statistiques"
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
        echo "3 - Voir mes statistiques"
        echo "4 - Quitter le programme"
        read answer
        if [[ "$answer" == "1" ]]
        then 
            answered="true"
            session
        elif [[ "$answer" == "2" ]]
        then 
            create_cards
        elif [[ "$answer" == "3" ]]
        then
            statistics
        elif [[ "$answer" == "4" ]]
        then 
            echo "Au revoir"
            answered="true"
        else
            echo "Je n'ai pas compris votre demande, veuillez insérer une commande correcte."
        fi 
    done
}

write_statistics()
{
    echo "Session du $(date), $1 réponses correctes, $2 réponses incorrectes" >> "$HOME"/FlashApp/data/periodic_stats.txt
    right=$1
    wrong=$2
    total=$3
    
    while IFS=";" read -r col1 col2 col3
    do  
        right=$(($right + $col1))
        wrong=$(($wrong + $col2))
        total=$(($total + $col3))
    done < "$HOME/FlashApp/data/at_stats.csv"
    echo "$right;$wrong;$total" > "$HOME/FlashApp/data/at_stats.csv"
}

if [[ -e ~/FlashApp/data ]]
then 
    main
else 
    installer
fi
