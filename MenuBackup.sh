#!/bin/bash

function IPeUser()
{

	#Aqui inserir um IP e User padrao facilita o uso e evita redigitacao
	local ippadrao="192.168.0.121"
	local userpadrao="eder"

      #funcao que recebe duas variaveis para preencher  ip  e login
       #Obtem IP do servidor
       local ipserver=$(dialog --stdout --inputbox 'IP' 0 0 $ippadrao)
       #Obtem Usuário
	local login=$(dialog --stdout --inputbox 'Usuário de login no server' 0 0 $userpadrao)
       #retorna valores
       	eval "$1=$ipserver"
       	eval "$2=$login"
}

	


function BackupRemoto()
{

	local datanome=$(date +%d-%m-%Y)

	#Obtem Nome do Modulo do Backup, sugerindo um nome
	local NomeModuloBackup=$(dialog --stdout --inputbox 'Nome do Backup' 0 0 "$USER-copia-$datanome")

	#Obtem Diretorio Origem do Backup
	local DiretorioOrigem=$(dialog --stdout --title 'Diretório Origem' --fselect "/home/$USER/backup" 14 48)
	#local DiretorioOrigem=$(dialog --stdout --inputbox 'Diretório Origem' 0 0)	

	#Obtem Diretorio Destino do Backup
	local DiretorioDestino=$(dialog --stdout --inputbox 'Diretório Destino' 0 0 /home/$USER/backup)

        #usa funcao para obter IP e Usuario de Login
        IPeUser IP_BCKUP BAKUSER


PORT=22;
local SAIDALOG="/tmp/BackupRemoto-outlog.log";
local TARLOG="/tmp/BackupRemoto-tar.log";

local TEMPDIR="/tmp/tempcopia";

#limpando arquivo temp da copia
rm $TEMPDIR -f -r
mkdir $TEMPDIR

local LogModuloDir="/tmp/logscopia";

if [ ! -d $LogModuloDir ]; then mkdir $LogModuloDir; fi

local LogModulo="${NomeModuloBackup}.log"
local LastModulo="/tmp/lastmodulo.log"
local MsgResumo="nulo"
local runbackup="/tmp/runbakup.sh"

#Checa se o host esta ligado
/bin/ping -c 1 -W 2 $IP_BCKUP > /dev/null
if [ "$?" -ne 0 ];
then 
	#O script termina aqui.
	dialog --msgbox "Erro!! host $IP_BCKUP offline ou falha na rede" 0 0
	Menu
else

	#nao precisa sudo, mas o usuario tem que ter acesso a pasta acima da que escolher como destion
	dialog --msgbox "Compactando $DiretorioOrigem para $TEMPDIR/$NomeModuloBackup no formato .tgz"
	#o ${} serve para fundir o nome da variavem com o .tgz
	tar -czvvf $TEMPDIR/${NomeModuloBackup}.tgz $DiretorioOrigem  1> $TARLOG 2>  $TARLOG;
	dialog --textbox $TARLOG 0 0;

	#cria comando do backup
	echo "#!/bin/bash" > $runbackup
	echo "rsync -avrzogupltC -e \"ssh -l $BAKUSER -p $PORT\"  $TEMPDIR/${NomeModuloBackup}.tgz $IP_BCKUP:$DiretorioDestino  1> $SAIDALOG 2>> $SAIDALOG" >> $runbackup
	chmod 755 $runbackup


	echo -e "Modulo: $NomeModuloBackup \n De: $DiretorioOrigem \n Para: $IP_BCKUP:$DiretorioDestino"  > /tmp/msg;
	MsgResumo=$(cat /tmp/msg)
	dialog --msgbox " $MsgResumo " 0 0 

	rsync -avrzogupltC -e "ssh -l $BAKUSER -p $PORT"  $TEMPDIR/${NomeModuloBackup}.tgz  $IP_BCKUP:$DiretorioDestino 1> $SAIDALOG 2>  $SAIDALOG;

	dialog --textbox $SAIDALOG 0 0;

	#Aqui gerado dados para Visualizar Modulo rodado por ultimo e log dos Modulos executados
	cat /tmp/msg > $LastModulo;

	cat $LastModulo $SAIDALOG > $LogModuloDir/$LogModulo;

	dialog --textbox $LogModuloDir/$LogModulo 0 0;

	dialog --msgbox "Backup Executado" 0 0;

fi
	Menu

}	

