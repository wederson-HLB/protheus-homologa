#include "rwmake.ch"


/*
Funcao      : LP572002_C
Parametros  : Nenhum
Retorno     : cRet
Objetivos   : Lan�amento que verifica a natureza e retorna a conta
Autor       : 
TDN         : 
Revis�o     : Tiago Luiz Mendon�a 
Data/Hora   : 06/02/2012
M�dulo      : Contabilidade.
*/    
   
*---------------------------*
 User Function LP572002_C()
*---------------------------*   

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

	IF SM0->M0_CODIGO $"02/VB/Z4/CH/BY/LA/GP/99"         /// EMPRESAS DO GRUPO PRYOR                                        
		IF ALLTRIM(SEU->EU_P_NATUR)$"2201"  		   /// INSS SOBRE SALARIOS
		    _CCREDITO:="21115003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4201" 		   /// inss s/servicos
		  	_CCREDITO:="21116013"                      ///alterado a peedido da haidee cham. 3830
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2202"         /// FGTS SOBRE SALARIOS
		    _CCREDITO:="21115004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4205/4209"    /// TLIF/TRSD
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4203"         /// IPTU
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3101/4206"    /// ISS S/SERVI�OS PRESTADOS   --- ISS RETIDO
			_CCREDITO:="21116003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3104"     	   /// ICMS
			_CCREDITO:="21116001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3105" 		   /// IPI
			_CCREDITO:="21116002"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3103"		   /// COFINS s/faturamento
			_CCREDITO:="21116004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4212"		   /// COFINS s/servicos
			_CCREDITO:="21116011"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6702" 		   /// CSLL faturamento
			_CCREDITO:="21116010" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4213" 		   /// CSLL s/servicos
			_CCREDITO:="21116007" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3102"  	   /// PIS SOBRE FATURAMENTO  
			_CCREDITO:="21116006"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4211"  	   /// PIS SOBRE servicos
			_CCREDITO:="211230011"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2105/2106"    /// IRRF S/SALARIOS E FERIAS
			_CCREDITO:="21115005"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4202" 		   /// IRRF S/SERVI�OS 
			_CCREDITO:="21116009"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6701"  	   /// IRPJ
			_CCREDITO:="21116008"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2902" 		   /// IPVA
			_CCREDITO:="21111001"   
		ELSE
			_CCREDITO:=SA2->A2_CONTA
		ENDIF
			
	ELSEIF SM0->M0_CODIGO $"FI"   //COVIT
			IF ALLTRIM(SEU->EU_P_NATUR)$"2201"  	   /// INSS SOBRE SALARIOS
		    _CCREDITO:="21115003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4201/INSS"    /// INSS S/SERVI�OS
			_CCREDITO:="21116013" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2202"         /// FGTS SOBRE SALARIOS
		    _CCREDITO:="21115004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4205/4209"    /// TLIF/TRSD
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4203"         /// IPTU
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4206/MUNIC"   /// ISS S/SERVI�OS PRESTADOS   --- ISS RETIDO
			_CCREDITO:="211230011"      
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3101"         /// ISS S/SERVI�OS PRESTADOS   --- ISS RETIDO
			_CCREDITO:="21116003"			
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3104"     	   /// ICMS
			_CCREDITO:="21116001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3105" 		   /// IPI
			_CCREDITO:="21116002"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3103"		   /// COFINS s/faturamento
			_CCREDITO:="21116004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4212"		      /// COFINS s/servicos                   
			_CCREDITO:="21116005"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6702" 		      /// CSLL faturamento
			_CCREDITO:="21116010" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4213" 		      /// CSLL s/servicos
			_CCREDITO:="21116011"                    
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3102"  	      /// PIS SOBRE FATURAMENTO  
			_CCREDITO:="21116006"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4211"  	      /// PIS SOBRE servicos
			_CCREDITO:="21116007"
	   ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
			_CCREDITO:="21115005"                                        
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4202/IRF"        /// IRRF S/SERVI�OS 
			_CCREDITO:="21116009"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6701"  	      /// IRPJ
			_CCREDITO:="21116008"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2902" 		      /// IPVA
			_CCREDITO:="21111001"   
		ELSE
			_CCREDITO:=SA2->A2_CONTA
		ENDIF
	ELSEIF SM0->M0_CODIGO $ "F2"
        IF ALLTRIM(SEU->EU_P_NATUR)$"2201"  		      /// INSS SOBRE SALARIOS
		    _CCREDITO:="21115003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4201/INSS"       /// INSS S/SERVI�OS
			_CCREDITO:="21116013" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2202"            /// FGTS SOBRE SALARIOS
		    _CCREDITO:="21115004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4205/4209"       /// TLIF/TRSD
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4203"            /// IPTU
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3101/4206/MUNIC" /// ISS S/SERVI�OS PRESTADOS   --- ISS RETIDO
			_CCREDITO:="21116003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3104"     	      /// ICMS
			_CCREDITO:="21116001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3105" 		      /// IPI
			_CCREDITO:="21116002"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3103"		      /// COFINS s/faturamento
			_CCREDITO:="21116004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4212"		      /// COFINS s/servicos                   
			_CCREDITO:="21116011"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6702" 		      /// CSLL faturamento
			_CCREDITO:="21116010" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4213" 		      /// CSLL s/servicos
			_CCREDITO:="21116007"                    
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3102"  	      /// PIS SOBRE FATURAMENTO  
			_CCREDITO:="21116006"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4211"  	      /// PIS SOBRE servicos
			_CCREDITO:="211230011"
	    ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
			_CCREDITO:="21115005"                                        
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4202/IRF"        /// IRRF S/SERVI�OS 
			_CCREDITO:="21116009"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6701"  	      /// IRPJ
			_CCREDITO:="21116008"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2902" 		      /// IPVA
			_CCREDITO:="21111001"   
		ELSE
			_CCREDITO:=SA2->A2_CONTA
		ENDIF
	ELSE
		IF ALLTRIM(SEU->EU_P_NATUR)$"2201"  		      /// INSS SOBRE SALARIOS
		    _CCREDITO:="21115003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4201/INSS"       /// INSS S/SERVI�OS
			_CCREDITO:="21116013" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2202"            /// FGTS SOBRE SALARIOS
		    _CCREDITO:="21115004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4205/4209"       /// TLIF/TRSD
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4203"            /// IPTU
			_CCREDITO:="21111001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3101/4206/MUNIC" /// ISS S/SERVI�OS PRESTADOS   --- ISS RETIDO
			_CCREDITO:="21116003"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3104"     	      /// ICMS
			_CCREDITO:="21116001"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3105" 		      /// IPI
			_CCREDITO:="21116002"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3103"		      /// COFINS s/faturamento
			_CCREDITO:="21116004"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4212"		      /// COFINS s/servicos                   
			_CCREDITO:="21116005"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6702" 		      /// CSLL faturamento
			_CCREDITO:="21116010" 
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4213" 		      /// CSLL s/servicos
			_CCREDITO:="21116011"                    
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"3102"  	      /// PIS SOBRE FATURAMENTO  
			_CCREDITO:="21116006"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4211"  	      /// PIS SOBRE servicos
			_CCREDITO:="21116007"
	    ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2105/2106"        /// IRRF S/SALARIOS E FERIAS
			_CCREDITO:="21115005"                                        
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"4202/IRF"        /// IRRF S/SERVI�OS 
			_CCREDITO:="21116009"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"6701"  	      /// IRPJ
			_CCREDITO:="21116008"
		ELSEIF ALLTRIM(SEU->EU_P_NATUR)$"2902" 		      /// IPVA
			_CCREDITO:="21111001"   
		ELSE
			_CCREDITO:=SA2->A2_CONTA
		ENDIF
	
	ENDIF  
	
Return(_CCREDITO)        
