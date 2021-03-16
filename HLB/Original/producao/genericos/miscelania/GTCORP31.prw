#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

/*
Funcao      : GTCORP31()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criação de tabelas ou empresas
Autor       : Renato Rezende
Data/Hora   : 05/12/2013
*/                          
*-------------------------*
 User Function GTCORP31()
*-------------------------*
Local oDlg, oVar, oCheck1, oCheck2, oTButton1
Private cTabela := space(3)
Private lCheck 	:= .F.
Private lCheck2 := .F.

Define Font oFont1 Name "Tahoma" Size 0,14 Bold       //PARA DEFINIR QUAIS FONTES SERAO UTILIZADAS NO PROGRAMA

    DEFINE DIALOG oDlg TITLE "Criar Empresa" FROM 180,180 TO 360,400 PIXEL
        
        @11,10 Say "Rotina para Criação de Empresa" Font oFont1 Pixel Of oDlg   

        oCheck1 := TCheckBox():New(21,10,'Criação Automática de Empresa',{|u| if(PCount()>0,lCheck:=u,lCheck)},oDlg,100,210,,,,,,,,.T.,,,) 
        
        oCheck2 := TCheckBox():New(31,10,'Appendar Tabelas Modelos',{|u| if(PCount()>0,lCheck2:=u,lCheck2)},oDlg,100,210,,,,,,,,.T.,,,)
        
        @41,10 Say "Tabela:" Color CLR_RED Font oFont1 Pixel Of oDlg 
           
        @41,40 MSGet oVar Var cTabela Picture "@!" Size 50,10 Pixel Of oDlg
    	
    	oTButton1 := TButton():New( 061, 050, "Ok",oDlg,{||CriaTab()}, 30,15,,,.F.,.T.,.F.,,.F.,,,.F. )
        
    ACTIVATE DIALOG oDlg CENTERED

/*
Funcao      : CriaTab()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criação de tabelas ou empresas
Autor       : Renato Rezende
Data/Hora   : 05/12/2013
*/                          
*---------------------------*				
 Static Function CriaTab()
*---------------------------*
Local aTab		:= {}
Local aTabSx	:= {}
Local r,n,o		:= 0
Local cTexto	:= ""
Local cDest		:= "" 

If lCheck == .T.

	AADD(aTab, "CT1")
	AADD(aTab, "CT5")
	AADD(aTab, "CTE")
	AADD(aTab, "CTG")
	AADD(aTab, "CTM")
	AADD(aTab, "CTO")
	AADD(aTab, "CTR")
	AADD(aTab, "CTT")
	AADD(aTab, "CVD")
	AADD(aTab, "CVN")
	AADD(aTab, "RC0")
	AADD(aTab, "SB1")
	AADD(aTab, "SNG")
	AADD(aTab, "SR5")
	AADD(aTab, "SRV")
	AADD(aTab, "SRX")
	AADD(aTab, "SRY")

	For r:=1 to Len (aTab)
		ChkFile(aTab[r])
		cTexto+="- Tabela Criada: "+aTab[r]+CHR(13)+CHR(10)	
	Next r
	
	AADD(aTabSx, "CTP")
	AADD(aTabSx, "SED")
	AADD(aTabSx, "SF4")
	AADD(aTabSx, "SM2")
	AADD(aTabSx, "SM4")
	AADD(aTabSx, "SYD")
	AADD(aTabSx, "SZ2")
	
	SX2->(DbGoTop())
	SX2->(DbSetOrder(1)) //X2_CHAVE
	For n:=1 to Len(aTabSx)
		If SX2->(DbSeek(aTabSx[n]))
			SX2->(RecLock('SX2', .F.))
			SX2->X2_ARQUIVO := aTabSx[n]+"YY0"
			SX2->(MsUnlock())
			cTexto += "- A Tabela "+aTabSx[n]+" atualizado para empresa Modelo!"+CHR(13)+CHR(10)
		EndIf 		
	Next n
EndIf

If lCheck2 == .T.


	aTab :={}
	
	AADD(aTab, "CT1")
	AADD(aTab, "CT5")
	AADD(aTab, "CTE")
	AADD(aTab, "CTG")
	AADD(aTab, "CTM")
	AADD(aTab, "CTO")
	AADD(aTab, "CTR")
	AADD(aTab, "CTT")
	AADD(aTab, "CVD")
	AADD(aTab, "CVN")
	AADD(aTab, "RC0")
	AADD(aTab, "SB1")
	AADD(aTab, "SNG")
	//AADD(aTab, "SR5")
	AADD(aTab, "SRV")
	AADD(aTab, "SRX")
	AADD(aTab, "SRY")
	
	For o:=1 To Len(aTab)
		//Select para carregar o conteúdo da empresa modelo
		cQuery := "SELECT * FROM "+aTab[o]+"YY0 WHERE D_E_L_E_T_ <> '*'"
		DbUseArea(.T., "TOPCONN",TCGENQRY(,,cQuery),'TMP',.F.,.T.)
		TMP->(DbGoTop())
		
		cDest := "\spool\"+aTab[o]+".DBF"
		//Excluindo arquivo caso já exista na pasta
		If file(cDest)
			FErase(cDest)
		EndIf
		//Verificando se o select retornou registro
		count to nRecCount
		If nRecCount > 0
			//Copiando as tabelas para um diretório do ambiente
			Copy To &cDest VIA "DBFCDXADS"
			DbSelectArea(aTab[o])
			(aTab[o])->(DbSetOrder(1))
			//Appendando os dados na empresa que está sendo criada. 
			Append from  &cDest
			cTexto += "- Append na tabela"+aTab[o]+CHR(13)+CHR(10)
		Else
	   		cTexto += "- Não foi possível appendar a tabela: "+aTab[o]+CHR(13)+CHR(10)	
		Endif
		//Excluindo arquivo gerado
		If file(cDest)
			FErase(cDest)
		EndIf
		TMP->(DbCloseArea())
	    
	Next o

EndIf
//Criar tabela a parte
If !Empty(Alltrim(cTabela))	
	ChkFile(cTabela)
	cTexto += "- Tabela Criada: "+cTabela+CHR(13)+CHR(10)
EndIf

MsgInfo(cTexto)
		
Return