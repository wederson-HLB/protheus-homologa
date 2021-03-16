#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FILEIO.CH"
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ'ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GTADP_08 ≥Autor  ≥ JAckson Capelato      ≥ Data ≥20/08/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Rel. HLB BRASIL ADP - Standard Return File             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Obs:      ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico HLB BRASIL                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
*------------------------------------*
User Function GTADP_08(cPath,cPeriodo)
*------------------------------------*
Processa( {|| GTADP08_SRF(cPath,cPeriodo) }, "Gerando Standard Return File ..." )

Return( .F. )
        
*-----------------------------------------*
Static Function GTADP08_SRF(cPath,cPeriodo)
*-----------------------------------------*
Local _cFolMes  := subs(GETMV("MV_FOLMES"),5,2)+"/"+subs(GETMV("MV_FOLMES"),1,4)
Local nPosVer := 0                         
Local cMsg := 0
Local i
Private aH0:={}
Private aH1:={}
Private aD0:={}
Private aD1:={}
PRIVATE _cPer1ini := subs(cPeriodo,4,4)+subs(cPeriodo,1,2)+"01"
PRIVATE _cPer1fin := ""
PRIVATE _cNomArq := "SRF"
Private _cPer3ini := ""
Private nYear3 := VAL(subs(cPeriodo,4,4))
PRIVATE cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))

Private cNomeEmx := ""
Private cNomeEmp := STRTRAN(ALLTRIM(SM0->M0_NOME),".","-")

for x = 1 to len(cNomeEmp)
	if substr(cNomeEmp,x,1) <> " "
		cNomeEmx := cNomeEmx + substr(cNomeEmp,x,1)	
	endif
next x

cNomeEmp := alltrim(cNomeEmx)

Private cCC := ' '


//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5")+"X0"+"CID")
	cCID := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"ENTITY")
	cENTITY := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif
If DbSeek(xFilial("SX5")+"X0"+"LID")
	cLID := X5_DESCRI
Else
	Aviso("ATEN«√O", "N„o encontrada tabela X0!. Verifique!", {"Ok"} )
	Return
Endif

// francisco neto  19/09/2016
DbSelectArea("SX2") //verifica compartilhamento de centro de custos
DbSetOrder(1)

If DbSeek("CTT")
	cCC := X2_MODO
Endif


	//// francisco neto 27/09/16
	IF UPPER(ALLTRIM(_cRegime)) == "S"
	
		// adianta periodo inicial para regime de caixa
		If subs(cPeriodo,1,2) = "12"
			_cMesfin := "01"
			_cAnofin := strzero(val(subs(cPeriodo,4,4))+1,2)
		Else
			_cMesfin := strzero(val(subs(cPeriodo,1,2))+1,2)
			_cAnofin := subs(cPeriodo,4,4)
		Endif 
		
		_cPer3ini := _cAnofin+_cMesfin
		nYear3 := _cAnofin
		
	ENDIF



//Armazena os dados da tabela X0 do SX5
DbSelectArea("SX5")
DbSetOrder(1)

AADD(aH0,{'DOC_ENCOD','DOC_CREATD','DOC_CREATT','DOC_TYPE','DOC_MVER','DOC_FVER','PTN_NAME','PTN_CID','CLT_LID','CLT_NAME',;
			'CLT_CID','CLT_CURID','PRL_PPD','PRL_PSD','PRL_PED','PRL_PSEQ','PRL_PDN','PRL_WTYPE','PRL_PRNUM'})
AADD(aH1,{'EMP_PMOD','EMP_CEEID','EMP_PEEID','EMP_FNAME','EMP_MNAME','EMP_ALIAS','EMP_FST','EMP_NPID','EMP_TTL','EMP_DOB','EMP_COB',;
		  'EMP_GND','EMP_MS_LC','EMP_MS_LBL','EMP_MS','EMP_NAT','EMP_NOC','EMP_NAD','EMP_AD1','EMP_AD2',;
          'EMP_AD3','EMP_ZIP','EMP_CITY','EMP_STATE','EMP_CTRY','EBK_IBAN01','EBK_BIC01','EBK_BBAN01','EBK_CURID01','EBK_OWN01',;
          'EBK_NAME01','EBK_IBAN02','EBK_BIC02','EBK_BBAN02','EBK_CURID02','EBK_OWN02','EBK_NAME02','MMV_BK01_PERCENT',;
          'MMV_BK01_AMOUNT','MMV_BK02_PERCENT','MMV_BK02_AMOUNT','JOB_TTL','JOB_TOC_LC','JOB_TOC_LBL','JOB_TOC','JOB_EMPST_LC',;
          'JOB_EMPST_LBL','JOB_EMPST','JOB_HIRR_LC','JOB_HIRR_LBL','JOB_HIRR','JOB_CTSD','JOB_CTED','JOB_EED','JOB_COSD',;
          'JOB_TERR_LC','JOB_TERR_LBL','JOB_TERR','JOB_CLASS_LC','JOB_CLASS_LBL','JOB_CLASS','JOB_PT','JOB_PTP','ORG_LEGAL_ID',;
          'ORG_LEGAL','ORG_BRANCH_ID','ORG_BRANCH','ORG_DEPART_ID','ORG_DEPARTMENT','ORG_SERVICE_ID','ORG_SERVICE',;
          'ORG_SITE_ID','ORG_SITE','ORG_CCID01','ORG_CCID02','ORG_CCID03','ORG_CCID04','ORG_CCID05','ORG_CCID06','ORG_CCID07',;
          'ORG_CCID08','ORG_CCID09','ORG_CCID10','ORG_CCNAME01','ORG_CCNAME02','ORG_CCNAME03','ORG_CCNAME04','ORG_CCNAME05',;
          'ORG_CCNAME06','ORG_CCNAME07','ORG_CCNAME08','ORG_CCNAME09','ORG_CCNAME10','ORG_CCSK01','ORG_CCSK02','ORG_CCSK03',;
          'ORG_CCSK04','ORG_CCSK05','ORG_CCSK06','ORG_CCSK07','ORG_CCSK08','ORG_CCSK09','ORG_CCSK10','GSL_BSS','GSL_SMS','GSL_SBC',;
          'GSL_OTC','GSL_BNS','GSL_COM','GSL_OVS','GSL_LEAV','GSL_HSD','GSL_HSC','GSL_LSD','GSL_LSC','GSL_NTHC','GSL_CCYN',;
          'GSL_CCBIK','GSL_OBIK','GSL_HALW','GSL_MALW','GSL_TALW','GSL_CALW','GSL_OALW','GSL_FEX','GSL_TPP','TOTAL_GSL','EED_WTX','EED_CSS',;
          'EED_CRT','EED_CUN','EED_CMC','EED_COTH','EED_VRT','EED_VMC','EED_VOTH','TOTAL_EED','TOTAL_NSL','NTP_SPPD','NTP_EXRF',;
          'NTP_EXPA','NTP_BIK','NTP_ONAD','NTP_SAA','NTP_TPP','TOTAL_NADJ','TOTAL_NTP','ERC_WTX','ERC_CSS','ERC_CRT','ERC_CUN','ERC_CMC',;
          'ERC_MCC','ERC_AWI','ERC_MCI','ERC_MTX','ERC_VOTH','TOTAL_ERC','ACR_HLS','ACR_HLC','ACR_BNS','ACR_BNC','ACR_SMS',;
          'ACR_SMC','TOTAL_ACR','EXT_CCBIK','EXT_OBIK'})

