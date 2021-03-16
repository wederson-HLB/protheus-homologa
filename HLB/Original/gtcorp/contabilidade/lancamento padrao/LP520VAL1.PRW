#include "rwmake.ch"
#include "topconn.ch"
                                                
USER FUNCTION LP520VAL1(cImpRet)


Local cPrefixo := ""
Local cNumero  := ""
Local cParcela := ""
Local cTipo    := cImpRet
Local cCliente := ""
Local cLoja    := ""
Local nValor := 0

DbSelectArea("SE1")
cAlias := Alias()
nOrder := DbSetOrder()
nRecno := Recno()

cPrefixo  := SE1->E1_PREFIXO
cNumero   := SE1->E1_NUM
cParcela  := SE1->E1_PARCELA
cCliente  := SE1->E1_CLIENTE
cLoja  	 := SE1->E1_LOJA
cSituaca  := SE1->E1_SITUACA
cSaldo    := SE1->E1_SALDO
_vValor   := 0

If  ( AllTrim(FUNNAME())$ "FINA200" .Or. AllTrim(FUNNAME())$ "FINA070" ) .AND. cImpRet $ "PI-/CF-/CS-"
   If! Empty(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO)
      
      If SE1->E1_SALDO==0                                                                                                                                                                         
       
      	If cImpRet $ "PI-" .AND. E1_SABTPIS = 0
      		_vValor := SE1->E1_PIS
        EndIf      
        
        If cImpRet $ "CF-" .AND. E1_SABTCOF = 0 
      		_vValor := SE1->E1_COFINS
        EndIf       
       
        If cImpRet $ "CS-" .AND. E1_SABTCSL = 0
      		_vValor := SE1->E1_CSLL
        EndIf
      Else
      	_vValor :=0
      EndIf  
             
   EndIf
ELSE                                 

IF cSituaca = "0" .or. cSituaca = "1" .or. cSituaca = "3"
	IF cSaldo = 0  
		DbSetOrder(2)
		IF DbSeek (xFilial("SE1")+cCliente+cLoja+cPrefixo+cNumero+cParcela+cTipo)
		   _vValor := SE1->E1_VALOR
		ENDIF
  endif      
endif

DbSelectArea(cAlias)
DbSetOrder(nOrder)
DbGoto(nRecno)


ENDIF
RETURN (_vValor)  

Static Function fGeraDados(cPrefixo,cNumero,cTipo)

If Select("SQL") > 0
	SQL->(dbCloseArea())
EndIf

aStruSE1 :={}
aStruSE1:= SE1->(dbStruct())
   
cQuery := "SELECT E1_PREFIXO,E1_NUM,E1_TIPO,E1_VALOR "+Chr(10)+CHR(13)
cQuery += "FROM "+RetSqlName("SE1")+" WHERE "+Chr(10)
cQuery += "E1_FILIAL = '"+xFilial("SE1")+"'"+Chr(10)
cQuery += "AND E1_PREFIXO='"+cPrefixo+"'"+Chr(10)
cQuery += "AND E1_NUM='"+cNumero+"'"+Chr(10)
cQuery += "AND E1_TIPO = '"+cTipo+"'"+Chr(10)
cQuery += "AND D_E_L_E_T_ <> '*' "+Chr(10)
cQuery += "ORDER BY E1_PREFIXO,E1_NUM,E1_TIPO "

TCQuery cQuery ALIAS "SQL" NEW

TCSetField("SQL","E1_VALOR","N",14,2)

For nX := 1 To Len(aStruSE1)
    If aStruSE1[nX,2]<>"C"
 	    TcSetField("SQL",aStruSE1[nX,1],aStruSE1[nX,2],aStruSE1[nX,3],aStruSE1[nX,4])
    EndIf
Next nX
IF (SQL->E1_VALOR) > 0
Return(SQL->E1_VALOR)
EndIf