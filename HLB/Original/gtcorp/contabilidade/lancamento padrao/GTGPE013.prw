#include "totvs.ch"

/*
  PARAMIXB -> cLP  -> Código do LP que chamará a função
*/

/*                                                                                                          
Funcao      : GTGPE013
Parametros  : cLP
Retorno     : cRet
Objetivos   : Retornar a conta de débito depentendo do centro de custo.  
Autor       : Renato Rezende
Data        : 20/05/2013
*/

*------------------------------*
 User Function GTGPE013()
*------------------------------*

Local cRet		:= "" 
Local cLp  		:= "" 
Local cCCusto1	:= ""
Local cCCusto2	:= ""
Local cCCusto3	:= ""

//RPB - 01/07/2016 - Atendendo ao chamado 034625 - inclusão no cCCusto1 os centros de custos 3173 e 6171
//CAS - 02/01/2017 - Atendendo ao chamado 038245 - inclusão no cCCusto1:3114/3174/3175/3176/3177/3178/3196/6173/6174/7190/7301/7302/7303
//CAS - 02/01/2017    7304/7305/7306/7307/7311/7312/7321/7331/7332/7333/7335/7401/7402/7404/7406/7421/7422/7423/7501/7599/7601/8000/8010
//CAS - 02/01/2017 - Atendendo ao Chamado 038248 - Alterado do cCCusto2 para o cCCusto1: 2001/2002/2107/3600/6101
cCCusto1 := '1140/2001/2002/2100/2101/2107/3110/3111/3112/3113/3114/3115/3117/3118/3119/3120/3125/3130/3140/3150/'
cCCusto1 +=	'3170/3171/3172/3173/3174/3175/3176/3177/3178/3180/3195/3196/3197/3198/3199/3600/3601/3603/3604/3605/'
cCCusto1 +=	'3606/3607/3608/3609/3610/4350/4351/4360/4370/6101/6104/6110/6130/6140/6150/6160/6161/6171/6173/6174/'
cCCusto1 +=	'7101/7102/7103/7104/7105/7106/7107/7108/7109/7110/7190/7201/7202/7203/7204/7205/7206/7207/7208/7209/'
cCCusto1 +=	'7210/7213/7301/7302/7303/7304/7305/7306/7307/7311/7312/7321/7331/7332/7333/7335/7401/7402/7404/7406/' 
cCCusto1 +=	'7421/7422/7423/7501/7599/7601/7801/8000/8010/8100/8103/8105/8500/9100/8101/'

//CAS - 02/01/2017 - Atendendo ao chamado 038246 - inclusão no cCCusto2: 1110/1111/7199/7399/7499/7699/7900/7908/7999 
//CAS - 02/01/2017 - Chamado 038248- Alterado do cCCusto1 para o cCCusto2:3602    -  do cCCusto3 para o cCCusto2:7905
cCCusto2 := '1000/1101/1102/1103/1104/1105/1106/1107/1108/1110/1111/1199/3116/3602/6100/6102/6180/7100/7199/7399/'
cCCusto2 +=	'7499/7699/7900/7901/7902/7903/7905/7908/7999/'

//CAS - 02/01/2017 - Atendendo ao chamado 038247 - inclusão no cCCusto3: 7195/7395/7495/7595/7695 
cCCusto3 := '1202/1203/2102/2103/6103/7195/7211/7212/7214/7395/7495/7595/7695/7904/8104' 
 
//Array que recebe os parâmetros informados.
cLP  := PARAMIXB[1]

 
	
//Validando Centro de Custo
If cLP $ "A01/A49/A50"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111004" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111004"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611004"
	EndIf
	 
ElseIf cLP $ "A03/A93/A14/A21"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113001" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113001"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613001"
	EndIf
	 
ElseIf cLP $ "A04/A23"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113003" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113003"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613003"
	EndIf
	 
ElseIf cLP $ "A05/A24"
	
	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113004" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113004"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613004"
	EndIf
	 
ElseIf cLP $ "A06/A61/A52/A53"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113002" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113002"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613002"
	EndIf
	 
ElseIf cLP == "A07"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113005" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113005"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613005"
	EndIf 
	 
ElseIf cLP == "A08"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42113006" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51113006"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51613006"
	EndIf 
	 
ElseIf cLP $ "A09/A67"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111001" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111001"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611001"
	EndIf
	 
ElseIf cLP $ "A10/A16"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111002" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111002"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611002"
	EndIf

ElseIf cLP == "A11"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42214004" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2+cCCusto3
		cRet:= "51214004"
	EndIf

ElseIf cLP == "A12"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111015" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111015"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611015"
	EndIf

ElseIf cLP $ "A28/B45"

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42112005" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51112005"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51612005"
	EndIf 
	
ElseIf cLP == "A29"
	 
	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111009" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111009"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611009"
	EndIf 

ElseIf cLP $ "A30/A72"
	 
	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42112004" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51112004"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51612004"
	EndIf
	
ElseIf cLP $ "A48/A70" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111005" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111005"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611005"
	EndIf
	
ElseIf cLP $ "A88/A17/A18/A19/A20" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111003" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111003"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611003"
	EndIf
	
ElseIf cLP == "B02"
 
	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111007" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111007"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611007"
	EndIf

ElseIf cLP == "B05"
 
	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111011" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111011"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611011"
	EndIf

ElseIf cLP $ "A79" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42111006" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51111006"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51611006"
	EndIf

ElseIf cLP $ "A80" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42218003" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2+cCCusto3
		cRet:= "51218004"
	EndIf

ElseIf cLP $ "B42" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1+cCCusto3
	    cRet:= "42212003" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51212003"
	EndIf

ElseIf cLP $ "B43/B47" 

	If ALLTRIM(SRZ->RZ_CC)$ cCCusto1
	    cRet:= "42112001" 
    ElseIf ALLTRIM(SRZ->RZ_CC)$ cCCusto2
		cRet:= "51112001"
	ElseIF ALLTRIM(SRZ->RZ_CC)$ cCCusto3
		cRet:= "51612001"
	EndIf
			
EndIf

Return (cRet)