aT1 := Array(167)
FOR X= 1 TO Len(aT1)
	If (X==39 .or. X>=104) .and. X <> 117
		aT1[X] := 0
	Else
		aT1[X] := ""	
	EndIf
NEXT

cData:=subs(dtos(ddatabase),1,4)+"/"+subs(dtos(ddatabase),5,2)+"/"+subs(dtos(ddatabase),7,2)
uDiaMes:=lastday(ctod('01/'+cPeriodo),0)
pDiaMes:=ctod('01/'+cPeriodo)
cLast:=subs(dtos(uDiaMes),1,4)+"/"+subs(dtos(uDiaMes),5,2)+"/"+subs(dtos(uDiaMes),7,2)
cFirst:=subs(dtos(pDiaMes),1,4)+"/"+subs(dtos(pDiaMes),5,2)+"/"+subs(dtos(pDiaMes),7,2)
_cPer1fin:=DTOS(uDiaMes)

AADD(aD0,{'UTF-8',cData,time(),'SRF','M2.0.2.0','F1.0.0','HLB BRASIL CONSULTORIA DE RH','BR',AllTrim(cLID),LEFT(ALLTRIM(SM0->M0_NOME),32),;
			'BR','BRL',cLast ,cFirst,cLast,'1','','NORMAL WAGES','0'})


/* aD1 - query definida pelos campos utilizando a src ou srd dependendo do periodo de extraÁao - OK*/
/* Associar a SRD/SRC com a srv para pegar o campo RV_XGRP - ele serÅEutilizado para agrupar o envio - sÅEdeverÅEir os preenchidos e com valor- OK*/
/* criar uma nova tabela de GRP e colocar o F3 para ela */
/* criar axcadastro para nova tabela */

AcPer:=subs(cPeriodo,4,4)+subs(cPeriodo,1,2)

IF cPERIODO = _cFolMes
	_cQrySrc := " SELECT RC_FILIAL FILIAL,RC_MAT MATR FROM "+RetSqlName("SRC")+" A   "	    // francisco neto 31/08/16
	_cQrySrc +=	" LEFT JOIN "+RetSqlName("SRV")+" B ON B.D_E_L_E_T_ <> '*' AND RV_COD = RC_PD AND RV_XGRP <> '' "
	_cQrySrc +=	" WHERE A.D_E_L_E_T_ <> '*' "
	_cQrySrc += " AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
	_cQrySrc += " AND left(RC_DATA,6) > ' ' "     /// francisco neto 21/10/2016   	
	_cQrySrc +=	" GROUP BY RC_FILIAL,RC_MAT "	// francisco neto 31/08/16
	_cQrySrc +=	" ORDER BY RC_FILIAL,RC_MAT "	//francisco neto 31/08/16
	_cQrySrV := ChangeQuery( _cQrySrc )
ELSE
	_cQrySrd := " SELECT RD_FILIAL FILIAL,RD_MAT MATR FROM "+RetSqlName("SRD")+" A   "	//francisco neto 31/08/16
	_cQrySrD +=	" LEFT JOIN "+RetSqlName("SRV")+" B ON B.D_E_L_E_T_ <> '*' AND RV_COD = RD_PD AND RV_XGRP <> '' "
	_cQrySrD +=	" WHERE A.D_E_L_E_T_ <> '*' AND RD_DATARQ = '"+AcPer+"' "
	_cQrySrD += " AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016	
	_cQrySrD +=	" AND RD_MAT NOT IN (SELECT RE_MATP FROM "+RetSqlName("SRE")+" WHERE D_E_L_E_T_ = '' AND RE_EMPD <> RE_EMPP AND LEFT(RE_DATA,6) > '"+AcPer+"')"		//RSB - 30/06/2017 - Esta trazendo a matricula que n„o estavo periodo informado, a transferencia n„o estava sendo considerada.
	_cQrySrD +=	" GROUP BY RD_FILIAL,RD_MAT "		//francisco neto 31/08/16	
	_cQrySrD +=	" ORDER BY RD_FILIAL,RD_MAT "		//francisco neto 31/08/16	
	_cQrySrV := ChangeQuery( _cQrySrd )
