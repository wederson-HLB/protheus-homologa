#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

User Function lp6202cre()        // incluido pelo assistente de conversao do AP5 IDE em 15/01/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ6ÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Execblock criado para retorna o valor do IRRF

Local vConta
Local cCfop:= "5949/6949/7949/5933/6933"
                                       	
vConta:="   "
SF4->(DbSetOrder(1))
SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
	
If SF4->F4_ISS == "S" .OR. ALLTRIM(SD2->D2_SERIE) == "ND"
   SB1->(DbSetOrder(1))
   SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
   If AllTrim(SM0->M0_CODIGO)$"Z4/RH/Z6/Z8/ZP" 
      If ALLTRIM(SD2->D2_CF) $ cCfop 
         IF SA1->A1_EST $ "EX"
            vConta:="311102022"
         ELSE
            vConta:= SB1->B1_CONTA
         ENDIF
      Else 
         vConta:=""
      EndIf   
   ElseIf AllTrim(SM0->M0_CODIGO) $ "CY"
      If Alltrim(SD2->D2_CF) $ cCfop
         IF SA1->A1_EST $ "EX"
            vConta:="311102022"
         ELSE
            vConta:="311101001"
         ENDIF
      ELSE
         vConta:="   "
      ENDIF
   ElseIf AllTrim(SM0->M0_CODIGO) $ "DJ/JN/E7/ZK/FB/DT/CJ/DN/48/GV/JG/S8/S9/SI"
      SB1->(DbSetOrder(1))
      SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
      vconta := SB1->B1_CONTA  

   ElseIf AllTrim(SM0->M0_CODIGO) $ "ED"    //JSS - Add tratamento para solucionar caso 021889
	  IF SD2->D2_TES="56V" .AND. SD2->D2_COD = "1406"
	      vconta := "311101007"   
	  ENDIF                     
	  //CAS - 31/07/2017 tratamento da empresa ED (OKUMA) para o Ticket #5976
	  If ALLTRIM(SD2->D2_CODISS) == "01880" 	
  	      vconta := "311101005"	  	  
  	  ElseIF ALLTRIM(SD2->D2_CODISS) == "06009" .AND. ALLTRIM(SF2->F2_EST) <> "EX"  	//Nacional
  	      vconta := "311101005"	  	  
  	  ElseIF ALLTRIM(SD2->D2_CODISS) == "06009" .AND. ALLTRIM(SF2->F2_EST) == "EX"		//Exterior
  	      vconta := "311102022"	  	  
  	  ElseIF ALLTRIM(SD2->D2_CODISS) == "07315"
  	      vconta := "311101007"	 
  	  ElseIF ALLTRIM(SD2->D2_CODISS) == "07498"
  	      vconta := "311101008"	  
  	  Else
  	  	  vconta := SB1->B1_CONTA 
  	  EndIF 
	  
   ElseIf AllTrim(SM0->M0_CODIGO) $ "U6" 	//CAS - 21/02/2017 tratamento da empresa U6 (INTRALOX) para o chamado 039333
      If ALLTRIM(SD2->D2_CF) $ cCfop 
         IF SA1->A1_EST$"EX"
            vConta:="311102022"
         ELSE
            vConta:="311101007"
         ENDIF   
      Else 
         vConta:=""
      EndIf          
   Else  
      If Alltrim(SD2->D2_CF) $ cCfop
         IF SA1->A1_EST$"EX"
            vConta:="311102022"
         ELSE
            vConta:="311101005"
         ENDIF
      ELSE
         vConta:="   "
      ENDIF
   EndIf
EndIf
			 
Return(vConta)
