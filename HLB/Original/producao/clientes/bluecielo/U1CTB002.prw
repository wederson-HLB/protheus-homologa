#INCLUDE "RWMAKE.CH"

/*
Funcao      : U1CTB002
Objetivos   : Padroniza??o do Lan?amento Padr?o para empresa U1
Autor       : Jo?o Silva
Obs.        :
Empresa		: BlueCielo
M?dulo		: RH / Contabil
Data        : 08/05/2015
*/

*--------------------------*
USER FUNCTION U1CTB002()
*--------------------------*
LOCAL cRet:= ""

IF SM0->M0_CODIGO $ "U1" .AND. ALLTRIM (SRZ->RZ_CC) $ "SS01"//Verifica se esta na empresa BlueCielo e se o centro de custa da folha ? SS01.
	IF ALLTRIM (SRV->RV_COD) $ "B25" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A01" // FGTS SAL 8%
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "001" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// SALARIO
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "160" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// HORA EXTRA 50%
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "190" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// DSR S/HORA EXTRA
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "097" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// SALDO SALARIO
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "163" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// HORA EXTRA 100%
		cRet:= "42111001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "286" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A09"// HORA EXTRA 75%
		cRet:= "42111002"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "090" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A10"// QUINQUENIO
		cRet:= "42111003"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "325" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A10"// BONUS ANUAL
		cRet:= "42111003"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "068" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A13"// 13?PROPORCIONAL
		cRet:= "42111003"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "069" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A13"// 13? S/AV.PREVIO
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "041" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// FERIAS GOZADAS
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "044" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// 1/3 FERIAS GOZADAS
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "215" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// MEDIAS FERIAS
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "057" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// FERIAS S/AVISO PREVIDE
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "058" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// 1/3 FER S/AV PREVIO
		cRet:= "42111004"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "062" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// FERIAS PROPORCIONAISDE
		cRet:= "42111007"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "063" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A21"// 1/3 FERIAS PROPORC
		cRet:= "42111010"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "060" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A48"// AV.PREVIO INDEN.
		cRet:= "42111010"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "072" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A49"// FGTS RESCISAO
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "074" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A49"// FGTS 40% S/RESC
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "091" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A49"// FGTS QUITACAO 13o
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "122" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A49"// FGTS MUL.S/DEP.10%
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "C83" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A88"// TERCEIROS
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "C94" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "A88"// S.A.T.
		cRet:= "42113001"
	ELSEIF ALLTRIM (SRV->RV_COD) $ "491" .AND. ALLTRIM (CT5->CT5_LANPAD) $ "B02"// AJ CUSTO FACULDADE
		cRet:= "42113002"
	ELSE
		cRet:= ""
	ENDIF
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A01\A09"
	cRet:= "51111001"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A10"
	cRet:= "51111002"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A88"
	cRet:= "51111003"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A49"
	cRet:= "51111004"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A48"
	cRet:= "51111005"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "B02"
	cRet:= "51111007"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A21"
	cRet:= "51113001"
ELSEIF ALLTRIM (CT5->CT5_LANPAD) $ "A13"
	cRet:= "21122002"
ENDIF

RETURN(cRet)