ENDIF

If Select("qSRV") <> 0
	qSRV->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQrySrV), "qSRV", .F., .T.)

IF cPERIODO = _cFolMes
	_cQrySrc := " SELECT RC_FILIAL FILIAL,RC_MAT MATR,  RV_XGRP GRUPO, SUM(RC_VALOR) VALOR FROM "+RetSqlName("SRC")+" A   "       //francisco neto 31/08/2016
	_cQrySrc +=	" LEFT JOIN "+RetSqlName("SRV")+" B ON B.D_E_L_E_T_ <> '*' AND RV_COD = RC_PD AND RV_XGRP <> '' "
	_cQrySrc +=	" WHERE A.D_E_L_E_T_ <> '*' "
	_cQrySrc += " AND RC_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016
	_cQrySrc += " AND LEFT(RC_DATA,6) > ' ' "     // francisco neto 21/10/2016   
	_cQrySrc +=	" GROUP BY RC_FILIAL,RC_MAT,RV_XGRP "	// francisco neto 31/08/2016
	_cQrySrc +=	" ORDER BY RC_FILIAL,RC_MAT,RV_XGRP "   // francisco neto 31/08/2016
	_cQrySrF := ChangeQuery( _cQrySrc )
ELSE
	_cQrySrD := " SELECT RD_FILIAL FILIAL,RD_MAT MATR,  RV_XGRP GRUPO, SUM(RD_VALOR) VALOR FROM "+RetSqlName("SRD")+" A   "	 // francisco neto 31/08/16
	_cQrySrD +=	" LEFT JOIN "+RetSqlName("SRV")+" B ON B.D_E_L_E_T_ <> '*' AND RV_COD = RD_PD AND RV_XGRP <> '' "
	_cQrySrD +=	" WHERE A.D_E_L_E_T_ <> '*' AND RD_DATARQ = '"+AcPer+"' "
	_cQrySrD += " AND RD_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016	
	_cQrySrD +=	" AND RD_MAT NOT IN (SELECT RE_MATP FROM "+RetSqlName("SRE")+" WHERE D_E_L_E_T_ = '' AND RE_EMPD <> RE_EMPP AND LEFT(RE_DATA,6) > '"+AcPer+"')"		//RSB - 30/06/2017 - Esta trazendo a matricula que n„o estavo periodo informado, a transferencia n„o estava sendo considerada.
	_cQrySrD +=	" GROUP BY RD_FILIAL,RD_MAT,RV_XGRP "	
	_cQrySrD +=	" ORDER BY RD_FILIAL,RD_MAT,RV_XGRP "	    // francisco neto 31/08/16
	
	_cQrySrF := ChangeQuery( _cQrySrd )
ENDIF

If Select("qSRF") <> 0
	qSRF->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQrySrF), "qSRF", .F., .T.)

dbSelectArea("qSRV")
dbGoTop()

