#Include "protheus.ch"              

/*
Funcao      : GTGEN042()
Objetivos   : Rotina para o preenchimento do número do Fluig.
Autor       : Richard Steinhauser Busso
Data/Hora   : 23/10/2017
Obs         : Alteração só será permitida na Inclusão.   
*/

User Function GTGEN042()
Local oButton1, oGet1, oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8 
Local oGroup1, oGroup2
Local lFluig := SuperGetMv("MV_P_00109",.T.,.F.) 
Local aAreaSD1 := GetArea()  

If !lFluig 
	Return
Endif 

If IsInCallStack("U_GTGEN047") .Or. IsInCallStack("U_Q6EST001")
   Return                                                                 	
EndIf

Private nNumFluig := 0
Private cNum := SF1->F1_DOC
Private cSer := SF1->F1_SERIE
Private cFor := SF1->F1_FORNECE
Private cLoj := SF1->F1_LOJA
Private cTipoNf := SF1->F1_TIPO  
Private cFilDoc := SF1->F1_FILIAL

If SD1->(FieldPos("D1_P_NUMFL"))>0
	nNumFluig := posicione("SD1",1,xFilial("SD1")+cNum+cSer+cFor+cLoj,"D1_P_NUMFL")  //SD1->D1_P_NUMFL	
Else
	MsgInfo("O campo de Numero do Fluig não existe.","Aviso")
	Return
Endif
	
Static oDlg
  
  DEFINE MSDIALOG oDlg TITLE "Número Fluig" FROM 000, 000  TO 245, 285 COLORS 0, 16777215 PIXEL
    //Grupo dados da NF
    @ 004, 004 GROUP oGroup1 TO 040, 140 OF oDlg COLOR 0, 16777215 PIXEL
    @ 008, 010 SAY oSay4 PROMPT "Documento : "+alltrim(cNum)+"" SIZE 060, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 018, 010 SAY oSay5 PROMPT "Série : "+alltrim(cSer)+"" SIZE 060, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 010 SAY oSay6 PROMPT "Fornecedor : "+alltrim(cFor)+"" SIZE 060, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 070 SAY oSay7 PROMPT "Loja : "+alltrim(cLoj)+"" SIZE 060, 008 OF oDlg COLORS 0, 16777215 PIXEL
    //Grupo Fluig
    @ 044, 004 GROUP oGroup2 TO 100, 140 OF oDlg COLOR 0, 16777215 PIXEL
    @ 050, 010 SAY oSay1 PROMPT "Favor informar o número da solicitação do Fluig, " SIZE 123, 009 OF oDlg COLORS 0, 16777215 PIXEL
    @ 060, 010 SAY oSay2 PROMPT "este será replicado para todos os itens da NF e" SIZE 123, 009 OF oDlg COLORS 0, 16777215 PIXEL
    @ 070, 010 SAY oSay3 PROMPT "será utilizado para consultas no próprio Protheus." SIZE 123, 009 OF oDlg COLORS 0, 16777215 PIXEL
	//Grupo Dados Fluig
    @ 083, 015 SAY oSay8 PROMPT "Num. Fluig :" SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 083, 049 MSGET oGet1 VAR nNumFluig SIZE 051, 010 OF oDlg COLORS 0, 16777215 PIXEL PICTURE "@E 99999999"
    @ 105, 045 BUTTON oButton1 PROMPT "Confirmar" Action ExecNFluig() SIZE 054, 011 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aAreaSD1)
Return

/*
Funcao      : ExecNFluig()
Objetivos   : Rotina que executa a alteração do numero do Fluig em cada item do documento de entrada.
Autor       : Richard Steinhauser Busso
Data/Hora   : 23/10/2017
*/

Static Function ExecNFluig()
Local strUpd := ""
Local aArea := GetArea()  

dbSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->(dbSeek(xFilial("SD1")+cNum+cSer+cFor+cLoj))
     
	While !SD1->(EOF()) .and. SD1->D1_DOC = cNum .and. SD1->D1_SERIE = cSer .and. SD1->D1_FORNECE = cFor .and. SD1->D1_LOJA = cLoj
			SD1->(RECLOCK("SD1",.F.))
				SD1->D1_P_NUMFL := nNumFluig
			SD1->(MSUNLOCK())
			SD1->(dbSkip())
		Loop   	
    Enddo
	//Update direto no banco para atualiza os campos no SE2	
	TcSqlExec( "UPDATE " + RetSqlName( "SE2" ) + " SET E2_P_NUMFL = " + Alltrim(cValtoChar(nNumFluig)) +;
			   " WHERE E2_FILORIG = '" + cFilDoc + "' AND E2_NUM = '" + cNum + "' AND E2_PREFIXO = '" + cSer + "' AND " +;
			   " E2_FORNECE = '" + cFor + "' AND E2_LOJA = '" + cLoj + "' " )
			
RestArea(aArea)
	
oDlg:End()

Return(.T.)
