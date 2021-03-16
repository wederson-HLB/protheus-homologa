#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"


/*
Função..................: V5Est003
Objetivo................: Tela para envio dos documentos de entrada para o sistema Sistech
Autor...................: Leandro Diniz de Brito ( LDB )  - BRL Consulting
Data....................: 05/09/2016
Cliente HLB.............: Vogel
*/

*----------------------------------*
User Function V5Est003
*----------------------------------*
Local cTitulo		:= 'Vogel - Envio de documento de entrada'
Local cDescription	:= 'Esta rotina permite enviar as notas fiscais de entrada, para o sistema Sistech, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private aRotina 	:= MenuDef()
Private cPerg 	 	:= 'V5EST003'

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )
Private cTpSel    


If !( cEmpAnt $ u_EmpVogel() )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf


AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }
oProcess 	:= tNewProcess():New( "V5EST003" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)

DbSelectArea( 'SF1' )
SET FILTER TO

Return

/*
Função..........: SelfNf
Objetivo........: Selecionar notas fiscais para impressão
*/
*-------------------------------------------------*
Static Function SelNf( oProcess )
*-------------------------------------------------*
Local oColumn
Local bValid        := { || .T. }  //** Code-block para definir alguma validacao na marcação, se houver necessidade

Private cExpAdvPL
Private oMarkB

Pergunte( cPerg , .F. )

dDtIni 	:= MV_PAR01
dDtFim 	:= MV_PAR02

SetKey( VK_F12 , { || Pergunte( 'V5EST003' , .T. ) } )

cExpAdvPL     := 'SF1->F1_FILIAL=="'+xFilial("SF1")+'" .And. F1_EMISSAO >= dDtIni .And. F1_EMISSAO <= dDtFim .And. F1_TIPO = "N" .And. F1_P_SISTE <> "S" '  //.And. !Empty( u_Est003Val() )

oMarkB := FWMarkBrowse():New()
oMarkB:SetOnlyFields( { "F1_COND" } )
oMarkB:SetAlias( 'SF1' )
oMarkB:SetFieldMark( 'F1_OK' )
oMarkB:SetValid( bValid )
	
/*
* Definição das colunas do browse
*/
ADD COLUMN oColumn DATA { || u_Est003Val()  } 	TITLE "Ped.Sistech"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F1_DOC   } 	TITLE "Nota Fiscal"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F1_SERIE   } 	TITLE "Serie"     		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F1_FORNECE   } TITLE "Fornecedor"     	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F1_LOJA  } 	TITLE "Loja"     		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F1_EMISSAO   } TITLE "Emissao"     	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALBRUT , X3Picture( 'F1_VALBRUT' ) )   } 	TITLE "Valor Bruto"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALICM , X3Picture( 'F1_VALICM' ) )   } 	TITLE "Valor Icms"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_ISS , X3Picture( 'F1_ISS' ) )   } 	TITLE "Valor ISS"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALPIS , X3Picture( 'F1_VALPIS' ) )   } 	TITLE "Valor Pis"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALCOFI , X3Picture( 'F1_VALCOFI' ) )   } 	TITLE "Valor Cofins"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALCSLL , X3Picture( 'F1_VALCSLL' ) )   } 	TITLE "Valor CSLL"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F1_VALIRF , X3Picture( 'F1_VALIRF' ) )   } 	TITLE "Valor IRRF"     SIZE  3 OF oMarkB	

/*
* Filtro ADVPL
*/
oMarkB:SetFilterDefault( cExpAdvPL ) 

DbSelectArea( 'SF1' )
SET FILTER TO &( cExpAdvPL ) 

oMarkB:SetAllMark( { || SF1->( DbGoTop() , DbEval( { || RecLock( 'SF1' , .F. ) , F1_OK := oMarkB:Mark() , MSUnlock() } , { || .T. } , { || !Eof() } ) , DbGoTop() , oMarkB:Refresh() ) } )

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