OLD:=''
X:=0
DO WHILE qSRV->(!eof())
	             
	aAdd(aD1,Array(167))
	
	_cQrySra := " SELECT RA_NOME, RA_CRACHA, RA_CIC, RA_NASC, RA_SEXO, RA_ESTCIVI, RA_ENDEREC, RA_CEP, RA_MUNICIP, RA_ESTADO, A6_NOME,  RJ_DESC, RA_TPCONTR, RA_SITFOLH, RA_ADMISSA, RA_DTFIMCT, RA_DEMISSA, RA_RESCRAI, RA_XJOBCL, "
	if UPPER(cCodemp) = "NX"
		_cQrySra += " RA_CATFUNC, RA_CC, CTT_DESC02, RA_SALARIO, RA_XNACION, RA_XCONTRB "	
	else
		_cQrySra += " RA_CATFUNC, RA_CC, CTT_DESC01, RA_SALARIO, RA_XNACION, RA_XCONTRB "
	endif
	_cQrySra += " FROM "+RetSqlName("SRA")+" A "
	_cQrySra += " LEFT JOIN "+RetSqlName("SA6")+" B ON B.D_E_L_E_T_ <> '*' AND A6_COD = SUBSTRING(RA_BCDEPSA,1,7) "	     // francisco neto  31/08/16
	_cQrySra += " LEFT JOIN "+RetSqlName("SRJ")+" C ON C.D_E_L_E_T_ <> '*' AND RJ_FUNCAO = RA_CODFUNC "

	if cCC = "C" 
		_cQrySra += " LEFT JOIN "+RetSqlName("CTT")+" D ON D.D_E_L_E_T_ <> '*' AND CTT_CUSTO = RA_CC "	// francisco neto 19/09/16
	else
		_cQrySra += " LEFT JOIN "+RetSqlName("CTT")+" D ON D.D_E_L_E_T_ <> '*' AND CTT_CUSTO = RA_CC AND CTT_FILIAL = RA_FILIAL"	// francisco neto 19/09/16
	endif
	
	_cQrySra += " WHERE A.D_E_L_E_T_ <> '*' AND A.RA_FILIAL = '"+qSRV->FILIAL+"' AND A.RA_MAT = '"+qSRV->MATR+"' "  // francisco neto 31/08/16
	_cQrySra += " AND RA_FILIAL BETWEEN '" + _cFilialI +"' AND '" + _cFilialF +"' "	//francisco neto 19/09/2016		
	_cQrySra := ChangeQuery( _cQrySra )
	
	If Select("qSRA") <> 0
		qSRA->(dbCloseArea())
	EndIf
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQrySra), "qSRA", .F., .T.)
	
	Z:=LEN(aD1)
	
	dbSelectArea("qSRA")
	dbGoTop()

	cCodemp := upper(ALLTRIM(SM0->M0_CODIGO))
    
    //RSB - 30/06/2017 - Os campo estavam sendo traduzidos, foi comentado a traduÁ„o das informaÁıes dos campo
	/*
	IF UPPER(cCodemp) = "NX"	
		IF qSRA->RA_ESTCIVI='C'
			xESTCIVI='MARRIED'
			xMARSTS := 'M'
		ELSEIF qSRA->RA_ESTCIVI='D'
			xESTCIVI='DIVORCED'
			xMARSTS := 'D'
		ELSEIF qSRA->RA_ESTCIVI='M'
			xESTCIVI='STABLE UNION'
			xMARSTS := 'O'
		ELSEIF qSRA->RA_ESTCIVI='O'
			xESTCIVI='OTHERS'
			xMARSTS := 'O'
		ELSEIF qSRA->RA_ESTCIVI='Q'
			xESTCIVI='DISCOUNTED'
			xMARSTS := 'D'
		ELSEIF qSRA->RA_ESTCIVI='S'
			xESTCIVI='NOT MARRIED'
			xMARSTS := 'S'
		ELSEIF qSRA->RA_ESTCIVI='V'
			xESTCIVI='WIDOWER'
			xMARSTS := 'W'
		ELSE
			xESTCIVI=''
			xMARSTS := 'O'
		ENDIF
	
	ELSE
	*/
		IF qSRA->RA_ESTCIVI='C'
			xESTCIVI='CASADO'
			xMARSTS := 'M'
		ELSEIF qSRA->RA_ESTCIVI='D'
			xESTCIVI='DIVORCIADO'
			xMARSTS := 'D'
		ELSEIF qSRA->RA_ESTCIVI='M'
			xESTCIVI='UNIAO ESTAVEL'
			xMARSTS := 'O'
		ELSEIF qSRA->RA_ESTCIVI='O'
			xESTCIVI='OUTROS'
			xMARSTS := 'O'
		ELSEIF qSRA->RA_ESTCIVI='Q'
			xESTCIVI='DESQUITADO'
			xMARSTS := 'D'
		ELSEIF qSRA->RA_ESTCIVI='S'
			xESTCIVI='SOLTEIRO'
			xMARSTS := 'S'
		ELSEIF qSRA->RA_ESTCIVI='V'
			xESTCIVI='VIUVO'
			xMARSTS := 'W'
		ELSE
			xESTCIVI=''
			xMARSTS := 'O'
		ENDIF
	/*
	ENDIF
	*/

	aD1[Z][001]:= "BKTR" //EMP_PMOD 
	aD1[Z][002]:= If(!Empty(qSRA->RA_CRACHA),AllTrim(qSRV->filial)+AllTrim(qSRA->RA_CRACHA),AllTrim(qSRV->filial)+AllTrim(qSRV->MATR))  //EMP_CEEID	   // francisco neto 06/09/16
	aD1[Z][003]:= AllTrim(qSRV->filial)+AllTrim(qSRV->MATR) //EMP_PEEID	      // francisco neto  31/08/16
	aD1[Z][004]:= ParteNome(AllTrim(qSRA->RA_NOME),"LAST") //EMP_FNAME
	aD1[Z][005]:= '' //EMP_MNAME
	aD1[Z][006]:= '' //EMP_ALIAS
	aD1[Z][007]:= ParteNome(AllTrim(qSRA->RA_NOME),"FIRST") //EMP_FST
	aD1[Z][008]:= qSRA->RA_CIC    //EMP_NPID
	aD1[Z][009]:= '' //EMP_TTL
	aD1[Z][010]:= IIF(EMPTY(qSRA->RA_NASC),"",subs(qSRA->RA_NASC,1,4)+"/"+subs(qSRA->RA_NASC,5,2)+"/"+subs(qSRA->RA_NASC,7,2)) //EMP_DOB 
	aD1[Z][011]:= '' //EMP_COB
	aD1[Z][012]:= qSRA->RA_SEXO //EMP_GND
	aD1[Z][013]:= qSRA->RA_ESTCIVI //EMP_MS_LC
	aD1[Z][014]:= xESTCIVI //EMP_MS_LBL
	aD1[Z][015]:= xMARSTS  //EMP_MS
	aD1[Z][016]:= AllTrim(qSRA->RA_XNACION) //EMP_NAT   ////If(AllTrim(qSRA->RA_XNACION) $ "10|20","BR","") //EMP_NAT
	aD1[Z][017]:= ' ' //EMP_NOC
	aD1[Z][018]:= ' ' //EMP_NAD
	aD1[Z][019]:= AllTrim(qSRA->RA_ENDEREC) //EMP_AD1
	aD1[Z][020]:= ' ' //EMP_AD2
	aD1[Z][021]:= ' ' //EMP_AD3
	aD1[Z][022]:= AllTrim(qSRA->RA_CEP) //EMP_ZIP
	aD1[Z][023]:= AllTrim(qSRA->RA_MUNICIP) //EMP_CITY
	aD1[Z][024]:= AllTrim(qSRA->RA_ESTADO) //EMP_STATE
	aD1[Z][025]:= ' ' //EMP_CTRY
	aD1[Z][026]:= ' ' //EBK_IBAN01
	aD1[Z][027]:= ' ' //EBK_BIC01
	aD1[Z][028]:= ' ' //EBK_BBAN01
	aD1[Z][029]:= 'BRL' //EBK_CURID01
	aD1[Z][030]:= ' ' //EBK_OWN01
	aD1[Z][031]:= AllTrim(subs(qSRA->A6_NOME,1,30))//EBK_NAME01   // francisco neto  06/09/2016
	aD1[Z][032]:= ' ' //EBK_IBAN02
	aD1[Z][033]:= ' ' //EBK_BIC02
	aD1[Z][034]:= ' ' //EBK_BBAN02
	aD1[Z][035]:= ' ' //EBK_CURID02
	aD1[Z][036]:= ' ' //EBK_OWN02
	aD1[Z][037]:= ' ' //EBK_NAME02
	aD1[Z][038]:= '100%' //MMV_BK01_PERCENT
	aD1[Z][039]:= ' '    //MMV_BK01_AMOUNT
	aD1[Z][040]:= ' '    //MMV_BK02_PERCENT
	aD1[Z][041]:= ' '    //MMV_BK02_AMOUNT
	aD1[Z][042]:= Alltrim(subs(qSRA->RJ_DESC,1,30)) //JOB_TTL       // francisco neto 06/09/2016
	aD1[Z][043]:= AllTrim(qSRA->RA_TPCONTR) //JOB_TOC_LC
    //RSB - 30/06/2017 - Os campo estavam sendo traduzidos, foi comentado a traduÁ„o das informaÁıes dos campo
    /*
    if	UPPER(cCodemp) = "NX"
		aD1[Z][044]:= IF(qSRA->RA_TPCONTR = '1','Undetermined','Determined') //JOB_TOC_LBL
		aD1[Z][045]:= IIF(qSRA->RA_TPCONTR = '1','UND','DET') //JOB_TOC
    else
	*/
		aD1[Z][044]:= IF(qSRA->RA_TPCONTR = '1','Indeterminado','Determinado') //JOB_TOC_LBL
		aD1[Z][045]:= IIF(qSRA->RA_TPCONTR = '1','IND','DEF') //JOB_TOC
	//endif
	aD1[Z][046]:= ' ' //JOB_EMPST_LC
	aD1[Z][047]:= ' ' //JOB_EMPST_LBL
	aD1[Z][048]:= SitFolha(AllTrim(qSRA->RA_SITFOLH)) //JOB_EMPST
	aD1[Z][049]:= ' ' //JOB_HIRR_LC
	aD1[Z][050]:= ' ' //JOB_HIRR_LBL
	aD1[Z][051]:= ' ' //JOB_HIRR
	aD1[Z][052]:= IIF(EMPTY(qSRA->RA_ADMISSA),"",subs(qSRA->RA_ADMISSA,1,4)+"/"+subs(qSRA->RA_ADMISSA,5,2)+"/"+subs(qSRA->RA_ADMISSA,7,2)) //JOB_CTSD
	aD1[Z][053]:= IIF(EMPTY(qSRA->RA_DTFIMCT),"",subs(qSRA->RA_DTFIMCT,1,4)+"/"+subs(qSRA->RA_DTFIMCT,5,2)+"/"+subs(qSRA->RA_DTFIMCT,7,2)) //JOB_CTED
	aD1[Z][054]:= IIF(EMPTY(qSRA->RA_DEMISSA),"",subs(qSRA->RA_DEMISSA,1,4)+"/"+subs(qSRA->RA_DEMISSA,5,2)+"/"+subs(qSRA->RA_DEMISSA,7,2)) //JOB_EED
	aD1[Z][055]:= ' ' //JOB_COSD
	aD1[Z][056]:= qSRA->RA_RESCRAI //JOB_TERR_LC
	aD1[Z][057]:= ' ' //JOB_TERR_LBL
	aD1[Z][058]:= TpTermination(AllTrim(qSRA->RA_RESCRAI))//JOB_TERR
	aD1[Z][059]:= AllTrim(qSRA->RA_XJOBCL) //JOB_CLASS_LC
	aD1[Z][060]:= JobClass(AllTrim(qSRA->RA_XJOBCL),1) //JOB_CLASS_LBL
	aD1[Z][061]:= JobClass(AllTrim(qSRA->RA_XJOBCL),2) //JOB_CLASS
	aD1[Z][062]:= 'FULL' //JOB_PT
	aD1[Z][063]:= '100%' //JOB_PTP
	aD1[Z][064]:= AllTrim(SM0->M0_CODIGO) //ORG_LEGAL_ID
	aD1[Z][065]:= LEFT(AllTrim(SM0->M0_NOME),32) //ORG_LEGAL
	aD1[Z][066]:= AllTrim(SM0->M0_CODFIL) //ORG_BRANCH_ID
	aD1[Z][067]:= LEFT(AllTrim(SM0->M0_FILIAL),32) //ORG_BRANCH 	// francisco neto 06/09/2016
	aD1[Z][068]:= ' ' //ORG_DEPART_ID
	aD1[Z][069]:= ' ' //ORG_DEPARTMENT 
	aD1[Z][070]:= ' ' //ORG_SERVICE_ID
	aD1[Z][071]:= ' ' //ORG_SERVICE
	aD1[Z][072]:= ' ' //ORG_SITE_ID
	aD1[Z][073]:= ' ' //ORG_SITE 
	aD1[Z][074]:= AllTrim(qSRA->RA_CC) //ORG_CCID01  	
	aD1[Z][075]:= ' '//ORG_CCID02
	aD1[Z][076]:= ' '//ORG_CCID03
	aD1[Z][077]:= ' '//ORG_CCID04
	aD1[Z][078]:= ' '//ORG_CCID05
	aD1[Z][079]:= ' '//ORG_CCID06
	aD1[Z][080]:= ' '//ORG_CCID07
	aD1[Z][081]:= ' '//ORG_CCID08
	aD1[Z][082]:= ' '//ORG_CCID09
	aD1[Z][083]:= ' '//ORG_CCID010
	if UPPER(cCodemp) = "NX"
		aD1[Z][084]:= subs(AllTrim(qSRA->CTT_DESC02),1,30) //ORG_CCNAME01	/ francisco neto 10/08/16	
	else
		aD1[Z][084]:= subs(AllTrim(qSRA->CTT_DESC01),1,30) //ORG_CCNAME01	/ francisco neto 10/08/16
	endif	
	aD1[Z][085]:= ' '//ORG_CCNAME02
	aD1[Z][086]:= ' '//ORG_CCNAME03
	aD1[Z][087]:= ' '//ORG_CCNAME04
	aD1[Z][088]:= ' '//ORG_CCNAME05
	aD1[Z][089]:= ' '//ORG_CCNAME06
	aD1[Z][090]:= ' '//ORG_CCNAME07
	aD1[Z][091]:= ' '//ORG_CCNAME08
	aD1[Z][092]:= ' '//ORG_CCNAME09
	aD1[Z][093]:= ' '//ORG_CCNAME10
	aD1[Z][094]:= '100%' //ORG_CCSK01
	aD1[Z][095]:= ' '//ORG_CCSK02
	aD1[Z][096]:= ' '//ORG_CCSK03
	aD1[Z][097]:= ' '//ORG_CCSK04
	aD1[Z][098]:= ' '//ORG_CCSK05
	aD1[Z][099]:= ' '//ORG_CCSK06
	aD1[Z][100]:= ' '//ORG_CCSK07
	aD1[Z][101]:= ' '//ORG_CCSK08
	aD1[Z][102]:= ' '//ORG_CCSK09
	aD1[Z][103]:= ' '//ORG_CCSK10
	aD1[Z][104]:= 'GSL_BSS'
	aD1[Z][105]:= 'GSL_SMS'
	aD1[Z][106]:= 'GSL_SBC'
	aD1[Z][107]:= 'GSL_OTC'
	aD1[Z][108]:= 'GSL_BNS'
	aD1[Z][109]:= 'GSL_COM'
	aD1[Z][110]:= 'GSL_OVS'
	aD1[Z][111]:= 'GSL_LEAV'
	aD1[Z][112]:= 'GSL_HSD'
	aD1[Z][113]:= 'GSL_HSC'
	aD1[Z][114]:= 'GSL_LSD'
	aD1[Z][115]:= 'GSL_LSC'
	aD1[Z][116]:= 'GSL_NTHC'
	aD1[Z][117]:= 'N'//'GSL_CCYN'
	aD1[Z][118]:= 'GSL_CCBIK'
	aD1[Z][119]:= 'GSL_OBIK'
	aD1[Z][120]:= 'GSL_HALW'
	aD1[Z][121]:= 'GSL_MALW'
	aD1[Z][122]:= 'GSL_TALW'
	aD1[Z][123]:= 'GSL_CALW'
	aD1[Z][124]:= 'GSL_OALW'
	aD1[Z][125]:= 'GSL_FEX'
	aD1[Z][126]:= 'GSL_TPP'
	aD1[Z][127]:= 'TOTAL_GSL'
	aD1[Z][128]:= 'EED_WTX'
	aD1[Z][129]:= 'EED_CSS'
	aD1[Z][130]:= 'EED_CRT'
	aD1[Z][131]:= 'EED_CUN'
	aD1[Z][132]:= 'EED_CMC'
	aD1[Z][133]:= 'EED_COTH'
	aD1[Z][134]:= 'EED_VRT'
	aD1[Z][135]:= 'EED_VMC'
	aD1[Z][136]:= 'EED_VOTH'
	aD1[Z][137]:= 'TOTAL_EED'
	aD1[Z][138]:= 'TOTAL_NSL'
	aD1[Z][139]:= 'NTP_SPPD'
	aD1[Z][140]:= 'NTP_EXRF'
	aD1[Z][141]:= 'NTP_EXPA'
	aD1[Z][142]:= 'NTP_BIK'
	aD1[Z][143]:= 'NTP_ONAD'
	aD1[Z][144]:= 'NTP_SAA'
	aD1[Z][145]:= 'NTP_TPP'
	aD1[Z][146]:= 'TOTAL_NADJ'
	aD1[Z][147]:= 'TOTAL_NTP'
	aD1[Z][148]:= 'ERC_WTX'
	aD1[Z][149]:= 'ERC_CSS'
	aD1[Z][150]:= 'ERC_CRT'
	aD1[Z][151]:= 'ERC_CUN'
	aD1[Z][152]:= 'ERC_CMC'
	aD1[Z][153]:= 'ERC_MCC'
	aD1[Z][154]:= 'ERC_AWI'
	aD1[Z][155]:= 'ERC_MCI'
	aD1[Z][156]:= 'ERC_MTX'
	aD1[Z][157]:= 'ERC_VOTH'
	aD1[Z][158]:= 'TOTAL_ERC'
	aD1[Z][159]:= 'ACR_HLS'
	aD1[Z][160]:= 'ACR_HLC'
	aD1[Z][161]:= 'ACR_BNS'
	aD1[Z][162]:= 'ACR_BNC'
	aD1[Z][163]:= 'ACR_SMS'
	aD1[Z][164]:= 'ACR_SMC'
	aD1[Z][165]:= 'TOTAL_ACR'
	aD1[Z][166]:= 'EXT_CCBIK'  // francisco neto 08/09/2016
	aD1[Z][167]:= 'EXT_OBIK'


	dbSelectArea("qSRV")
	dbSkip()
