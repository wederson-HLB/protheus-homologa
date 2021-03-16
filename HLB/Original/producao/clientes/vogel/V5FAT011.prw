#Include "TOTVS.CH"
#include "Topconn.Ch"

/*
Funcao      : V5FAT011()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Reenvio de log de cancelamento de notas manualmentes
Autor       : Renato Rezende
Cliente		: Vogel
Data/Hora   : 06/10/2016
*/
*-----------------------------------------------*
 User Function V5FAT011()
*-----------------------------------------------* 
Local aHeaderLog 	:= { 'EMP','FILIAL','STATUS','C5_NUM','C5_P_REF','A1_CGC','D2_SERIE','D2_DOC','D2_EMISSAO','D2_COD','D2_TOTAL','D2_CF' }
Local aLog 			:= {}    
Local aAux          := {}

Local cAliasQ		:= ""                         
Local cArquivo  	:= ""

Private cPerg		:="V5FAT011"

If (cEmpAnt $ u_EmpVogel()) .And. (SF2->F2_TIPO == 'N')

	//Ajusta os perguntes
	AjusSx1()
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF

	cArquivo := 'SAIDAS_CANC_' + SM0->M0_CGC + '_' + DtoS( dDataBase ) + StrTran( Time() , ':' , '' ) + '.CSV' 
	Aadd( aLog , { , aHeaderLog } )	                
	Aadd( aLog , { cArquivo , {} })

	cSql := "SELECT C5_NUM,C5_P_REF,A1_CGC,D2_SERIE,D2_DOC,D2_EMISSAO,D2_DOC,D2_TOTAL,D2_CF,D2_COD "+CRLF
	cSql += "  FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SA1")+" A1 ON D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA "+CRLF
	cSql += "INNER JOIN " + RetSqlName("SC5") + " C5 ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "+CRLF
	cSql += " WHERE C5.D_E_L_E_T_ = '*' AND D2.D_E_L_E_T_ = '*' AND A1.D_E_L_E_T_ = '' AND "+CRLF
	cSql += " A1_FILIAL = '"+xFilial('SA1')+"' AND C5_FILIAL = '" +xFilial('SC5')+"' AND D2_FILIAL = '"+xFilial('SD2')+"' AND "+CRLF
	cSql += " D2_DOC = '"+MV_PAR02+"' AND D2_SERIE = '"+MV_PAR01+"' " 

    cAliasQ := GetNextAlias()
    TCQuery cSql ALIAS (cAliasQ) NEW
    
    Count to nRecCount
    (cAliasQ)->(DbGoTop())
    
    If nRecCount > 0
		While ( cAliasQ )->( !Eof() )
		    aAux := { SM0->M0_CGC ,;
						cFilAnt ,;
						'C',;
						( cAliasQ )->C5_NUM ,;
						( cAliasQ )->C5_P_REF,;
						( cAliasQ )->A1_CGC,;
						( cAliasQ )->D2_SERIE,;
						( cAliasQ )->D2_DOC,;
						DtoC( StoD( ( cAliasQ )->D2_EMISSAO ) ) ,;
						( cAliasQ )->D2_COD,;
						Transf( ( cAliasQ )->D2_TOTAL , "@R 99999999999.99" ) ,;
						( cAliasQ )->D2_CF }
							
			Aadd( aLog[ 2 ][ 2 ] , aAux )
			(cAliasQ)->(DbSkip())
		EndDo    
	
		//Gera arquivo de log e envia ao servidor FTP
	    If Len( aLog[ 2 ][ 2 ] ) > 0
			u_GerEnvLg( aLog , .F. )
			MsgInfo("Log Gerado!","Grant Thronton")    
	    EndIf
	    
	Else
		MsgInfo("Registro não encontrado!","Grant Thronton")
	EndIf      
    
    ( cAliasQ )->( DbCloseArea() )

EndIf

Return

/*
Função  : CriaPerg
Objetivo: Criação dos .
Autor   : Renato Rezende
Data    : 06/10/2016
*/
*------------------------------*
 Static Function AjusSx1()
*------------------------------*
Local lAjuste 	:= .F.

Local nI 		:= 0

Local aHlpPor 	:= {}
Local aHlpEng 	:= {}
Local aHlpSpa 	:= {}
Local aSX1    	:= {	{"01","Série ?"    },;
  						{"02","No. Nota ?"   }}
  					
//Verifica se o SX1 está correto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Série ")
	Aadd( aHlpPor, "que deseja imprimir.") 
	
	U_PUTSX1(cPerg,"01","Série ?","Série ?","Série ?","mv_ch1","C",03,0,0,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Documento ")
	Aadd( aHlpPor, "que deseja imprimir.")
	
	U_PUTSX1(cPerg,"02","No. Nota ?","No. Nota ?","No. Nota ?","mv_ch2","C",09,0,0,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	

EndIf

Return
