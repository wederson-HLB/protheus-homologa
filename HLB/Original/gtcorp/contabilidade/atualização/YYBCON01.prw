
/*
Funcao      : YYBCON01
Parametros  : 
Retorno     : 
Objetivos   : Alterar o lançamento padrão no cadastro de verbas.
Autor       : Wederson Lourenco
Data/Hora   : 18/01/2006    15:41
Revisão	    : Matheus Massarotto                   
Data/Hora   : 30/08/2012    15:19
Módulo      : Contabilidade
*/

#Include "rwmake.ch" 
#Include "colors.ch"   
User Function YYBCON01()

//If __cUserId $ "000015/000000/" //Haidee/Administrador/
   aRotina  := {{"Pesquisar",'AxPesqui',0,1},{"Alterar",'U_fAlterar()',0,2 }}
   MBrowse( 6,1,22,75,"SRV",,,,,,,,)
//Else
//    MsgInfo("Usuario sem permissao !","A T E N C A O")
//Endif

Return

//-----------------------------------------Alteração da LP

User Function fAlterar     
cVerba:= SRV->RV_COD
cDesc := SRV->RV_DESC
cLp   := SRV->RV_LCTOP

@ 200,001 To 380,420 Dialog oLeTxt Title "Alterar"
@ 001,002 To 015,209 
@ 016,002 To 089,209 
@ 005,004 Say "Verba" COLOR CLR_HBLUE, CLR_WHITE 
@ 005,030 Say "Descricao" COLOR CLR_HBLUE, CLR_WHITE 
@ 005,130 Say "LP" COLOR CLR_HBLUE, CLR_WHITE 
@ 025,005 Say cVerba 
@ 025,030 Get cDesc Size 100,100 When .F.
@ 025,130 Get cLp Size 40,40 F3 "CT5"  
@ 070,128 BmpButton Type 01 Action fOkGrava()
@ 070,158 BmpButton Type 02 Action Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return
      
//-------------------------------

Static Function fOkGrava()
Close(oLeTxt)
Reclock("SRV",.F.)
Replace SRV->RV_LCTOP With cLp
MsUnlock()
Return