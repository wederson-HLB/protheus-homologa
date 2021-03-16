#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#Include "TbiConn.ch"
//#include "ap5mail.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SRFM001   ∫Autor  ≥JAIRO OLIVEIRA      ∫ Data ≥  17/02/2010 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Gera arquivo EXCEL PARA abilizacao da SABIC para EMS        ∫±±
±±∫          ≥conforme leioute recebido                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function SRFM001()
Local aArea			:= GetArea()
Local cArqHora		:= DtoS(MSDATE()) + SubsTr(Time(),1,2) + SubsTr(Time(),4,2) + ".TXT"

Private _cFile		:=	"CT2" 
Private _cArq1		:=	"MOV" + "_"+ cArqHora // movimento
Private _cArq2		:=	"PAYR" + "_"+ cArqHora // PAYROLL 
Private _cArq3		:=	"FIN" + "_"+ cArqHora // FICHA FINANCEIRA
Private _cPath  	:=	fGetPath() // "C:\" //
Private cArqTxt 	:=	Alltrim(_cPath) + _cArq2

Private _cMens		:=	""
Private _lAuto		:=	.f.
Private	cBanco		:= Alltrim(Upper(TCGetDb()))


PRIVATE cPerg := "SRFM01"
//PRIVATE cXARQ := "ZZ4"
//GRAVA O NOME DA FUNCAO NA Z03
//U_CFGRD001(FunName())
//_cPath  	:=	fGetPath() // "C:\" //
//cArqTxt 	:=	Alltrim(_cPath) + _cArq2
AjustaSX1()                                                      

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica as perguntas selecionadas                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis utilizadas para parametros                         ≥
//≥ mv_par01     // Data de                                      ≥
//≥ mv_par02     // Data ate                                     ≥
//≥ mv_par03     // Lote de                                      ≥
//≥ mv_par04     // Lote ate                                     ≥
//≥ mv_par05     // doc  de                                      ≥
//≥ mv_par06     // Doc  Ate                                     ≥
//≥ mv_par07     // Moeda                                        ≥
//≥ mv_par08     // Sub Lote de                                  ≥
//≥ mv_par09     // Sub Lote de                                  ≥
//≥ mv_par10     // Imprime Lancto                               ≥
//≥ mv_par11     // Tipo de Contrato                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

If Pergunte(cPerg)                            
	//cDir+Iif(SubStr(cDir,Len(cDir),1)!="\","\","")
	//_cPath := alltrim(MV_PAR07) +  Iif(SubStr(Alltrim(mv_par07),Len(Alltrim(mv_par07)),1)!="\","\","")
	//cArqTxt 	:=	_cPath  + _cArq2
	// Deleta Arquivo Antigo Caso Ele Exista
	cArqTxt := _cPath + if(MV_Par13=1,"P","T") + "_SRF_" + alltrim(MV_Par09) + "_" + strtran(_Dtoc(mv_par03),"/","") + "_" + strtran(_dtoc(mv_par04),"/","") + "_" + ;
				alltrim(mv_par05) + ".txt"
	If File(cArqTxt)
		Ferase(cArqTxt)
	EndIf

	Processa({|| GPEMI1a() },"Aguarde! Selecionando Registros...",,.T.)
EndIf

RestArea(aArea)
Return
                          
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GPEMI1a   ∫Autor  ≥Jairo Oliveira      ∫ Data ≥  01/05/2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GPEMI1a()            
Local vH1			:= {}
Local vD1			:= {}
Local vD1_			:= {}
Local vT1			:= {} // valor
Local vT1_			:= {} // texto
Local aDetExcel		:= {}
Local aAreaSRA		:= SRA->(GETAREA())
//Local aAreaZZZ		:= ZZZ->(GETAREA()) //RRP - 30/05/2014 - Retirado, pois estava dando erro de que a ·rea n„o existia no ambiente GTCORP11.
Local _cCIC			:= ""
Local cCAMPO		:= ""
Local cSinal		:= ""
Local nVl1			:= 0
Local nCt			:= 0            
Local oExcelApp		:= nil
Local vCC1			:= {}

Local nNum			:= 0
Local nVlTot		:= 0
Local nNum1			:= 0
Local aCamposTXT	:= {}
Local _aArea		:= GetArea()
Local _cStr			:= ""
Local _nMs			:= "" //Len(CriaVar("A2_MSEXP"))
Local nHdl			:= fCreate(cArqTxt)
Local cEOL			:= ""
Local aSa2Auto		:= {}  // array para enviar arq dos autonomos
Local aMaxCod		:= {}  // array com os codigos maximos dos autonomos pro filial
Local cQuery		:= ""
Local aStruSA2		:= {}
Local aStruZZ1		:= {}                           
Local aMudaEnd		:= {}
Local aCfops		:= {}
Local cCodfrm		:= ""
Local cCampo		:= ""                    
LOCAL J				:= 0
Local cLin			:= ""
Local _cLinha		:= ""
Local nTamLin		:= 0
Local aStrStru		:= {}
Local nCount		:= 0
Local CRET			:= ""
//Local lAllSL	:= If(Empty(mv_par10) .or. mv_par10=="*",.T.,.F.)
Local cCat			:= ""
Local nR 			:= 0
Local nE			:= 0
/*
SELECT   XFILIAL, 
         XGRP, 
         XMAT, 
         XNOME, 
         XCIC, 
         XRECNO, 
         Sum(XVALOR) XVALOR 
FROM     (SELECT RC_FILIAL     XFILIAL, 
                 RV.RV_COD     XPD, 
                 RV.RV_XGRP    XGRP, 
                 RA_MAT        XMAT, 
                 RA_NOME       XNOME, 
                 RA_CIC        XCIC, 
                 RA.R_E_C_N_O_ XRECNO, 
                 RC_VALOR      XVALOR 
          FROM   SRCHN0 RC, 
                 SRVHN0 RV, 
                 SRAHN0 RA 
          WHERE  RC.D_E_L_E_T_ = ' ' 
                 AND RC_PD IN (SELECT RV_COD 
                               FROM   SRVHN0 
                               WHERE  RV_FILIAL = '  ' 
                                      AND RV_XGRP <> '   ' 
                                      AND D_E_L_E_T_ = ' ') 
                 AND RV.RV_FILIAL = '  ' 
                 AND RV.RV_COD = RC_PD 
                 AND RV.D_E_L_E_T_ = ' ' 
                 AND RA_FILIAL = RC_FILIAL 
                 AND RA_MAT = RC_MAT 
                 AND RA.D_E_L_E_T_ = ' ') QRYX 
GROUP BY XFILIAL, 
         XMAT, 
         XNOME, 
         XCIC, 
         XRECNO, 
         XGRP 
ORDER BY XFILIAL, 
         XMAT, 
         XGRP 
*/         