EndDo

dbSelectArea("qSRF")
dbGoTop()

tGSL:=0
tSRF:=0
tACR:=0
tERC:=0
tNADJ:=0
tEED:=0
tNSL:=0
tNTP:=0
tEXT:=0   //  francisco neto  08/09/2016
OLD := ""
DO WHILE qSRF->(!eof())
	If Empty(qSRF->GRUPO) .or. (ASC(LEFT(qSRF->GRUPO,1)) >= 48 .And. ASC(LEFT(qSRF->GRUPO,1)) <= 57)
	 	qSRF->(DBSKIP())
	 	LOOP
	EndIf

	Pos:=ascan(aD1,{|x| AllTrim(x[3]) = AllTrim(qSRF->FILIAL+qSRF->MATR)})		// francisco neto 31/08/16
    // francisco neto 27/04/2017  - Tratamento para caso de n„o encontrar a Filial+Matricula
	If Pos < 1
		Aviso("ATEN«√O", "Filial+Matricula: "+AllTrim(qSRF->FILIAL+qSRF->MATR)+" N„o encontrada. Verifique!", {"Ok"} )
	 	qSRF->(DBSKIP())
	 	LOOP
	EndIf

	IF SUBSTR(qSRF->GRUPO,1,3) == 'GSL'
		tGSL+=qSRF->VALOR
	ELSEIF SUBSTR(qSRF->GRUPO,1,3) == 'ACR'
		tACR+=qSRF->VALOR
	ELSEIF SUBSTR(qSRF->GRUPO,1,3) == 'ERC'
		tERC+=qSRF->VALOR
	ELSEIF SUBSTR(qSRF->GRUPO,1,3) == 'NTP'
		tNADJ+=qSRF->VALOR
	ELSEIF SUBSTR(qSRF->GRUPO,1,3) == 'EED'
		tEED+=qSRF->VALOR
	ELSEIF SUBSTR(qSRF->GRUPO,1,3) == 'EXT'    // francisco neto 08/09/2016
		tEXT+=qSRF->VALOR                      // francisco neto 08/09/2016
	ENDIF

	nPosVer := aScan(aD1[Pos],AllTrim(qSRF->GRUPO))
		
	If nPosVer > 0
		aD1[Pos][nPosVer]	:= TRANSFORM(qSRF->VALOR,'@E 999999999.99')
		aT1[nPosVer]		+= qSRF->VALOR
	EndIf 
	
	OLD := AllTrim(qSRF->FILIAL + qSRF->MATR)        // francisco neto 06/09/16

	qSRF->(DBSKIP())
	
	If qSRF->(EOF()) .OR. AllTrim(OLD) <> AllTrim(qSRF->FILIAL + qSRF->MATR) // francisco neto  06/09/16	
		tNSL:=tGSL-tEED
		tNTP:=tNADJ+tNSL
	
		aD1[Pos][127]:=TRANSFORM(tGSL,'@E 999999999.99')
		aD1[Pos][137]:=TRANSFORM(tEED,'@E 999999999.99')
		aD1[Pos][138]:=TRANSFORM(tNSL,'@E 999999999.99')
		aD1[Pos][146]:=TRANSFORM(tNADJ,'@E 999999999.99')
		aD1[Pos][039]:=TRANSFORM(tNTP,'@E 999999999.99') //Bank 01 Amount
		aD1[Pos][147]:=TRANSFORM(tNTP,'@E 999999999.99')
		aD1[Pos][158]:=TRANSFORM(tERC,'@E 999999999.99')
		aD1[Pos][165]:=TRANSFORM(tACR,'@E 999999999.99')
	
		aT1[127]+=tGSL
		aT1[137]+=tEED
		aT1[138]+=tNSL
		aT1[146]+=tNADJ
		aT1[039]+=tNTP //Bank 01 Amount
		aT1[147]+=tNTP
		aT1[158]+=tERC
		aT1[165]+=tACR

		tGSL:=0
		tSRF:=0
		tACR:=0
		tERC:=0
		tNADJ:=0
		tEED:=0
		tNSL:=0
		tNTP:=0
		tEXT:=0   // francisco neto 08/09/2016		
		
	ENDIF
