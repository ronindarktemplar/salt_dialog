#!/bin/bash

function IPeUser()
{
       #funcao que recebe duas variaveis para preencher  ip  e login

        #Obtem IP do servidor
	local ipserver=$(dialog --stdout --inputbox 'IP' 0 0)
	
	#Obtem Usuário
	local login=$(dialog --stdout --inputbox 'Usuário de login no server' 0 0)

	#retorna valores
	eval "$1=$ipserver"
	eval "$2=$login"

}


function EnlaceServer()
{    
    clear;

    dialog --msgbox "Ativar o serviço iperf nesse host" 0 0
    ServerLog=/tmp/ServerLog.log
    local data=$(date)

	menuSrv=$(dialog --menu "Escolha as opções de Configuração" 20 35 15 \
	1 "Server Modo TCP" \
	2 "Server Modo UDP" \
	9 "Voltar" --stdout)
        
    case $menuSrv in        
        1)
		COMANDO="iperf -s"
		echo -e  "\n============Comando dispardo por $USER em $data======================" >> $ServerLog
		dialog --msgbox "pressione CTRL+C para encerrar o modo Servidor" 0 0
	        $COMANDO 1>> $ServerLog 2>> $ServerLog | dialog --tailbox $ServerLog 0 0
            	;;

        2) 
		COMANDO="iperf -u -s"
		echo -e  "\n============Comando dispardo por $USER em $data======================" >> $ServerLog
		dialog --msgbox "pressione CTRL+C para encerrar o modo Servidor" 0 0
	        $COMANDO 1>> $ServerLog 2>> $ServerLog | dialog --tailbox $ServerLog 0 0
		;; 

        9)  	Menu
	    	;;

        *) echo "Menu Inválido!" ;;

    esac

    Menu
}



function EnlaceCliente()
{    
    clear;

    #Obtem IP do servidor
    local ip=$(dialog --stdout --inputbox 'IP do Servidor de iperf' 0 0)
    ClienteLog=/tmp/ClientLog.log
    local data=$(date)
    
    

	menuCli=$(dialog --menu "Escolha as opções de Configuração" 20 35 15 \
	1 "Modo TCP" \
	2 "Modo UDP" \
	9 "Voltar" --stdout)
        
    case $menuCli in        
        1) 
		COMANDO="iperf -c $ip"
		echo -e  "\n============Comando dispardo por $USER em $data======================" >> $ClienteLog
	        $COMANDO 1>> $ClienteLog 2>> $ClienteLog;
		dialog --tailbox $ClienteLog 0 0
            	;;

        2) 
		local banda=$(dialog --stdout --inputbox 'Modo UDP usa 1MB/s, Informe outra banda Ex: 10m ou 100m ' 0 0)
		COMANDO="iperf -u -c $ip -b$banda"
		echo -e  "\n============Comando dispardo por $USER em $data======================" >> $ClienteLog
	        $COMANDO 1>> $ClienteLog 2>> $ClienteLog;
	        dialog --tailbox $ClienteLog 0 0
		#iperf -u -c $ip -b$banda -o $ClienteLog | dialog --textbox $ClienteLog 0 0
		;; 

        9)  	Menu
	    	;;

        *) echo "Menu Inválido!" ;;

    esac
   
    Menu
}


function AnalisarLogs()
{    
    clear;

   local CliLog=/tmp/ClientLog.log
   local SerLog=/tmp/ServerLog.log
    

	menuAnalise=$(dialog --menu "Escolha Logs do Servidor ou Cliente" 20 35 15 \
	1 "Logs Servidor" \
	2 "Logs Cliente" \
	9 "Voltar" --stdout)
        
    case $menuAnalise in        
        1) 
		dialog --textbox $SerLog 0 0
            	;;

        2) 
		dialog --textbox $CliLog 0 0
		;; 

        9)  	Menu
	    	;;

        *) echo "Menu Inválido!" ;;

    esac
  
    Menu
}

function Menu()
{
    clear

menuEnlace=$(dialog --menu "Menu/Usuarios" 20 35 15 \
1 "Rodar como Servidor" \
2 "Rodar como Cliente" \
3 "Analisar Logs" \
9 "Voltar" --stdout)


  
        
    case $menuEnlace in        
        1) 
            EnlaceServer
            ;;

        2) 
            EnlaceCliente
            ;; 

        3) 
            AnalisarLogs
            ;;

        9)      ./Main.sh;;

        

        *) echo "Menu Inválido!" ;;

    esac
}

function Iniciar(){

    
    
    Menu
}

Iniciar
