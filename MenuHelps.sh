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
	    else
		    dialog --cr-wrap --sleep 1 --infobox "Escolhido $minionpadrao" 0 0
	fi

 
       #retorna valores
	eval "$1=$minionpadrao"

}

function SelectFunc()
{	
	clear;
    	local todialog=$GTMP/RespToDialog.txt

	DEFAULT="sys.list_functions";
	mycomm=${1-$DEFAULT}
	DEFAULT="cmd";
	mymod=${2-$DEFAULT}


  
    dialog --msgbox "Selecione na lista de $mycomm ." 0 0
    echo -e "$(sudo salt-call $mycomm $mymod | sed -e 1d | cut -d'-' -f2 )" > $todialog
    dialog --msgbox "Criada lista, tecle enter" 0 0
    
    local modules=$(cat $todialog )

    myescolha=$(dialog --stdout --menu 'Escolha o interpretador de comandos:' 0 0 0 \
	    `
            for x in $modules; do
		    echo " "$x" Escolha-me ";
	    done;
    `);
    #Valida se houve uma selecao de usuario ou nao
    if [ $? -eq 1 ]; then
	    dialog --cr-wrap --sleep 2 --title 'Tente Novamente' --infobox "Nenhum escolhido" 5 17
		eval "$3=test.ping"
		Menu;
    	else
		#dialog --cr-wrap --sleep 2 --infobox "Escolhido: $myescolha" 0 0
		eval "$3=$myescolha"
    fi

}


function SelectFunction()
{	
	clear;
    	local todialog=$GTMP/RespToDialog.txt

	DEFAULT="sys.list_functions";
	mycomm=${1-$DEFAULT}

    dialog --msgbox "Selecione na lista de $mycomm ." 0 0

    echo -e "$(sudo salt-call $mycomm | sed -e 1d | cut -d'-' -f2 )" > $todialog

    dialog --msgbox "Lista criada tecle enter." 0 0

    local modules=$(cat $todialog )

    myescolha=$(dialog --stdout --menu 'Escolha o interpretador de comandos:' 0 0 0 \
	    `
            for x in $modules; do
		    echo " "$x" Escolha-me ";
	    done;
    `);
    #Valida se houve uma selecao de usuario ou nao
    if [ $? -eq 1 ]; then
	    dialog --cr-wrap --sleep 2 --title 'Tente Novamente' --infobox "Nenhum escolhido" 5 17
		eval "$2=test.ping"
		Menu;
    	else
		#dialog --cr-wrap --sleep 2 --infobox "Escolhido: $myescolha" 0 0
		eval "$2=$myescolha"
    fi

}


function ModulesDoc()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
        
	local mycommand="sys.list_modules"

	SelectFunction $mycommand mychoice

	
	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mymodule" 0 0
		
    	echo -e "$(sudo salt-call sys.doc $mychoice)" > $todialog

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}

function FunctionsDoc()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
        
	local mycommand="sys.list_functions"

	SelectFunction $mycommand mychoice


	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice" 0 0
		
    	echo -e "$(sudo salt-call sys.doc $mychoice)" > $todialog

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}

function StateFunctionsDoc()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
        
	local mycommand="sys.list_state_functions"

	SelectFunction $mycommand mychoice


	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice" 0 0
		
    	echo -e "$(sudo salt-call sys.state_doc $mychoice)" > $todialog

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}



function ModuleToFunction()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
       
	local mycommando="sys.list_modules"
	SelectFunction $mycommando mymodule

        local mycommand="sys.list_functions" 
	SelectFunc $mycommand $mymodule mychoice

	
	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice " 0 0
		
    	echo -e "$(sudo salt-call sys.doc $mychoice)" > $todialog

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}

function StateModuleToFunction()
{    
	clear;

    	local todialog=$GTMP/RespToDialog.txt
       
	local mycommando="sys.list_state_modules"
	SelectFunction $mycommando mymodule

	local mycommand="sys.list_state_functions" 
	SelectFunc $mycommand $mymodule mychoice

	
	#dialog --cr-wrap --sleep 2 --infobox "Escolhi: $mychoice " 0 0
		
    	echo -e "$(sudo salt-call sys.state_doc $mychoice)" > $todialog

	dialog --title 'Documentation' --textbox $todialog 0 0

	Menu
}



function Menu()
{
	clear

	menuopt=$(dialog --menu "Menu" 20 35 15 \
	1 "Modules Doc" \
	2 "Functions Doc" \
	3 "Modulo->Functions" \
	4 "State Modules" \
	5 "State Functions" \
	9 "Sair" --stdout)
	
    	
	case $menuopt in		
		1) 
			ModulesDoc
			;;

		2) 
			FunctionsDoc
			;; 

		3) 
			ModuleToFunction
			;;

		4) 
			StateFunctionsDoc
			;; 

		5) 
			StateModuleToFunction
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
