#include "rwmake.ch"
#include "colors.ch"
#include "topconn.ch"

/*
Funcao      : AYYEST01
Parametros  : Nehum
Retorno     : Nenhum
Objetivos   : Volta Virada de saldo 
Autor       : Wederson Lourenço Santana
Data/Hora   : 29/06/2004
Revisão		: Renato Rezende                   
Data/Hora   : 25/02/2013
Módulo      : Estoque
*/

*-------------------------*
User Function AYYEST01()
*-------------------------*

Private dMv_UlMes :=Date()
Private dNew_UlMes:=Date()
Private lRet := .T.
Private lFifo:=.F.

@ 0,0 TO 300,460 DIALOG oDlg TITLE  "Virada de Saldo"
@ 001,003 TO 040,230
@ 045,003 TO 100,230
@ 010,020 SAY "Esta rotina ira reabrir um periodo fechado para nova virada de saldo !!" COLOR CLR_HRED, CLR_WHITE
@ 060,020 Say "Data do último fechamento" COLOR CLR_HBLUE, CLR_WHITE
@ 060,100 Get dMv_UlMes Size 040,040
@ 080,020 Say "Nova Data para abertura" COLOR CLR_HBLUE, CLR_WHITE
@ 080,100 Get dNew_UlMes Size 040,040 Valid fOkValid()
@ 120,140 BMPBUTTON TYPE 01 ACTION Processa({|| fOkProc() },"Virada de Saldo")
@ 120,180 BMPBUTTON TYPE 02 ACTION Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED

//If Select("SX6") > 0
//	DbSelectArea("SX6")
//	DbCloseArea("SX6")
//Endif

Return


*-------------------------*
Static Function fOkProc()
*-------------------------*

Local cChave :=" "
Close(oDlg)
// Grava o MV_ULMES
DbSelectArea("SX6")
DbGotop()
cChave :=If(lRet =.T.,cFilAnt+"MV_ULMES  ",Space(02)+"MV_ULMES  ")
lFifo := !Empty(cFilAnt+"MV_CUSFIFO")      
lLote := !Empty(cFilAnt+"MV_RASTRO ")
lEnder:= !Empty(cFilAnt+"MV_LOCALIZ")

