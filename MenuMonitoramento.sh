#!/bin/bash

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

function VisualizarLogs(){
	
	#Exibe no dialog valores do arquivo de Logs
	dialog --textbox /tmp/LogHistMonitoramento.txt 20 70

	Menu
}

function MonitorarPorta()
{
	local tempFile="/tmp/tempMonit.txt"


	IPeUser myminion


	
	#formata um pouco o futuro arquivo de log
	echo "---------------------------------------------------" >> $tempFile
	echo `date` >> $tempFile
	echo "Comando executado: salt $myminion  cmd.run "netstat -vatupn" " >> $tempFile
	echo "---------------------------------------------------" >> $tempFile
        #Executa comando
	sudo  salt $myminion cmd.run "netstat -vatupn" >> $tempFile	

	cat $tempFile >> /tmp/LogHistMonitoramento.txt

	#Exibe no dialog valores do arquivo temporário
	dialog --title 'Resultado do monitoramento' --textbox $tempFile 20 70
	#dialog --title 'Resultado do monitoramento' --tailbox $tempFile 24 79

	#Exclui arquivo temporário
	rm -rf $tempFile

	Menu

}

function GerenciaPeriodo()
{
        dialog --msgbox "Com uso do salt, pode-se usar Beacoms para monitorar eventos\
		         nos minions e o reactor para até reagir a esses eventos no master."
	Menu

}


function Menu()
{
	clear

	menuConfiguracao=$(dialog --menu "Menu/Configuração" 20 35 15 \
	1 "Monitorar Portas" \
	2 "Vizualizar Logs" \
	3 "Gerencia Agendamento" \
	9 "Voltar" --stdout)
	
    	
	case $menuConfiguracao in		
		1) 
			MonitorarPorta
			;;	

		2) 
			VisualizarLogs
			;;	
	
		3) 
			GerenciaPeriodo
			;;	

		9)  ./Main.sh
			;;

		*) echo "Menu Inválido!" ;;

	esac
}

function Iniciar(){

	Menu
}

Iniciar
