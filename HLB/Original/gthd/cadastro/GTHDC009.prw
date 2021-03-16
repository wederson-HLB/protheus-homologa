#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTHDC009
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina de controle de Atualização noturna.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
User Function GTHDC009()
*----------------------*
Local aCores    := {{"Z12->Z12_STATUS == '1'","BR_VERDE"   },; //Em Aberto
					{"Z12->Z12_STATUS == '2'","BR_VERMELHO"},; //Concluido
				    {"Z12->Z12_STATUS == '3'","BR_PRETO"   },; //Cancelado
				    {"Z12->Z12_STATUS == '4'","BR_AMARELO" }} //Em Atendimento

Private cCadastro  := "Solicitação de Atualização"
Private aIndexZ12 := {}
Private aRotina	  := {}

Private lLider	  := ValLogin()
                          
aAdd(aRotina, { "Pesquisar"		,"AxPesqui"  , 0, 1})
aAdd(aRotina, { "Visualizar"	,"AxVisual"  , 0, 2})
aAdd(aRotina, { "Nova"			,"U_HDC009N" , 0, 3})
aAdd(aRotina, { "Cancelar"		,"U_HDC009C" , 0, 4})

If lLider
	aAdd(aRotina, { "Aprova/Rejeita"		,"U_HDC009A" , 0, 5})
EndIf
aAdd(aRotina, { "Legenda"		,"U_HDC009L" , 0, 6})

//Filtro para exibição dos chamados.
U_HDC009Fil(.F.,"Z12",@aIndexZ12)

//Define a tecla F12 para chamar a tela de filtro.
SetKey(VK_F12,{|| U_HDC009Fil(.T.,"Z12",@aIndexZ12)} )


//Exibe o browse.
mBrowse( 6,1,22,75,"Z12",,,,,,aCores)

Return .T.

