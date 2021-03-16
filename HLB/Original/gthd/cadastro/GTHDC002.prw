#include "totvs.ch"   
#Include "TBICONN.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GTHDC002  �Autor  Eduardo C. Romanini  � Data �  21/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de cadastro de empresas                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grant Thornton                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

*----------------------*
User Function GTHDC002()
*----------------------* 
Local cAlias := "Z04"

Local aCores    := {{"Z04->Z04_SIGMAT == 'S'","BR_VERDE"    },;	//Empresa cadastrada no Sigamat
					{"Z04->Z04_SIGMAT == 'N'","BR_VERMELHO" }}	//Empresa sem cadastrado no Sigamat

Private cCadastro := "Cadastro de Empresas"

Private aRotina := {}

//Rotinas do Browse.
aAdd(aRotina,{"Pesquisar"   	  ,"AxPesqui"    ,0,1})
aAdd(aRotina,{"Visualizar"	      ,"AxVisual"    ,0,2})
aAdd(aRotina,{"Incluir"	          ,"U_HDC002Inc" ,0,3})
aAdd(aRotina,{"Alterar"	          ,"AxAltera"    ,0,4})
aAdd(aRotina,{"Excluir"	          ,"AxDeleta"    ,0,5})

aAdd(aRotina,{ "Importa  Empresas","U_GTHDAEMP"  ,0,3}) //Importa��o de empresas do sigamat.
aAdd(aRotina,{ "Atu.Cod.Telefone" ,"U_GTSA1COD"  ,0,3}) //Atualiza��o de c�digo. 
aAdd(aRotina,{ "Atualiza Servidor","U_HDC002Serv",0,3}) //Atualiza��o de servidor. 
aAdd(aRotina,{ "Atualiza Sigamat" ,"U_HDC002Sig" ,0,3}) //Atualiza��o de cadastro no sigamat.

aAdd(aRotina,{ "Legenda"          ,"U_HDC002Leg" ,0,6}) //Legenda

//Exibi��o do browse
dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

Return                               

/*
Funcao      : HDC002Leg
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe a legenda do browse
Autor       : Eduardo C. Romanini
Data/Hora   : 19/03/13
*/
*-----------------------*
User Function HDC002Leg()
*-----------------------*
Local aLegenda := {	{"BR_VERDE"   ,"Cadastrada no SigaMat" },;
					{"BR_VERMELHO","N�o cadastrada no SigaMat"} }
		

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil

/*
Funcao      : HDC002Inc
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Inclus�o de empresas
Autor       : Eduardo C. Romanini
Data/Hora   : 19/03/2013
*/
*---------------------------------------*
User Function HDC002Inc(cAlias,nReg,nOpc)
*---------------------------------------*
Local nOpcao := 0

Local aParam := {}

//Adiciona codeblock a ser executado dentro da rotina AxInclui
aAdd( aParam,  {|| PreTela() })	//Antes da abertura da tela
aAdd( aParam,  {|| .T.})    	//Ao clicar no botao ok
aAdd( aParam,  {|| })    	 	//Durante a transacao
aAdd( aParam,  {|| })			//Termino da transacao

nOpcao := AxInclui(cAlias,nReg,nOpc,,,,,,,,aParam)

Return

/*
Funcao      : HDC002Serv
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Confirma��o de atualiza��o do servidor das empresas
Autor       : Eduardo C. Romanini
Data/Hora   : 12/03/2013
*/
*-----------------------*
User Function HDC002Serv
*-----------------------*                   
//MSM - 05/11/2013 - Alterado para poder executar esta rotina via job.
if select("SX3")>0 //Se n�o for schedule

	If MsgYesNo("Confirma a atualiza��o de servidor de todas as empresas?","Aten��o")
		Processa({ |lEnd| AtuServ(.F.) })
	EndIf

else //Se for via schedule

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "01" Filial "01"
	
	AtuServ(.T.)
		 
endif

Return Nil                 


/*
Funcao      : AtuServ
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Processamento de atualiza��o do servidor
Autor       : Eduardo C. Romanini
Data/Hora   : 12/03/2013
*/
*-------------------------------*
Static Function AtuServ(lEhSched)
*-------------------------------*

//Posiciona na primeira empresa
Z04->(DbSetOrder(1))
Z04->(DbGoTop())

if !lEhSched  //se n�o for schedule
	//Inicializa controle para movimenta��oo do cursor
	ProcRegua( Z04->(RecCount()) )
endif

//Looping em todas as empresas
While Z04->(!EOF())

	if !lEhSched //se n�o for schedule   
		//Movimenta a r�gua
		IncProc()
    endif

	If !Empty(Z04->Z04_AMB)
	
		//Posiciona no cadastro de Ambientes X Empresas
	    Z10->(DbSetOrder(1))
	    If Z10->(DbSeek(xFilial("Z10")+Z04->Z04_AMB+Z04->Z04_RELEAS))
			
			//Atualiza a empresa com o Servidor e a porta
			Z04->(RecLock("Z04"),.F.)
			
			Z04->Z04_SERVID := Z10->Z10_SERVID
			Z04->Z04_PORTA  := Z10->Z10_PORTA
	
			Z04->(MsUnlock())		    	
	
		EndIf	
	EndIf
			
    Z04->(DbSkip())
EndDo

Return Nil                                                   

/*
Funcao      : PreTela
Parametros  : nOpc: Op��o Selecionada no Browse
Retorno     : Nil
Objetivos   : Fun��o executada antes da abertura da tela
Autor       : Eduardo C. Romanini
Data/Hora   : 19/03/2013
*/
*---------------------------*
Static Function PreTela(nOpc)
*---------------------------*

