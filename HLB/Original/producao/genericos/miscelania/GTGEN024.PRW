#Include "rwmake.ch"    


/*
Funcao      : GTGEN024
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exportar determinada tabela do sistema
Autor       : Tiago Luiz Mendonça
Data/Hora   : 05/02/2014
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Ativo Fixo.
*/ 

*--------------------------*
 User Function GTGEN024()
*--------------------------*

Local oDlg

Private cItem
Private aItens:={"SN1","SN2","SN3","SN4"}  

@ 200,001 To 380,420 Dialog oDlg Title "Exportar tabela..."
@ 001,002 To 089,209
@ 015,020 Say "Selecione a tabela a ser exportada. " 
@ 055,005 Say "Tabela "
@ 055,025 COMBOBOX cItem ITEMS aItens SIZE 40,20 
@ 070,128 BmpButton Type 01 Action Processa( {||  ExpTable() }, "Aguarde...", "Executando exportação... aguarde",.F.) 
@ 070,158 BmpButton Type 02 Action Close(oDlg)
                  
ACTIVATE DIALOG oDlg  CENTERED

Return .T.

*-------------------------*
STATIC FUNCTION ExpTable()
*-------------------------*  

Local cQry := ""

cAliasWork := "WORK"
If Select(cAliasWork) > 0
	(cAliasWork)->(DbCloseArea())
EndIf 

aStru := (cItem)->(DbStruct())
cNome := CriaTrab(aStru,.T.)
dbUseArea(.T.,,cNome,cAliasWork,.F.,.F.)
cQry := "SELECT * FROM "+RetSqlName(cItem)+" WHERE D_E_L_E_T_ <> '*'"
SqlToTrb (cQry,aStru,cAliasWork)

(cAliasWork)->(DbCloseArea())

cArqOrig := "\SYSTEM\"+cNome+".DBF"
cPath     := AllTrim(GetTempPath())                                                   
CpyS2T( cArqOrig , cPath, .T. )
                           
If ApOleClient("MsExcel")      
	oExcelApp:=MsExcel():New()
 	oExcelApp:WorkBooks:Open(cPath+cNome+".DBF" )  
  	oExcelApp:SetVisible(.T.)    
Else 
   Alert("Excel não instalado")      
EndIf
   
Return .T.



