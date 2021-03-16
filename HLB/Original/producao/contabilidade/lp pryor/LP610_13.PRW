#include "rwmake.ch"       

User Function LP610_13()   

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴6컴컴컴컴컴컴컴?

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
            vConta:="31113002"
         ELSE
            vConta:= SB1->B1_CONTA
         ENDIF
      Else 
         vConta:=""
      EndIf

	// PAULO SILVA - EZ4 EMPRESA - FAIR - CH#23525
   ElseIf AllTrim(SM0->M0_CODIGO)    $ "10"
 	  If ALLTRIM(SD2->D2_CODISS) 	 $ "02800" 
      	vconta := "31113003"       
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "02919" 
	   	vconta := "31113006"   
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "03115" 
	   	vconta := "31113005"	   	
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "05762" 
	   	vconta := "31113005" 
         ENDIF
      ELSE
        vConta:="   "
      ENDIF
      
   ElseIf AllTrim(SM0->M0_CODIGO) $ "JB"   //CAS - 21/06/2017 - Inserido bloco da "JB" para solucionar o chamado 040143 (Mudar conta para 31111002).
      If Alltrim(SD2->D2_CF) $ cCfop
         IF SA1->A1_EST $ "EX"
            vConta:="31111002"
         ELSE
            vConta:="31111001"
         ENDIF
      ELSE
         vConta:="   "
      ENDIF
   ElseIf AllTrim(SM0->M0_CODIGO) $ "CY"
      If Alltrim(SD2->D2_CF) $ cCfop
         IF SA1->A1_EST $ "EX"
            vConta:="31113002"
         ELSE
            vConta:="31111001"
         ENDIF
      ELSE
         vConta:="   "
      ENDIF
   ElseIf AllTrim(SM0->M0_CODIGO) $ "DJ/JN/E7/ZK/FB/DT/CJ/DN/48/GV/JG/S8/S9"
      SB1->(DbSetOrder(1))
      SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
      vconta := SB1->B1_CONTA
  //JSS - 05/12/2014 - Ajusta para solucionar o caso 022874.    
   ElseIf AllTrim(SM0->M0_CODIGO)    $ "4Z"
 	  If ALLTRIM(SD2->D2_CODISS) 	    $ "05762" 
      	vconta := "311130011"       
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "02917" 
	   	vconta := "311130012"   
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "02879" 
	   	vconta := "311130013"	   	
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "02798" 
	   	vconta := "311130014"      	   	   	
      ElseIf ALLTRIM(SD2->D2_CODISS) $ "03115" 
	   	vconta := "31114002"  
	  EndIf
   Else 

      If Alltrim(SD2->D2_CF) $ cCfop
         IF SA1->A1_EST$"EX"
			If AllTrim(SM0->M0_CODIGO) $ "AW"
				vconta := "31117001"
			Else	
				vConta:="31113002"
			EndIf
         Else
			If  AllTrim(SM0->M0_CODIGO) $ "UY/AW" 
				vConta:="31113003"
			Else
				vConta:="31113001"
			EndIf
		 ENDIF
      ELSE                                    
         vConta:="   "
      ENDIF
   EndIf
	 
Return(vConta)