/*
Funcao      : HDC009N
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Nova Solicitação.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*--------------------------------------*
USer Function HDC009N(cAlias,nReg,nOpc)
*---------------------------------------*
Local nOpca := 0

Local aCpos     := {}
Local aCposEdit := {}
Local aCposNot  := {}
Local aButtons	:= {}
Local aParam    := {}

Private lInclui := .T.

Private cDesTpMov := "Nova Solicitação de Atualização"

//Define os campos que não serão exibidos na tela
aCposNot := {"Z12_STATUS","Z12_USER","Z12_DTUSER","Z12_HRUSER"}

//Carrega os campos que serão exibidos na tela (capa).
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If !(SX3->X3_CAMPO $ Right(cAlias,2)+"_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
		If aScan(aCposNot,AllTrim(SX3->X3_CAMPO)) == 0
			aAdd(aCpos,SX3->X3_CAMPO)
		EndIf
	EndIf		 
	SX3->(DbSkip())
EndDo

aAdd(aCpos,"NOUSER")

//Define os campos que serão editaveis
aCposEdit := aClone(aCpos)

//Exibe a tela de inclusão
nOpca := AxInclui(cAlias,,3,aCpos,,aCposEdit,,,,aButtons,aParam,,,.T.)

Return Nil      
                                                                      
/*                                                                    
Funcao      : HDC009C
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Cancelar atividade.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-------------------------------------*
USer Function HDC009C(cAlias,nReg,nOpc) 
*-------------------------------------*            
(cAlias)->(DbGoTo(nReg))              

If ((cAlias)->Z12_STATUS <> "1" .And. !lLider) .Or. (cAlias)->Z12_STATUS == "2" .or. (cAlias)->Z12_STATUS == "3"
	MsgInfo("Status ou permissão não permite cancelar Solicitação!","Grant Thornton Brasil.")
	Return .T.
EndIf

If ALLTRIM(UPPER(Z12->Z12_USER)) <> ALLTRIM(UPPER(cUserName))
	MsgInfo("Solicitação so pode ser cancelada pelo solicitante!","Grant Thornton Brasil.")
	Return .T.
EndIf

If MsgYesNo("Deseja Realmente cancelar a tarefa selecionada?","Grant Thornton Brasil.")
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->Z12_STATUS := "3"
	(cAlias)->Z12_HIST := (cAlias)->Z12_HIST+"Cancelado por "+cUserName+" Data/hora:"+DtoC(dDataBase)+"-"+Time()+CHR(13)+CHR(10)
	(cAlias)->(MsUnlock())
EndIf

Return .T.          

/*                                                                    
Funcao      : HDC009A
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Aprovar atividade.
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-------------------------------------*
USer Function HDC009A(cAlias,nReg,nOpc) 
*-------------------------------------*            
Local nStatus := 1
Local cGet1 := Space(50)
Local lOk := .F.

If (cAlias)->Z12_STATUS <> "1" .or. !lLider
	MsgInfo("Status ou permissão não permite Aprovação da Solicitação!","Grant Thornton Brasil.")
	Return .T.
EndIf

aButtons := {{"BSTART",{|| U_AprovaTask(cAlias,nReg,nOpc)},"Aprovar"},;
			 {"BEND",{|| U_RejeitaTask(cAlias,nReg,nOpc)},"Rejeitar"};
			}

AxVisual(cAlias,nReg,2,,,,,aButtons)
        
Return .T.
/*                                                                    
Funcao      : AprovaTask
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : 
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-----------------------------------------*
User Function AprovaTask(cAlias,nReg,nOpc) 
*-----------------------------------------*
If (cAlias)->Z12_STATUS <> "1" .or. !lLider
	MsgInfo("Status ou permissão não permite Aprovação da Solicitação!","Grant Thornton Brasil.")
	Return .T.
EndIf
(cAlias)->(DbGoTo(nReg)) 
(cAlias)->(RecLock(cAlias,.F.))
(cAlias)->Z12_STATUS := "4"
(cAlias)->Z12_HIST := (cAlias)->Z12_HIST+"Aprovado por "+cUserName+" Data/hora:"+DtoC(dDataBase)+"-"+Time()+CHR(13)+CHR(10)
(cAlias)->(MsUnlock())
Return .T.
                        
/*                                                                    
Funcao      : RejeitaTask
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : 
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*-----------------------------------------*
User Function RejeitaTask(cAlias,nReg,nOpc)
*-----------------------------------------*
Local cGet1 := Space(60)
Local cHist := ""
Local cMsg := ""

If (cAlias)->Z12_STATUS <> "1" .or. !lLider
	MsgInfo("Status ou permissão não permite Rejeição da Solicitação!","Grant Thornton Brasil.")
	Return .T.
EndIf    

oDlg1      := MSDialog():New( 256,322,369,1017,"Grant Thornton Brasil.",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 020,004,{||"Motivo:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      := TGet():New( 032,004,{|u|if(Pcount()>0,cGet1:=u,cGet1)},oDlg1,328,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oSBtn1     := SButton():New( 008,304,1,{|| oDlg1:end()},oDlg1,,"", )

oDlg1:Activate(,,,.T.)

cHist := "Rejeitado por "+cUserName+" Data/hora:"+DtoC(dDataBase)+"-"+Time()+CHR(13)+CHR(10)
cHist += "   Motivo: "+ALLTRIM(cGet1)+CHR(13)+CHR(10)

(cAlias)->(DbGoTo(nReg)) 
(cAlias)->(RecLock(cAlias,.F.))
(cAlias)->Z12_STATUS := "3"             
(cAlias)->Z12_HIST := (cAlias)->Z12_HIST+cHist+CHR(13)+CHR(10)
(cAlias)->(MsUnlock())

Z03->(DbGoTop())
While Z03->(!EOF())
	If ALLTRIM(UPPER(Z03->Z03_NOME)) == ALLTRIM(UPPER(Z12->Z12_USER))
		If !EMPTY(UsrRetMail(Z03->Z03_ID_PSS ))
		
			cMsg := ""
			cMsg += "Atualização:"+ALLTRIM(Z12->Z12_CODIGO)+CHR(13)+CHR(10)
			cMsg += "Rejeitada por:"+ALLTRIM(cUserName)+CHR(13)+CHR(10)
			cMsg += "Motivo: "+ALLTRIM(cGet1)+CHR(13)+CHR(10)
			
			oEmail          := DEmail():New()
			oEmail:cFrom   	:= "totvs@br.gt.com"
			oEmail:cTo		:= PADR(ALLTRIM(UsrRetMail(Z03->Z03_ID_PSS )),200)
			oEmail:cSubject	:= padr("REJEICAO - Atualizacao noturna - '"+Z12->Z12_CODIGO+"'",200)
			oEmail:cBody   	:= cMsg
			oEmail:Envia()
			
			Exit
		EndIf
	EndIf
	Z03->(DbSkip())
EndDo           

Return .T.
 

/*                                                                    
Funcao      : HDC009L
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Legenda
Autor       : Jean Victor Rocha	
Data/Hora   : 
*/
*----------------------*
USer Function HDC009L() 
*---------------------*  
Local aLegenda := {	{"BR_VERDE"   ,"Aberto"},;
		   			{"BR_VERMELHO","Encerrado"},;
					{"BR_PRETO"   ,"Cancelado"},;
				 	{"BR_AMARELO" ,"Em Atendimento"}} 
				 	