Processa({ |lEnd| GeraCodEmp() })

Return Nil                      

/*
Funcao      : GeraCodEmp
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Exibe o pr�ximo c�digo de empresa dispon�vel
Autor       : Eduardo C. Romanini
Data/Hora   : 19/03/2013
*/
*--------------------------*
Static Function GeraCodEmp()
*--------------------------*
Local lLivre 	:= .F.

Local cCodigo 	:= "01" 

Local nVld		:= 1

Z04->(DbSetOrder(1))

//Inicializa controle para movimenta��oo do cursor
ProcRegua( Z04->(RecCount()) )

//Looping enquanto n�o encontrar o pr�ximo n�mero livre.
While !lLivre
	If VldCod(cCodigo)//Valida se encontra o codigo na tabela
	//If Z04->(DbSeek(xFilial("Z04")+cCodigo))//Pesquisa o c�digo na tabela de empresas - RRP - 20/08/2014 - Ajuste para maior combina��o de c�digos.
		cCodigo := Soma1(cCodigo,0,.F.,.T.)
	//Verifica se encontrou um c�digo livre
	Else//If cCodigo <> 'ZZ'
		lLivre := .T.
	//Teste para quando n�o encontrar c�digo livre.
	//Else
		//Exit
	EndIf
EndDo

If lLivre .and. Len(cCodigo) == 2
	//Grava��o do c�digo danovo empresa
	M->Z04_CODIGO := cCodigo
	M->Z04_CODFIL := "01"	
Else
	MsgInfo("N�o existe c�digo dispon�vel para inclus�o da empresa")
EndIf
 
Return Nil
  
/*
Funcao      : VldCod
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Valida o numero no Z04
Autor       : Jean Victor Rocha
Data/Hora   : 05/05/2015
*/
*-----------------------------*
Static Function VldCod(cCodigo)
*-----------------------------*
Local lRet := .T.
Local cQry := ""

cQry += " SELECT COUNT(*) AS NUMERO
cQry += " FROM "+RETSQLNAME("Z04")
cQry += " WHERE D_E_L_E_T_ <> '*'
cQry += "		AND Z04_CODIGO = '"+cCodigo+"'
cQry += " 		AND LEFT(Z04_AMB,3) not in ('AP7')
    
If select("QRY")>0
	QRY->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "QRY", .F., .F. )

lRet := QRY->NUMERO <> 0

Return lRet

/*
Funcao      : HDC002Sig
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Verifica se as empresas est�o cadastradas no sigamat.
Autor       : Eduardo C. Romanini
Data/Hora   : 19/03/2013
*/
*----------------------*
User Function  HDC002Sig
*----------------------*

If MsgYesNo("Confirma a atualiza��o de sigamat de todas as empresas?","Aten��o")
	Processa({ |lEnd| AtuSigaMat() })
EndIf

Return Nil

/*
Funcao      : AtuSigaMat
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Atualiza o cadastro de empresas, de acordo com o sigamat.
Autor       : Eduardo C. Romanini
Data/Hora   : 20/03/2013
*/
*------------------------*
Static Function AtuSigaMat
*------------------------*
Local cAmb    := ""
Local cEmpBase:= ""

Local nPos := 0
Local nI   := 0
Local nX   := 0

Local aEmp := {}

//Posiciona no primeiro ambiente
Z10->(DbSetOrder(1))
Z10->(DbGoTop())

//Inicializa controle para movimenta��oo do cursor
ProcRegua( Z10->(RecCount()) )

//Looping em todos os ambientes
While Z10->(!EOF())

	//Movimenta a r�gua
	IncProc("Recuperando sigamat do ambiente " + AllTrim(Z10->Z10_AMB))

	//Tratamento para a conex�o
	If  AllTrim(Z10->Z10_AMB) == "GTCORP"   	
		cAmb := "GTCORP11"
		cEmpBase := "Z4"
	Else
		cAmb := AllTrim(Z10->Z10_AMB)
		cEmpBase := "YY"
	EndIf	

	//RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil) 
	oServ:=  RpcConnect(AllTrim(Z10->Z10_SERVID),Val(Z10->Z10_PORTA),cAmb,cEmpBase,"01")        
	
	If ValType(oServ) == 'O'
		//Retorna as empresas do sigamat
		aAdd(aEmp,oServ:CallProc("U_GTSM0EMP"))

		//Disconecta do servidor
		RpcDisConnect(oServ)
	EndIf
	
	Z10->(DbSkip())	
EndDo

Z04->(DbSetOrder(1))
Z04->(DbGoTop())

//Inicializa controle para movimenta��oo do cursor
ProcRegua( Z04->(RecCount()) )

//Looping em todas as empresas
While Z04->(!EOF())

	//Movimenta a r�gua
	IncProc("Atualizando empresa " + Alltrim(Z04->Z04_NOME))

    //Procura se a empresa est� dentro do array aEmp
    nPos := aScan(aEmp, {|e| aScan(e,{|e| e[1]+e[2] == Z04->(Z04_CODIGO+Z04_CODFIL) } )>0 })

	Z04->(RecLock("Z04",.F.))	    

    If nPos > 0
		Z04->Z04_SIGMAT := "S"
   	Else
		Z04->Z04_SIGMAT := "N"   
    EndIf

	Z04->(MsUnlock())

	Z04->(DbSkip())
EndDo

Return Nil