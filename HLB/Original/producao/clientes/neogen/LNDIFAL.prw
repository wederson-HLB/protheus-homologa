#INCLUDE "RWMAKE.CH"   
#include 'totvs.ch'
#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LN_DIFAL.
 Exibir mensagem de difal de acordo com a TES
 Exemplo  X3_VALID - A410MultT() .And. A410SitTrib() .And.  IIF(FINDFUNCTION("U_LNDIFAL"),U_LNDIFAL(),.T.)                                                                          
@author    
@version   
@since    08/09/2020
/*/
//-------------------------------------------------------------------------------------------------------------
User Function LNDIFAL(cReadVar)

Local aArea     := GetArea()
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local lDifal    := .T.
Local lTesDifal := .F.
Local lCliDifal := .F. 
Local cEstMatr  := SM0->M0_ESTCOB
Local CodFilial := Alltrim(FWFilialName())

cReadVar := ReadVar()
xConteudo:= &(cReadVar)

dbSelectArea("SA1")
dbSetOrder(1)
MsSeek(xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI)

If SA1->A1_CONTRIB = '2' .And. SA1->A1_EST <> cEstMatr .And. (!Empty(SA1->A1_INSCR) .Or. Empty(SA1->A1_INSCR) .Or. SA1->A1_INSCR = "ISENTO            ")
   lCliDifal := .T.
EndIf

If "C6_TES" $ cReadVar
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+M->C6_TES)
                                                                                      
	If SF4->F4_COMPL = 'S' .And. SF4->F4_LFICM <> 'N' 
	   lTesDifal := .T.
	EndIf
	
    If M->C6_TES == "9Z7"   //Instrução de bloqueio temporaria 
       lTesDifal := .F.
	EndIf

    If SA1->A1_EST == 'PR'  //Instrução de bloqueio temporaria 
	   lTesDifal := .T.
    EndIf
EndIf

If lCliDifal   // Cliente tem DIFAL
   If !lTesDifal  //TES não tem DIFAL
      lDifal := .F. 
	  MsgAlert("Este Cliente possui calculo de DIFAL, verifique a TES.", "Atenção")
   EndIf 	  
EndIf
RestArea(aArea)
Return lDifal