BrwLegenda(cCadastro, "Legenda", aLegenda)
Return .T.

/*
Funcao      : ValLogin
Parametros  : Nenhum
Retorno     : 
Objetivos   : Verifica se o usuário logado possui permissão para acessar a rotina.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------*
Static Function ValLogin()
*------------------------*  
Local lRet := .F.

Local cCodUsr := RetCodUsr()

Z03->(DbSetOrder(2))
If Z03->(DbSeek(xFilial("Z03")+cCodUsr))
	If Z03->Z03_TIPO == "L" //Líder
		lRet := .T.	
	EndIf		
EndIf

Return lRet

/*
Funcao      : HDC009Fil
Parametros  : lExibe : Indica se a tela de parametros será exibida
Retorno     : Nil
Objetivos   : Tratamento de filtro para mBrowse.
Autor       : Jean Victor Rocha
Data/Hora   :
*/
*------------------------------------------------*
User Function HDC009Fil(lExibe,cAlias,aIndexZ12)
*------------------------------------------------*
Local cCondFil := ""
Local cCodUsr  := ""
Local cArea    := (cAlias)->(GetArea())

//Inicializa as variaveis de pergunta.
Pergunte("GTHD003",lExibe,"Filtro de exibição")

//Filtro de data
cCondFil += "DtoS(Z12_DATA) >= '" +DtoS(mv_par01)+"'" //Data Inicial

If !EMPTY(mv_par02)
	cCondFil += " .AND. "
	cCondFil += "DtoS(Z12_DATA) <= '" +DtoS(mv_par02)+"'" //Data Final
EndIf

//Filtro de codigo da empresa
cCondFil += " .AND. "
cCondFil += "Z12_EMP >= '" +mv_par03+"'" //Empresa De:

If !EMPTY(mv_par04)
	cCondFil += " .AND. "
	cCondFil += "Z12_EMP <= '" +mv_par04+"'" //Empresa Ate:
EndIf

//Exibe apenas os chamados do usuário logado.
If mv_par07 == 2
	Z03->(DbSetOrder(2))
	If Z03->(DbSeek(xFilial("Z03")+RetCodUsr()))
		cNomeUsr := ALLTRIM(UPPER(Z03->Z03_NOME))
	EndIf
	cCondFil += " .AND. "
	cCondFil += " ALLTRIM(Z12_USER) == '"+cNomeUsr+"'"
EndIf

//Verifica se o filtro foi reformulado.                      
If lExibe
	// Deleta o filtro anterior utilizado na função FilBrowse
	EndFilBrw(cAlias,aIndexZ12)	
EndIf

//Determina o novo filtro
bFiltraBrw := {|| FilBrowse(cAlias,@aIndexZ12,@cCondFil)}

//Atualiza o MBrowse.
Eval(bFiltraBrw)

RestArea(cArea)

(cAlias)->(DbGoTop())

Return Nil