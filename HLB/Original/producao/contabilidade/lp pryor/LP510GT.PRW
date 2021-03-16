#include "rwmake.ch"      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP510GT   ºAutor  ³Juliana Mellao      º Data ³  27/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Referente ao LP 510 para os ambientes GT                   º±±
±±º          ³ Atualiza a conta crédito do novo plano de contas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GT                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 


User Function LP510GT()   
                                        
SetPrvt("_CCREDITO,")

   _CCREDITO := " "
   ComparaCC := " "
   
IF GetMv("MV_MCONTAB") $ "CTB" 
	ComparaCC:=paramixb
ENDIF                          

	IF Alltrim(ComparaCC) $ "531003"
      SE2->(DbSetOrder(1))
      SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+" "))
	EndIf 
	
	IF cEmpAnt = '40'//JSS - 23/09/2014 - CHAMADO 021508
			IF AllTrim(FUNNAME())$ "FINA370" 				  ///JSS 19/11/2014 -  Alterado para solucionar caso 022701
			     SA6->(DbSetOrder(1))	///A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
			     SA6->(DbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
    	     	_CCREDITO:= SA6->A6_CONTA		
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105"  		  /// IRRF S/SALARIOS
			    _CCREDITO:="21105004"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2106"  		  /// IRRF S/FERIA
			    _CCREDITO:="21105004"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2114"       	  /// IRRF S/13. SALARIO
				_CCREDITO:="21105004" 
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2201"            /// INSS S/SALARIOS
			    _CCREDITO:="21104001"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"		      /// FGTS S/SALARIOS
				_CCREDITO:="21104002"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2204"            /// INSS 13. SALARIO
				_CCREDITO:="21104001"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2205"            /// FGTS S/13. SALARIO
				_CCREDITO:="21104002"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101"     	      /// ISS S/ SERV.PRESTADOS
				_CCREDITO:="21105009"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102" 		      /// PIS S/FATURAMENTO
				_CCREDITO:="21105011"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS
				_CCREDITO:="21105012"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201"		  	  /// INSS RETIDO               
				_CCREDITO:="21105008"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202" 		      /// IRRF S/ SERVICOS
				_CCREDITO:="21105007" 
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4206" 		      /// ISS RETIDO
				_CCREDITO:="21105009"                    
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4207"  	      /// OUTROS IMPOSTOS RETIDOS 
				_CCREDITO:=" " 
			ELSE
				_CCREDITO:=SA2->A2_CONTA
			ENDIF
						
	ELSE//JSS
	        
			IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
			    _CCREDITO:="21115003"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
			    _CCREDITO:="21115003"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       /// INSS S/SERVIÇOS
				_CCREDITO:="21116013" 
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            /// FGTS SOBRE SALARIOS
			    _CCREDITO:="21115004"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       /// TLIF/TRSD
				_CCREDITO:="21111001"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4609"           /// TLIF/ - AOA - 10/05/2016 - Inclusão de conta para nova natureza, chamado 033575
				_CCREDITO:="21111003"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            /// IPTU
				_CCREDITO:="211230001"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" /// ISS S/SERVIÇOS PRESTADOS   --- ISS RETIDO
				_CCREDITO:="211220005"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      /// ICMS
				_CCREDITO:="21116001"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3108" .AND. cEmpAnt = 'N6' /// ICMS DIFAL / - HMO - 27/08/2018 - Inclusão de conta para natureza, Ticket #43972
				_CCREDITO:="21116015"				
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      /// IPI
				_CCREDITO:="21116002"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS s/faturamento
				_CCREDITO:="21116004"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      /// COFINS s/servicos                   
				_CCREDITO:="21116005"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      /// CSLL faturamento
				_CCREDITO:="21116010" 
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      /// CSLL s/servicos
				_CCREDITO:="21116011"                    
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      /// PIS SOBRE FATURAMENTO  
				_CCREDITO:="21116006"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      /// PIS SOBRE servicos
				_CCREDITO:="21116007"
		    ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
				_CCREDITO:="21115005"                                        
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        /// IRRF S/SERVIÇOS 
				_CCREDITO:="21116009"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	      /// IRPJ
				_CCREDITO:="21116008"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		      /// IPVA
				_CCREDITO:="21111001"   
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2906"			  /// IR S/ INVOICE
				_CCREDITO:="21116009"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2907"			  /// IOF S/ INVOICE
				_CCREDITO:="21116016"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2908"			  /// PIS S/ INVOICE
				_CCREDITO:="21116006"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2909"			  /// COFINS S/ INVOICE
				_CCREDITO:="21116004"
			ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2910"			  /// CIDE S/ INVOICE
				_CCREDITO:="21116014"
			ELSE
				_CCREDITO:=SA2->A2_CONTA
			ENDIF
	
	ENDIF //JSS
  
Return(_CCREDITO)   