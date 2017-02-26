#!/bin/bash

#Global Variables
GNAME="NULL";
GTMP="/tmp";


function IPeUser()
{
       #funcao que recebe uma variavel  para preencher nome do minionn
	local minionpadrao="minion1"
	local listminions=/tmp/listminions.txt
	dialog --cr-wrap --sleep 1 --infobox "Procurando Minions Disponíveis..." 0 0

	echo -e "$(sudo salt '*' test.ping -s --out=txt | sed "s/\://g" )" > $listminions

	local minions=$(cat $listminions)

	minionpadrao=$(dialog --stdout --menu 'Escolha o Minion:' 0 0 0 \
	    `
	    for x in $minions; do
		    echo " $x ";
	    done;
	`);
	#Valida se houve uma selecao de usuario ou nao
	if [ $? -eq 1 ]; then
	    dialog --cr-wrap --sleep 2 --title 'Tente Novamente' --infobox "Nenhum escolhido" 5 17
	    Menu;
#	    else
#		    dialog --cr-wrap --sleep 1 --infobox "Escolhido $minionpadrao" 0 0
	fi
 
       #retorna valores
	eval "$1=$minionpadrao"

}

function ListStatesTree()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
        
	IPeUser myminion        

	#local mycommand="tree /srv/salt -L 1 | grep -v sls | grep -v directories"
	#SelectTree $mycommand mychoice
	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice" 0 0
	#SelectViewDoTest $mychoice commandtorun
	#dialog --cr-wrap --sleep 2 --infobox "Recebi: $commandtorun" 0 0
#	
    	#echo -e "$(sudo salt $myminion state.show_highstate --out=json | grep __sls__ | sed 's/, *$//' | sort -u | awk '{print $2}')" > $todialog
	#comando mais simples
	echo -e "$(sudo salt $myminion  cp.list_states | sed 1d | sed "s/\-//g" | tr -s [:space:] )" > $todialog

	dialog --title "States off minion: $myminion " --textbox $todialog 45 50

	Menu
}

function RunState()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
       
	IPeUser myminion        

	echo -e "$(sudo salt $myminion  cp.list_states | sed 1d | sed "s/\- //g" | tr -s [:space:] )" > $todialog

	#local mycommand=$(cat $todialog)  
	SelectFunction mychoice

	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice" 0 0
	SelectViewDoTest $myminion $mychoice 

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}


function RunTopState()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
       
	IPeUser myminion        

	echo -e "$(sudo salt $myminion state.show_top | grep " - " | tr -s [:space:] | sed "s/ \- //g")" > $todialog

	#local mycommand=$(cat $todialog)  
	SelectFunction mychoice

	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice" 0 0
	SelectViewDoTest $myminion $mychoice 

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}



function RunHighState()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt

	IPeUser mymini

	myselect=$(dialog --stdout --radiolist 'Opcoes'  0 0 0   \
            run      'Run  / Executar    '  off  \
            testonly 'Test / Testar      '  on \
            viewonly 'View / Vizualizar  '  off);
case $myselect in
	"run")
		#echo "tree-only"
		echo -e "$(sudo salt $mymini state.highstate)" > $todialog
		;;
	"testonly")
		#echo "all-files"
		echo -e "$(sudo salt $mymini state.highstate test=true)" > $todialog
		;;
	"viewonly")
		#echo "all"
		echo -e "$(sudo salt $mymini state.show_highstate )" > $todialog
		;;
	*)
		echo "Menu Inválido!"
	       	;;

esac

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}


function Menu()
{
	clear

	menuopt=$(dialog --menu "Menu" 20 35 15 \
	1 "List All Jobs" \
	2 "List Running Jobs" \
	3 "List Active Jobs" \
	4 "Lookup Job" \
	5 "Kill a Job" \
	9 "Exit" --stdout)
	
    	
	case $menuopt in		
		1) 
			ListAllJobs
			;;

		2) 
			ListRunsJobs
			;; 

		3) 
			ListActJobs
			;;

		4) 
			LookupAJob
			;;

		5) 
			KillJob
			;;




		9)      exit
			;;

		*) echo "Menu Inválido!" ;;

	esac
}

function Iniciar(){
	Menu
}

Iniciar