If DbSeek(cChave)
	If fBkpSB9() 
	    Sx6->(Dbseek(cChave))
		Reclock("SX6",.F.)
		Replace X6_CONTEUD With Dtos(dNew_UlMes)
		MsUnlock()
		
		// Apaga os dados referente ao utlimo mes de fechamento
		DelSB9 := "BEGIN TRANSACTION " + Chr(10)
		DelSB9 += "Go " + Chr(10)
		DelSB9 += "UPDATE "+RetSqlName("SB9") + " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_=R_E_C_N_O_  WHERE B9_DATA BETWEEN '"+DTOS(dMv_UlMes)+"' AND '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
		DelSB9 += "B9_FILIAL = '" +XFILIAL("SB9")+ "'" +Chr(10)
		DelSB9 += "COMMIT TRANSACTION "
		
		If TcSqlExec(DelSB9) < 0
			Alert("Entre em contato com o Administrador ! "+Chr(10)+Chr(13)+TcSqlError())
		Else
			MsgInfo("Processo Finalizado para Custo Médio !!"," OK")
		EndIf
	Else	
    	MsgInfo("Nao existem dados para serem processados Custo Médio  !"," ATENCAO")
	Endif     
	
	If lFifo          
	   If fBkpSCC() 
	   // Apaga os dados referente ao utlimo mes de fechamento
	       DelSCC := "BEGIN TRANSACTION " + Chr(10)
		   DelSCC += "Go " + Chr(10)
		   DelSCC += "UPDATE "+RetSqlName("SCC") + " SET D_E_L_E_T_ = '*' WHERE CC_DATA BETWEEN '"+DTOS(dMv_UlMes)+"' AND '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
		   DelSCC += "CC_FILIAL = '" +XFILIAL("SCC")+ "'" +Chr(10)
		   DelSCC += "COMMIT TRANSACTION "
		// Acerta o status do mês anterior  ( A-Aberto / E-Encerrado )
		   AcSCC := "BEGIN TRANSACTION " + Chr(10)
		   AcSCC += "Go " + Chr(10)
		   AcSCC += "UPDATE "+RetSqlName("SCC") + " SET CC_STATUS='A' WHERE CC_DATA = '"+DTOS(dNew_UlMes)+"'"+ Chr(10)
		   AcSCC += " AND CC_FILIAL = '" +XFILIAL("SCC")+ "'" +Chr(10)
		   AcSCC += "COMMIT TRANSACTION " 		   
	                               		                                           
		   If TcSqlExec(DelSCC) < 0  .Or. TcSqlExec(AcSCC) < 0  
			  Alert("Entre em contato com o IT."+Chr(10)+Chr(13)+TcSqlError()) 
   		   Else
		      MsgInfo("Processo Finalizado para Custo FIFO."," OK")
		   EndIf
	   Else	
    	  MsgInfo("Nao existem dados para serem processados Custo FIFO."," ATENCAO")
	   Endif 
	EndIf    
	
	If lLote          
	   If fBkpSBJ() 
	   // Apaga os dados referente ao utlimo mes de fechamento
	       DelSBJ := "BEGIN TRANSACTION " + Chr(10)
		   DelSBJ += "Go " + Chr(10)
		   DelSBJ += "UPDATE "+RetSqlName("SBJ") + " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_=R_E_C_N_O_ WHERE BJ_DATA BETWEEN '"+DTOS(dMv_UlMes)+"' AND '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
		   DelSBJ += "BJ_FILIAL = '" +XFILIAL("SBJ")+ "'" +Chr(10)
		   DelSBJ += "COMMIT TRANSACTION "
	                               		                                           
		   If TcSqlExec(DelSBJ) < 0  
			  Alert("Entre em contato com o IT. Problema Lote"+Chr(10)+Chr(13)+TcSqlError()) 
		   EndIf
       EndIf
	EndIf
	
	If lEnder          
	   If fBkpSBK() 
	   // Apaga os dados referente ao utlimo mes de fechamento
	       DelSBK := "BEGIN TRANSACTION " + Chr(10)
		   DelSBK += "Go " + Chr(10)
		   DelSBK += "UPDATE "+RetSqlName("SBK") + " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_=R_E_C_N_O_ WHERE BK_DATA BETWEEN '"+DTOS(dMv_UlMes)+"' AND '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
		   DelSBK += "BK_FILIAL = '" +XFILIAL("SBK")+ "'" +Chr(10)
		   DelSBK += "COMMIT TRANSACTION "
	   
	                               		                                           
		   If TcSqlExec(DelSBK) < 0  
			  Alert("Entre em contato com o IT. Problema Endereçamento"+Chr(10)+Chr(13)+TcSqlError()) 
		   EndIf 
	   EndIF	   
	EndIf
	
Endif

Return

*-------------------------*
Static Function fOkValid() 
*-------------------------*

Local lOk :=.T.
If Select("SX6") > 0
	DbSelectArea("SX6")
	DbCloseArea("SX6")
Endif
dbUseArea(.T.,,"SX6"+cEmpAnt+"0","SX6",.T.,.F.)
DbSetIndex("SX6"+cEmpAnt+"0")
If Select("SX6")>0
	DbSelectArea("SX6")
	If! DbSeek(cFilAnt+"MV_ULMES  ")
		lRet :=.F.
		If! DbSeek(Space(02)+"MV_ULMES  ")
			MsgInfo("Parametro MV_ULMES nao encontrado na empresa - "+cEmpAnt+"."," ATENCAO")
         lOk:=.F.
		Endif
	Endif
