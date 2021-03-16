
/*
Funcao      : MT410ALT
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Altera��o do produto limpar o campo C5_P_STATS
Autor     	: Tiago Luiz Mendon�a
Data     	: 08/09/08 
Obs         : 
TDN         : P.E. Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). Est� localizado na rotina de altera��o do pedido, A410ALTERA(). � executado ap�s a grava��o das altera��es.
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 14/03/2012
M�dulo      : Faturamento.
Cliente     : Dr Reddys / Shiseido
*/

*------------------------*
 User Function MT410ALT()
*------------------------*

Local dData:=""   
      
If cEmpAnt $ "U2"   

   If SC5->(FieldPos("C5_P_STATS")) > 0
   
      If MSGYESNO("Deseja reenviar o arquivo de pedido para Ativa ? Ser� gravado um log desse procedimento.")
   
         If SC5->C5_P_STATS == "E"
   
            Reclock("SC5",.F.)
            SC5->C5_P_STATS := ""
            MSUnlock()  
   
            SC6->(DbSetOrder(1))         
            If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))  
               
               While SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM    
               
                  Reclock("SC6",.F.)
                  SC6->C6_LOTECTL := ""
                  SC6->C6_DTVALID := STOD(dData)
                  MSUnlock()    
                  SC6->(DbSkip())
                  
               EndDo
   
               ZRD->(DbSetOrder(3))  
               If ZRD->(DbSeek(xFilial("ZRD")+SC5->C5_NUM))
                  
                  Reclock("ZRD",.F.) 
                  ZRD->ZRD_OBS   := "Aten��o pedido alterado, necess�rio gera-lo novamente para Ativa."
                  ZRD->ZRD_USER  := cUserName
                  ZRD->ZRD_RETOK  :="N"
                  MSUnlock()    
                  
               EndIf                    
   
            EndIf 
   
         EndIf                          
   
      EndIf            
   
   EndIf        
   
EndIf
     

If cEmpAnt $ "R7"
  If SC5->(FieldPos("C5_DESCTAB")) > 0  
     If SC5->C5_DESCTAB > 0
        SC6->(DbSetOrder(1))         
        If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))  
           If SC5->C5_DESCTAB <> SC6->C6_DESCONT 
              If MSGYESNO("Deseja recalcular o desconto?")   
                 While SC5->C5_FILIAL == SC6->C6_FILIAL .AND. SC5->C5_NUM == SC6->C6_NUM
                    DA1->(DbSetOrder(1))
                    If DA1->(DbSeek(xFilial("DA1")+SC5->C5_TABELA+SC6->C6_PRODUTO))
                       Reclock("SC6",.F.)
                        SC6->C6_PRCVEN  := ROUND(DA1->DA1_PRCVEN*((100-M->C5_DESCTAB)/100),2) 
                        SC6->C6_PRUNIT  := DA1->DA1_PRCVEN
                        SC6->C6_VALOR   := SC6->C6_QTDVEN*(ROUND(DA1->DA1_PRCVEN*((100-M->C5_DESCTAB)/100),2))
                        SC6->C6_DESCONT := M->C5_DESCTAB
                        SC6->C6_VALDESC := ROUND(DA1->DA1_PRCVEN*(M->C5_DESCTAB/100),2)*SC6->C6_QTDVEN                                           
                        MSUnlock()    
                    EndIf
                    SC6->(DbSkip())
                 EndDo  
              EndIf
           EndIf   
        EndIf
     EndIf
  EndIf
EndIf

Return 
