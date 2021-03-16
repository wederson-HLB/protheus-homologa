#include "rwmake.ch"
#include "topconn.ch"

/*
Funcao      : GTGEN001
Parametros  : cImpRet
Retorno     : _vValor
Objetivos   : Função utilizada em Lançamentos Padrões, no estorno de compensação de RA
Autor       : Matheus Massarotto
Data/Hora   : 30/08/2012    15:41
Revisão		:                    
Data/Hora   : 
Módulo      : Financeiro
*/

*-------------------------------*                                                
USER FUNCTION LP588VAL1(cImpRet)
*-------------------------------*
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
cLoja	  := SE1->E1_LOJA
cSituaca  := SE1->E1_SITUACA
cSaldo    := SE1->E1_SALDO
_vValor   := 0

If  ( AllTrim(FUNNAME())$ "FINA330") .AND. cImpRet $ "PI-/CF-/CS-"
   If! Empty(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO)
      //No estorno ou exclusão volta o saldo.
      If SE1->E1_SALDO>0                                                                                                                                                                         
       
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
Endif

RETURN (_vValor)  

