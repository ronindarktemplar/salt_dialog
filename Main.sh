#!/bin/bash

clear


function Menu()
{
    menugeral=$(dialog --menu "escolha uma opcao:" 20 35 15 \
	1 "Usuarios" \
	2 "Monitoramento" \
	3 "Backup" \
	4 "Enlace" \
	5 "Salt-Help" \
	6 "Salt-Jobs" \
	7 "Salt-States" --stdout)



	
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

		6)  ./MenuJobs.sh
			;;

		7)  ./MenuStates.sh
			;;			
		*) exit
		       	;;
	esac
	
	
}

function Iniciar(){
	Menu
}

Iniciar
