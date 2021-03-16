#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"

/*
Funcao      : V5FIN02()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Tela para envio dos titulos baixados para o sistema Sistech
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 23/08/2016
*/

*----------------------------------*
User Function V5FIN002()
*----------------------------------*
Local cTitulo		:= 'Vogel - Envio de titulos ao Sistech'
Local cDescription	:= 'Esta rotina permite enviar os titulos baixados do contas a receber e a pagar, para o sistema Sistech, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private aRotina 	:= MenuDef()
Private cPerg 	 	:= 'V5FIN02'
Private cModLog		:= OAPP:CMODNAME

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )

If !( cEmpAnt $ u_EmpVogel() )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf

AjusSx1()

bProcesso	:= { |oSelf| SelTit( oSelf ) }
oProcess 	:= tNewProcess():New( "V5FIN002" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)

DbSelectArea( 'SE5' )
SET FILTER TO

Return

/*
Função	 : SelTit
Objetivo : Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelTit( oProcess )
*-------------------------------------------------*
Local oColumn
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade

Private cExpAdvPL 	:= ""
Private oMarkB

Pergunte( cPerg , .F. )

dDtIni 	:= MV_PAR01
dDtFim 	:= MV_PAR02

SetKey( VK_F12 , { || Pergunte( 'V5FIN002' , .T. ) } )

//Atualiza o E5_P_REF
If !AtuPRef()
	Return()
EndIf

If cModLog $ "SIGAEST/SIGACOM"
	cExpAdvPL     := 'SE5->E5_FILIAL=="'+xFilial("SE5")+'" .And. SE5->E5_DATA >= dDtIni .And. SE5->E5_DATA <= dDtFim .And. SE5->E5_TIPO == "NF" .And. SE5->E5_P_SISTE <> "S" .And. SE5->E5_RECPAG == "P" .And. SE5->E5_TIPODOC == "BA" .And. SE5->E5_P_REF <> ""'
Else
	cExpAdvPL     := 'SE5->E5_FILIAL=="'+xFilial("SE5")+'" .And. SE5->E5_DATA >= dDtIni .And. SE5->E5_DATA <= dDtFim .And. SE5->E5_TIPO == "NF" .And. SE5->E5_P_SISTE <> "S" .And. SE5->E5_RECPAG == "R" .And. SE5->E5_TIPODOC == "VL" .And. SE5->E5_P_REF <> ""'	
EndIf

oMarkB := FWMarkBrowse():New()
oMarkB:SetOnlyFields( { "E5_HISTOR" } )
oMarkB:SetAlias( 'SE5' )
oMarkB:SetFieldMark( 'E5_OK' )
oMarkB:SetValid( bValid )
	
/*
* Definição das colunas do browse
*/
ADD COLUMN oColumn DATA { || E5_NUMERO		} TITLE "Título"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_P_REF  		} TITLE "Sistech"	 SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_PREFIXO		} TITLE "Prefixo"    SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_PARCELA		} TITLE "Parcela"    SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_TIPO		} TITLE "Tipo"		 SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_DATA		} TITLE "Dt. Baixa"  SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_CLIFOR		} TITLE "Cliente"    SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || E5_LOJA		} TITLE "Loja Cli."  SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( E5_VALOR , X3Picture( 'E5_VALOR' ) )   } 	TITLE "Valor do Título"     SIZE  3 OF oMarkB

/*
* Filtro ADVPL
*/
oMarkB:SetFilterDefault( cExpAdvPL ) 

DbSelectArea( 'SE5' )
SET FILTER TO &( cExpAdvPL ) 

oMarkB:SetAllMark( { || SE5->( DbGoTop() , DbEval( { || RecLock( 'SE5' , .F. ) , E5_OK := oMarkB:Mark() , MSUnlock() } , { || .T. } , { || !Eof() } ) , DbGoTop() , oMarkB:Refresh() ) } )

oMarkB:ForceQuitButton( .T. )
oMarkB:Activate()

Return


/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function MenuDef()
*-------------------------------------------------*
Local aRotina 	:= {}

ADD OPTION aRotina TITLE 'Processar' ACTION 'u_V5FINENV()' OPERATION 10 ACCESS 0 

Return aRotina

/*
Função..........: V5FINENV
Objetivo........: Enviar Log para o Sistech
*/
*-------------------------*
User Function V5FINENV()
*-------------------------*

If cModLog $ "SIGAEST/SIGACOM"
	MsgRun( 'Transmitindo títulos para o Sistech.... favor aguarde' , '' , { || LogPagar() } )
Else
	MsgRun( 'Transmitindo títulos para o Sistech.... favor aguarde' , '' , { || LogReceb() } )
EndIf

Return

/*
Função..........: LogReceb
Objetivo........: Enviar Log para o Sistech
*/
*----------------------------*
 Static Function LogReceb()
*----------------------------*
Local aHeaderLog 	:= { 'EMP','FILIAL','RECPAG','PEDORIGEM','PREFIXO','NUMERO','PARCELA','TIPO','CGC','EMISSAO','VENCTO','VENCREA','VALOR','BAIXA','SALDO','DECRESCIMO','ACRESCIMO' }
Local cArquivo