Else
	MsgInfo("Nao foi possivel carregar os parametros da empresa (SX6"+cEmpAnt+"0)."," ATENCAO")
	lOk:=.F.
Endif

Return(lOk)

*-------------------------*
Static Function fBkpSB9()
*-------------------------*

Local lTmp :=.F.
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSB9:= SB9->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SB9")+"  WHERE B9_DATA = '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
cQuery += "B9_FILIAL = '"+XFilial("SB9")+"' AND D_E_L_E_T_ <> '*'"+Chr(10)

TCQuery cQuery ALIAS "SQL" NEW

For nX := 1 To Len(aStruSB9)
	If aStruSB9[nX,2]<>"C"
		TcSetField("SQL",aStruSB9[nX,1],aStruSB9[nX,2],aStruSB9[nX,3],aStruSB9[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

dbSelectArea("SQL")
dbGoTop()
If RecCount("SQL")>0
	Copy To \SALVA\SB9EST01
	DbCloseArea("SQL")
	lTmp :=.T.
Endif

Return(lTmp)               

*-------------------------*
Static Function fBkpSCC()  
*-------------------------*

Local lTmp :=.F.
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSCC:= SCC->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SCC")+"  WHERE CC_DATA = '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
cQuery += "CC_FILIAL = '"+XFilial("SCC")+"' AND D_E_L_E_T_ <> '*'"+Chr(10)

TCQuery cQuery ALIAS "SQL" NEW

For nX := 1 To Len(aStruSCC)
	If aStruSCC[nX,2]<>"C"
		TcSetField("SQL",aStruSCC[nX,1],aStruSCC[nX,2],aStruSCC[nX,3],aStruSCC[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

dbSelectArea("SQL")
dbGoTop()
If RecCount("SQL")>0
	Copy To \SALVA\SCCEST01
	DbCloseArea("SQL")
	lTmp :=.T.
Endif

Return(lTmp)                       

*----------------------------*
   Static Function fBkpSBJ()  
*----------------------------*  
 
Local lTmp :=.F.
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSBJ:= SBJ->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SBJ")+"  WHERE BJ_DATA = '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
cQuery += "BJ_FILIAL = '"+XFilial("SBJ")+"' AND D_E_L_E_T_ <> '*'"+Chr(10)

TCQuery cQuery ALIAS "SQL" NEW

For nX := 1 To Len(aStruSBJ)
	If aStruSBJ[nX,2]<>"C"
		TcSetField("SQL",aStruSBJ[nX,1],aStruSBJ[nX,2],aStruSBJ[nX,3],aStruSBJ[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

dbSelectArea("SQL")
dbGoTop()
If RecCount("SQL")>0
	Copy To \SALVA\SBJEST01
	DbCloseArea("SQL")
	lTmp :=.T.
Endif

Return(lTmp)
               

*-------------------------------*
  Static Function fBkpSBK() 
*-------------------------------*  

Local lTmp :=.F.
If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSBK:= SBK->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SBK")+"  WHERE BK_DATA = '"+DTOS(dMv_UlMes)+"' AND " + Chr(10)
cQuery += "BK_FILIAL = '"+XFilial("SBK")+"' AND D_E_L_E_T_ <> '*'"+Chr(10)

TCQuery cQuery ALIAS "SQL" NEW

For nX := 1 To Len(aStruSBK)
	If aStruSBK[nX,2]<>"C"
		TcSetField("SQL",aStruSBK[nX,1],aStruSBK[nX,2],aStruSBK[nX,3],aStruSBK[nX,4])
	EndIf
Next nX

cArqTMP := CriaTrab(NIL,.F.)
Copy To &cArqTMP
dbCloseArea()
dbUseArea(.T.,,cArqTMP,"SQL",.T.)

dbSelectArea("SQL")
dbGoTop()
If RecCount("SQL")>0
	Copy To \SALVA\SBKEST01
	DbCloseArea("SQL")
	lTmp :=.T.
Endif

Return(lTmp)