aadd( vH1 , 'H1' )//1
aadd( vH1 , 'EMP_PMOD' )//2
aadd( vH1 , 'EMP_CEEID' )//3
aadd( vH1 , 'EMP_PEEID' )//4
aadd( vH1 , 'EMP_FNAME' )//5
aadd( vH1 , 'EMP_MNAME' )//6
aadd( vH1 , 'EMP_ALIAS' )//7
aadd( vH1 , 'EMP_FST' )//8
aadd( vH1 , 'EMP_NPID' )//9
aadd( vH1 , 'EMP_TTL' )//10
aadd( vH1 , 'EMP_DOB' )//11
aadd( vH1 , 'EMP_COB' )//12
aadd( vH1 , 'EMP_GND' )//13
aadd( vH1 , 'EMP_MS_LC' )//14
aadd( vH1 , 'EMP_MS_LBL' )//15
aadd( vH1 , 'EMP_MS' )//16
aadd( vH1 , 'EMP_NAT' )//17
aadd( vH1 , 'EMP_NOC' )//18
aadd( vH1 , 'EMP_NAD' )//19
aadd( vH1 , 'EMP_AD1' )//20
aadd( vH1 , 'EMP_AD2' )//21
aadd( vH1 , 'EMP_AD3' )//22
aadd( vH1 , 'EMP_ZIP' )//23
aadd( vH1 , 'EMP_CITY' )//24
aadd( vH1 , 'EMP_STATE' )//25
aadd( vH1 , 'EMP_CTRY' )//26
aadd( vH1 , 'EBK_IBAN01' )//27
aadd( vH1 , 'EBK_BIC01' )//28
aadd( vH1 , 'EBK_BBAN01' )//29
aadd( vH1 , 'EBK_CURID01' )//30
aadd( vH1 , 'EBK_OWN01' )//31
aadd( vH1 , 'EBK_NAME01' )//32
aadd( vH1 , 'EBK_IBAN02' )//33
aadd( vH1 , 'EBK_BIC02' )//34
aadd( vH1 , 'EBK_BBAN02' )//35
aadd( vH1 , 'EBK_CURID02' )//36
aadd( vH1 , 'EBK_OWN02' )//37
aadd( vH1 , 'EBK_NAME02' )//38
aadd( vH1 , 'MMV_BK01_PERCENT' )//39
aadd( vH1 , 'MMV_BK01_AMOUNT' )//40
aadd( vH1 , 'MMV_BK02_PERCENT' )//41
aadd( vH1 , 'MMV_BK02_AMOUNT' )//42
aadd( vH1 , 'JOB_TTL' )//43
aadd( vH1 , 'JOB_TOC_LC' )//44
aadd( vH1 , 'JOB_TOC_LBL' )//45
aadd( vH1 , 'JOB_TOC' )//46
aadd( vH1 , 'JOB_EMPST_LC' )//47
aadd( vH1 , 'JOB_EMPST_LBL' )//48
aadd( vH1 , 'JOB_EMPST' )//49
aadd( vH1 , 'JOB_HIRR_LC' )//50
aadd( vH1 , 'JOB_HIRR_LBL' )//51
aadd( vH1 , 'JOB_HIRR' )//52
aadd( vH1 , 'JOB_CTSD' )//53
aadd( vH1 , 'JOB_CTED' )//54
aadd( vH1 , 'JOB_EED' )//55
aadd( vH1 , 'JOB_COSD' )//56
aadd( vH1 , 'JOB_TERR_LC' )//57
aadd( vH1 , 'JOB_TERR_LBL' )//58
aadd( vH1 , 'JOB_TERR' )//59
aadd( vH1 , 'JOB_CLASS_LC' )//60
aadd( vH1 , 'JOB_CLASS_LBL' )//61
aadd( vH1 , 'JOB_CLASS' )//62
aadd( vH1 , 'JOB_PT' )//63
aadd( vH1 , 'JOB_PTP' )//64
aadd( vH1 , 'ORG_LEGAL_ID' )//65
aadd( vH1 , 'ORG_LEGAL' )//66
aadd( vH1 , 'ORG_BRANCH_ID' )//67
aadd( vH1 , 'ORG_BRANCH' )//68
aadd( vH1 , 'ORG_DEPART_ID' )//69
aadd( vH1 , 'ORG_DEPARTMENT ' )//70
aadd( vH1 , 'ORG_SERVICE_ID' )//71
aadd( vH1 , 'ORG_SERVICE' )//72
aadd( vH1 , 'ORG_SITE_ID' )//73
aadd( vH1 , 'ORG_SITE ' )//74
aadd( vH1 , 'ORG_CCID01' )//75
aadd( vH1 , 'ORG_CCID02' )//76
aadd( vH1 , 'ORG_CCID03' )//77
aadd( vH1 , 'ORG_CCID04' )//78
aadd( vH1 , 'ORG_CCID05' )//79
aadd( vH1 , 'ORG_CCID06' )//80
aadd( vH1 , 'ORG_CCID07' )//81
aadd( vH1 , 'ORG_CCID08' )//82
aadd( vH1 , 'ORG_CCID09' )//83
aadd( vH1 , 'ORG_CCID10' )//84
aadd( vH1 , 'ORG_CCNAME01' )//85
aadd( vH1 , 'ORG_CCNAME02' )//86
aadd( vH1 , 'ORG_CCNAME03' )//87
aadd( vH1 , 'ORG_CCNAME04' )//88
aadd( vH1 , 'ORG_CCNAME05' )//89
aadd( vH1 , 'ORG_CCNAME06' )//90
aadd( vH1 , 'ORG_CCNAME07' )//91
aadd( vH1 , 'ORG_CCNAME08' )//92
aadd( vH1 , 'ORG_CCNAME09' )//93
aadd( vH1 , 'ORG_CCNAME10' )//94
aadd( vH1 , 'ORG_CCSK01' )//95
aadd( vH1 , 'ORG_CCSK02' )//96
aadd( vH1 , 'ORG_CCSK03' )//97
aadd( vH1 , 'ORG_CCSK04' )//98
aadd( vH1 , 'ORG_CCSK05' )//99
aadd( vH1 , 'ORG_CCSK06' )//100
aadd( vH1 , 'ORG_CCSK07' )//101
aadd( vH1 , 'ORG_CCSK08' )//102
aadd( vH1 , 'ORG_CCSK09' )//103
aadd( vH1 , 'ORG_CCSK10' )//104
aadd( vH1 , 'GSL_BSS' )//105
aadd( vH1 , 'GSL_SMS' )//106
aadd( vH1 , 'GSL_SBC' )//107
aadd( vH1 , 'GSL_OTC' )//108
aadd( vH1 , 'GSL_BNS' )//109
aadd( vH1 , 'GSL_COM' )//110
aadd( vH1 , 'GSL_OVS' )//111
aadd( vH1 , 'GSL_LEAV' )//112
aadd( vH1 , 'GSL_HSD' )//113
aadd( vH1 , 'GSL_HSC' )//114
aadd( vH1 , 'GSL_LSD' )//115
aadd( vH1 , 'GSL_LSC' )//116
aadd( vH1 , 'GSL_NTHC' )//117
aadd( vH1 , 'GSL_CCYN' )//118
aadd( vH1 , 'GSL_CCBIK' )//119
aadd( vH1 , 'GSL_OBIK' )//120
aadd( vH1 , 'GSL_HALW' )//121
aadd( vH1 , 'GSL_MALW' )//122
aadd( vH1 , 'GSL_TALW' )//123
aadd( vH1 , 'GSL_CALW' )//124
aadd( vH1 , 'GSL_OALW' )//125
aadd( vH1 , 'GSL_FEX' )//126
aadd( vH1 , 'GSL_TPP' )//127
aadd( vH1 , 'TOTAL_GSL' )//128
aadd( vH1 , 'EED_WTX' )//129
aadd( vH1 , 'EED_CSS' )//130
aadd( vH1 , 'EED_CRT' )//131
aadd( vH1 , 'EED_CUN' )//132
aadd( vH1 , 'EED_CMC' )//133
aadd( vH1 , 'EED_COTH' )//134
aadd( vH1 , 'EED_VRT' )//135
aadd( vH1 , 'EED_VMC' )//136
aadd( vH1 , 'EED_VOTH' )//137
aadd( vH1 , 'TOTAL_EED' )//138
aadd( vH1 , 'TOTAL_NSL' )//139
aadd( vH1 , 'NTP_SPPD' )//140
aadd( vH1 , 'NTP_EXRF' )//141
aadd( vH1 , 'NTP_EXPA' )//142
aadd( vH1 , 'NTP_BIK' )//143
aadd( vH1 , 'NTP_ONAD' )//144
aadd( vH1 , 'NTP_SAA' )//145
aadd( vH1 , 'NTP_TPP' )//146
aadd( vH1 , 'TOTAL_NADJ' )//147
aadd( vH1 , 'TOTAL_NTP' )//148
aadd( vH1 , 'ERC_WTX' )//149
aadd( vH1 , 'ERC_CSS' )//150
aadd( vH1 , 'ERC_CRT' )//151
aadd( vH1 , 'ERC_CUN' )//152
aadd( vH1 , 'ERC_CMC' )//153
aadd( vH1 , 'ERC_MCC' )//154
aadd( vH1 , 'ERC_AWI' )//155
aadd( vH1 , 'ERC_MCI' )//156
aadd( vH1 , 'ERC_MTX' )//157
aadd( vH1 , 'ERC_VOTH' )//158
aadd( vH1 , 'TOTAL_ERC' )//159
aadd( vH1 , 'ACR_HLS' )//160
aadd( vH1 , 'ACR_HLC' )//161
aadd( vH1 , 'ACR_BNS' )//162
aadd( vH1 , 'ACR_BNC' )//163
aadd( vH1 , 'ACR_SMS' )//164
aadd( vH1 , 'ACR_SMC' )//165
aadd( vH1 , 'TOTAL_ACR' )//166
aadd( vH1 , 'EXT_CCBIK' )//167
aadd( vH1 , 'EXT_OBIK' )//168

