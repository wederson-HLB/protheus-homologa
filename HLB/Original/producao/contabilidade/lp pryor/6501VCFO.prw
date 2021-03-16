#include "rwmake.ch"

*------------------------*
 User Function 6501VCFO()   // Altera豫o do LP650-01 02/07/2008
*------------------------*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as vari,aveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VALRESULT,_CFOP1,_CTES1")

lEasy     := SuperGetMV("MV_EASY") == "S"

_valResult:=0

_cfop1 := "1100/2100/1101/2101/2102/1111/2111/1113/1117/2113/1116/2116/2117/1118/2118/" 	 // COMPRAS

_cfop1 += "1120/2120/1121/2121/1122/2122/1124/2124/1125/2125/1126/2126/"                     // COMPRAS 

_cfop1 += "1407/2407/1410/2410/2501/1501/"					                                 // COMPRAS /Inserido o CFOP 2407 por JSS em 22/08/2012

_cfop1 += "1551/2551/1406/2406/"                                                      	   	 // COMPRAS ATIVO

_cfop1 += "1910/2910/3910/"   	                                                       		 // DOACAO OU BRINDE

_cfop1 += "1911/2911/"	                                                    				 // AMOSTRA GRATIS

_cfop1 += "1912/2912/1913/2913/1914/2914/"                                                 	 // CONSIGNACAO

_cfop1 += "1251/2251/1252/1253/2252/1253/2253/1254/2254/1255/2255/1256/2256/1257/2257/"      // ENERGIA

_cfop1 += "1301/2301/1302/2302/1303/2303/1304/2304/1305/2305/1306/2306/"                     // COMPRA SERV.COMUN

//_cfop1 += "1351/2351/1352/2352/1353/2353/1354/2354/1355/2355/1356/2356/"                   // COMPRA SERV.TRANSP

//_cfop1 += "3101/3102/"	                                                       		     // IMPORT.P/COMERC
                                                                                            
_cfop1 += "1949/2949/3949/"                                                    				 // IMPORT. OUTRAS

_cfop1 += "1151/2151/1152/2152/"                                           				     // TRANSFERENCIAS

_cfop2 := "1401/2401/1403/2403/1353/2353/1352/2352/1933/2933/1102/2908/1908/"                // COMPRAS ST

_cTes1 := "08P/49P/48P/46O/"	                                            				 // SERVICOS TOMADOS (O8P)    /Inserido o CFOP 2407 por JSS em 22/08/2012          
                                                                     

_cfop3 := "1351/2351/1352/2352/1354/2354/1355/2355/1356/2356/"                               // COMPRA SERV.TRANSP   
                                                                                                                     
_cfop4 := "/1556/2556/1653/2653/1922/2922/1551/2551/1406/2406/1407/2407/1202"            	         // COMPRA MAT. CONSUMO 

_cfop5 := "3101/3102/1117/"	                                                       		     // IMPORT.P/COMERC     

_cfop6 := "1102"

_cfop7:= "1128/2128"

