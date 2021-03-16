#include "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ()บAutor   ณ Francisco F S Neto        บ Data ณ 24/05/2017  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelamento de cแlculo de beneficios: VT/VR/VA            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes HLB BRASIL                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION GTGPE029()   

	Private cPerg     := "GTGPE029  "
	private cPeriodo := ""
	
	private x_Codigo := ""
	private x_CodFi := ""
	private cNOMECOM := ""
	
	private	_cFilial := ""
	private	_cMat 	 := ""
	
	private	mesano :=  ""
	private mesanoa := ""
	private yBuffer := ""
	
	private cNOMECOM := space(40)
	private cCGC     := space(20)
	private cCNPJ    := space(20)
	
	cNOMECOM := SM0->M0_NOMECOM
	cCGC     := SM0->M0_CGC
	cCNPJ    := SUBSTR(cCGC,1,2)+"."+SUBSTR(cCGC,3,3)+"."+SUBSTR(cCGC,6,3)+"/"+SUBSTR(cCGC,9,4)+"-"+SUBSTR(cCGC,13,2)
	private cCodigo  := SM0->M0_CODIGO

	private datadois := ""  
	private datamov  := ctod("  /  /  ")

	private cPath  := AllTrim(GetTempPath()) + "LOGCAN\"
	private _TEXTO	:= "LOGCAN"+cCodigo+".TXT"
	private cArqXis	:=	cPath + _texto
	private nHdlXis	:= 0

	private cHora	:= ""
	private nHora	:= ""
	Private cDataOc := CTOD(SUBSTR(dtoc(ddatabase),1,2)+"/"+SUBSTR(dtoc(ddatabase),4,2)+"/"+SUBSTR(dtoc(ddatabase),7,4))	

	cHora := time()
    nHora := substr(cHora,1,2)+"."+substr(cHora,4,2)+"."+substr(cHora,7,2)

	//Cria o diretorio caso nใo exista
	If MAKEDIR(cPath) == 0
		//Aviso( "Importante", "O Diret๓rio '" +cPath+ "' foi criado",{"Ok"})
	EndIf    

	_CRETEXTO()  // cria arquivo de log

	CriaSX1(cPerg)
	
	SET DECIMALS TO 2
	
	If Pergunte(cPerg,.T.)
		If SimNao("Cancelamento de cแlculos de Benef๚€ios? ") == "S"
			Processa({ |lEnd| EXCLUSAO(@lEnd),OemToAnsi("Cancelando Cแlculo, aguarde...")}, OemToAnsi("Aguarde..."))
		Else
			Return
		EndIf
	Else
		Return
	EndIf
	
RETURN


STATIC FUNCTION EXCLUSAO()
	
	private cQuery := ' '
	private cOrdm  := "01"

	PswOrder(1)
	PswSeek(__CUSERID,.T.)
	aUser := PswRet()
	cNomeUser := aUser[1][4]
	
	mesano := STRZERO(VAL(MV_PAR01),4)+STRZERO(VAL(MV_PAR02),2)  

	if MV_PAR07 = 1
		_tpben := "0"	   // Vale Transporte
	elseif MV_PAR07 = 2
		_tpben := "1"	   // Vale Refeicao	
	elseif MV_PAR07 = 3
		_tpben := "2"	   // Vale Alimentacao
	else
		_tpben := "9"	   // Nao definido
	endif

	cQuery := CRLF +" UPDATE " + RetSqlName("RG2") + " SET D_E_L_E_T_ = '*' "
	cQuery += CRLF +" FROM "+ RETSQLNAME("RG2")+ " A, "	+ RETSQLNAME("SRA")+ " B "
	cQuery += CRLF +" WHERE A.D_E_L_E_T_ = ' ' AND A.D_E_L_E_T_ = ' ' "
	cQuery += CRLF +" AND RG2_FILIAL = RA_FILIAL AND RG2_MAT = RA_MAT "
	cQuery += CRLF +" AND LEFT(RG2_PERIOD,6)  = '"+mesano+"'  "
 	cQuery += CRLF +" AND RG2_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04 +"' " 
 	cQuery += CRLF +" AND RG2_MAT BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06 +"' " 
 	cQuery += CRLF +" AND RA_ADMISSA BETWEEN '"+DTOS(MV_PAR08)+"' AND '"+DTOS(MV_PAR09) +"' " 
	cQuery += CRLF +" AND RG2_TPVALE = '"+_tpben+"'  "

	TcSqlExec( cQuery )

	_GRVTEXTO()	  // gravacao de log

	FCLOSE( nHdlXis )
	
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSX1   บAutor  ณFrancisco F S Neto  บ Data ณ24/05/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere novas perguntas ao sx1                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaSX1(cPerg)

	Local aRegs := {}
