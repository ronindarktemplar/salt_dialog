#!/bin/bash

clear


function Menu()
{
    menugeral=$(dialog --menu "escolha uma opcao:" 20 35 15 \
	1 "Usuarios" \
	2 "Monitoramento" \
	3 "Backup" \
	4 "Enlace" \
	5 "Help" --stdout)

	
	#echo $menugeral

	case $menugeral in		
		1) 
		     ./MenuUsuarios.sh 
			;;

		2)   ./MenuMonitoramento.sh 
			;;

		3)  ./MenuBackup.sh
			;;

		4)  ./MenuEnlace.sh
			;;

		5)  ./MenuHelps.sh
			;;			

	*) echo "Menu Inválido!" ;;
	esac
	
	
}

function Iniciar(){
	Menu
}

Iniciar