//If !lEasy      
If EMPTY(SD1->D1_CONHEC)
	//IF SD1->D1_RATEIO $ '2'
	//RRP - 22/08/2013 - Monster Retirada.
	//RRP - 13/10/2015 - Retirada da empresa Exeltis. Chamado 029172.
	IF SF4->F4_DUPLIC =="N"  .and. (!(ALLTRIM(SD1->D1_CF)) $ _cfop5) .AND.;
	!(SM0->M0_CODIGO $ 'JO/UY/SU') .OR. SF1->F1_TIPO $ 'D'
		_valResult:=0     

    // Paulo Silva - EZ4 = Chamado: #12087	
       ELSEIF (ALLTRIM(SD1->D1_CF) $ _cfop7) .AND. (SM0->M0_CODIGO $ 'T4')
    	_valResult:= SD1->D1_TOTAL	
		
	// PAULO SILVA - EZ4 - SOLARIS RETENCAO DE IMPOSTOS 11/03/2020
      ELSEIF (ALLTRIM(SD1->D1_CF) $ '1949/2949/3949/2933/1933/3933') .AND. SM0->M0_CODIGO $ 'HH/HJ'
    //	_valResult:= SD1->D1_TOTAL-(SD1->D1_VALISS+SD1->D1_VALIRR+SD1->D1_VALINS)-SD1->D1_VALDESC
	    _valResult:= SD1->D1_TOTAL
	
	// PAULO SILVA - EZ4 - Notas de Servicos - COGNIZANTE - S2 CH#21340 - RETENCAO DE IMPOSTOS 26/03/2020 (VALIDADO POR RAFAEL AZARIAS)
      ELSEIF (ALLTRIM(SD1->D1_CF) $ '1353/2353/3353/1933/2933/3933/1923/2923/3923/1949/2949/3949/') .AND. SM0->M0_CODIGO $ 'S2'
   	    _valResult:= SD1->D1_TOTAL

    // PAULO SILVA - EZ4 - 19/01/2020  - #20752
      ELSEIF (ALLTRIM(SD1->D1_TES) $ '2XT/2XS/2VO/2WM/2W9/3CW') .AND. SM0->M0_CODIGO $ 'HH/HJ'
    //  _valResult:= SD1->D1_TOTAL		
        _valResult:= (SD1->D1_TOTAL+SD1->D1_DESPESA+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_VALIPI)-SD1->D1_VALDESC 

	  ELSEIF SM0->M0_CODIGO == 'MN'                                        ///Alterado por Jo?.Silva
    	_valResult:= SD1->D1_TOTAL   
    	
      ELSEIF SM0->M0_CODIGO == 'EG' .AND. SD1->D1_TES == '2TM'   			//CAS - 24-01-2018 - Ticket #13281 - Ajuste nos lan?mentos padr?s que estavam errados.
    	_valResult:= (SD1->D1_CUSTO)
		   
      ELSEIF SM0->M0_CODIGO == 'JO' .AND. SD1->D1_TES == '1RY'   			//PAULO SILVA - EZ4 - 07/04/2020 - Ticket #23045 - Ajuste nos lancamentos padrao que estavam errados. //VALIDADO JACQUELINE - MONSTER
    	_valResult:= SD1->D1_TOTAL   		
     
      ELSEIF (ALLTRIM(SD1->D1_CF) $ '1551') .AND. SM0->M0_CODIGO == 'RW'   //solicita豫o Rodrigo Justo - A100ROW - Chamado 001019
    	_valResult:= (SD1->D1_CUSTO - SD1->D1_VALIMP5 - SD1->D1_VALIMP6)  

      ELSEIF (ALLTRIM(SD1->D1_CF) $ '1407/1556/1653/2556/2653') .AND. SM0->M0_CODIGO $ 'HH/HJ'   //CAS - 07-08-2017 - Ticket #4491-Solaris-Altera豫o de parametriza豫o dos lan?mentos cont?eis - NF Entrada
    	_valResult:= ( (SD1->D1_TOTAL+SD1->D1_VALIPI) - (SD1->D1_VALIMP5 + SD1->D1_VALIMP6 ))  

      ELSEIF SM0->M0_CODIGO == '07' .AND. SD1->D1_TES == '08P' //CAS - 27/12/2017 -  Tratamento para empresa Engecorps - Ticket 20708
         _valResult:= (SD1->D1_TOTAL)           	  

      ELSEIF (ALLTRIM(SD1->D1_CF) $ '1406/1126') .AND. SM0->M0_CODIGO == 'P0'   //JSS - Auxliando EBF - Ajustado para solucionar o caso 022146
    	_valResult:= (SD1->D1_TOTAL)    	     
	
      ELSEIF  (ALLTRIM(SD1->D1_CF) $ _cfop2) 	.or.  (ALLTRIM(SD1->D1_CF)) $ _cfop5 
			//RRP - 08/02/2013 - Tratamento para empresa Media - Chamado 009908.    
			IF  cEmpAnt == 'UY' .AND. SD1->D1_TES == '1CK/11O'
				_valResult:= (SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM-SD1->D1_ICMSRET+SD1->D1_VALIPI)
			//TLM 17/07/2014 - Tratamento Bottega 
			ElseIf cEmpAnt == '46'
				_valResult:= (SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM-SD1->D1_ICMSRET)
			//RRP - 27/10/2014 - Tratamento para empresa Silver. Chamado 0210500.
			ElseIf cEmpAnt == 'L2'
				_valResult:= (SD1->D1_TOTAL+SD1->D1_ICMSRET-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM)
			//HMO - 16/08/2018 - Tratamento para Exeltis - ticket 42906.	
			ElseIf cEmpAnt == 'LG' .AND. SD1->D1_TES == '1QG'
				_valResult:= (SD1->D1_TOTAL)	 
			ElseIf cEmpAnt == 'X2' //CAS - 14-12-2020 Ajuste para antender a empresa X2-Marici
				_valResult:= (SD1->D1_TOTAL+SD1->D1_ICMSRET-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM)	
			Else
				_valResult:= (SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM-SD1->D1_VALIPI-SD1->D1_ICMSRET)
			EndIf
      ELSEIF SM0->M0_CODIGO == '6H' .AND. SD1->D1_TES == '1P7' //JSS - Chamado 007465
         _valResult:= (SD1->D1_TOTAL+SD1->D1_ICMSRET-SD1->D1_VALIMP5-SD1->D1_VALIMP6)   
    
      ELSEIF  (ALLTRIM(SD1->D1_CF) $ _cfop3) 
	
	     _valResult:= SD1->D1_CUSTO + SD1->D1_VALICM
	  
	  //AOA - 22/04/2015 - Resolver chamado 025757
	  ELSEIF  (ALLTRIM(SD1->D1_CF) $ _cfop4) .AND. SM0->M0_CODIGO $ '7F/JO/K1/50/HL/O5/OD/WA/BJ/9J/8Z/G2/N5/28/BI/MM/7N/S2/VW/XC/10/OU/EI/FG/H9/RY/NN/K2/BT/9X/IN/GN/4Z/SS/M1/RF/RT/ZJ/MR/ZR/MA/MB/S1/JV/40/ED/QU/7I/LB/JP/R7/DW/AT/26/SC/S6/2E/6Q/XR/7M/6T/TP/D8/7G/41/TM/UZ/HH/HJ/M7/QN/0F/8V/V6/V7/X3'		//CAS - 04/06/2019 - TAXID(abater o desconto)
         _valResult:= (SD1->D1_TOTAL+SD1->D1_DESPESA+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_VALIPI)-SD1->D1_VALDESC       

      ELSEIF  ((ALLTRIM(SD1->D1_CF) $ _cfop1) .OR. (SD1->D1_TES$_cTes1)) 
	
	     _valResult:= SD1->D1_CUSTO
    
      ELSEIF  (ALLTRIM(SD1->D1_CF) $ _cfop4) 
	
	     _valResult:= SD1->D1_TOTAL                   
	     
	     
	  ELSEIF  (ALLTRIM(SD1->D1_CF) $ _cfop6) .AND. SM0->M0_CODIGO $ 'A6'  //Solicita豫o Ana Carolina - Chamado 000650
	                                                           
	     _valResult:= SD1->D1_CUSTO - SD1->D1_VALIPI
	     
      ENDIF
  /*                                      
   ELSE

      _valResult:=0  	 

   ENDIF
    */
EndIf

If SD1->D1_RATEIO == "1"
	cQry := " SELECT R_E_C_N_O_ FROM "+RETSQLNAME("SDE")+chr(13)+chr(10)
	cQry += " WHERE D_E_L_E_T_<>'*' AND RTRIM(DE_FILIAL)+RTRIM(DE_DOC)+RTRIM(DE_SERIE)+RTRIM(DE_FORNECE)+RTRIM(DE_LOJA)+RTRIM(DE_ITEMNF) ='"
	cQry += RTRIM(SD1->D1_FILIAL)+RTRIM(SD1->D1_DOC)+RTRIM(SD1->D1_SERIE)+RTRIM(SD1->D1_FORNECE)+RTRIM(SD1->D1_LOJA)+RTRIM(SD1->D1_ITEM)+"'"
	If select("QUERY")>0
		QUERY->(DbCloseArea())
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QUERY", .F., .T.)
	COUNT TO nRecCount
	If nRecCount>0
		_valResult:=""	
	EndIf
EndIf             

RETURN(_valResult)
