#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'TBICONN.CH'
#include 'AP5MAIL.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} F811MAILTO
Ponto de entrada para envio das cartas de cobrança de e-mail especifico

@author Sandro Silva
@since  29/07/2020
@version 12.1.25
/*/
//-------------------------------------------------------------------
User function F811MAILTO()

Local cEmail    := ''
Local cRet      := ''
Local cQuery    := ''
Local cAlias    := ''
Local aArea     := GetArea()

If cEmpAnt = 'ZJ'  //LinkedIn

   cAlias := GetNextAlias()

   cQuery += "SELECT * FROM " + RetSqlName('SC5') 	+ " SC5 "
   cQuery += "WHERE SC5.C5_FILIAL = '" + SE1->E1_FILIAL + "' "
   cQuery += "AND SC5.C5_CLIENTE  = '" + SE1->E1_CLIENTE + "' "
   cQuery += "AND SC5.C5_LOJACLI  = '" + SE1->E1_LOJA + "' "
   cQuery += "AND SC5.C5_NOTA = '"     + SE1->E1_NUM + "' "
   cQuery += "AND SC5.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

   If !Empty( (cAlias)->C5_P_MAIL  )
      cEmail:= Strtran((cAlias)->C5_P_MAIL,"/",",")
   EndIf
   (cAlias)->(dbCloseArea())
   MsErase(cAlias) 
   If !empty(cEmail)
      cRet := cEmail
   Else
      cRet := SA1->A1_EMAIL
   EndIf
Else
    cRet := SA1->A1_EMAIL
EndIf
RestArea(aArea)
Return cRet

