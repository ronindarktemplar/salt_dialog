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

function Inter()
{
	clear
	DEFAULT="0";
    	local todialog=/tmp/ListaInterpretadores.txt
	DEFAULT="minion1";
	mymini=${1-$DEFAULT}

    dialog --msgbox "Interpretadores em $mymini" 0 0

    echo -e "$(sudo salt $mymini cmd.run "cat /etc/shells | grep -v ^#")" > $todialog

    local serverinters=$(cat $todialog | sed -e 1d)

    myescolha=$(dialog --stdout --menu 'Escolha o interpretador de comandos:' 0 0 0 \
	    `
            for x in $serverinters; do
		    echo " "$x" Escolha-me ";
	    done;
    `);
    #Valida se houve uma selecao de usuario ou nao
    if [ $? -eq 1 ]; then
	    dialog --cr-wrap --sleep 2 --title 'Tente Novamente' --infobox "Nenhum escolhido" 5 17
		eval "$2=/bin/bash"
		Menu;
    	else
		dialog --cr-wrap --sleep 2 --infobox "Escolhido: $myescolha" 0 0
		eval "$2=$myescolha"
    fi

}


function SelectUser()
{    
	clear;
	local todialog=/tmp/RespToDialog.txt
	local todialog2=/tmp/RespTwoDialog.txt
	#Oferece lista de usuarios do minion to Edit/Delete
	DEFAULT="0";
	DEFAULT="minion1";
	mymini=${1-$DEFAULT}

	dialog --msgbox "Usuarios em $mymini" 0 0
	#    awk -F: '($3 >= 1000) {printf "%s:%s\n",$1,$3}' /etc/passwd
	#    cut -d: -f1,3 /etc/passwd

	echo -e "$(sudo salt $mymini cmd.run "cut -d: -f3,1 /etc/passwd")" > $todialog
	echo -e "$(cat $todialog | tr -s [:space:] | tr ':' ' ' | sed -e 1d | awk '{ print $2 " " $1}' )" > $todialog2


grpusers=$(dialog --stdout --radiolist 'Grupo'  0 0 0   \
            comuns  'usuários comuns    '  on  \
            sistema 'usuários de sistema'  off \
            todos   'todos os usuários  '  off);
case $grpusers in
	"comuns")
		#echo "comunas"
		local serverinters=$(cat $todialog2 | grep  [0-9][0-9][0-9][0-9] )
		;;
	"sistema")
		#echo "sys users"
		local serverinters=$(cat $todialog2  | grep -v [0-9][0-9][0-9][0-9] )
		;;
	"todos")
		#echo "all"
	    	local serverinters=$(cat $todialog2 | sort -n )
		;;
	*)
		echo "Menu Inválido!"
	       	;;

esac


    myescolha=$(dialog --stdout --menu 'Escolha o usuario:' 0 0 0 \
	    `
            for x in $serverinters; do
		    echo " $x ";
	    done;
    `);
    #Valida se houve uma selecao de usuario ou nao
    if [ $? -eq 1 ]; then
	    dialog --cr-wrap --sleep 2 --title 'Tente Novamente' --infobox "Nenhum escolhido" 5 17
		eval "$2=null"
		Menu;
    	else
		dialog --cr-wrap --sleep 2 --infobox "Escolhido: $myescolha" 0 0
		eval "$2=$myescolha"
    fi
   
}



function ListarUsuarios()
{

    local listusers=/tmp/ListaUsers.txt

    IPeUser mini

    echo -e "$(sudo salt $mini cmd.run "cat /etc/passwd | cut -d ':' -f 1")" > $listusers
    
    #dialog --title 'Listagem dos usuários' --textbox $listusers 0 0
    dialog --title 'Listagem dos usuários' --textbox /tmp/ListaUsers.txt 20 50

    rm $listusers


    Menu
}


function CriarUsuario()
{    
    clear;

    IPeUser mini

    Nuser=$(dialog --stdout --inputbox 'Nome de login - sem espacos' 0 0)
    FNuser=$(dialog --stdout --inputbox 'Nome completo' 0 0)
    local todialog=/tmp/RespToDialog.txt

    Inter $mini Interpretador

    #parametro -m do useradd cria o diretorio /home/$Nuser
    #sudo salt user.add $Nuser
    #sudo salt user.chshell $Nuser $Interpretador
    #sudo salt cmd.run "sudo useradd $Nuser -m -s $Interpretador"
    echo -e "$(sudo  salt $mini state.single user.present name=$Nuser fullname="$FNuser" home=/home/$Nuser shell=$Interpretador)" 1> $todialog
    dialog --textbox $todialog 0 0
 
    Menu
}



