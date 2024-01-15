#!/bin/bash

#expr interprete les chaines de caractères comme des int
#cut -f 2,3 prend en compte les colonnes 2 et 3 | cut -d; indique le délimiteur
#mkdir xdg-user-dir DOCUMENTS/dirname to create a directory in the user's documents folder
#pour faire l'installer, il pourrait être judicieux de detecter si les fichiers sont bien présents au démarrage du programme
#si il ne sont pas présent, le programme commence avec main, autrement il suggère l'installation du programme. 
#ajouter un onglet statistiques
#ne pas oublier de faire un vide dans la création de la session après la session, créer une boite session ?

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
    read name
    mkdir -p "$HOME"/FlashApp/data/"$name"/{levels,session}/
    mkdir -p "$HOME"/FlashApp/data/"$name"/levels/{1,2,3,4}/
    mkdir -p "$HOME"/FlashApp/data/"$name"/session/{1,2,3,4}/
    echo "Assurez vous d'avoir bien placé votre fichier .csv dans le dossier utilisateur"
    echo "Veuillez écrire le nom du fichier" 
    read file
    echo -ne '#####                     (33%)\r'
    sleep 1
    cp "$HOME""/$file" "$HOME"/FlashApp/data/"$name"
    FILE="$HOME/FlashApp/data/$name/$file"
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
        } > "$HOME/FlashApp/data/$name/levels/1/pair$count.md"
    done < "$FILE"
    echo -ne '#######################   (100%)\r'
    echo -ne '\n'
    echo "Cartes crées ! Vous pouvez commencer la session."
}

test()
{
    echo
    
}

cleaning()
{
    ls $HOME/FlashApp/data/*/session/*/*.md
    for c in $(ls $HOME/FlashApp/data/*/session/*/*.md)
    do 
        set_name=$(echo "$c" | cut -d '/' -f 6)
        level=$(echo "$c" | cut -d '/' -f 8)
        mv "$c" "$HOME"/FlashApp/data/"$set_name"/levels/"$level"/
    done
}

session()
{
    echo "Quel set de carte voulez-vous pratiquer ?"
    for set in $(ls "$HOME"/FlashApp/data/)
    do  
        echo $set
    done
    read chosen_set
    echo "Préparation de la session" 
    mv_amount=4
    for i in $(seq 1 4)
    do
        echo $mv_amount
        if [[ $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/"$i"/ | wc -l) -ge $mv_amount ]]
        then 
            for c in $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/$i/*.md | shuf -n $mv_amount)
            do 
                mv $c "$HOME"/FlashApp/data/"$chosen_set"/session/$i/
            done
        elif [[ $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/$i | wc -l) -ge 1 && $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/$i | wc -l) -lt $mv_amount ]]
        then 
            for c in $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/$i/*.md)
            do 
                mv $c "$HOME"/FlashApp/data/"$chosen_set"/session/$i/
            done
        fi
        ((mv_amount--))
    done
    nb_cards=$(ls "$HOME"/FlashApp/data/"$chosen_set"/session/*/*.md | wc -l)
    if [[ $nb_cards -lt 10 ]]
    then 
        gap=$(expr 10 - "$nb_cards")
        for c in $(ls "$HOME"/FlashApp/data/"$chosen_set"/levels/*/*.md | shuf -n "$gap")
        do 
            level=$(echo "$c" | cut -d '/' -f 8)
            mv "$c" "$HOME"/FlashApp/data/"$chosen_set"/session/"$level"/
        done
    fi
    
    #####
    echo "Début de la session"
    for c in $(ls "$HOME"/FlashApp/data/"$chosen_set"/session/*/*.md | shuf)
    do 
        level=$(echo "$c" | cut -d '/' -f 8)
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
                    level=$(expr "$level" + 1)
                    mv "$c" "$HOME"/FlashApp/data/"$chosen_set"/levels/"$level"/
                    echo "carte $c dans la boite $level"
                fi
                answered="true"

            elif [[ "$answer" == "n" ]]
            then 
                if [[ $level != 1 ]]
                then 
                    level=$(expr $level - 1)
                    mv "$c" "$HOME"/FlashApp/data/"$chosen_set"/data/levels/"$level"/
                    echo "carte $c dans la boite $level"
                else 
                    mv "$c" "$HOME"/FlashApp/data/"$chosen_set"/levels/"$level"
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
    nb_cards=$(ls "$HOME"/FlashApp/data/"$chosen_set"/session/*/*.md 2>/dev/null | wc -l)
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

if [[ -e ~/FlashApp/data ]]
then 
    main
else 
    installer
fi



#ls session/*/*.md | shuf
#fait un échantillon de fichiers aléatoire parmi les boites

#echo "$f" | cut -d '/' -f 3 
#commande qui va analyser le path du fichier pour avoir 

