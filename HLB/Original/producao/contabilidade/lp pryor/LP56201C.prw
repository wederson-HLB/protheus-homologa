#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02
#include "protheus.ch"                      

User Function LP56201C()        // incluido pelo assistente de conversao do AP5 IDE em 13/11/02

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_CCREDITO,")
SetPrvt("cNaturez")

//If AllTrim(FUNNAME())$ "FINA080"   Teste - Wederson
//   If Empty(cCheque)
//      Return("")
//   Endif
//Endif

_CCREDITO := " "
ComparaCC := " "

IF GetMv("MV_MCONTAB") $ "CTB"
	ComparaCC:=paramixb
ENDIF

IF Alltrim(ComparaCC) $ "531003"
	SE2->(DbSetOrder(1))
	SE2->(DbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECEDOR)) //CAS - 02/02/2017, Complementado o indice com E2_PARCELA+E2_TIPO+E2_FORNECEDOR-Chamado:036037
EndIf

IF SM0->M0_CODIGO $"02/VB/Z4/CH/BY/LA/GP/"         /// EMPRESAS DO GRUPO PRYOR
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		   /// INSS SOBRE SALARIOS
		_CCREDITO:="211310004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201" 		   /// inss s/servicos
		_CCREDITO:="211230004"                     ///alterado a peedido da haidee cham. 3830
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"         /// FGTS SOBRE SALARIOS
		_CCREDITO:="211310005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"    /// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"         /// IPTU
		_CCREDITO:="211230001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206"    /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="211220005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	   /// ICMS
		_CCREDITO:="211220001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		   /// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		   /// COFINS s/faturamento
		_CCREDITO:="211220004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		   /// COFINS s/servicos
		_CCREDITO:="211230009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		   /// CSLL faturamento
		_CCREDITO:="211210003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		   /// CSLL s/servicos
		_CCREDITO:="211230010"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	   /// PIS SOBRE FATURAMENTO
		_CCREDITO:="211220003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	   /// PIS SOBRE servicos
		_CCREDITO:="211230011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"    /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="211230002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202" 		   /// IRRF S/SERVI?S
		_CCREDITO:="211230003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	   /// IRPJ
		_CCREDITO:="211210001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		   /// IPVA
		_CCREDITO:="211130001"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
	
	// EBF - 29/11/2013 - ALTERA플O PARA ATENDER O CHAMADO 015610
	// RPB - 30/06/2016 - ALTERA플O PARA ATENDER AO CHAMADO 034741
	// RPB - 02/08/2016 - ALTERA플O PARA ATENDER AO CHAMADO 035205 - VALIDA플O DAS NATUREZAS 3111 E 3112 NA BAIXA POR BORDERO
ELSEIF SM0->M0_CODIGO $"1Z"
	IF ALLTRIM(SE2->E2_NATUREZ)$"4212"	           /// COFINS s/servicos
		_CCREDITO:="21116012"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 	       /// CSLL s/servicos
		_CCREDITO:="21116012"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	   /// PIS SOBRE servicos
		_CCREDITO:="21116012"  
    ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202"		   /// IRRF SOBRE SERVI?S 
		_CCREDITO:="21116009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3111"		   /// COFINS SOBRE FATURAMENTO  
		_CCREDITO:="21116004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3112"		   /// PIS SOBRE FATURAMENTO
		_CCREDITO:="21116006"
	
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
	
ELSEIF SM0->M0_CODIGO $"53"
	IF ALLTRIM(SE2->E2_NATUREZ)$"4211"  		   /// PIS - Boston
		_CCREDITO:="21240004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212" 		   /// Cofins - Boston
		_CCREDITO:="21240005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213"         /// Csll - Boston
		_CCREDITO:="21240006"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202"         /// IRRF - Boston
		_CCREDITO:="21240002"
	ELSEIF ALLTRIM (SE2->E2_NATUREZ)$"4201"        /// INSS TERC - Boston
		_CCREDITO:="21210007"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
	