aadd( vCC1 , 'H0' )				//01
aadd( vCC1 , 'DOC_ENCOD' )		//02
aadd( vCC1 , 'DOC_CREATD' )		//03
aadd( vCC1 , 'DOC_CREATT' )		//04
aadd( vCC1 , 'DOC_TYPE' )
aadd( vCC1 , 'DOC_MVER' )
aadd( vCC1 , 'DOC_FVER' )
aadd( vCC1 , 'PTN_NAME' )
aadd( vCC1 , 'PTN_CID' )
aadd( vCC1 , 'CLT_LID' )
aadd( vCC1 , 'CLT_NAME' )
aadd( vCC1 , 'CLT_CID' )
aadd( vCC1 , 'CLT_CURID' )
aadd( vCC1 , 'PRL_PPD' )
aadd( vCC1 , 'PRL_PSD' )
aadd( vCC1 , 'PRL_PED' )
aadd( vCC1 , 'PRL_PSEQ' )
aadd( vCC1 , 'PRL_PDN' )
aadd( vcc1 , 'PRL_WTYPE' )
aadd( vCC1 , 'PRL_PRNUM' )

for nNum := len(vCC1) + 1 to Len(vH1)
	aadd( vCC1 , "" )
end

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

If nHdl == -1
	_cMens := "O arquivo de nome "+cArqTxt+" nao pode ser executado!"
	If _lAuto
		//_GerEml(_cMens)
	Else
		MsgAlert(_cMens + Space(1) + "Verifique os parametros.","Atencao!")
	EndIf
	
	Return()
Endif
                    
// Inicializa array dos campos do arquivo texto
//for nNum := 1 to 16     //206
//	aadd( aCamposTXT , "" )
//Next                     
//RRP - 28/11/2014 - Ajuste no Select para atender os 3 par‚metros do MV_PAR14
cQuery := ""
cQuery += " SELECT   XFILIAL, " + CRLF
cQuery += "          XGRP, " + CRLF
cQuery += "          XSINAL, " + CRLF
cQuery += "          XMAT, " + CRLF
cQuery += "          XNOME, " + CRLF
cQuery += "          XCIC, " + CRLF
cQuery += "          XRECNO, " + CRLF
cQuery += "          Sum(XVALOR) XVALOR " + CRLF
cQuery += " FROM     (SELECT " + if(MV_PAR14=1,"RC_FILIAL",IF(MV_PAR14=2,"RD_FILIAL","RI_FILIAL")) + "    XFILIAL, " + CRLF
cQuery += "                  RV.RV_COD     XPD, " + CRLF
cQuery += "                  RV.RV_XGRP    XGRP, " + CRLF
cQuery += "                  RV.RV_XSINAL  XSINAL, " + CRLF
cQuery += "                  RA_MAT        XMAT, " + CRLF
cQuery += "                  RA_NOME       XNOME, " + CRLF
cQuery += "                  RA_CIC        XCIC, " + CRLF
cQuery += "                  RA.R_E_C_N_O_ XRECNO, " + CRLF
cQuery += "                  RA_CATFUNC XCATFUNC, " + CRLF
cQuery += "                  RA_CC XCC, " + CRLF
cQuery += "                  " + if(MV_PAR14=1,"RC_VALOR",IF(MV_PAR14=2,"RD_VALOR","RI_VALOR")) + "     XVALOR " + CRLF
//RRP - 18/12/2014 - Ajuste para carregar o 13o. do Historico. Chamado 023249. 
If MV_PAR14=1//MÍs 
	cQuery += "           FROM   " + retsqlname("SRC") + " RC, " + CRLF 
ElseIf MV_PAR14=2//HistÛrico
	cQuery += "           FROM   " + retsqlname("SRD") + " RC, " + CRLF 
ElseIf MV_PAR14=3//MÍs 13o.
	cQuery += "           FROM   " + retsqlname("SRI") + " RC, " + CRLF 
Else //Historico 13o.
	cQuery += "           FROM   " + "RI"+cEmpAnt+Substr(DTOS(MV_PAR03),3,2)+"13" + " RC, " + CRLF		
