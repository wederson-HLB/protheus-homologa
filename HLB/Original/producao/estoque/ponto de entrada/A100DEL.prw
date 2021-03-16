
/*
Funcao      : A100DEL
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para validação da exclusão da nota de entrada.
Autor     	: Tiago Luiz Mendonça
Data     	: 20/10/2009  
Obs         : 
TDN         : O P.E. e' chamado antes de qualquer atualizacao na exclusao e deve ser utilizado para validar se a exclusao deve ser efetuada ou nao.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 14/03/2012
Módulo      : Estoque.
Cliente     : Monavie / Veraz / Eurosilicone
*/

*-------------------------*
  User Function A100DEL()  
*-------------------------*

Local lRet:=.T.     
Local cQuery,aStruSD1,lControle
Local cText,aSays,aButtons,cRomaneio         

/*//AOA - 27/06/2019 - Empresa antiga, nao existe mais e foi reaproveitado o código da empresa 
If cEmpAnt $ "MV"

   lControle:= GETMV("MV_P_NEGAT")
                       
   If !(lControle)    
   
      If Select("SD1Temp") > 0
	     SD1Temp->(dbCloseArea())
      EndIf
      
      aStruSD1  := SD1->(dbStruct())
      cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO "
      cQuery    += "FROM "+RetSqlName("SD1")+" SD1 "
      cQuery    += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
      cQuery    += "SD1.D1_DOC='"+SF1->F1_DOC+"' AND "
      cQuery    += "SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND "
      cQuery    += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
      cQuery    += "SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND "
      cQuery    += "SD1.D1_TIPO='"+SF1->F1_TIPO+"' AND "
      cQuery    += "SD1.D_E_L_E_T_=' ' "
      cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SD1Temp",.T.,.T.)

      For nX := 1 To Len(aStruSD1)
         If aStruSD1[nX][2]<>"C"
            TcSetField("SD1Temp",aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
         EndIf
      Next nX             
      
      SF4->(DbSetOrder(1))
      If SF4->(DbSeek(xFilial("SF4")+SD1Temp->D1_TES))					                     
         If SF4->F4_ESTOQUE == "S"
            SB2->(DbSetOrder(1))					                     
	        SD1Temp->(DbGoTop())
	        While SD1Temp->(!EOF())
	           If SB2->(DbSeek(SD1Temp->D1_FILIAL+SD1Temp->D1_COD+SD1Temp->D1_LOCAL))   
	              If (SB2->B2_QATU-SD1Temp->D1_QUANT) < 0  
	                 MsgAlert("O item "+alltrim(SD1Temp->D1_COD)+" Arm. "+alltrim(SD1Temp->D1_LOCAL)+" ficará negativo, nota não pode ser excluída. ","Monavie - FIFO ")
                     lRet:=.F.   
                  EndIf      
	           EndIf
	        SD1Temp->(DbSkip())   	     
	        EndDo
	     EndIf
	  EndIf 
	  	       	    
   EndIf

EndIf   
*/

/*
Objetivos   : Ponto de entrada para validação da exclusão da nota de entrada  x Romaneio 
Autor       : Tiago Luiz Mendonça
Data/Hora   : 10/02/2009     
Obs         : Tratamento para interface de integração Veraz.
*/      

