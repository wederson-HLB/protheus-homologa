/*
Funcao      : VLDTPLCTO
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : N�o permite o usu�rio mudar a conta para o tipo hist�rico
Autor     	: Adriane Sayuri Kamiya	 	
Data     	: 02/20/2011
Obs         : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 15/03/2012
M�dulo      : Contabilidade.
*/

*--------------------------*
User Function VldTplcto 
*--------------------------*
Local lRet := .T. 
                                                 
If !inclui
   If TMP->CT2_DC == '4' .AND. TMP->CT2_VALR04 > 0  
      MsgStop("N�o � permitido alterar o lan�amento para tipo Hist�rico.","Atencao!")
      lRet := .F.
   EndIf   
EndIf

Return(lRet)