EndIf
cQuery += "                  " + retsqlname("SRV") + " RV, " + CRLF
cQuery += "                  " + retsqlname("SRA") + " RA " + CRLF
cQuery += "           WHERE  " + CRLF             
IF MV_PAR14 = 1
	cQuery += "                      RC_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery += "                  AND RC_DATA   BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + CRLF
	cQuery += "                  AND RC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "                  AND RC_PD IN (SELECT RV_COD " + CRLF
ELSEIF MV_PAR14 = 2
	cQuery += "                      RD_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery += "                  AND RD_DATARQ   = '" +IF(MV_PAR14=2,SUBSTR(DTOS(MV_PAR03),1,6),SUBSTR(DTOS(MV_PAR03),1,4) + "13") + "' " + CRLF
	cQuery += "                  AND RC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "                  AND RD_PD IN (SELECT RV_COD " + CRLF          

ELSEIF MV_PAR14 = 3 .OR. MV_PAR14 = 4
	cQuery += "                      RI_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " + CRLF
	cQuery += "                  AND RI_DATA   BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' " + CRLF
	cQuery += "                  AND RC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "                  AND RI_PD IN (SELECT RV_COD " + CRLF
END
cQuery += "                                FROM   " + RETSQLNAME("SRV") + " " + CRLF
cQuery += "                                WHERE  RV_FILIAL = '" + XFILIAL("SRV") +"' " + CRLF
cQuery += "                                       AND RV_XGRP <> '   ' AND RV_XGRP <> '999' " + CRLF
cQuery += "                                       AND D_E_L_E_T_ = ' ') " + CRLF
cQuery += "                  AND RV.RV_FILIAL = '" + XFILIAL("SRV") + "' " + CRLF
cQuery += "                  AND RV.RV_COD = " + if(MV_PAR14=1,"RC_PD",IF(MV_PAR14=2,"RD_PD","RI_PD")) +  " " + CRLF
cQuery += "                  AND RV.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "                  AND RA_FILIAL = " + if(MV_PAR14=1,"RC_FILIAL",IF(MV_PAR14=2,"RD_FILIAL","RI_FILIAL")) + " " + CRLF
cQuery += "                  AND RA_MAT = " + if(MV_PAR14=1,"RC_MAT",IF(MV_PAR14=2,"RD_MAT","RI_MAT")) + " " + CRLF
cQuery += "                  AND RA.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "           UNION ALL " + CRLF
cQuery += "           SELECT RA_FILIAL      XFILIAL, " + CRLF
cQuery += "                  ''             XPD, " + CRLF
cQuery += "                  '000'          XGRP, " + CRLF 
cQUERY += "                  ''             XSINAL, " + CRLF
cQuery += "                  RA_MAT         XMAT, " + CRLF
cQuery += "                  RA_NOME        XNOME, " + CRLF
cQuery += "                  RA_CIC         XCIC, " + CRLF
cQuery += "                  XRA.R_E_C_N_O_ XRECNO, " + CRLF
cQuery += " 				 RA_CATFUNC XCATFUNC, " + CRLF
cQuery += " 				 RA_CC XCC, " + CRLF
cQuery += "                  0              XVALOR " + CRLF
cQuery += "           FROM   " + retsqlname("SRA") + "  XRA " + CRLF
cQuery += "           WHERE  RA_FILIAL BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + CRLF
cQuery += "                  AND XRA.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "                  AND RA_SITFOLH <> 'D' ) QRYX " + CRLF 
//RRP - 02/05/2014 - Categoria a Imprimir. Chamado 018220. 
If !Empty(Alltrim(MV_PAR15))	
	//Gerar categoria e Situacao para incluir no Select
	cCat := STRTRAN(Alltrim(MV_PAR15) , '*')
	MV_PAR15 := ""
	For nR := 1 To Len(cCat)
		If !Empty(alltrim(cCat))
			MV_PAR15 += "'"+Substr( cCat, nR, 1)+"',"
		EndIf
	Next nR
	MV_PAR15 := Substr(MV_PAR15, 1, Len(MV_PAR15)-1)
EndIf 
//RRP - 02/01/2015 - Filtrar Centro de Custo. Chamado 023312.
If !Empty(Alltrim(MV_PAR16))
	//Gerar cfop para incluir no Select
	aCfops :=STRTOKARR(MV_PAR16,";")
	MV_PAR16 := ""
	For nE:=1 to Len(aCfops)
		If !Empty(alltrim(aCfops[nE]))
			MV_PAR16+="'"+Alltrim(aCfops[nE])+"',"
		EndIf
	Next
	MV_PAR16 := LEFT(MV_PAR16,Len(MV_PAR16)-1)
EndIf
If !Empty(Alltrim(MV_PAR15)) .AND. !Empty(Alltrim(MV_PAR16))
	cQuery += " WHERE XCATFUNC IN ("+Alltrim(MV_PAR15)+") AND XCC IN ("+Alltrim(MV_PAR16)+") " + CRLF
ElseIf !Empty(Alltrim(MV_PAR15)) .OR. !Empty(Alltrim(MV_PAR16))
	cQuery += " WHERE "
	If !Empty(Alltrim(MV_PAR15))
		cQuery += "	XCATFUNC IN ("+Alltrim(MV_PAR15)+") " + CRLF
	Else
		cQuery += " XCC IN ("+Alltrim(MV_PAR16)+") " + CRLF
	EndIf
EndIf
cQuery += " GROUP BY XFILIAL, "
cQuery += "          XMAT, "
cQuery += "          XNOME, "
cQuery += "          XCIC, "
cQuery += "          XRECNO, "
cQuery += "          XGRP, "
cQuery += "          XSINAL " + CRLF
cQuery += " ORDER BY XFILIAL, "
cQuery += "          XMAT, "
cQuery += "          XGRP "



MEMOWRITE("C:\TEMP\SQLRV.TXT",CQUERY)

cQuery := ChangeQuery(cQuery)		   

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )

/*aStrSTRU := CT2->(dbStruct())      //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
        
For nStr := 1 to Len( CT2->(dbStruct()) )        //// LE A ESTRUTURA DA TABELA
	If aStrSTRU[nStr][2] <> "C" .and. TRB->(FieldPos(aStrSTRU[nStr][1])) > 0
		TcSetField("TRB",aStrSTRU[nStr][1],aStrSTRU[nStr][2],aStrSTRU[nStr][3],aStrSTRU[nStr][4])
	EndIf
Next*/    

TcSetField("TRB","XVALOR","N",12,2)

DbSelectArea("TRB")
DbGoTop()   
J := 0
DbEval({||j++  })
DbGoTop()   
                             
nCount := 0

TRB->(ProcRegua(J))                            

aadd( aDetExcel , vCC1 )
vCC1 := array(Len(vh1))

for nNum := 1 to len(vCC1)
	vCC1[nNum] := ""
next

vCC1[01]		:= "D0"
vCC1[02]		:= "UTF-8"
vCC1[03]		:= _DTOC(dDATABASE)
vCC1[04]		:= TIME()
vCC1[05]		:= "SRF"
vCC1[06]		:= "M2.0.2.0"
vCC1[07]		:= "F1.0.0"
vCC1[08]		:= ALLTRIM(MV_PAR07) //"PAGUS"
vCC1[09]		:= ALLTRIM(MV_PAR08) //"BR"
vCC1[10]		:= ALLTRIM(MV_PAR09) //"1234"
vCC1[11]		:= ALLTRIM(MV_PAR10) //"PAGUS"
vCC1[12]		:= ALLTRIM(MV_PAR11) //"BR"
vCC1[13]		:= ALLTRIM(MV_PAR12) //"BRL"
vCC1[14]		:= _DTOC( MV_PAR06 )
vCC1[15]		:= _DTOC( MV_PAR03 )
vCC1[16]		:= _DTOC( MV_PAR04 )
vCC1[17]		:= MV_PAR05
vCC1[18]		:= ""
vCC1[19]		:= "NORMAL"
vCC1[20]		:= "0"

aAdd( aDetExcel , vCC1 )
aAdd( aDetExcel , vH1 )

vT1 := ARRAY(LEN(vH1))
vT1_:= Array(Len(vH1))
FOR nNum := 1 TO LEN(vT1)
	vT1_[nNUM] := ""
	vT1[nNum] := 0
NEXT

vT1_[1] := "T1"

While !EOF()                
	IncProc("Recuperando InformaÁıes dos Funcion·rios....")
	/**/
	nCount += 1            
	SRA->(DBGOTO(TRB->XRECNO))

	SRG->(DBSETORDER(1))
	SRG->(DBSEEK( SRA->(RA_FILIAL + RA_MAT )) )

	vD1 := ARRAY(LEN(vH1))
	vD1_ := ARRAY(LEN(vH1))
	FOR nNum := 1 TO LEN(vD1)
		vD1[nNUM] := "" 
		vD1_[nNum] := 0 // para somar as colunas de total. // jj em 16/03/2010
	NEXT
	
	vD1[1]		:= "D1"
	vD1[2]		:= "BKTR"
	vD1[3]		:= if(empty(SRA->RA_CRACHA),TRB->XMAT,SRA->RA_CRACHA)
	vD1[4]		:= TRB->XMAT
	vD1[5]		:= GetTxt(Substr(Alltrim(TRB->XNOME),1,32)) //RRP - 12/03/2015 - Tratamento para retirar os caracteres especiais e tambÈm no tamanho m·ximo de 32 caracteres.
	vD1[6]		:= ""
	vD1[7]		:= ""
	vD1[8]		:= SF1STNAME(TRB->XNOME)
	vD1[9]		:= TRB->XCIC
	vD1[10]		:= IF(SRA->RA_SEXO=="M","MR","MRS")
	vD1[11]		:= _dtoc(SRA->RA_NASC)
//	vD1[12]		:= IF(SRA->RA_NACIONA$"10/20","BR","EX") //jj DE PARA PAIS
	vD1[12]		:= SRA->RA_XNACION // HMS 31/08/11
	vD1[13]		:= SRA->RA_SEXO
	vD1[14]		:= SRA->RA_ESTCIVI
	vD1[15]		:= Upper(AllTrim(Posicione("SX5",1,xFilial("SX5")+"33"+SRA->RA_ESTCIVI,"X5_DESCENG")))
	vD1[16]		:= sfestciv(SRA->RA_ESTCIVI)
//	vD1[17]		:= IF(SRA->RA_NACIONA$"10/20","BR","EX") //jj DE PARA PAIS
	vD1[17]		:= SRA->RA_XNACION // HMS 31/08/11
	vD1[18]		:= SFDEPEND(SRA->(RA_FILIAL+RA_MAT),"F") // DEPENDENTES PARA IR //EMP_NOC
	vD1[19]		:= SFDEPEND(SRA->(RA_FILIAL+RA_MAT)," ") // DEPENDENTES PARA IR //EMP_NAD // adultos dependentes
	vD1[20]		:= GetTxt(Alltrim(SRA->RA_ENDEREC))
	vD1[21]		:= GetTxt(Substr(IIF(!Empty(SRA->RA_COMPLEM),Alltrim(SRA->RA_COMPLEM) + " - ","") + Alltrim(SRA->RA_BAIRRO),1,31)) //RRP - 12/03/2015 - M·ximo de 32 caracteres.
	vD1[22]		:= "" //SRA->RA_MUNICIP + "-" + SRA_RA_ESTADO
	vD1[23]		:= SRA->RA_CEP
	vD1[24]		:= GetTxt(Alltrim(SRA->RA_MUNICIP)) //RRP - 18/03/2015 - Tratamento para retirar os caracteres especiais.
	vD1[25]		:= SRA->RA_CEP
	vD1[26]		:= "BR" // PAIS ONDE RESIDE O FUNC. // EMP_CTRY // 
	vD1[27]		:= ALLTRIM(SRA->RA_BCDEPSA)+SRA->RA_CTDEPSA	//	vD1[27]		:= SUBSTR(SRA->RA_BCDEPSA,1,3)
	vD1[28]		:= ""										//	vD1[28]		:= SUBSTR(SRA->RA_BCDEPSA,4,5) 
	vD1[29]		:= ""					  					//vD1[29]		:= SRA->RA_CTDEPSA
	vD1[30]		:= "BRL"
	vD1[31]		:= GetTxt(Substr(Alltrim(SRA->RA_NOME),1,32)) //RRP - 12/03/2015 - Tratamento para retirar os caracteres especiais e tambÈm no tamanho m·ximo de 32 caracteres.
	vD1[32]		:= PADR(Posicione("SA6",1,xFilial("SA6")+vD1[27]+vD1[28],"SA6->A6_NOME"),32)
	vD1[33]		:= ""
	vD1[34]		:= ""
	vD1[35]		:= ""
	vD1[36]		:= ""
	vD1[37]		:= ""
	vD1[38]		:= ""
	vD1[39]		:= "100%"
	vD1[40]		:= ""
	vD1[41]		:= ""
	vD1[42]		:= ""
	vD1[43]		:= fDesc('SRJ',SRA->RA_CODfUNC,'RJ_DESC',TAMSX3('RJ_DESC'),SRA->RA_FILIAL) // JOB TITLE // JOB_TTL
	vD1[44]		:= IF(SRA->RA_TPCONTR="2","DEFINITE","INDEFIITE") //"CDI" // JJ
	vD1[45]		:= IF(SRA->RA_TPCONTR="2","TEMPORARIO","PERMANENTE") //"PERMANENTE" // JJ JOB_TOC_LBL  // TIPO DE CONTRATO . PERMANENTE OU NAO
	vD1[46]		:= IF(SRA->RA_TPCONTR="2","DEF","IND") //"IND" // INDERTERMINADO / JJ // JOB_TOC
	vD1[47]		:= sfempst(1) // codigo  // JOB_EMPST // JJ
	vD1[48]		:= sfempst(2) // label "" //JJ
	vD1[49]		:= sfempst(1) // status ""
	vD1[50]		:= SRA->RA_TIPOADM //"CRE" // jj em 26/06/2011 //""

    // Trecho inserido por conta dos caracteres especiais e espaÁos na tabela 38  //
	If SRA->RA_TIPOADM == "1A"
		vD1[51]		:= "DIRETOR NAO EMPREGADO / 1 EMPREG" 
	ELSEIF SRA->RA_TIPOADM == "1B"
		vD1[51]		:= "DIRETOR NAO EMPREGADO / REEMPREG"
	ELSEIF SRA->RA_TIPOADM == "1C"
		vD1[51]		:= "DIRETOR NAO EMPREGADO / TRANSFER"
	ELSEIF SRA->RA_TIPOADM == "2A"
		vD1[51]		:= "TRABALHADOR RURAL / 1 EMPREGO"
	ELSEIF SRA->RA_TIPOADM == "2B"
		vD1[51]		:= "TRABALHADOR RURAL / REEMPREGO"
	ELSEIF SRA->RA_TIPOADM == "2C"
		vD1[51]		:= "TRABALHADOR RURAL / TRANSFERENCI"
	ELSEIF SRA->RA_TIPOADM == "3A"
		vD1[51]		:= "MENOR APRENDIZ / 1 EMPREGO"
	ELSEIF SRA->RA_TIPOADM == "3B"
		vD1[51]		:= "MENOR APRENDIZ / REEMPREGO"
	ELSEIF SRA->RA_TIPOADM == "3C"
		vD1[51]		:= "MENOR APRENDIZ / TRANFERENCIA"
	ELSEIF SRA->RA_TIPOADM == "9A"
		vD1[51]		:= "OUTROS / 1 EMPREGO"
	ELSEIF SRA->RA_TIPOADM == "9B"
		vD1[51]		:= "OUTROS / REEMPREGO"
	ELSEIF SRA->RA_TIPOADM == "9C"
		vD1[51]		:= "OUTROS / TRANSFERENCIA"	
	ELSE
		vD1[51]		:= alltrim(Posicione("SX5",1,xFilial("SX5")+"38"+SRA->RA_TIPOADM,"X5_DESCRI")) //"CRE"	
	ENDIF
	//////////////////////////////////////////////////////////////////////////// HMS 31/08/11
	vD1[52]		:= "CRE" // JJ // MOTIVO DA CONTRATACAO
	vD1[53]		:= _dtoc(SRA->RA_ADMISSA)
	vD1[54]		:= if(empty(SRA->RA_DEMISSA),"",_dtoc(SRA->RA_DEMISSA))
	vD1[55]		:= if(empty(SRA->RA_DEMISSA),"",_dtoc(SRA->RA_DEMISSA)) // CONFORME EMAIL DE 13/06/2011 //""
	vD1[56]		:= if(srg->(eof()),"",_dtoc(srg->rg_datadem) )  //_dtoc(SRA->RA_ADMISSA) // CONFORME EMAIL 13/06/2011 // "" // JJ
	vD1[57]		:= if(srg->(eof()),"",srg->rg_tipores + " " + SFTIPODEM())  //SFTERM(1) // COD ""
	vD1[58]		:= SFTERM(2) // LABEL ""
	vD1[59]		:= SFTERM(1) // CODD "" 
	vD1[60]		:= if(SRA->RA_XJOBCL="1","APP",IF(SRA->RA_XJOBCL="3","WKR",IF(SRA->RA_XJOBCL="4","SUP",IF(SRA->RA_XJOBCL="5","DIR","EMP"))))  //  //) //SRA->RA_CODFUNC
	vD1[61]		:= fDesc('SRJ',SRA->RA_CODfUNC,'RJ_DESC',TAMSX3('RJ_DESC'),SRA->RA_FILIAL) // JOB_CLASS_LBL // JJ ?
	vD1[62]		:= "EMP" // JJ // JOB_CLASS
	vD1[63]		:= SFJOBPT(1) // JOB_PT //"FULL" // JJ
	vD1[64]		:= SFJOBPT(2) // "100%"
	vD1[65]		:= SFFIL(TRB->XFILIAL,"1") // cnpj
	vD1[66]		:= PADR(SFFIL(TRB->XFILIAL,"2"),32) // nome emp
	vD1[67]		:= TRB->XFILIAL
	vD1[68]		:= SFFIL(TRB->XFILIAL,"3") // nome fil
	vD1[69]		:= SRA->RA_CC
	vD1[70]		:= fDesc("SI3",SRA->RA_CC, "SI3->I3_DESC")
	vD1[71]		:= ""
	vD1[72]		:= ""
	vD1[73]		:= CEMPANT //+ "/" + SRA->RA_FILIAL // CONFORME EMAIL 13/06/2011 EMPRSA /  FILIAL""
	vD1[74]		:= SRA->RA_CC // CONFORME EMAIL 13/06/2011 // RECEBER MAIS INFORMACOES //""
	vD1[75]		:= SRA->RA_CC // jj
	vD1[76]		:= ""
	vD1[77]		:= ""
	vD1[78]		:= ""
	vD1[79]		:= ""
	vD1[80]		:= ""
	vD1[81]		:= ""
	vD1[82]		:= ""
	vD1[83]		:= ""
	vD1[84]		:= ""
	vD1[85]		:= fDesc("SI3",SRA->RA_CC, "SI3->I3_DESC")
	vD1[86]		:= ""
	vD1[87]		:= ""
	vD1[88]		:= ""
	vD1[89]		:= ""
	vD1[90]		:= ""
	
	vD1[91]		:= ""
	vD1[92]		:= ""
	vD1[93]		:= ""
	vD1[94]		:= ""
	vD1[95]		:= "100%"	
	vD1[96]		:= ""
	vD1[97]		:= ""
	vD1[98]		:= ""
	vD1[99]		:= ""
	vD1[100]	:= ""
	
	vD1[101]	:= ""
	vD1[102]	:= ""
	vD1[103]	:= ""
	vD1[104]	:= ""
	//vD1[105]	:= Transform(SRA->RA_SALARIO ,"@e 999999999999.99") // GSL_BSS
	//vD1_[105]	:= SRA->RA_SALARIO // GSL_BSS
	//vT1[105]    += SRA->RA_SALARIO
	vD1[118]	:= "" // jj //GSL_CCYN // beneficio carro da empresa
	
	_cCIC := TRB->XCIC
	
	WHILE !EOF() .AND. _cCIC == TRB->XCIC
	
		IF TRB->XGRP == "000" .OR. TRB->XGRP == "999"
			TRB->(DBSKIP())
			LOOP
		END
		
		IF ZZZ->(DBSEEK(XFILIAL("ZZZ") + "02" + TRB->XGRP))
			cCampo := ALLTRIM( SUBSTR( ZZZ->ZZZ_TXT , 31,15 ) ) 
			cSinal := SUBSTR( ZZZ->ZZZ_TXT , 46,1 ) // SINAL NEGATIVO - OU NAO
			nNum := aScan( vH1 , cCampo )
			if nNum <> 0 .and. sfcolx(nNum) // ve se coluna e de somatoria
				nVl1 := TRB->XVALOR
				nVL1 := TRB->XVALOR * IF(TRB->XSINAL="-",-1,1)
				nVL1 := nVL1 + vD1_[nNUM]
				vD1[nNum] := alltrim( transform( nVL1 * IF(cSinal=="-",-1,1),"@e 999999999999.99" ) )
				vD1_[nNum] := nVL1 * IF(cSinal=="-",-1,1)
				vT1[nNum]  += nVL1 * IF(cSinal=="-",-1,1)
			end
		END
		DBSKIP()
	END                          
	
	// coloca zeros nas colunas a  partir de 105 - menos a coluna 118 // jj em 16/3/2010
	for nNum := 105 to len(vH1)
		if nNum <> 118
			if vD1[nNum] == ""
				vD1[nNum] :=  "0"
			end
		end
	next                                                       
	
	// soma campos de valor           
	nVlTot	:= 0
	for nNum := 105 to 127
		nVlTot += vD1_[nNum]
	Next                     
	vT1[128] += nVlTot
	vD1[128] := alltrim( transform( nVlTot ,"@e 999999999999.99" ) )
	vd1_[128] := nVlTot
	
	nVlTot	:= 0
	for nNum := 129 to 137
		nVlTot += vD1_[nNum]
	Next                     
	vT1[138] += nVlTot
	vD1[138] := alltrim( transform( nVlTot ,"@e 999999999999.99" ) )
	vd1_[138] := nVlTot                                                                        
	
//	vD1[139] := AllTrim( transform( vd1_[128] - nVlTot ,"@e 999999999999.99") ) // TOTAL_NSL // ALTERADO EM 18/05/2010 A PEDIDO
// VISTO QUE O CAMPO TOTAL_EED VAI TER VALORES NEGATIVOS. ENTAO ESTAVA DISTORCENDO COM NEGATIVO MENOS NEGATIVO
//	vD1[139] := AllTrim( transform( vd1_[128] + nVlTot ,"@e 999999999999.99") ) // TOTAL_NSL
//	vD1_[139] :=  vd1_[128] + nVlTot  // TOTAL_NSL
//	vT1[139] += (vd1_[128] + nVlTot)

// em 2/08/2010 novamente alterado a pedido
	vD1[139] := AllTrim( transform( vd1_[128] - nVlTot ,"@e 999999999999.99") ) // TOTAL_NSL
	vD1_[139] :=  vd1_[128] - nVlTot  // TOTAL_NSL
	vT1[139] += (vd1_[128] - nVlTot)
	
	nVlTot	:= 0
	for nNum := 140 to 146
		nVlTot += vD1_[nNum]
	Next                     
	vT1[147] += nVlTot
	vD1[147] := alltrim( transform( nVlTot ,"@e 999999999999.99" ) )
	vd1_[147] := nVlTot                     
	
	vd1[148] := alltrim( transform( vd1_[139] + nVlTot , "@e 999999999999.99") )
	vd1_[148] := vd1_[139] + nVlTot
	vt1[148] += ( vd1_[139] + nVlTot )

// conforme email em 13/06/2011  - jj - MMV_BK01_AMOUNT = TOTAL_NTP - 40 = 148
	vd1[40] := alltrim( transform( vd1_[139] + nVlTot , "@e 999999999999.99") )
	vd1_[40] := vd1_[139] + nVlTot
	vt1[40] += ( vd1_[139] + nVlTot )
		
	nVlTot	:= 0
	for nNum := 149 to 158
		nVlTot += vD1_[nNum]
	Next                     
	vT1[159] += nVlTot
	vD1[159] := alltrim( transform( nVlTot ,"@e 999999999999.99" ) )
	vd1_[159] := nVlTot                     	

	nVlTot	:= 0
	for nNum := 160 to 165
		nVlTot += vD1_[nNum]
	Next                     
	vT1[166] += nVlTot
	vD1[166] := alltrim( transform( nVlTot ,"@e 999999999999.99" ) )
	vd1_[166] := nVlTot                     
		
	AADD( ADETEXCEL , vD1 )
	
	DBSELECTAREA("TRB")	
	
End


for nNum := 1 to len(vH1)
	if vT1[nNum] <> 0
		vT1_[nNum] := transform( vT1[nNum] ,"@e 999999999999.99" )
	end                                                             
	
	if nNum >= 105 .and. nNum <> 118 .and. vT1[nNum] = 0
		vT1_[nNum] := "0"
	end
	
Next

aadd( aDetExcel , vT1_ )

For nNum := 1 to len(aDetExcel)
	_cLinha := ""
	For nCt := 1 to Len(aDetExcel[nNum])
		_cLinha := _cLinha + aDetExcel[nNum,nCt] + "^"
	next                                            
		nTamLin 	:= Len(_cLinha)
		cLin    	:= Space(nTamLin) + cEOL // Variavel para criacao da linha do registros para gravacao
		//  cLin := Stuff(cLin                 ,01                   ,02                ,cCpo)
		//                Expressao Vazia       Numero Carac Inicio   Tamanho            String(Expressao com Conteudo)
		cLin := Stuff(cLin,001,nTamLin,_cLinha)
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ≥
		//≥ linha montada.                                                      ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //RRP - 14/10/2014 - Retirado o UTF8 porque estava conflitando algumas linhas
		//If fWrite(nHdl,EncodeUTF8(cLin),Len(cLin)) != Len(cLin)
			_cMens := "Ocorreu um erro na gravacao do arquivo."
			If _lAuto
				//_GerEml(_cMens)
				Exit
			Else
				If !MsgBox( _cMens + Space(1) + "Continua?","YESNO")
					Exit
				Endif
			EndIf
		Endif
	    /**/
Next

cTitExcel := "CONFERENCIA DE BENEFICIOS"
//  	DlgToExcel({{"ARRAY","",;
//  	vH1,aDetExcel}})      
/*  	DlgToExcel({{"ARRAY",cTitExcel,{;
	"CRACHA",;
	"NOME",;
	"C.CUSTO",;
	"MATR",;
	"IDADE",;
	"FILIAL",;
	"DATA",;
	"VERBA",;
	"DESC.VERB",;
	"COD DEP/AGR",;
	"NOME DEP/AGR",;
	"GRAU PARENT.",;
	"VALOR",;
	"IDADE",;
	"tipovb";
  	},aDetExcel}})      */
If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf
              
SA2->(DBSETORDER(1))

/**/
            
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ O arquivo texto deve ser fechado                                    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
fClose(nHdl)

If File(cArqTxt)
		
	If !_lAuto
		MsgBox("Arquivo criado em '" + cArqTxt + "'."," Termino de Processamento","INFO")
	EndIf
Else
	_cMens := "Arquivo '"+ cArqTxt + "' N„o Foi Gravado Verifique!"
			
	If _lAuto
		//_GerEml(_cMens)
	Else
		MsgBox(_cMens)
	Endif
EndIf

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

	//oExcelApp := MsExcel():New()
	//oExcelApp:WorkBooks:Open(cArqTxt)
	//oExcelApp:SetVisible(.T.)
	//oExcelApp:Destroy()     

RETURN()                                                                         
        

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AjustaSX1 ≥ Autor ≥ Marcos V. Ferreira    ≥ Data ≥ 21.06.06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Ajusta o grupo de perguntas                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ MATR285                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function AjustaSX1()
Local aRegs    := {}
Local i,j 

Local aPerg :={}
                                                                     
//RRP - 14/11/2014 - Ajuste nos perguntes conforme Layout ADP
aadd(aRegs,{cPerg,"01","Filial De ?                   ","mv_ch1","C",02,0,0,"G","","mv_par01","","  ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"02","Filial Ate ?                  ","mv_ch2","C",02,0,0,"G","","mv_par02","","ZZ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"03","Data Inicial ?                ","mv_ch3","D",08,0,0,"G","","mv_par03","","20040101","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"04","Data Final ?                  ","mv_ch4","D",08,0,0,"G","","mv_par04","","20091231","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"05","Num de Correcao ?             ","mv_ch5","C",02,0,0,"G","","mv_par05","","00","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"06","Dt Proc Folha ?               ","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"07","PTN_NAME  ?                   ","mv_ch7","C",32,0,0,"G","","mv_par07","","  ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"08","PTN_CID   ?                   ","mv_ch8","C",02,0,0,"G","","mv_par08","","BR","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"09","CLT_LID   ?                   ","mv_ch9","C",10,0,0,"G","","mv_par09","","  ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"10","CLT_NAME  ?                   ","mv_chA","C",32,0,0,"G","","mv_par10","","  ","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"11","CLT_CID   ?                   ","mv_chB","C",02,0,0,"G","","mv_par11","","BR","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"12","CLT_CURID ?                   ","mv_chC","C",03,0,0,"G","","mv_par12","","BRL","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"13","Producao  ?                   ","MV_CHD","C",01,0,0,"C","naovazio","mv_par13","Sim","","","Nao","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"14","Origem dos Dados ?            ","MV_CHE","C",01,0,0,"C","naovazio","mv_par14","Mes","","","Historico","","","MÍs 13o.","","","Hist. 13o.","","","","",""})
//RRP - 23/04/2014 - Inclus„o de filtro. Chamado 018220. 
aadd(aRegs,{cPerg,"15","Categorias a Imp.  ?          ","mv_chf","C",10,0,0,"G","fCategoria","mv_par15","","ACDEGHIJMP**","","","","","","","","","","","","",""})
//RRP - 02/01/2015 - Filtrar Centro de Custo. Chamado 023312.
PutSx1( cPerg, "16", "Centro Custo ?", "Centro Custo ?", "Centro Custo ?", "MV_CHG", "C",50,00,00,"G","" , "","","","MV_PAR16","","","","","","","","","","","","","","","","",{"Informe o codigo separado por ;","exemplo:","5912;6912"})

_fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)

RETURN NIL
*----------------------------------------*
 Static function _fAtuSx1(cPerg,aRegs)
*----------------------------------------*
local _nOrdSx1:=sx1->(indexord()),;
      _nRecSx1:=sx1->(recno()),_nVez,_lApaga:=.f.,_nPergs:=0

sx1->(dbsetorder(1))
// Verifica se o formato solicitado ainda e o mesmo, caso contrario,
For _nVez:=1 to Len(aRegs)
  If sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     _nPergs++
     //Apaga e inclui tudo novamente
     If alltrim(sx1->x1_pergunt)<>alltrim(aRegs[_nVez,3])
        _lApaga:=.t.
        exit
     //RRP - 14/11/2014 - Ajuste no tamanho dos campos.
     ElseIf SX1->X1_TAMANHO <> aRegs[_nVez,6]
     	If SX1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     		SX1->(RecLock(Alias(),.F.))
     		SX1->X1_TAMANHO:= aRegs[_nVez,06]
     		SX1->(MsUnlock())
     	EndIf
     //RRP - 18/12/2014 - Incluir opÁ„o no MV_PAR14
     ElseIf Alltrim(SX1->X1_DEF04) <> Alltrim(aRegs[_nVez,21])
     	If SX1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     		SX1->(RecLock(Alias(),.F.))
     		SX1->X1_DEF04:= aRegs[_nVez,21]
     		SX1->(MsUnlock())
     	EndIf
     EndIf
  EndIf
Next
if _nPergs<>len(aRegs).or._lApaga
   sx1->(DbSeek(cPerg,.f.))
   do while sx1->(!eof().and.x1_grupo==aRegs[1,1])
      if sx1->(reclock(alias(),.f.))
         sx1->(dbdelete())
         sx1->(msunlock())
      endif
      sx1->(dbskip(1))
   enddo
endif

For _nVez:=1 to Len(aRegs)
  If !sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
    sx1->(RecLock(alias(),.T.))
    sx1->X1_GRUPO  :=aRegs[_nVez,01]
    sx1->X1_ORDEM  :=aRegs[_nVez,02]
    sx1->X1_PERGUNT:=aRegs[_nVez,03]
    sx1->X1_VARIAVL:=aRegs[_nVez,04]
    sx1->X1_TIPO   :=aRegs[_nVez,05]
    sx1->X1_TAMANHO:=aRegs[_nVez,06]
    sx1->X1_DECIMAL:=aRegs[_nVez,07]
    sx1->X1_PRESEL :=aRegs[_nVez,08]
    sx1->X1_GSC    :=aRegs[_nVez,09]
    sx1->X1_VALID  :=aRegs[_nVez,10]
    sx1->X1_VAR01  :=aRegs[_nVez,11]
    sx1->X1_DEF01  :=aRegs[_nVez,12]
    sx1->X1_CNT01  :=aRegs[_nVez,13]
    sx1->X1_VAR02  :=aRegs[_nVez,14]
    sx1->X1_DEF02  :=aRegs[_nVez,15]
    sx1->X1_CNT02  :=aRegs[_nVez,16]
    sx1->X1_VAR03  :=aRegs[_nVez,17]
    sx1->X1_DEF03  :=aRegs[_nVez,18]
    sx1->X1_CNT03  :=aRegs[_nVez,19]
    sx1->X1_VAR04  :=aRegs[_nVez,20]
    sx1->X1_DEF04  :=aRegs[_nVez,21]
    sx1->X1_CNT04  :=aRegs[_nVez,22]
    sx1->X1_VAR05  :=aRegs[_nVez,23]
    sx1->X1_DEF05  :=aRegs[_nVez,24]
    sx1->X1_CNT05  :=aRegs[_nVez,25]
    sx1->X1_F3     :=aRegs[_nVez,26]
    if len(aRegs[_nVez])>26
       sx1->x1_picture:=aRegs[_nVez,27]
    endif
    sx1->(MsUnlock())
  Endif
Next
sx1->(dbgoto(_nRecSx1))
sx1->(dbsetorder(_nOrdSx1))
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo	 ≥ fGetPath ≥ Autor ≥ Eduardo Alberti       ≥ Data ≥12/Apr/05 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Permite que o usuario decida onde sera criado o arquivo    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function fGetPath()

//Local _mvRet  :=	Alltrim(ReadVar())
Local _cPath  := ""
Local _cFila  := ""

While .T.
	If Empty(_cPath)
		_cPath := 	cGetFile( "Arquivos de Exportacao Autonomos | ",OemToAnsi("Selecione Diretorio"),,"",.f.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
		//  GETF_LOCALHARD
		//  GETF_RETDIRECTORY
		//  GETF_NETWORKDRIVE
		//  GETF_ONLYSERVER
		//  GETF_LOCALFLOPPY
	EndIf
	
	If Empty(_cPath)
		Return ("") //.F.
	EndIf
	
	Exit
EndDo
       
_cFila := _cPath

Return(_cFila)


/* FORMATA VALOR */
STATIC FUNCTION SFVALOR(nVL)
LOCAL CRET := REPLICATE("0",10)

cRet := strzero(nVl*100,9)

cRet := Substr(cRet,1,7) + "." + Substr(cRet,8,2)

Return(cRet)

/* RETORNA O PRIMEIRO NOME */
STATIC FUNCTION SF1STNAME(cNome)
Local cRET	:= ""
Local npos	:= 0

nPos := at(" ",cNome)
if nPos <> 0
	cRet := Left(cNome,nPos)
else
	cret := cNome
End
Return(cRet)

/* RETORNA NUMERO DE FILHOS DEPENDENTES PARA IR */
STATIC FUNCTION SFDEPEND(cCh,cTpx)
Local nRet		:= 0
Local aAreaSRB	:= SRB->(GETAREA())

SRB->(DBSEEK(cCH))
WHILE !SRB->(EOF()) .AND. SRB->(RB_FILIAL+RB_MAT) == cCh
	IF cTPX == "F" .And. SRB->RB_GRAUPAR == "F" .AND. SRB->RB_TIPIR <> "4"
		nRet++
	END                                                                  
	
	IF cTPX == " " .And. SRB->RB_GRAUPAR <> "F" .AND. SRB->RB_TIPIR <> "4"
		nRet++
	END                                                                  

	SRB->(DBSKIP())
End
                   
SRB->(RESTAREA(aAreaSRB))
Return( Transform(nRet , "@E 9999") )

/* RETORNA NOME DA FILIAL */
STATIC FUNCTION SFFIL(_cFIL,_ctp)
LOCAL cRET	:= ""
LOCAL aAREA	:= SM0->(GETAREA())

SM0->(DBSEEK(cEmpAnt+_cFil))
cRET := if(_ctp=="1",SM0->M0_CGC,IF(_ctp=="2",alltrim(SM0->M0_NOMECOM),IF(_ctp="3",alltrim(SM0->M0_FILIAL),"")))
SM0->(restArea(aArea))
Return(cRet)

/*  funcao para retornar AAAA/MM/DD */
Static Function _DTOC(dData)
Local cRet	:= Space(10)
LocaL cDt		:= Space(10)

cDt := DTOS(dData)

cRet := Substr(cDt,1,4) + "/" + substr(cDt,5,2) + "/" + substr(cDt,7,2)
Return(cRet)

/* ve se coluna e de somatoria */
static Function SfColx(nColx)
Local lret := .T.
Local cColx	:= ""

cColX := strzero(nColx,3)

if cColx $ "128,138,139,147,148,159,166"
	lRet := .F.
end

Return(lRet)

static function sfestciv(cest)
local cret := "S"       

do case     
	case alltrim(cest) == "C"
		cret := "M"
	case alltrim(cest) == "S"
		cret := "S"
	case alltrim(cest) == "D"
		cret := "D"
	case alltrim(cest) == "V"
		cret := "W"
	case alltrim(cest) == "M"
		cret := "O"
	case alltrim(cest) == "Q"
		cret := "D"
end

return(cret)

/* jj em 05/05/2010   empoyment status */
Static Function SFempSt(nTp) // 1 codigo // 2 label
Local cRet	:= ""

//if SRA->RA_SITFOLH = ' '
IF SRA->RA_SITFOLH = ' ' .Or. SRA->RA_SITFOLH = 'F' //HMS 31/08/11
	cRET := IF(nTP=1,"WKG","Working")
ELSEIF SRA->RA_SITFOLH = "D"
	cRET := IF(nTP=1,"TER","Terminated")
ELSEIF SRA->RA_SITFOLH = "A"//AFASTADO
	IF SRA->RA_AFASFGT = "P"
		cRET := IF(nTP=1,"LTSCK","Long term sickness")
	ELSEIF SRA->RA_AFASFGT = "Q"
		cRET := IF(nTP=1,"MAT","Maternity leave")
	ELSEIF SRA->RA_AFASFGT = "R"
		cRET := IF(nTP=1,"SPL","Special leave")
	ELSEIF SRA->RA_AFASFGT = "O"
		cRET := IF(nTP=1,"WRI","Work related illness")
	END		
END

Return(cRet)


/* TERMINATION REASON */
STATIC FUNCTION SFTERM(nTp)
LOCAL cRET := ""

IF SRA->RA_SITFOLH = "D"
	IF SRA->RA_AFASFGT $ "HI"
		CRET := IF(nTp=1,"DIS","Dismissal")
	elseif SRA->RA_AFASFGT = "J"
		CRET := IF(nTp=1,"RES","Resignation")
	ELSEIF SRA->RA_AFASFGT = "3"
		CRET := IF(nTp=1,"EOC","End of Contract")
	ELSEIF SRA->RA_AFASFGT = "M"
		CRET := IF(nTp=1,"RED","Redundancy")
	ELSEIF SRA->RA_AFASFGT = "U"
		CRET := IF(nTp=1,"RET","Retirement")
	ELSEIF SRA->RA_AFASFGT = "5"
		CRET := IF(NTP=1,"TRA","Transfer")
	END
END    
RETURN(CRET)

/* JOB_PT */
STATIC FUNCTION SFJOBPT(nTp)
Local cRet := ""
Local nPerc:= 0
//RRP - 23/02/2015 - Programa n„o tratava Pro-Labore. Chamado 024428.
if SRA->RA_CATFUNC $ "MEP" // MENSALISTA / ESTAGIARIOS MENSALISTAS / PRO-LABORE
	IF SRA->RA_HRSMES >= 160
		CRET := IF(nTp=1,"FULL","100%")
	ELSEIF SRA->RA_HRSMES < 160 .AND. nTP = 1
		CRET := "PART"    
	ELSEIF SRA->RA_HRSMES < 160 .AND. NTP = 2
		nPerc := (SRA->RA_HRSMES*100) / 160
		cRet := strzero(nperc,3) + "%"
	END
ELSEIF SRA->RA_CATFUNC $ "HG" // HORISTA E ESTAGIARIO HORISTA
	cret := If(nTp=1,"HOUR","100%")
END

Return(cRet)

/* TIPO DE DEMISSAO */
STATIC FUNCTION SFTIPODEM()
// LOCAL CRET := ""
LOCAL CRET := Space(29)

IF SRX->(dbSeek( xFilial("SRX")+"32"+SRG->RG_TIPORES ))
//	CRET := SUBSTR(SRX->RX_TXT,1,30)
	CRET := SUBSTR(SRX->RX_TXT,1,29) //HMS 31/08/11
ENDIF
RETURN(CRET)

/*
Funcao      : GetTxt()
Parametros  : cTxt
Retorno     : cTxt
Objetivos   : Tratamento para Retirada de caracteres invalidos dos textos.
Autor       : Renato Rezende
Data/Hora   : 23/02/2015
*/
*-------------------------------------*
Static Function GetTxt(cTxt)
*-------------------------------------*
Local i := 0
Local aCar := {"	","/","\",";","?","!","@","#","$","%","&","*","(",")","+","=","|","[","]","{","}","™","∫"}

//Retirando os acentos
cTxt:=NoAcento(cTxt)

For i:=1 to len(aCar)
	cTxt:=strtran(cTxt,aCar[i]," ")
Next i

Return cTxt