function VisualizarBackup()
{
	clear;

	local LastModulo="/tmp/lastmodulo.log"
	local LogModuloDir="/tmp/logscopia";

	local menuVer=$(dialog --menu "Modulo Vizualizar" 20 35 15 \
	1 "Ultimo Modulo Executado " \
	2 "Todos Modulos de Backup" \
	9 "Voltar        " --stdout)
	
    	
	case $menuVer in		
	
		1) 
			dialog --textbox $LastModulo 0 0
			;; 
		2) 
			local Modulos=$(dialog --stdout --title 'Modulos' --fselect $LogModuloDir/ 14 48)
			dialog --textbox $Modulos 0 0 
			;;

		9)  Menu
			;;

		*) echo "Menu Inválido!" ;;

	esac

	Menu
}



function agenda()
{
	clear;


	local runbackup="/tmp/runbakup.sh"
	local SAIDALOG="/tmp/BackupRemoto-outlog.log";
        local tmptsk="/tmp/crontasks.temp"
        local fixtsk="/tmp/fixcrontasks.temp"

	local LastModulo="/tmp/lastmodulo.log"
        local LogModuloDir="/tmp/logscopia";

	
	dialog --title 'Modulo a ser agendado' --textbox $LastModulo 0 0

	local min=$(dialog --stdout --inputbox 'Minuto 0-59' 0 0 "*/5")
	local hora=$(dialog --stdout --inputbox 'Hora 0-23' 0 0 "*")
	local dia=$(dialog --stdout --inputbox 'Dia 1-31' 0 0 "*")
	local mes=$(dialog --stdout --inputbox 'Mes 1-12' 0 0 "*")
	local diasemana=$(dialog --stdout --inputbox 'Dia-Semana 0-7' 0 0 "*")

	#salva tarefas existentes
        sudo crontab -l > $fixtsk

	#aqui foi tirado o user root
	echo "$min $hora $dia $mes $diasemana $runbackup"  > $tmptsk

        #Aqui joga a tarefa nova junto com as existentes
        cat $tmptsk >> $fixtsk
        sudo crontab $fixtsk

	dialog --title 'Agendado' --textbox $tmptsk 0 0

	AgendarBackup

}

function edita()
{
	clear;
        local tmptsk="/tmp/crontasks.temp"
        local fixtsk="/tmp/fixcrontasks.temp"
        local SelectTsk="/tmp/selectfixcrontasks.temp"
	local escolha="/tmp/select.temp"

	local SAIDALOG="/tmp/BackupRemoto-outlog.log";
	local LastModulo="/tmp/lastmodulo.log"
        local LogModuloDir="/tmp/logscopia";

	#salva tarefas existentes
        sudo crontab -l > $fixtsk
	#Numera para facilitar selecao
	sudo crontab -l | nl -nln -ba > $SelectTsk

	#Mostra em Dialog a lista numerada e dah opcao de selecionar
	dialog --title "Selecione a tarefa" --begin 3 3 --textbox $SelectTsk 20 100 --and-widget --begin 20 30 \
		--title "Digite o numero" --inputbox "Numero" 10 48 2>$escolha

	keys=$?
	case $keys in
	1)  # Cancel.
		return;;
	255) # ESC.
		return;;
	esac
					
	num=$(cat $escolha)

	linha=$(awk NR==$num $fixtsk)

        # Capturamos todos los datos de la tarea en variables.
        mins=`echo "$linha"  | awk '{print $1}' | tr ',' ' ' `
        horas=`echo "$linha"  | awk '{print $2}' | tr ',' ' ' `
        dias=`echo "$linha"  | awk '{print $3}' | tr ',' ' ' `
        meses=`echo "$linha"  | awk '{print $4}' | tr ',' ' ' `
        diasemanas=`echo "$linha"  | awk '{print $5}' | tr ',' ' '`
        tskuser=`echo "$linha"  | awk '{print $6}' | tr ',' ' ' `
        tskcomando=`echo "$linha"  | awk '{print $7}' | tr ',' ' '`

												
	local min=$(dialog --stdout --inputbox 'Minuto 0-59' 0 0 "$mins")

	local hora=$(dialog --stdout --inputbox 'Hora 0-23' 0 0 "$horas")

	local dia=$(dialog --stdout --inputbox 'Dia 1-31' 0 0 "$dias")

	local mes=$(dialog --stdout --inputbox 'Mes 1-12' 0 0 "$meses")

	local diasemana=$(dialog --stdout --inputbox 'Dia-Semana 0-7' 0 0 "$diasemanas")


	echo "$min $hora $dia $mes $diasemana $tskuser $tskcomando"  > $tmptsk
	cont=$(cat $tmptsk)

	#pega as tarefas do crontab -l , substitui a da linha escolhida e joga para exportar
	cat $fixtsk | sed -e "3s:.*:$cont:" > $tmptsk

        sudo crontab $tmptsk

	dialog --title 'Agendado' --textbox $tmptsk 0 0

	AgendarBackup
}