function ModificarUsuario()
{    
	clear;

	IPeUser mini

	SelectUser $mini Nuser

	#informa user a alterar
	#Nuser=$(dialog --stdout --inputbox 'Informe o usuario:' 0 0)
        #informa novo nome para o user
	NewNuser=$(dialog --stdout --inputbox 'Informe o novo nome do usuario:' 0 0)	

    	local todialog=/tmp/RespToDialog.txt
        
	Inter $mini Interpretador
		

	#altera nome do /home/$Nuser para /home/$NewNuser

    
	dialog --msgbox "Criarah copia de /home/$Nuser para /home/$NewNuser" 0 0
	echo -e "Criando Copia de diretorio home \n" > $todialog
	echo -e "$(sudo salt $mini user.chhome $Nuser /home/$NewNuser True)" 1>> $todialog
	dialog --textbox $todialog 0 0

	#altera nome do usuário a partir daqui $NewNuser jah eh o nome do usuario
	echo -e "Renomenado Usuario \n" > $todialog
    	echo -e "$(sudo salt $mini user.rename $Nuser $NewNuser)" 1>> $todialog
	dialog --textbox $todialog 0 0


	#altera nome completo
	echo -e "Alterando nome completo \n" > $todialog
	echo -e "$(sudo salt $mini user.chfullname $NewNuser "$NewNuser")" 1>> $todialog
	dialog --textbox $todialog 0 0
	
	# altera o interpretador
	echo -e "Mudando Interpretador \n" > $todialog
	echo -e "$(sudo salt $mini user.chshell $NewNuser $Interpretador)" 1>> $todialog
	dialog --textbox $todialog 0 0

	dialog --msgbox "Usuário $Nuser agora é $NewNuser " 0 0 

	Menu
}

function ExcluirUsuario()
{    
    clear;


    local todialog=/tmp/RespToDialog.txt

    IPeUser mini

    SelectUser $mini UserToDel

    #poderia pegar uma lista dos user (nao de sistema) do server escolhido dar 
    #a opção de escolher e não digitar

    ##aqui nao precisaria da lista de users
    ##UserToDel=$(dialog --stdout --inputbox 'Informe o usuario para exclusao:' 0 0)
    #echo -e "Aplicando User Absent para $UserToDel ... \n" > $todialog
    #echo -e "$(sudo salt $mini state.single user.absent name=$UserToDel)" 1>> $todialog
 
    ##aqui precisaria da lista de users   
    echo -e "Aplicando user.delete para $UserToDel ... \n" > $todialog
    echo -e "$(sudo salt $mini user.delete $UserToDel remove=False force=False)" 1>> $todialog

    
    dialog --textbox $todialog 0 0

    dialog --msgbox "Usuário $UserToDel removido, porém diretório home e arquivos foram mantidos." 0 0
    
    Menu
}

function ProcurarUsuario()
{    
    clear;

    local finduser="/tmp/FindUser.txt"

    IPeUser myminion
    
    #Obtem Usuário ou parcial do nome
    local PesqUser=$(dialog --title "Procuar Usuário"  --stdout --inputbox 'Nome' 0 0)

    #dialog --sleep 5 --infobox "Cmd: sudo salt $myminion file.grep /etc/passwd $PesqUser --out=raw" 0 0 

    echo -e "$(sudo salt $myminion file.grep /etc/passwd $PesqUser )" > $finduser
    # local result=$(cat $finduser | cut -d\' -f14)
    # dialog --msgbox "Chave: $PesqUser \nResultado:\n$result" 0 0 

    #echo -e "$(sudo salt $myminion user.info $PesqUser)" > $finduser

    dialog --textbox $finduser 0 0

    Menu
}

function Menu()
{
    clear

menuUsuario=$(dialog --menu "Menu/Users" 20 35 15 \
1 "List  Users" \
2 "Add    User" \
3 "Del    User" \
4 "Modify User" \
5 "Search User" \
9 "Exit" --stdout)



    
        
    case $menuUsuario in        
        1) 
            ListarUsuarios
            ;;

        2) 
            CriarUsuario
            ;; 

        3) 
            ExcluirUsuario
            ;;

        4)    
            ModificarUsuario
            ;;

        5)    
            ProcurarUsuario
            ;;


        9)      ./Main.sh;;

        

        *) echo "Menu Inválido!" ;;

    esac
}

function Iniciar(){

    
    
    Menu
}

Iniciar