If cEmpAnt $ "KX/XC" //Veraz 
 
   ZX1->(DbSetOrder(2))
   If ZX1->(DbSeek(xFilial("ZX1")+SF1->F1_DOC+SF1->F1_SERIE))
   
      If ZX1->ZX1_VINC=='G'  .And. ZX1->ZX1_ORIGEM<>'LOC'    // Gerado e não Local deve ser estornado a movimentação antes da exclusão
   
         aSays:={}
         aButtons:={} 
          
         cText:="Estorno rejeitado"     
         Aadd(aSays,"Essa nota não pode ser estornada possui movimentação interna, ")
         Aadd(aSays,"gerada pela integração com Romaneio. " )  
         Aadd(aSays," ")   
         Aadd(aSays,"Solução: Estornar a movimentação na rotina de romaneio de entrada ")                                                                                                      
                                        
         Aadd(aButtons, { 1,.T.,{|o| o:oWnd:End() }} )
         //Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
   
         FormBatch( cText, aSays, aButtons,,200,405  ) 
         
         lRet:=.F.
    
      ElseIf ZX1->ZX1_VINC $ 'V' // Vinculado a romaneio 
      
         IF MsgYesNo("Essa nota possui vinculo com romaneio, deseja excluir ?","Veraz")
        
            lRet:=.T.     
            cRomaneio:=ZX1->ZX1_NUM    
            RecLock("ZX1",.F.)  
            ZX1->ZX1_VINC  :='N' //Order from Veraz Israel 
            ZX1->ZX1_NOTA  :=''   
            ZX1->ZX1_SERIE :='' 
            ZX1->ZX1_DT_NF :=CToD('  /  /  ')
            ZX1->(MsUnlock())
            ZX2->(DbSetOrder(1))
            ZX2->(DbSeek(xFilial("ZX2")+cRomaneio))
        
            While ZX2->(!EOF()) .And. Alltrim(cRomaneio)==ZX2->ZX2_NUM
               RecLock("ZX2",.F.)
               ZX2->ZX2_NOTA  :=''                            
               ZX2->ZX2_SERIE :=''
               ZX2->ZX2_DT_NF :=CToD('  /  /  ')
               ZX2->(MsUnlock())                  
               ZX2->(DbSkip())
            EndDo       
                  
            Alert("Estorno do vinculo com romaneio feito com sucesso, essa nota deve ser excluída.","Veraz")
     
         Else
            lRet:=.F.
         EndIf
      ElseIf ZX1->ZX1_VINC $ 'G' .And. ZX1->ZX1_ORIGEM=='LOC'   
      
         IF MsgYesNo("Essa nota possui vinculo com romaneio, deseja excluir ?","Veraz")
        
            lRet:=.T.     
            cRomaneio:=ZX1->ZX1_NUM    
            RecLock("ZX1",.F.)  
            ZX1->ZX1_VINC  :='L' //Order from Veraz Brazil
            ZX1->ZX1_NOTA  :=''   
            ZX1->ZX1_SERIE :='' 
            ZX1->ZX1_DT_NF :=CToD('  /  /  ')
            ZX1->(MsUnlock())
            ZX2->(DbSetOrder(1))
            ZX2->(DbSeek(xFilial("ZX2")+cRomaneio))
        
            While ZX2->(!EOF()) .And. Alltrim(cRomaneio)==ZX2->ZX2_NUM
               RecLock("ZX2",.F.)
               ZX2->ZX2_NOTA  :=''                            
               ZX2->ZX2_SERIE :=''
               ZX2->ZX2_DT_NF :=CToD('  /  /  ')
               ZX2->(MsUnlock())                  
               ZX2->(DbSkip())
            EndDo       
                  
            Alert("Estorno do vinculo com romaneio feito com sucesso, essa nota deve ser excluída.","Veraz")
     
         Else
            lRet:=.F.
         EndIf
          
      EndIf

   EndIf
   
EndIf 

/*
Objetivos   : Ponto de entrada para validação da exclusão da nota de entrada  x Numero de Serie
Autor       : Tiago Luiz Mendonça
Data/Hora   : 16/12/2010     
Obs         : Tratamento de numeração de serie EUROSILICONE
*/      
      
If cEmpAnt $ "3U"  

   ZX0->(DbSetOrder(2))
   If ZX0->(DbSeek(xFilial("ZX0")+SF1->F1_DOC+SF1->F1_SERIE))
      
      If ZX0->ZX0_STATUS<>"SEM"
         lRet:=.F.
         MsgStop("Essa nota possui vinculo com serie ou seu(s) iten(s) já foram faturados, não poderá ser excluída. Verificar na rotina de inclusão de serie.","EUROSILICONE")  
      Else
         lRet:=.T.            
         RecLock("ZX0",.F.)                    
         DbDelete()
         ZX0->(MsUnlock())

         ZX1->(DbSetOrder(2))  
         If ZX1->(DbSeek(xFilial("ZX1")+SF1->F1_DOC+SF1->F1_SERIE)) 
            While ZX1->(!Eof()) .And. SF1->F1_DOC+SF1->F1_SERIE==ZX1->ZX1_DOC+ZX1->ZX1_SERIE
               RecLock("ZX1",.F.)                    
               DbDelete()
               ZX1->(MsUnlock()) 
            
               ZX1->(DbSkip())  
            EndDo
         EndIF      
         
      EndIf                  
   
                        
   EndIf
 
      
EndIf


Return lRet






