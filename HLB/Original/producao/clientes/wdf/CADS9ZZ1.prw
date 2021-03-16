#INCLUDE "rwmake.ch"  

/*
Funcao      : CADS9ZZ1
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de Ref. NBR   
Autor     	: Adriane Sayuri Kamiya
Data     	: 15/04/2009 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento.
*/

*-----------------------*
 User Function CADS9ZZ1
*-----------------------*

Private cAlias    := "ZZ1"
Private aRotina   := {}
Private cCadastro := "REF. NBR"

AAdd( aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1} )
AAdd( aRotina, {"Visualizar", "AxVisual"   , 0, 2} )
AAdd( aRotina, {"Incluir"   , "u_ZZ1Inclui", 0, 3} )
AAdd( aRotina, {"Alterar"   , "AxAltera"   , 0, 4} )
AAdd( aRotina, {"Excluir"   , "AxDeleta"   , 0, 5} )

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(,,,,cAlias)

Return Nil

//----------------------------------------------------------------------------//
User Function ZZ1Inclui(cAlias, nRegistro, nOpcao)

Local nConfirmou

nConfirmou := AxInclui(cAlias, nRegistro, nOpcao)

If nConfirmou == 1      // Confirmou a inclusao.

   Begin Transaction

      If !Empty(ZZ1->ZZ1_REFNBR)
         DbSelectArea("CTD")
         CTD->(DbSetOrder(1))
         CTD->(DbGoTop())
         If !(CTD->(DbSeek(xFilial("CTD")+ZZ1->ZZ1_REFNBR)))
            RecLock("CTD",.T.)
            CTD->CTD_FILIAL  := "01" 
            CTD->CTD_ITEM    := ZZ1->ZZ1_REFNBR
            CTD->CTD_CLASSE  := "2" 
            CTD->CTD_NORMAL  := "1" 
            CTD->CTD_DESC01  := "REF NBR " + ZZ1->ZZ1_REFNBR
            CTD->CTD_BLOQ    := "2"
            CTD->CTD_DTEXIS  := CTOD('01/01/80')
            CTD->CTD_ITLP    := "0"
            CTD->CTD_CLOBRG  := "2"         
            CTD->CTD_ACCLVL  := "1"         
            CTD->(MsUnlock())
         EndIf
      EndIF

   End Transaction

EndIf

Return


