/*
Funcao      : VLDTPLCTO
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Não permite o usuário mudar a conta para o tipo histórico
Autor     	: Adriane Sayuri Kamiya	 	
Data     	: 02/20/2011
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Contabilidade.
*/

*--------------------------*
User Function VldTplcto 
*--------------------------*
Local lRet := .T. 
                                                 
If !inclui
   If TMP->CT2_DC == '4' .AND. TMP->CT2_VALR04 > 0  
      MsgStop("Não é permitido alterar o lançamento para tipo Histórico.","Atencao!")
      lRet := .F.
   EndIf   
EndIf

Return(lRet)