Local aLog 			:= {}    
Local aAux

Pergunte( 'V5FIN002' , .F. )

SD2->( DbSetOrder( 3 ) ) 
SC5->( DbSetOrder( 1 ) )
SA1->( DbSetOrder( 1 ) )
SF2->( DbGotop() )

cArquivo := 'TITULO_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
Aadd( aLog , { , aHeaderLog } )	                
Aadd( aLog , { cArquivo , {} }  ) 

While SE5->( !Eof() )

	If ( SE5->E5_OK == oMarkB:Mark() )
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))               
		SE1->(DbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ) )//E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->( DbSeek( xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA ) )
		
	    aAux := { 	SM0->M0_CGC ,;
					SE1->E1_FILORIG ,;
					SE5->E5_RECPAG,;
					SE5->E5_P_REF ,;
					SE5->E5_PREFIXO,;
					SE5->E5_NUMERO,;
					SE5->E5_PARCELA,;
					SE5->E5_TIPO,;
					SA1->A1_CGC,;
					DtoC( SE1->E1_EMISSAO ) ,;
					DtoC( SE1->E1_VENCTO ) ,;
					DtoC( SE1->E1_VENCREA ) ,;
					TRANSFORM( SE5->E5_VALOR , "@R 99999999999.99" ) ,;
					DtoC( SE5->E5_DATA ) ,;
					TRANSFORM( SE1->E1_SALDO , "@R 99999999999.99" ) ,;
					TRANSFORM( SE5->E5_VLDECRE , "@R 99999999999.99" ) ,;
					TRANSFORM( SE5->E5_VLACRES , "@R 99999999999.99" ) }
						
		Aadd( aLog[ 2 ][ 2 ] , aAux )					
				  
		
		SE5->( RecLock( 'SE5' , .F. ) )
			SE5->E5_P_SISTE := 'S'
		SE5->( MSUnLock() )
				

	EndIf
	
	SE5->( DbSkip() )	
EndDo

/*
	* Gera arquivo de log e envia ao servidor FTP
*/
If Len( aLog[ 2 ][ 2 ] ) > 0
	u_GerEnvLg( aLog , .F. )
	MsgInfo( 'Processamento realizado com sucesso !' )    
EndIf

SE1->(DbCloseArea())
SC5->(DbCloseArea())
SA1->(DbCloseArea())	

Return

/*
Função..........: LogPagar
Objetivo........: Enviar Log para o Sistech
*/
*----------------------------*
 Static Function LogPagar()
*----------------------------*
Local aHeaderLog 	:= { 'EMP','FILIAL','RECPAG','PEDORIGEM','PREFIXO','NUMERO','PARCELA','TIPO','CGC','EMISSAO','VENCTO','VENCREA','VALOR','BAIXA','SALDO','DECRESCIMO','ACRESCIMO' }
Local cArquivo

Local aLog 			:= {}    
Local aAux

Pergunte( 'V5FIN002' , .F. )

SD2->( DbSetOrder( 3 ) ) 
SC5->( DbSetOrder( 1 ) )
SA1->( DbSetOrder( 1 ) )
SF2->( DbGotop() )

cArquivo := 'TITULO_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
Aadd( aLog , { , aHeaderLog } )	                
Aadd( aLog , { cArquivo , {} }  ) 

While SE5->( !Eof() )

	If ( SE5->E5_OK == oMarkB:Mark() )
		DbSelectArea("SE2")
		SE2->(DbSetOrder(1))               
		SE2->(DbSeek(xFilial("SE2")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ) )//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->( DbSeek( xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA ) )
		
	    aAux := { 	SM0->M0_CGC ,;
					SE2->E2_FILORIG ,;
					SE5->E5_RECPAG,;
					SE5->E5_P_REF ,;
					SE5->E5_PREFIXO,;
					SE5->E5_NUMERO,;
					SE5->E5_PARCELA,;
					SE5->E5_TIPO,;
					SA1->A1_CGC,;
					DtoC( SE2->E2_EMISSAO ) ,;
					DtoC( SE2->E2_VENCTO ) ,;
					DtoC( SE2->E2_VENCREA ) ,;
					TRANSFORM( SE5->E5_VALOR , "@R 99999999999.99" ) ,;
					DtoC( SE5->E5_DATA ) ,;
					TRANSFORM( SE2->E2_SALDO , "@R 99999999999.99" ) ,;
					TRANSFORM( SE5->E5_VLDECRE , "@R 99999999999.99" ) ,;
					TRANSFORM( SE5->E5_VLACRES , "@R 99999999999.99" ) }
						
		Aadd( aLog[ 2 ][ 2 ] , aAux )					
				  
		
		SE5->( RecLock( 'SE5' , .F. ) )
			SE5->E5_P_SISTE := 'S'
		SE5->( MSUnLock() )
				

	EndIf
	
	SE5->( DbSkip() )	
EndDo