function apaga() {

	clear;
        local tmptsk="/tmp/crontasks.temp"
        local fixtsk="/tmp/fixcrontasks.temp"
        local SelectTsk="/tmp/selectfixcrontasks.temp"
	local escolha="/tmp/select.temp"

	#salva tarefas existentes
        sudo crontab -l > $fixtsk
	#Numera para facilitar selecao
	sudo crontab -l | nl -nln -ba > $SelectTsk

	#Mostra em Dialog a lista numerada e dah opcao de selecionar
	dialog --title "Selecione a tarefa" --begin 3 3 --textbox $SelectTsk 20 100 --and-widget --begin 20 30 \
		--title "Apagar a tarefa" --inputbox "Numero" 10 48 2>$escolha

	keys=$?
	case $keys in
	1)  # Cancel.
		return;;
	255) # ESC.
		return;;
	esac
					
	num=$(cat $escolha)

	linha=$(awk NR==$num $fixtsk)

	#pega as tarefas do crontab -l , substitui a da linha escolhida e joga para exportar

	cat $fixtsk | sed -e "${num}d" > $tmptsk

	dialog --title 'Tarefas Restantes' --textbox $tmptsk 0 0;

        sudo crontab $tmptsk

	dialog --msgbox "Tarefa $num - $linha foi deletada" 0 0;

	AgendarBackup


}



function AgendarBackup()
{
	clear;

	local LastModulo="/tmp/lastmodulo.log"

	local menuAge=$(dialog --menu "Modulo Agendamento" 20 35 15 \
	1 "Agendar  " \
	2 "Apagar Agendamento" \
	3 "Editar Agendamento" \
	9 "Voltar        " --stdout)
	
    	
	case $menuAge in		
	
		1) 
			agenda
			;; 
		2) 
			apaga
			;;
		3) 
			edita
			;;

		9)  Menu
			;;

		*) echo "Menu Inválido!" ;;

	esac

	Menu
}



function Menu()
{
	clear

	local menuBackup=$(dialog --menu "Modulo Backup" 20 35 15 \
	1 "Backup Remoto " \
	2 "Agendar Backup" \
	3 "Ver Dir Modulo Backup" \
	9 "Voltar        " --stdout)
	
    	
	case $menuBackup in		
	
		1) 
			BackupRemoto
			;; 
		2) 
			AgendarBackup
			;;
		3)
			VisualizarBackup
			;;	

		9)  ./Main.sh
			;;

		*) echo "Menu Inválido!" ;;

	esac
}

function Iniciar(){

	#BackupsDatabase="ListaBackups.txt"	
	#ServidoresDatabase="ListaServers.txt"
	#local serverOrigem="serv1@10.30.3.12"
	#local serverDestino="serv2@10.30.3.5"
	Menu
}

Iniciar
