
/*
Funcao      : VldCpo
Parametros  : cCampo
Retorno     : .T. ou .F.
Objetivos   : Validação de campo  / Validação de campo para Nota Fiscal Eletronica
Autor       : Tiago Luiz Mendonça
Obs.        :
*/

*----------------------------------*
    User Function VldCpo(cCampo)  
*----------------------------------*  

Local lRet:=.F. 
Local nPos:=0 

Do Case
 
   Case cCampo == "A2_COD"
     
      If (Len(alltrim(M->A2_COD))<6)
         MsgStop("Numero deve ter 6 caracteres") 
         Return .F.      
      Else
         lRet:=.t.
      EndIf   
             
   Case cCampo == "A1_COD"  
     
      If (Len(alltrim(M->A1_COD))<6)
         MsgStop("Numero deve ter 6 caracteres") 
         Return .F.      
      Else
         lRet:=.t.
      EndIf    
      
   Case cCampo == "B1_COD" //Okuma 
                 
      nPos+=At("\",Alltrim(M->B1_COD))  
      nPos+=At("/",Alltrim(M->B1_COD))
      nPos+=At(".",Alltrim(M->B1_COD))
      nPos+=At("-",Alltrim(M->B1_COD))  
      nPos+=At(",",Alltrim(M->B1_COD))
      nPos+=At(";",Alltrim(M->B1_COD))
      nPos+=At("'",Alltrim(M->B1_COD)) 
      nPos+=At("^",Alltrim(M->B1_COD))
      nPos+=At("~",Alltrim(M->B1_COD))
      nPos+=At(" ",Alltrim(M->B1_COD))    
      
      If nPos > 0    
         MsgStop("Formato inválido","Okuma") 
         Return .F. 
      EndIf 
                 
      
     lRet:=.T. 
       
   Case cCampo == "B5_CEME"  // Empresas com nota fiscal eletrônica.
                 
     // nPos+=At("\",Alltrim(M->B5_CEME))  
     // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->B5_CEME))
      nPos+=At(">",Alltrim(M->B5_CEME))    
      nPos+=At("º",Alltrim(M->B5_CEME))  
      nPos+=At("ª",Alltrim(M->B5_CEME))                                 
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F. 
      EndIf 
      
     lRet:=.T.    
     
   Case cCampo == "A1_END"  // Empresas com nota fiscal eletrônica.
                 
      // nPos+=At("\",Alltrim(M->B5_CEME))  
      // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->A1_END))
      nPos+=At(">",Alltrim(M->A1_END))    
      nPos+=At("º",Alltrim(M->A1_END))  
      nPos+=At("ª",Alltrim(M->A1_END))                                     
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F. 
      EndIf 
      
      lRet:=.T.  
    
   Case cCampo == "A2_END"  // Empresas com nota fiscal eletrônica.
                 
      // nPos+=At("\",Alltrim(M->B5_CEME))  
      // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->A2_END))
      nPos+=At(">",Alltrim(M->A2_END))    
      nPos+=At("º",Alltrim(M->A2_END))  
      nPos+=At("ª",Alltrim(M->A2_END))  
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F. 
      EndIf 
      
      lRet:=.T.  
      
   Case cCampo == "C5_MENNOTA"  // Empresas com nota fiscal eletrônica.
                 
      // nPos+=At("\",Alltrim(M->B5_CEME))  
      // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->C5_MENNOTA))
      nPos+=At(">",Alltrim(M->C5_MENNOTA))    
      nPos+=At("º",Alltrim(M->C5_MENNOTA))  
      nPos+=At("ª",Alltrim(M->C5_MENNOTA))                                    
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F. 
      EndIf 
      
      lRet:=.T.             
                         
   Case cCampo == "A1_COMPLEMEN"  // Empresas com nota fiscal eletrônica.
                 
      // nPos+=At("\",Alltrim(M->B5_CEME))  
      // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->A1_COMPLEMEN))
      nPos+=At(">",Alltrim(M->A1_COMPLEMEN))    
      nPos+=At("º",Alltrim(M->A1_COMPLEMEN))  
      nPos+=At("ª",Alltrim(M->A1_COMPLEMEN))  
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F.            
      EndIf 
       
      lRet:=.T.  
   
   Case cCampo == "A2_COMPLEMEN"  // Empresas com nota fiscal eletrônica.
                 
      // nPos+=At("\",Alltrim(M->B5_CEME))  
      // nPos+=At("/",Alltrim(M->B5_CEME))
      nPos+=At("<",Alltrim(M->A2_COMPLEMEN))
      nPos+=At(">",Alltrim(M->A2_COMPLEMEN))    
      nPos+=At("º",Alltrim(M->A2_COMPLEMEN))  
      nPos+=At("ª",Alltrim(M->A2_COMPLEMEN))                                     
      
      If nPos > 0    
         MsgStop("Formato inválido","NFE") 
         Return .F. 
      EndIf 
      
      lRet:=.T. 
      
   Case cCampo == "D1_TES"  // Empresas que utilizam EIC
   
      If buscAcols("D1_CONHEC") <> ' '
         SF4->(DbSetOrder(1))
         If SF4->(DbSeek(xFilial("SF4")+M->D1_TES))
            If !(SF4->F4_AGREG $ 'B/C')
               MsgSTOP("ESSE NOTA FOI GERADA PELO EIC: TES INFORMADA NÃO É DE IMPORTAÇÃO, OS VALORES DOS IMPOSTOS FORAM ALTERADOS, FAVOR SAIR SEM GRAVAR, CLICAR EM CLASSIFICAR E INFORMAR A TES CORRETA.","HLB")           
            EndIf
         EndIf      
      EndIf
      
      lRet:=.T.   
   
EndCase  
  

Return lRet    
               


