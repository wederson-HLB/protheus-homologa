
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VldTplcto ∫Autor  ≥Adriane Sayuri Kamiya∫ Data ≥  02/20/11  ∫±±

±±∫Desc.     ≥ N„o permite o usu·rio mudar a conta para o tipo histÛrico  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

Funcao      : VLDTPLCTO
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : N„o permite o usu·rio mudar a conta para o tipo histÛrico
Autor     	: Adriane Sayuri Kamiya	 	
Data     	: 02/20/2011
Obs         : 
TDN         : 
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 15/03/2012
MÛdulo      : Contabilidade.
*/                               
    
*--------------------------*
 User Function VldTplcto() 
*--------------------------*
 
Local lRet := .T. 
                                                 
If !inclui
   If TMP->CT2_DC == '4' .AND. TMP->CT2_VALR04 > 0  
      MsgStop("N„o ÅEpermitido alterar o lanÁamento para tipo HistÛrico.","Atencao!")
      lRet := .F.
   EndIf   
EndIf 
         
// 15/03/2012  - TLM validaÁ„o para empresa Paypal
If cEmpAnt $ ("PD/PB/7W") 
	          
	//Partida dobrada n„o pode ser lanÁada devido a geraÁ„o do arquivo de upload
	If M->CT2_DC == '3' 
		lRet:=.F.
      	MsgStop("N„o ÅEpermitido lanÁamento de partida dobrada para o cliente Paypal.","HLB BRASIL - AtenÁ„o")			
	EndIf

EndIf

          
Return lRet