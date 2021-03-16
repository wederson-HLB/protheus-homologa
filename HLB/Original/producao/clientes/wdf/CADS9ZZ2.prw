#INCLUDE "rwmake.ch"  

/*
Funcao      : CADS9ZZ2
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cadastro de Ref. NBR   
Autor     	: Adriane Sayuri Kamiya
Data     	: 15/04/2009 
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 13/03/2012
Módulo      : Faturamento..
*/

*-----------------------*
  User Function CADS9ZZ2
*-----------------------*

Private cAlias    := "ZZ2"
Private aRotina   := {}
Private cCadastro := "REF. NBR"

AAdd( aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1} )
AAdd( aRotina, {"Visualizar", "AxVisual"   , 0, 2} )
AAdd( aRotina, {"Incluir"   , "u_ZZ2Inclui", 0, 3} )
AAdd( aRotina, {"Alterar"   , "AxAltera"   , 0, 4} )
AAdd( aRotina, {"Excluir"   , "AxDeleta"   , 0, 5} )

dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(,,,,cAlias)

Return Nil

//----------------------------------------------------------------------------//
User Function ZZ2Inclui(cAlias, nRegistro, nOpcao)

Local nConfirmou

nConfirmou := AxInclui(cAlias, nRegistro, nOpcao)

If nConfirmou == 1      // Confirmou a inclusao.

   Begin Transaction

      If !Empty(ZZ2->ZZ2_REGIST)
         DbSelectArea("CTH")
         CTH->(DbSetOrder(1))
         CTH->(DbGoTop())
         If !(CTH->(DbSeek(xFilial("CTH")+ZZ2->ZZ2_REGIST)))
            RecLock("CTH",.T.)
            CTH->CTH_FILIAL  := "01" 
            CTH->CTH_CLVL    := ZZ2->ZZ2_REGIST
            CTH->CTH_CLASSE  := "2" 
            CTH->CTH_NORMAL  := "2" 
            CTH->CTH_DESC01  := ZZ2->ZZ2_REGIST
            CTH->CTH_BLOQ    := "2"
            CTH->CTH_DTEXIS  := CTOD('01/01/80')
            CTH->CTH_CLVLLP  := "0"
            CTH->(MsUnlock())
         EndIf
      EndIF

   End Transaction

EndIf

Return


