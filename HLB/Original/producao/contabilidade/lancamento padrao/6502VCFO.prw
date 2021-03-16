#include "rwmake.ch"

*------------------------*
 User Function 6502VCFO()   // Altera豫o do LP650-02 02/07/2008
*------------------------*
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_VALRESULT,_CFOP1,_CTES1")

lEasy     := SuperGetMV("MV_EASY") == "S"

_valResult:=0                   

_cfop1:= "1100/2100/1101/2101/1102/2102/1111/2111/1113/2113/1116/2116/2117/1118/1117/2118/"     	    // COMPRAS

_cfop1+= "1120/2120/1121/2121//1126/2126/1401/2401/1403/2403/1407/2407/"								// COMPRAS /Inserido o CFOP 2407 por JSS em 22/08/2012

_cfop1+= "1551/2551/1406/2406/2501/1501/"                                                				// COMPRAS ATIVO
                                                                                                    
_cfop1+= "1910/2910/3910/" 	                                                        	         		// DOACAO OU BRINDE

_cfop1+= "1911/2911/"	                                                    				     		// AMOSTRA GRATIS

_cfop1+= "1912/2912/1913/2913/1914/2914/"                                                 	     		// CONSIGNACAO

_cfop1+= "1251/2251/1252/2252/1253/22531254/2254/1255/2255/1256/2256/1257/2257/"                 		// ENERGIA

_cfop1+= "1301/2301/1302/2302/1303/2303/1304/2304/1305/2305/1306/2306/"                          		// COMPRA SERV.COMUN

//_cfop1+= "3101/3102/"	                                                        			     		// IMPORT.P/COMERC

_cfop1+= "1949/2949/3949/"                                                            			   		// IMPORT. OUTRAS

_ctes1:= "08P/49P/48P/46O/"                                                 					 		// SERVICOS TOMADOS (O8P)
_ctes2:= "110/2DR"
_ctes3:= "2XT/2XS/2VO/2WM/2W9/3CW"                                                 					 		// SERVICOS TOMADOS (O8P)
                                           
_cfop2:= "1351/2351/1352/2352/1353/2353/1354/2354/1355/2355/1356/2356/1556/2556/3556/1653/2908/1908/"	// COMPRA SERV.TRANSP                                            

_cfop2+= "2653/1933/2933/1922/2922/1551/2551/1406/2406/1407/2407/"

_cfop3:= "1122/2122/1124/2124/1125/2125/"	                                                         	//Industrializa豫o    

_cfop4 := "3101/3102/1117/"	                	                                        		     	// IMPORT.P/COMERC

_cfop5:= "1128/2128"

