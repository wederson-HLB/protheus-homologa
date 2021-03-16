
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldTplcto �Autor  �Adriane Sayuri Kamiya� Data �  02/20/11  ���

���Desc.     � N�o permite o usu�rio mudar a conta para o tipo hist�rico  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

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
 User Function VldTplcto() 
*--------------------------*
 
Local lRet := .T. 
                                                 
If !inclui
   If TMP->CT2_DC == '4' .AND. TMP->CT2_VALR04 > 0  
      MsgStop("N�o �Epermitido alterar o lan�amento para tipo Hist�rico.","Atencao!")
      lRet := .F.
   EndIf   
EndIf 
         
// 15/03/2012  - TLM valida��o para empresa Paypal
If cEmpAnt $ ("PD/PB/7W") 
	          
	//Partida dobrada n�o pode ser lan�ada devido a gera��o do arquivo de upload
	If M->CT2_DC == '3' 
		lRet:=.F.
      	MsgStop("N�o �Epermitido lan�amento de partida dobrada para o cliente Paypal.","HLB BRASIL - Aten��o")			
	EndIf

EndIf

          
Return lRet