ENDDO
FOR X:= 1 TO LEN(aD1)
	FOR Y:= 104 TO 167
		IF Len(SUBSTR(aD1[X][Y],1,3)) >= 3 .and. SUBSTR(aD1[X][Y],1,3) $ 'GSL|ACR|ERC|NTP|EED|EXT|TOTAL'		
			aD1[X][Y]:='0,00'
		ENDIF
	NEXT
NEXT

If !ExistDir(cPATH)
	MakeDir(Trim(cPATH))
Endif

cArquivo := "P_"+_cNomArq+"_"+AllTrim(cLID)+"_"+_cPer1ini+"_"+_cPer1fin+"_"+"00"+"_"+"V2_0000_00000_FILE_NOE_"+cNomeEmp+"-SRF.TXT"

nHdl := FCreate(ALLTRIM(cPath) + "\" + cArquivo,,,.F.)
If nHdl == -1
	MsgStop("Erro na criacao do arquivo na estacao local. Contate o administrador do sistema")
	RESTINTER()
	Return
EndIf

//-----------------------------------------
cMsg := 'H0'+'^'
For i:=1 to Len(aH0[1])
	cMsg += aH0[1][i]+'^'
Next i
cMsg := LEFT(cMsg,LEN(cMsg)-1)+Chr(13)+Chr(10)
cMsg := encodeutf8(cMsg)  // francisco neto 18/08/16
FWrite(nHdl,cMsg)
//-----------------------------------------
cMsg := 'D0'+'^'
For i:=1 to Len(aD0[1])
	cMsg += aD0[1][i]+'^'
Next i
cMsg := LEFT(cMsg,LEN(cMsg)-1)+Chr(13)+Chr(10)
cMsg := encodeutf8(cMsg)	// francisco neto 18/08/16
FWrite(nHdl,cMsg)
//-----------------------------------------
cMsg := 'H1'+'^'
For i:=1 to Len(aH1[1])
	cMsg += aH1[1][i]+'^'
Next i
cMsg := LEFT(cMsg,LEN(cMsg)-1)+Chr(13)+Chr(10)
cMsg := encodeutf8(cMsg)	// francisco neto 18/08/16
FWrite(nHdl,cMsg)
//-----------------------------------------
FOR Z1 := 1 TO LEN(aD1)
	cMsg := 'D1'+'^'
	For i:=1 to Len(aD1[Z1])
		cMsg += aD1[Z1][i]+'^'
	Next i
	cMsg := LEFT(cMsg,LEN(cMsg)-1)+Chr(13)+Chr(10)
	cMsg := encodeutf8(cMsg)	// francisco neto 18/08/16
	FWrite(nHdl,cMsg)
NEXT

cTxtT1 := 'T1'+'^'
For X:=1 To Len(aT1)
	If ValType(aT1[X])=="N"
		cTxtT1 +=AllTrim(Transform(aT1[X],"@E 999,999,999.99"))
	Else
		cTxtT1 +=aT1[X]
	EndIf
	If X==Len(aT1)
		cTxtT1 +=Chr(13)+Chr(10)
	Else
		cTxtT1 +='^'	
	EndIf
Next
cMsg := encodeutf8(cTxtT1)	// francisco neto 18/08/16
FWrite(nHdl,cTxtT1)

fClose(nHdl)

Return( Nil )

*----------------------------------------*
Static Function ParteNome(cFullName,cTipo)
*----------------------------------------*
Local cRet := ""
Local aString:= {}
Local cParteStr:= ""
Local nAt:= 0

If Empty(cFullName) .or. Empty(cTipo)
	Return cRet
EndIf

While ( nAt:= At(" ",cFullName) ) > 0 .And. ( Len(cFullName) > 0 )
	// Retira uma parte da String
	cParteStr:= Alltrim( Subs(cFullName,1,nAt) )

	// Guarda o pedaco em um array
	aAdd( aString, cParteStr)

	// Reescreve variavel sem a parte retirada.
	cFullName:= Alltrim( Subs(cFullName,nAt) )

EndDo

// Grava o resto da string.
If Len(cFullName) > 0
   aAdd( aString, cFullName )
EndIf                                   

//Retorna o tipo do nome
If cTipo == "FIRST"
	cRet := aString[1]
ElseIf cTipo == "LAST"
	cRet := aString[Len(aString)]
EndIf

Return cRet

*---------------------------------*
Static Function SitFolha(cSitFolha)
*---------------------------------*
Local cRet := ""

If Empty(cSitFolha)
	cRet := "WKG"
ElseIf cSitFolha == "D"
	cRet := "TER"
ElseIf cSitFolha == "A"
	cRet := "AUA"
ElseIf cSitFolha == "F"
	cRet := "WKG"
EndIf

Return cRet

*--------------------------------------*
Static Function TpTermination(cRescRais)
*--------------------------------------*
Local cRet := ""

If cRescRais $ "10|11|12"
	cRet := "DIS"
ElseIf cRescRais $ "20|21"
	cRet := "RES"
ElseIf cRescRais >= "70" .and. cRescRais <= "80"
	cRet := "RET"
EndIf

Return cRet   

*-------------------------------------*
Static Function JobClass(cClasse,nTipo)
*-------------------------------------*
Local cRet := ""

If cClasse == "1"
	If nTipo == 1
		cRet := "Apprentice"
	ElseIf nTipo == 2
		cRet := "APP"
	EndIf
ElseIf cClasse == "2"
	If nTipo == 1
		cRet := "Employee"
	ElseIf nTipo == 2
		cRet := "EMP"
	EndIf
ElseIf cClasse == "3"
	If nTipo == 1
		cRet := "Worker"
	ElseIf nTipo == 2
		cRet := "WKR"
	EndIf
ElseIf cClasse == "4"
	If nTipo == 1
		cRet := "Supervisor"
	ElseIf nTipo == 2
		cRet := "SUP"
	EndIf
ElseIf cClasse == "5"
	If nTipo == 1
		cRet := "Director"
	ElseIf nTipo == 2
		cRet := "DIR"
	EndIf
EndIf

Return cRet