// GRUPO/ORDEM/PERGUNT/PERSPA/PERENG/VARIAV/TIPO/TAM/DEC/PRESEL/GSC/VALID/VAR01/DEF01/DEFSPA1/DEFENG1/CNT01/VAR02/DEF02/DEFSPA2/DEFENG2/CNT02/VAR03/DEF03/DEFSPA3/DEFENG3/CNT03/VAR04/DEF04/DEFSPA4/DEFENG4/CNT04/VAR05/DEF05/DEFSPA5/DEFENG5/CNT05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
	
	Aadd(aRegs,{cPerg,'01','Ano  (AAAA)          ','','','MV_CH1','C',04,0,0,'G','','MV_PAR01','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'02','M๊s: (MM)            ','','','MV_CH2','C',02,0,0,'G','','MV_PAR02','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'03','Filial de            ','','','MV_CH3','C',02,0,0,'G','','MV_PAR03','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'04','Filial AtE          ','','','MV_CH4','C',02,0,0,'G','','MV_PAR04','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'05','Matricula de         ','','','MV_CH5','C',06,0,0,'G','','MV_PAR05','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','SRA',' ','','','',''})
	Aadd(aRegs,{cPerg,'06','Matricula AtE       ','','','MV_CH6','C',06,0,0,'G','','MV_PAR06','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','SRA',' ','','','',''})
	Aadd(aRegs,{cPerg,'07','Tipo de Beneficio    ','','','MV_CH7','N',01,0,0,'C','','MV_PAR07','0=VT','','','','','1=VR','','','','','2=VA','','','','','','','','','','','','','','   ','1','','','',''})
	Aadd(aRegs,{cPerg,'08','Data Admissใo de :   ','','','MV_CH8','D',08,0,0,'G','','MV_PAR08','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})
	Aadd(aRegs,{cPerg,'09','Data Admissใo AtE:  ','','','MV_CH9','D',08,0,0,'G','','MV_PAR09','    ','','','','','    ','','','','','    ','','','','','','','','','','','','','','   ',' ','','','',''})

	ValidPerg(aRegs,cPerg,.T.)

Return

//// abertura do arquivo TXT
STATIC FUNCTION _CRETEXTO()

	nHdlXis	:=	MsFCreate(cArqXis)
	If nHdlXis < 0
		Break
	EndIf
	
RETURN


//// grava arquivo TXT
STATIC FUNCTION _GRVTEXTO()

	yBuffer := "Cancelamento de cแlculo de beneficio: "+alltrim(_tpben)+ " Periodo: "+alltrim(mesano)+" Filiais de: " +alltrim(MV_PAR03) + " ATE: "+alltrim(MV_PAR04)
	yBuffer += " Matriculas de: " +alltrim(MV_PAR05) + " ATE: "+alltrim(MV_PAR06)+"   " 	
	yBuffer += " para admitidos de: "+alltrim(DTOS(MV_PAR08))+ " a: "+alltrim(DTOS(MV_PAR09))+" Usuario: " + alltrim(cNomeUser)+"   " 	
	yBuffer += " em:  "+ substr(dtos(cDataoc),7,2)+"/"+substr(dtos(cDataoc),5,2)+"/"+substr(dtos(cDataoc),1,4)
	yBuffer += " hora:  " + nHora

	FWrite(nHdlXis,yBuffer,Len(yBuffer))
	yBuffer := ""    
	
RETURN    