/*
	* Gera arquivo de log e envia ao servidor FTP
*/
If Len( aLog[ 2 ][ 2 ] ) > 0
	u_GerEnvLg( aLog , .F. )
	MsgInfo( 'Processamento realizado com sucesso !' )    
EndIf

SE1->(DbCloseArea())
SC5->(DbCloseArea())
SA1->(DbCloseArea())	

Return

/*
Função..........: AjustaSx1
Objetivo........: Cadastrar automaticamente as perguntas no arquivo SX1
*/
*-------------------------------------------------*
Static Function AjusSx1
*-------------------------------------------------*

U_PUTSX1( cPerg ,'01' , 'Da Emissao' ,'Da Emissao'/*cPerSpa*/,'Da Emissao'/*cPerEng*/,'mv_ch1','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR01'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Inicial Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )
U_PUTSX1( cPerg ,'02' , 'Ate Emissao' ,'Ate Emissao'/*cPerSpa*/,'Ate Emissao'/*cPerEng*/,'mv_ch2','D' , 8 ,0 ,0/*nPresel*/,'G'/*cGSC*/,/*cValid*/,/*cF3*/, /*cGrpSxg*/,/*cPyme*/,'MV_PAR02'/*cVar01*/,/*cDef01*/,/*cDefSpa1*/,/*cDefEng1*/,/*cCnt01*/,	/*cDef02*/,/*cDefSpa2*/,/*cDefEng2*/,/*cDef03*/,/*cDefSpa3*/,/*cDefEng3*/,	/*cDef04*/,/*cDefSpa4*/,/*cDefEng4*/,/*	cDef05*/,/*cDefSpa5*/,/*cDefEng5*/,{ "Periodo de Emissao Final Nota Fiscal" }/*aHelpPor*/,/*aHelpEng*/,/*aHelpSpa*/,/*cHelp*/ )

Return 

/*
Função..........: AtuPRef
Objetivo........: Atualiza o E5_P_REF conforme a tabela SE1 ou SE2
*/
*----------------------------*
 Static Function AtuPRef()
*----------------------------*
Local lRet		:= .T.
Local cQuery	:= ""

cQuery:= " UPDATE "+RetSqlName("SE5")+" SET E5_P_REF = P_REF "+CRLF
cQuery+= " 	 FROM "+RetSqlName("SE5")+" "+CRLF
cQuery+= " 	 JOIN ( "+CRLF
cQuery+= " SELECT E1_FILORIG AS FILIAL, E1_CLIENTE AS CLIFOR, E1_LOJA AS LOJA, E1_PREFIXO AS PREFIXO, E1_NUM AS NUM, E1_PARCELA AS PARCELA, E1_TIPO AS TIPO, E1_P_REF AS P_REF, 'SE1' AS TABELA "+CRLF
cQuery+= "  FROM "+RetSqlName("SE1")+" "+CRLF
cQuery+= " WHERE E1_TIPO = 'NF' AND D_E_L_E_T_ <> '*' AND E1_P_REF <> '' "+CRLF
cQuery+= " UNION ALL "+CRLF
cQuery+= " SELECT E2_FILORIG AS FILIAL, E2_FORNECE AS CLIFOR, E2_LOJA AS LOJA, E2_PREFIXO AS PREFIXO, E2_NUM AS NUM, E2_PARCELA AS PARCELA, E2_TIPO AS TIPO, E2_P_REF AS P_REF, 'SE2' AS TABELA "+CRLF
cQuery+= "  FROM "+RetSqlName("SE2")+" "+CRLF
cQuery+= " WHERE E2_TIPO = 'NF' AND D_E_L_E_T_ <> '*' AND E2_P_REF <> '' "+CRLF
cQuery+= " ) AS FINA ON "+RetSqlName("SE5")+".D_E_L_E_T_ <> '*' "+CRLF 
cQuery+= "			AND "+RetSqlName("SE5")+".E5_P_REF = '' "+CRLF
cQuery+= "			AND "+RetSqlName("SE5")+".E5_TIPO = 'NF' "+CRLF
cQuery+= "			AND "+RetSqlName("SE5")+".E5_TIPODOC IN ('VL','BA') "+CRLF
cQuery+= "			AND "+RetSqlName("SE5")+".E5_P_SISTE = '' "+CRLF
cQuery+= "			AND "+RetSqlName("SE5")+".E5_FILORIG+"+RetSqlName("SE5")+".E5_CLIFOR+"+RetSqlName("SE5")+".E5_LOJA+"+RetSqlName("SE5")+".E5_PREFIXO+"+RetSqlName("SE5")+".E5_NUMERO+"+RetSqlName("SE5")+".E5_PARCELA+"+RetSqlName("SE5")+".E5_TIPO = FILIAL+CLIFOR+LOJA+PREFIXO+NUM+PARCELA+TIPO "

If TcSqlExec(cQuery) < 0
	MsgInfo("Não foi possível atualizar o número do pedido Sistech no Financeiro!","Grant Thronton")
	lRet:= .F.
EndIf

Return lRet