ELSEIF SM0->M0_CODIGO $"FI"   //COVIT
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
		_CCREDITO:="211310004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       /// INSS S/SERVI?S
		_CCREDITO:="211230004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            /// FGTS SOBRE SALARIOS
		_CCREDITO:="211310005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       /// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            /// IPTU
		_CCREDITO:="211230001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4206/MUNIC"      /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="211230011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101"            /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="211220005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      /// ICMS
		_CCREDITO:="211220001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      /// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS s/faturamento
		_CCREDITO:="211220004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      /// COFINS s/servicos
		_CCREDITO:="211230008"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      /// CSLL faturamento
		_CCREDITO:="211210003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      /// CSLL s/servicos
		_CCREDITO:="211230009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      /// PIS SOBRE FATURAMENTO
		_CCREDITO:="211220003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      /// PIS SOBRE servicos
		_CCREDITO:="211230010"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="211230002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        /// IRRF S/SERVI?S
		_CCREDITO:="211230003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	      /// IRPJ
		_CCREDITO:="211210001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		      /// IPVA
		_CCREDITO:="211130001"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
ELSEIF SM0->M0_CODIGO $ "F2"
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
		_CCREDITO:="211310004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       /// INSS S/SERVI?S
		_CCREDITO:="211230004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            /// FGTS SOBRE SALARIOS
		_CCREDITO:="211310005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       /// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            /// IPTU
		_CCREDITO:="211230001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="211220005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      /// ICMS
		_CCREDITO:="211220001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      /// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS s/faturamento
		_CCREDITO:="211220004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      /// COFINS s/servicos
		_CCREDITO:="211230009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      /// CSLL faturamento
		_CCREDITO:="211210003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      /// CSLL s/servicos
		_CCREDITO:="211230010"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      /// PIS SOBRE FATURAMENTO
		_CCREDITO:="211220003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      /// PIS SOBRE servicos
		_CCREDITO:="211230011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="211230002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        /// IRRF S/SERVI?S
		_CCREDITO:="211230003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	      /// IRPJ
		_CCREDITO:="211210001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		      /// IPVA
		_CCREDITO:="211130001"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
ELSEIF SM0->M0_CODIGO $ "40"  //JSS
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"// INSS SOBRE SALARIOS
		_CCREDITO:="21104001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"// INSS S/SERVI?S
		_CCREDITO:="21105008"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"// FGTS SOBRE SALARIOS
		_CCREDITO:="21104002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC"// ISS S/SERVI?S PRESTADOS
		_CCREDITO:="21105001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC"// ISS S/SERVICOS A RECOLHER
		_CCREDITO:="21105009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"// COFINS s/faturamento
		_CCREDITO:="21105006"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"// COFINS s/servicos
		_CCREDITO:="21105012"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213"// CSLL s/servicos
		_CCREDITO:="21105013"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"// PIS SOBRE FATURAMENTO
		_CCREDITO:="21105005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"// PIS SOBRE servicos
		_CCREDITO:="21105011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105"// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="21105004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"// IRRF S/SERVI?S
		_CCREDITO:="21105007"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"// IRPJ
		_CCREDITO:="21111002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902"// CSLL
		_CCREDITO:="21111001"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
