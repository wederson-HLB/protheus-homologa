#Include 'Totvs.ch'

/*
Funcao      : HHEST003 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gerar tela para gravar número do Protocolo na Capa do Documento de Entrada
Autor       : Renato Rezende
Cliente		: Solaris 
Data/Hora   : 03/03/2017
*/
*--------------------------------------------------------------* 
 User Function HHEST003(nChamada)
*--------------------------------------------------------------*
Local nGet1:= 0
Local oDlg1,oGrp1,oSay1,oGet1,oBtn1,oBtn2 

Private nRotina := nChamada

If SF1->(FieldPos("F1_P_IDPRO"))>0
	nGet1:= SF1->F1_P_IDPRO
Else
	MsgInfo("Empresa não parametrizada para utilizar essa rotina!","HLB BRASIL")
	Return
EndIf

//Definicao do Dialog e todos os seus componentes.
oDlg1      := MSDialog():New( 227,514,352,772,"Cadastro do No. Protocolo",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,040,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 012,020,{||"Num Protocolo:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oGet1      := TGet():New( 020,020,{|u| if(PCount()>0,nGet1:=u,nGet1)},oGrp1,088,008,'9999999999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nGet1",,)
oBtn1      := TButton():New( 044,012,"Salvar",oDlg1,{||  IIF(Empty(nGet1),alert("Preencha o campo código!"),( IIF(MsgYesNo("Deseja realmente salvar este código de Protocolo?"),(SalvaFl(nGet1),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 044,080,"Cancelar",oDlg1,{|| IIF(MsgYesNo("Deseja realmente cancelar?"),oDlg1:end(),) },037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return

/*
Funcao      : SalvaFl()
Objetivos   : Grava em campo customizado no F1 o número do Protocolo
Autor       : Renato Rezende
Data/Hora   : 03/03/2017 
*/
*-------------------------------------*
 Static Function SalvaFl(nGet1)
*-------------------------------------*

RecLock("SF1",.F.)
	SF1->F1_P_IDPRO:=nGet1
MsUnLock()

//nRotina 1 - Menu / nRotina 2 - Rotina Automática
If nRotina == 1
	//Gravar o SE2 se achar o título	
	If SE2->(FieldPos("E2_P_IDPRO"))>0
	
		//Atualiza campo E2_P_IDPRO
		TcSqlExec( "UPDATE " + RetSqlName( "SE2" ) + " SET E2_P_IDPRO = " + Alltrim(cValtoChar(SF1->F1_P_IDPRO)) + " WHERE E2_FILORIG = '" + SF1->F1_FILIAL + "' AND " +;
					"E2_NUM = '" + SF1->F1_DUPL + "' AND E2_PREFIXO = '" + SF1->F1_PREFIXO + "' AND E2_FORNECE = '" + SF1->F1_FORNECE + "' AND E2_LOJA = '" + SF1->F1_LOJA + "' " )

		//RRP - 17/03/2017 - Atualizar campo no SD1
		//Atualiza campo D1_P_IDPRO
		TcSqlExec( "UPDATE " + RetSqlName( "SD1" ) + " SET D1_P_IDPRO = " + Alltrim(cValtoChar(SF1->F1_P_IDPRO)) + " WHERE D1_FILIAL = '" + SF1->F1_FILIAL + "' AND " +;
					"D1_DOC = '" + SF1->F1_DOC + "' AND D1_SERIE = '" + SF1->F1_SERIE + "' AND D1_FORNECE = '" + SF1->F1_FORNECE + "' AND D1_LOJA = '" + SF1->F1_LOJA + "' " )
					
	EndIf
EndIf

Return