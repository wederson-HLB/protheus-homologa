#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "tbiconn.ch"


/*
Função..................: V5Fat008
Objetivo................: Tela para envio dos documentos de saída para o sistema Sistech
Autor...................: Leandro Diniz de Brito ( LDB )  - BRL Consulting
Data....................: 19/08/2016
Cliente HLB.............: Vogel
*/

*----------------------------------*
User Function V5Fat008
*----------------------------------*
Local cTitulo		:= 'Vogel - Envio de documento de saída'
Local cDescription	:= 'Esta rotina permite enviar as notas fiscais de saída, para o sistema Sistech, dentro do periodo informado .'

Local oProcess
Local bProcesso

Private aRotina 	:= MenuDef()
Private cPerg 	 	:= 'V5FAT008'

Private dDtIni 		:= CtoD( '' )
Private dDtFim 		:= CtoD( '' )
Private cTpSel    


If !( cEmpAnt $ u_EmpVogel() )
	MsgStop( 'Empresa nao autorizada.' )  
	Return
EndIf


AjusSx1()

bProcesso	:= { |oSelf| SelNf( oSelf ) }
oProcess 	:= tNewProcess():New( "V5FAT008" , cTitulo , bProcesso , cDescription , cPerg ,,,,,.T.,.T.)

DbSelectArea( 'SF2' )
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

SetKey( VK_F12 , { || Pergunte( 'V5FAT008' , .T. ) } )

cExpAdvPL     := 'SF2->F2_FILIAL=="'+xFilial("SF2")+'" .And. SF2->F2_EMISSAO >= dDtIni .And. SF2->F2_EMISSAO <= dDtFim .And. SF2->F2_TIPO = "N" .And. SF2->F2_P_SISTE <> "S" '

oMarkB := FWMarkBrowse():New()
oMarkB:SetOnlyFields( { "F2_COND" } )
oMarkB:SetAlias( 'SF2' )
oMarkB:SetFieldMark( 'F2_OK' )
oMarkB:SetValid( bValid )
	
/*
* Definição das colunas do browse
*/
ADD COLUMN oColumn DATA { || F2_P_REF   } 	TITLE "Ped.Sistech"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_DOC   } 	TITLE "Nota Fiscal"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_SERIE   } 	TITLE "Serie"     		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_CLIENTE   } TITLE "Cliente"     	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_LOJA  } 	TITLE "Loja"     		SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || F2_EMISSAO   } TITLE "Emissao"     	SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALBRUT , X3Picture( 'F2_VALBRUT' ) )   } 	TITLE "Valor Bruto"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALICM , X3Picture( 'F2_VALICM' ) )   } 	TITLE "Valor Icms"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALISS , X3Picture( 'F2_VALISS' ) )   } 	TITLE "Valor ISS"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALPIS , X3Picture( 'F2_VALPIS' ) )   } 	TITLE "Valor Pis"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALCOFI , X3Picture( 'F2_VALCOFI' ) )   } 	TITLE "Valor Cofins"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALCSLL , X3Picture( 'F2_VALCSLL' ) )   } 	TITLE "Valor CSLL"     SIZE  3 OF oMarkB
ADD COLUMN oColumn DATA { || Transf( F2_VALIRRF , X3Picture( 'F2_VALIRRF' ) )   } 	TITLE "Valor IRRF"     SIZE  3 OF oMarkB	

/*
* Filtro ADVPL
*/
oMarkB:SetFilterDefault( cExpAdvPL ) 

DbSelectArea( 'SF2' )
SET FILTER TO &( cExpAdvPL ) 

oMarkB:SetAllMark( { || SF2->( DbGoTop() , DbEval( { || RecLock( 'SF2' , .F. ) , F2_OK := oMarkB:Mark() , MSUnlock() } , { || .T. } , { || !Eof() } ) , DbGoTop() , oMarkB:Refresh() ) } )

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

ADD OPTION aRotina TITLE 'Processar' ACTION 'u_V5FatEnv()' OPERATION 10 ACCESS 0 

Return aRotina

/*
Função..........: V5FatEnv
Objetivo........: Enviar Log para o Sistech
*/
*-------------------------------------------------*
User Function V5FatEnv( lPreview  ); Return ( MsgRun( 'Transmitindo notas para o Sistech.... favor aguarde' , '' , { || EnviaLog() } ) )
*-------------------------------------------------*


/*
Função..........: EnviaLog
Objetivo........: Enviar Log para o Sistech
*/
*-------------------------------------------------*
Static Function EnviaLog
*-------------------------------------------------*
Local aHeaderLog 	:= { 'EMP','FILIAL','STATUS','C5_NUM','C5_P_REF','A1_CGC','D2_SERIE','D2_DOC','D2_EMISSAO','D2_COD','D2_TOTAL','D2_CF' }
Local cArquivo  	

Local aLog 			:= {}    
Local aAux


Pergunte( 'V5FAT008' , .F. )

SD2->( DbSetOrder( 3 ) ) 
SC5->( DbSetOrder( 1 ) )
SA1->( DbSetOrder( 1 ) )
SF2->( DbGotop() )

cArquivo := 'SAIDAS_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
Aadd( aLog , { , aHeaderLog } )	                
Aadd( aLog , { cArquivo , {} }  ) 

While SF2->( !Eof() )

	If ( SF2->F2_OK == oMarkB:Mark() )               
		SA1->( DbSeek( xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
		SD2->( DbSeek( xFilial('SD2') + SF2->F2_DOC +  SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
		
		While SD2->( !Eof() .And. D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = ;
					xFilial( 'SD2' ) + SF2->F2_DOC +  SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) 

			SC5->( DbSeek( xFilial('SC5') + SD2->D2_PEDIDO ) )
		    aAux := { SM0->M0_CGC ,;
						cFilAnt ,;
						'A',;
						SC5->C5_NUM ,;
						SC5->C5_P_REF,;
						SA1->A1_CGC,;
						SD2->D2_SERIE,;
						SD2->D2_DOC,;
						DtoC( SD2->D2_EMISSAO ) ,;
						SD2->D2_COD,;
						Transf( SD2->D2_TOTAL , X3Picture( 'D2_TOTAL' ) ) ,;
						SD2->D2_CF }
							
			Aadd( aLog[ 2 ][ 2 ] , aAux )					
					
			SD2->( DbSkip() )				
		EndDo    
		
		SF2->( RecLock( 'SF2' , .F. ) )
		SF2->F2_P_SISTE := 'S'
		SF2->( MSUnLock() )
				

	EndIf
	
	SF2->( DbSkip() )	
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