ELSEIF SM0->M0_CODIGO $ "B1"  //JSS ZOOM - CHAMADO 029887
	IF(SE2->E2_NATUREZ)$"2201" /// INSS SOBRE SALARIOS
		_CCREDITO:="21115003"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS" /// INSS S/SERVI?S
		_CCREDITO:="21116013"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202" /// FGTS SOBRE SALARIOS
		_CCREDITO:="21115004"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203" /// IPTU
		_CCREDITO:="21124003"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" /// ISS S/SERVI?S PRESTADOS --- ISS RETIDO PARA 21116015
		_CCREDITO:="21116015"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104" /// ICMS
		_CCREDITO:="21116001"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" /// IPI
		_CCREDITO:="21116002"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103" /// COFINS s/faturamento
		_CCREDITO:="21116004"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212" /// COFINS s/servicos
		_CCREDITO:="21116012"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" /// CSLL faturamento
		_CCREDITO:="21116010"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" /// CSLL s/servicos
		_CCREDITO:="21116012"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102" /// PIS SOBRE FATURAMENTO
		_CCREDITO:="21116006"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211" /// PIS SOBRE servicos
		_CCREDITO:="21116012"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106" /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="21115005"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF" /// IRRF S/SERVI?S
		_CCREDITO:="21116009"
		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701" /// IRPJ
		_CCREDITO:="21116008" 

	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" /// IPVA
		_CCREDITO:="21116009"

	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2115" /// PAGAMENTO DE FERIAS
		_CCREDITO:="21122001"
	
	//RRP - 06/11/2015 - Solicita豫o por email Daniel Florence.		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2906"
		_CCREDITO:="21116009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2907"
		_CCREDITO:="21116016"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2908"
		_CCREDITO:="11320014"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2909"
		_CCREDITO:="11320015"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2910"
		_CCREDITO:="21116014"		
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
ELSEIF SM0->M0_CODIGO $ "83"						 //JSS - Chamado 030699 
	IF ALLTRIM(SE2->E2_NATUREZ)$	"4201/INSS"      	 /// INSS SOBRE SERVI?S 
		_CCREDITO:="21116013"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC"/// ISS SOBRE SERVI?S PRESTADOS 
		_CCREDITO:="21116003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		     /// COFINS SOBRE SERVI?S 
		_CCREDITO:="21116005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		     /// CSLL SOBRE SERVI?S
		_CCREDITO:="21116011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	     /// PIS SOBRE SERVI?S 
		_CCREDITO:="21116007"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"       /// IRRF SOBRE SERVI?S 
		_CCREDITO:="21116009"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
//WFA - 20/12/2016 - Chamado 037522
ELSEIF SM0->M0_CODIGO $ "85" //GS1 
	cNaturez := ALLTRIM(SE2->E2_NATUREZ)	
	IF cNaturez == "4201".OR.cNaturez == "INSS"         					// INSS SOBRE SERVI?
		_CCREDITO:="213102009"
	ELSEIF cNaturez == "4213".OR.cNaturez == "4212".OR.cNaturez == "4211"  	// PIS, COFINS E CSLL SOBRE SERVI?
		_CCREDITO:="213102007"
	ELSEIF cNaturez == "4202".OR.cNaturez == "IRF"        					// IRRF SOBRE SERVI?
		_CCREDITO:="213102001"
	ELSEIF cNaturez == "4206".OR.cNaturez == "3101".OR.cNaturez == "MUNIC" 	// ISS SOBRE SERVI?
		_CCREDITO:="213102008"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