ADD OPTION aRotina TITLE 'Processar' ACTION 'u_V5EstEnv()' OPERATION 10 ACCESS 0 

Return aRotina

/*
Função..........: V5EstEnv
Objetivo........: Enviar Log para o Sistech
*/
*-------------------------------------------------*
User Function V5EstEnv( lPreview  ); Return ( MsgRun( 'Transmitindo notas para o Sistech.... favor aguarde' , '' , { || EnviaLog() } ) )
*-------------------------------------------------*


/*
Função..........: EnviaLog
Objetivo........: Enviar Log para o Sistech
*/
*-------------------------------------------------*
Static Function EnviaLog
*-------------------------------------------------*
Local aHeaderLog 	:= { 'EMP','FILIAL','STATUS','C7_NUM','C7_P_REF','A2_CGC','D1_SERIE','D1_DOC','D1_EMISSAO','D1_COD','D1_TOTAL','D1_CF','D1_QUANT' }
Local cArquivo  	

Local aLog 			:= {}    
Local aAux


Pergunte( 'V5EST003' , .F. )

SD1->( DbSetOrder( 1 ) ) 
SC7->( DbSetOrder( 1 ) )
SA2->( DbSetOrder( 1 ) )
SF1->( DbGotop() )

cArquivo := 'ENTRADAS_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
Aadd( aLog , { , aHeaderLog } )	                
Aadd( aLog , { cArquivo , {} }  ) 

While SF1->( !Eof() )

	If ( SF1->F1_OK == oMarkB:Mark() )               
		SA2->( DbSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
		SD1->( DbSeek( xFilial("SD1") + SF1->F1_DOC +  SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
		
		While SD1->( !Eof() .And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA = ;
					xFilial( 'SD1' ) + SF1->F1_DOC +  SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) 

			SC7->( DbSeek( xFilial("SC7") + SD1->D1_PEDIDO ) )
		    aAux := { SM0->M0_CGC ,;
						cFilAnt ,;
						'A',;
						SC7->C7_NUM ,;
						SC7->C7_P_REF,;
						SA2->A2_CGC,;
						SD1->D1_SERIE,;
						SD1->D1_DOC,;
						DtoC( SD1->D1_EMISSAO ) ,;
						SD1->D1_COD,;
						Transf( SD1->D1_TOTAL , "@R 99999999999.99" ) ,;
						SD1->D1_CF ,;
						Transf( SD1->D1_QUANT , "@R 99999999.9999" )}
							
			Aadd( aLog[ 2 ][ 2 ] , aAux )					
					
			SD1->( DbSkip() )				
		EndDo    
		
		SF1->( RecLock( 'SF1' , .F. ) )
		SF1->F1_P_SISTE := 'S'
		SF1->( MSUnLock() )
				

	EndIf
	
	SF1->( DbSkip() )	
EndDo

/*
	* Gera arquivo de log e envia ao servidor FTP
*/
If Len( aLog[ 2 ][ 2 ] ) > 0
	u_GerEnvLg( aLog , .F. )
	MsgInfo( 'Processamento realizado com sucesso !' )    
EndIf	

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
Função..........: Est003Val
Objetivo........: Validar se o pedido da nota de origem Sistech  .  
Parametros......: 
Retorno.........: cRet => Pedido Sistech
*/
*-------------------------------------------------*
User Function Est003Val
*-------------------------------------------------*
Local cRet  := ""

SC7->( DbSetOrder( 1 ) )  
SD1->( DbSetOrder( 1 ) )

If SD1->( DbSeek( xFilial("SD1") + SF1->F1_DOC +  SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) ) .And. ;
		!Empty( SD1->D1_PEDIDO ) .And. ;
		SC7->( DbSeek( xFilial("SC7") + SD1->D1_PEDIDO ) ) .And. ;
		!Empty( SC7->C7_P_REF ) 

	cRet := SC7->C7_P_REF		
EndIf		

Return( cRet )

