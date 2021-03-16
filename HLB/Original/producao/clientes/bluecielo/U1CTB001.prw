/*                                                                                                          
Funcao      : U1CTB001
Objetivos   : Padronização do Lançamento Padrão 610 para empresa U1
Autor       : Renato Rezende
Obs.        :
Empresa		: BlueCielo
Módulo		: Faturamento / Contabil    
Data        : 01/10/2014
*/  
*---------------------------*
 User Function U1CTB001()
*---------------------------*
Local cRet	:= ""
Local cSeq  := ""
Local cTipo := ""

//Verificando se está na empresa BlueCielo
If !(cEmpAnt) $ "U1"
	Return cRet
EndIf

//Array que recebe os parâmetros informados.
cSeq  := PARAMIXB[1]
cTipo := PARAMIXB[2]

DbSelectArea("SB1")
SB1->(DbSetorder(1))
If SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	Do Case
		//Conta Crédito
		CASE cTipo == "CC"
			//Tratamento por produto no Valor NF Serv
			If Alltrim(SB1->B1_COD) == "1 -LI - INTERNO"
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1 -TS - INTERNO"
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111004"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1- PS INTERNO"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31111005"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-TRAINING INT."
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111006"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-SP 1YEAR INT"
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111007"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-MA RENEW INT"
				If cSeq $ "13" //Valor NF Serv 
					cRet:= "31111003"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-MA1 YEAR INT"
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111002"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-CESS USO INT." 
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111009"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-SP-RENEW INT"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31111008"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1- EXPENSE INTE"
				If cSeq $ "13" //Valor NF Serv
					cRet:= "31111010"
				ElseIf cSeq $ "20" //PIS
					cRet:= "21116006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "21116004"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				ElseIf cSeq $ "23" //INSS
					cRet:= "21116015"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2 -LI - EXTERNO"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112001" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-MA RENEW EXT"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112002"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2 -TS - EXTERNO"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112003"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2- PS EXTERNO"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112004" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-TRAINING EXT."
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112005" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-SP 1YEAR EXT"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112006"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-SP-RENEW EXT"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112007"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2- EXPENSE EXTE"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112008"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-MA1 YEAR EXT"
				If cSeq $ "13" //Valor NF Serv
			   		cRet:= "31112002"
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			EndIf	
		//Conta Débito
		CASE cTipo == "CD"
			//Tratamento por produto no Valor NF Serv
			If Alltrim(SB1->B1_COD) == "1 -LI - INTERNO"
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213006" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213007"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213005"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213008"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1 -TS - INTERNO"
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213010" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213011"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213009"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213012"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1- PS INTERNO"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213014" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213015"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213013"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-TRAINING INT."
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213018" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213019"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213017"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213020"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-SP 1YEAR INT"
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213034" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213035"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213033"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213036"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-MA RENEW INT"
				If cSeq $ "12" //Valor NF Serv 
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213002" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213003"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213001"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213004"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-MA1 YEAR INT"
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213030" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213031"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213029"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213032"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-CESS USO INT." 
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213026" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213027"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213025"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213028"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1-SP-RENEW INT"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213022" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213023"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213024"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "1- EXPENSE INTE"
				If cSeq $ "12" //Valor NF Serv
					cRet:= "11211001"
				ElseIf cSeq $ "20" //PIS
					cRet:= "31213038" 
				ElseIf cSeq $ "21" //COFINS
			   		cRet:= "31213039"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213037"
				ElseIf cSeq $ "23" //INSS
					cRet:= "31213040"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2 -LI - EXTERNO"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "21116016"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-MA RENEW EXT"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2 -TS - EXTERNO"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2- PS EXTERNO"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-TRAINING EXT."
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001" 
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-SP 1YEAR EXT"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-SP-RENEW EXT"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2- EXPENSE EXTE"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			ElseIf Alltrim(SB1->B1_COD) == "2-MA1 YEAR EXT"
				If cSeq $ "12" //Valor NF Serv
			   		cRet:= "11216001"
				ElseIf cSeq $ "22" //ISS
					cRet:= "31213021"
				EndIf
			EndIf
	EndCase
EndIf

Return cRet