//If !lEasy
If EMPTY(SD1->D1_CONHEC)
	
	//RRP - 22/08/2013 - Retirada da empresa Monster. Chamado 014085
    //RRP - 13/10/2015 - Retirada da empresa Exeltis. Chamado 029172
	IF SF4->F4_DUPLIC=="N" .AND. (!(ALLTRIM(SD1->D1_CF)) $ _cfop4) .AND. !(SM0->M0_CODIGO $ 'JO/UY/SU');
	.OR. SF1->F1_TIPO $ 'D'
    	_valResult:=0 

    // Paulo Silva = Chamado: #12087	
    ELSEIF (ALLTRIM(SD1->D1_CF) $ _cfop5) .AND. (SM0->M0_CODIGO $ 'T4')
      _valResult:= SD1->D1_TOTAL
	  
	// PAULO SILVA - SOLARIS RETENCAO DE IMPOSTOS 03/01/2020 CH#20752
    ELSEIF (ALLTRIM(SD1->D1_CF) $ '1949/2949/3949/2933/1933/3933') .AND. SM0->M0_CODIGO $ 'HH/HJ/UT/'
    	_valResult:= SD1->D1_TOTAL-(SD1->D1_VALISS+SD1->D1_VALIRR+SD1->D1_VALINS)-SD1->D1_VALDESC
		
    // PAULO SILVA - 19/01/2020  - #20752
    ELSEIF (ALLTRIM(SD1->D1_TES) $ '2XT/2XS/2VO/2WM/2W9/3CW') .AND. SM0->M0_CODIGO $ 'HH/HJ'
        _valResult:= SD1->D1_TOTAL
	   
	// Daniel Fonseca de Lira - Chamado 007788 - Erika 
	/* ELSEIF (ALLTRIM(SD1->D1_CF) = '1117') .AND. SM0->M0_CODIGO == 'MN'   //solicita豫o Erika - Lapa 
    	_valResult:= SD1->D1_TOTAL */
 	ElseIf (ALLTRIM(SD1->D1_CF) $ '1406/1126') .AND. SM0->M0_CODIGO == 'P0'   //JSS - Auxliando EBF - Ajustado para solucionar o caso 022146
    	_valResult:= (SD1->D1_TOTAL-SD1->D1_VALDESC)  	    

	// Daniel Fonseca de Lira - Chamado 007788 - Erika
	ElseIf SM0->M0_CODIGO == 'MN'
		_valResult:= SD1->D1_TOTAL - SD1->D1_VALINS - SD1->D1_VALISS - SD1->D1_VALIRR

	//CAS - 24-01-2018 - Ticket #13281 - Ajuste nos lan?mentos padr?s que estavam errados.
    ELSEIF SM0->M0_CODIGO == 'EG' .AND. SD1->D1_TES == '2TM'   			
    	_valResult:= SD1->D1_TOTAL

	//JSS - Chamado 030325 
	ELSEIF (ALLTRIM(SD1->D1_CF) $ '1949/2949') .AND. SM0->M0_CODIGO == 'B1' //(ALLTRIM(SD1->D1_TES) $ '46O') RRP - 18/12/2015 - Solicitado por email. Daniel Florence.
		_valResult:=(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_II-SD1->D1_VALINS-SD1->D1_VALIRR) 
    
	//PAULO SILVA 11/03/2020 - Solaris-Altera豫o de parametriza豫o dos lancamentos contabeis - NF Entrada
	ELSEIF (ALLTRIM(SD1->D1_CF) $ '1407/1556/1653/2556/2653') .AND. SM0->M0_CODIGO $ 'HH/HJ'   
    //	_valResult:= (SD1->D1_TOTAL+SD1->D1_VALIPI) 
    	_valResult:= (SD1->D1_TOTAL+SD1->D1_DESPESA+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_VALIPI)-SD1->D1_VALDESC 
		
	// PAULO SILVA - 03/01/2020 E # - Adicionei a empresa HH
	ElseIf (ALLTRIM(SD1->D1_TES) $ '2XT/2XS/2VO/2WM/2W9') .AND. SM0->M0_CODIGO $ 'HH'
       _valResult:= SD1->D1_TOTAL-(SD1->D1_VALICM+SD1->D1_ICMSCOM+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALIMP5+SD1->D1_VALIMP6+SD1->D1_DESPESA+SD1->D1_VALFEEF+SD1->D1_VLSLXML+SD1->D1_VALDESC)          
        	
    // PAULO SILVA - ADICIONEI A EMPRESA 9X CH#20137
    ELSEIF (ALLTRIM(SD1->D1_CF) $ '1949/2949/3949/2933/1933/3933') .AND. SM0->M0_CODIGO $ '9X'
    	_valResult:= SD1->D1_TOTAL-(SD1->D1_VALISS-SD1->D1_VALCSL-SD1->D1_VALIRR-SD1->D1_VALPIS-SD1->D1_VALCOF-SD1->D1_VALINS)-SD1->D1_VALDESC
	
	// PAULO SILVA - Notas de Servicos - COGNIZANTE - S2 CH#21340 (VALIDADO - RAFAEL AZARIAS. 25/03/2020)
    ELSEIF (ALLTRIM(SD1->D1_CF) $ '1353/2353/3353/1933/2933/3933/1923/2923/3923/1949/2949/3949/') .AND. SM0->M0_CODIGO $ 'S2'
    	_valResult:= SD1->D1_TOTAL-(SD1->D1_VALISS+SD1->D1_VALIRR+SD1->D1_VALINS)
	
	//JSS - Add o campo SD1->D1_VALFRE solicitado no chamado 021936
	ELSEIF SM0->M0_CODIGO $ 'ZX/ZW/ZV/ZU/ZY/0B/0C/0E/'
		_valResult:=(SD1->D1_TOTAL+SD1->D1_VALFRE+SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_II-SD1->D1_VALISS-SD1->D1_VALINS-SD1->D1_VALIRR) 		
	
	ELSEIF  ((ALLTRIM(SD1->D1_CF) $ _cfop1) .OR. (SD1->D1_TES $ _cTes1))

   		//If SM0->M0_CODIGO $'0H/8D/8W/NR/NS/O8/O9/O9/OF/OH/02/19/70/8G/B1/B1/BK/D5/X8/XW/ZT/1M/1N/1O/1U/6S/6Y/7A/7B/V2/2O/6A/O7/UA/48/71/3C/YC/YH/NB/P3/'//JSS - 11/02/2016 Tratamento criado para solu豫o do caso 031934
	   	//RRP - 03/05/2016 - Ajuste para reten豫o correta do ISS para empresas dentro e fora do RJ.
	   	If ALLTRIM(SM0-> M0_ESTENT) == 'RJ'
	   		_valResult:=(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_II-SD1->D1_VALINS-SD1->D1_VALIRR) 
	   	Else
		   	_valResult:=(SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET-SD1->D1_II-SD1->D1_VALISS-SD1->D1_VALINS-SD1->D1_VALIRR)-SD1->D1_VALDESC //JAM - CHAMADO 002160  //CAS - 04-06-2019 - Resolver problema da Monster-TAXID(abater o desconto)
   		EndIf
	ElseIf (ALLTRIM(SD1->D1_CF) $ _cfop4) .AND. SM0->M0_CODIGO $ '2L' 
		_valResult:= SD1->D1_TOTAL
	
	// EBF - 06/11/2014 - Tratamento para atender o chamado 022352.
	ElseIf (ALLTRIM(SD1->D1_CF) $ _cfop4) .AND. SM0->M0_CODIGO $ 'SS'
		_valResult:= SD1->D1_TOTAL-SD1->D1_DESPESA

	ElseIf (ALLTRIM(SD1->D1_CF) $ _cfop4) 
		_valResult:= (SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6-SD1->D1_ICMSCOM-SD1->D1_VALIPI-SD1->D1_ICMSRET)    
    
	ElseIf (ALLTRIM(SD1->D1_CF) $ _cfop3) 
		_valResult:= SD1->D1_TOTAL + SD1->D1_VALIPI
   
	//AOA - 22/04/2015 - Resolver chamado 025757
	ElseiF (ALLTRIM(SD1->D1_CF) $ _cfop2) .AND. SM0->M0_CODIGO $ '7F/JO/K1/50/HL/O5/OD/WA/BJ/9J/8Z/G2/N5/28/BI/MM/7N/S2/VW/XC/10/OU/EI/FG/H9/RY/NN/K2/BT/9X/IN/GN/4Z/SS/M1/RF/RT/ZJ/MR/ZR/MA/MB/S1/JV/40/ED/QU/7I/LB/JP/R7/DW/AT/26/SC/S6/2E/6Q/XR/7M/6T/TP/D8/7G/41/TM/UZ/HJ/M7/QN/0F/V6/V7/X3'		//CAS - 04/06/2019 - TAXID(abater o desconto)
         _valResult:= (SD1->D1_TOTAL+SD1->D1_DESPESA+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_VALIPI)-(SD1->D1_VALDESC-SD1->D1_VALINS - SD1->D1_VALISS - SD1->D1_VALIRR) //SD1->D1_VALINS - SD1->D1_VALISS - SD1->D1_VALIRR #CHAMADO #20764

	//CAS - 01/06/2017 - Tratamento para atender o chamado 036811.         
	ElseiF (ALLTRIM(SD1->D1_CF) $ _cfop2) .AND. SM0->M0_CODIGO == '1Z' 
		_valResult:= SD1->D1_TOTAL - SD1->D1_VALINS - SD1->D1_VALISS - SD1->D1_VALIRR
	
	ElseiF (ALLTRIM(SD1->D1_CF) $ _cfop2) //.AND. SF4->F4_CREDICM $ 'N'
 		_valResult:= SD1->D1_TOTAL//+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALICM-SD1->D1_II-SD1->D1_VALISS-SD1->D1_VALIRR-SD1->D1_VALINS+SE2->E2_CSLL+SE2->E2_COFINS+SE2->E2_PIS)

	EndIf

EndIf

//RRP - 16/12/2015 - C?ia do tratamento do programa 6501VCFO para n? trazer o lan?mento total nota quando tiver rateio por C.C.Chamado 027629
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