ELSEIF SM0->M0_CODIGO $ "YG"						    //CAS - 12/09/2017 - Ticket #11057 - Lan?mentos Folhas/natureza de IOF.
	IF ALLTRIM(SE2->E2_NATUREZ)$ "3004"  		      	
		_CCREDITO:="211230011"         
	//WFA - 26/10/2017
	ElseIF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
		_CCREDITO:="211310004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       /// INSS S/SERVI?S
		_CCREDITO:="211230004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            /// FGTS SOBRE SALARIOS
		_CCREDITO:="211310005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       /// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            /// IPTU
		_CCREDITO:="211230001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="211220005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      /// ICMS
		_CCREDITO:="211220001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      /// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS s/faturamento
		_CCREDITO:="211220004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      /// COFINS s/servicos
		_CCREDITO:="211230008"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      /// CSLL faturamento
		_CCREDITO:="211210003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      /// CSLL s/servicos
		_CCREDITO:="211230009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      /// PIS SOBRE FATURAMENTO
		_CCREDITO:="211220003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      /// PIS SOBRE servicos
		_CCREDITO:="211230010"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="211230002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        /// IRRF S/SERVI?S
		_CCREDITO:="211230003"	
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	      /// IRPJ
		_CCREDITO:="211210001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		      /// IPVA
		_CCREDITO:="211130001"
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF	 	
ELSEIF SM0->M0_CODIGO $ "09"						    //CAS - Chamado 038649 	
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      	/// INSS SOBRE SALARIOS
		_CCREDITO:="21115003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       	/// INSS S/SERVI?S
		_CCREDITO:="21116013"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            	/// FGTS SOBRE SALARIOS
		_CCREDITO:="21115004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       	/// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            	/// IPTU
		_CCREDITO:="21116014"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" 	/// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO
		_CCREDITO:="21116003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      	/// ICMS
		_CCREDITO:="211220001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      	/// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      	/// COFINS s/faturamento
		_CCREDITO:="21116004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      	/// COFINS s/servicos
		_CCREDITO:="21116005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      	/// CSLL faturamento
		_CCREDITO:="21116010"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      	/// CSLL s/servicos
		_CCREDITO:="21116011"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      	/// PIS SOBRE FATURAMENTO
		_CCREDITO:="21116006"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      	/// PIS SOBRE servicos
		_CCREDITO:="21116007"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        	/// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="21115005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        	/// IRRF S/SERVI?S
		_CCREDITO:="21116009"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701" 		  		/// IRPJ
		_CCREDITO:="21116009" 
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 				/// IPVA
		_CCREDITO:="21116014" 
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF			  
ELSE
	IF ALLTRIM(SE2->E2_NATUREZ)$"2201"  		      /// INSS SOBRE SALARIOS
		_CCREDITO:="211310004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4201/INSS"       /// INSS S/SERVI?S
   		//HMO - 19/09/2018 - Tratamento de INSS para Buzzfeed - Ticket #43671
		IF SM0->M0_CODIGO $ "BI"                      
			_CCREDITO:="21116003"	
		ELSE	
			_CCREDITO:="211230004"
		ENDIF	
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2202"            /// FGTS SOBRE SALARIOS
		_CCREDITO:="211310005"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4205/4209"       /// TLIF/TRSD
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4203"            /// IPTU
		_CCREDITO:="211230001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3101/4206/MUNIC" /// ISS S/SERVI?S PRESTADOS   --- ISS RETIDO 
   		//HMO - 24/08/2018 - Ticket 40441 
		IF SM0->M0_CODIGO $ "N6"                      
			_CCREDITO:="21116003"
		ELSE	
			_CCREDITO:="211220005" 
		ENDIF
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3104"     	      /// ICMS 
	    //HMO - 24/08/2018 - Ticket 40441 
		IF SM0->M0_CODIGO $ "N6"                      
			_CCREDITO:="21116001"
		ELSE	
			_CCREDITO:="211220001"  
		ENDIF	
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3105" 		      /// IPI
		_CCREDITO:="211220002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3103"		      /// COFINS s/faturamento
		_CCREDITO:="211220004"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4212"		      /// COFINS s/servicos
		//HMO - 06/09/2018 - Tratamento de Cofins para Buzzfeed - Ticket #43671
		IF SM0->M0_CODIGO $ "BI"
			_CCREDITO:= "21116005" 
		ELSE	
			_CCREDITO:="211230008"
		ENDIF		
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6702" 		      /// CSLL faturamento
		_CCREDITO:="211210003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4213" 		      /// CSLL s/servicos
		//HMO - 06/09/2018 - Tratamento de CSLL para Buzzfeed - Ticket #43671
		IF SM0->M0_CODIGO $ "BI"
			_CCREDITO:= "21116011" 
		ELSE	
			_CCREDITO:="211230009"
		ENDIF			
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3102"  	      /// PIS SOBRE FATURAMENTO
		_CCREDITO:="211220003"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4211"  	      /// PIS SOBRE servicos
		//HMO - 06/09/2018 - Tratamento de PIS para Buzzfeed - Ticket #43671
		IF SM0->M0_CODIGO $ "BI"
			_CCREDITO:= "21116007" 
		ELSE	
			_CCREDITO:="211230010"
		ENDIF				
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
		_CCREDITO:="211230002"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"4202/IRF"        /// IRRF S/SERVI?S
		//WFA - 20/07/2016 - Chamado 034211.
		If SM0->M0_CODIGO $ "UA"
			_CCREDITO:="21116009"
		Else
			_CCREDITO:="211230003"	
		EndIf
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"6701"  	      /// IRPJ
		_CCREDITO:="211210001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"2902" 		      /// IPVA
		_CCREDITO:="211130001"
	ELSEIF ALLTRIM(SE2->E2_NATUREZ)$"3108" .AND. SM0->M0_CODIGO $ "N6"     /// ICMS      //HMO - 05/09/2018 - Ticket 44918	
		_CCREDITO:="21116015"	
	ELSE
		_CCREDITO:=SA2->A2_CONTA
	ENDIF
	
ENDIF
Return(_CCREDITO)
