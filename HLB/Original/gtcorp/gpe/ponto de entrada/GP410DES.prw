#include "protheus.ch"

/*
Funcao      : GP410DES
Parametros  : 
Retorno     : lRet
Objetivos   : P	Ponto de entrada para tratar os tipos de operações na geração do CNAB de folha da Robert Half | CC/DOC/TED
TDN			: Geração de Líquido de funcionários. Este ponto de entrada esta localizado após consistência de funcionários.  Caso o rdmake retorne falso (.F.) o funcionário posicionado será desprezado.
Autor       : Matheus Massarotto
Data/Hora   : 18/08/2011    17:05
Revisão		: 
Data/Hora   : 
Módulo      : Gestão de Pessoal
Cliente		: Harris(K2)
*/

*---------------------*
User Function GP410DES
*---------------------*
Local lRet:=.T.

LOCAL nOP  := 0

if cEmpAnt $ "3J"
	
	//trata somente banco ITAU credito em conta
	if alltrim(UPPER(cArqent))==UPPER("K341CCJ.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"409" 
			lRet:=.F.	
		endif 
	//trata DOC - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341DOCJ.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR>=5000
			lRet:=.F.	
		endif
	//trata TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341TEDJ.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR<5000
			lRet:=.F.	
		endif
	
	endif

elseif cEmpAnt $ "3K"
	cTpConta := ""
	//RRP - 13/05/2013 - Ajuste na validação do campo.
	If 	SRA->(FieldPos("RA_P_TPCNT")) <> 0
		cTpConta := SRA->RA_P_TPCNT
	EndIF
	
	//trata somente banco ITAU credito em conta
	if alltrim(UPPER(cArqent))==UPPER("K341CCK.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		ElseIf !EMPTY(cTpConta) .AND. cTpConta == "2"   
			lRet:=.F.	
		endif
	//trata somente banco ITAU credito em Poupança
	Elseif alltrim(UPPER(cArqent))==UPPER("K341CPK.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		ElseIf EMPTY(cTpConta) .or. cTpConta == "1"
			lRet:=.F.	
		endif  
	//trata DOC - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341DOCK.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR>=5000
			lRet:=.F.	
		endif
	//trata TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341TEDK.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR<5000
			lRet:=.F.	
		endif
	
	endif
endif

//CitiBank para VCT  MATHEUS - 21/10/2011
if cEmpAnt $ "KW"
	
	//trata somente banco CITIBANK credito em conta
	if alltrim(UPPER(cArqent))==UPPER("K745KWCC.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"745"
			lRet:=.F.	
		endif 
	//trata DOC/TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K745KWDT.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="745"
			lRet:=.F.	
		endif
	endif
endif  

//Os arquivos CNAB na pasta system tem que ter o padrão: Kxx745CC.2PE / Kxx745DT.2PE / Kxx745DC.2PE onde xx é o código da empresa
//Tratamento para CNAB CitiBank - AOA Anderson Arrais 03/11/2015
//Tratamento para CNAB CitiBank DOC e TED em arquivos de configuração separado
if cEmpAnt $ "ZR/OZ/6I/MZ/OM/JU/H9/XN/8P/69/T6/JV/I0/TP/"//Código das empresas
	
	//trata somente banco Bank Of America credito em conta
	If alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"745CC.2PE")
		If SUBSTR(SRA->RA_BCDEPSA,1,3)<>"745"
					lRet:=.F.	
		Endif 
	//trata DOC - outros bancos	
	ElseIf alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"745DC.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="745" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"745" .AND. NVALOR>=250
			lRet:=.F.	
		EndIf
	//trata TED - outros bancos	
	ElseIf alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"745DT.2PE") 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)=="745" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"745"  .AND. NVALOR<250
			lRet:=.F.	
		EndIf
	EndIf
EndIf

//Os arquivos CNAB na pasta system tem que ter o padrão: Kxx033.2PE / Kxx033DV.2PE onde xx é o código da empresa
//Tratamento para CNAB Santander - AOA Anderson Arrais 28/08/2015
if cEmpAnt $ "PL/4J/XC/VC/IW/76/9P/GN/73/OU/"//Código das empresas
	
	//trata somente banco SANTANDER credito em conta
	if alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"033.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"033"
					lRet:=.F.	
		endif 
	//trata DOC/TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"033DV.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="033"
			lRet:=.F.	
		endif
	endif 
endif             

//Banco do Brasil para XY João - 22/08/2013
if cEmpAnt $ "XY" //Consorcio Tegram
	
	//trata somente banco BRANCO DO BRASIL credito em conta
	if alltrim(UPPER(cArqent))==UPPER("KXY001.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"001"
					lRet:=.F.	
		endif 
	//trata DOC/TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("KXY001DV.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="001"
			lRet:=.F.	
		endif
	endif
endif     

//Os arquivos CNAB na pasta system tem que ter o padrão: Kxx755CC.2PE / Kxx755DC.2PE / Kxx755TD.2PE onde xx é o código da empresa
//Tratamento para CNAB Bank Of America - AOA Anderson Arrais 06/08/2015
if cEmpAnt $ "M5/SV/5M/H9/9M/KY/ZJ/8O/NE/9N/60/6T/NM/3Z/KS/6G/6U/9X/"//Código das empresas
	
	//trata somente banco Bank Of America credito em conta
	If alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"755CC.2PE")
		If SUBSTR(SRA->RA_BCDEPSA,1,3)<>"755"
					lRet:=.F.	
		Endif 
	//trata DOC - outros bancos	
	ElseIf alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"755DC.2PE") 
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="755" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"755" .AND. NVALOR>=500
			lRet:=.F.	
		EndIf
	//trata TED - outros bancos	
	ElseIf alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"755TD.2PE") 
		If SUBSTR(SRA->RA_BCDEPSA,1,3)=="755" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"755"  .AND. NVALOR<500
			lRet:=.F.	
		EndIf
	EndIf
EndIf

//Os arquivos CNAB na pasta system tem que ter o padrão: Kxx399F.2PE / Kxx399DT.2PE onde xx é o código da empresa
//Tratamento para CNAB HSBC - AOA Anderson Arrais 04/08/2015
If cEmpAnt $ "VN/AY/UZ/N8/HP/I2/4V/WA/DP/46/M7/JO/6X/L1/KI/VW/3Q/H8/B8/1F/TM/40/10/4K/8F/CH/RH/Z4/Z8/ZB/ZF/ZG/"//Código das empresas
    
    //trata somente banco HSBC credito em conta
    If alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"399F.2PE")
        If SUBSTR(SRA->RA_BCDEPSA,1,3)<>"399"
                    lRet:=.F.    
        Endif 
    //trata DOC/TED - outros bancos    
    ElseIf alltrim(UPPER(cArqent))==UPPER("K"+AllTrim(cEmpAnt)+"399DT.2PE") 
        if SUBSTR(SRA->RA_BCDEPSA,1,3)=="399"
            lRet:=.F.    
        EndIf
    EndIf
EndIf

if cEmpAnt $ "52" //Univ Picture

DO CASE
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONTED.2RE'
		nOP  := 1
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONDOC.2RE'
		nOP  := 2
    CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETTED.2RE'
		nOP  := 3
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETDOC.2RE'  
		nOP  := 4 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCON.2RE'
	    nOP  := 5 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNET.2RE'  
		nOP  := 6		
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'K52033DOC.2RE'
	    nOP  := 7 
	CASE UPPER(ALLTRIM(MV_PAR21)) == 'K52033TED.2RE'  
		nOP  := 8		

    OTHERWISE
        nOP  := 0
ENDCASE

if nOp==0
   lCod:=.t.
else
   lCod:=.f.

	
	//SELECIONA OS REGISTROS VALIDOS
	DO CASE 

		CASE nOP == 1 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 
		CASE nOP == 2 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T. 
		CASE nOP == 3 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 	
		CASE nOP == 4 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
		CASE nOP == 5 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.   
		CASE nOP == 6 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
   		CASE nOP == 7 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
		     lCod := .T. 	
		CASE nOP == 8 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
		     lCod := .T.
	
		
		ENDCASE

endif
   
Return(lCod)     


endif

//Tellabs - ITAU - 04/11/2011 - Matheus
if cEmpAnt $ "D1"

	//trata somente banco ITAU credito em conta
	if alltrim(UPPER(cArqent))==UPPER("K341D1CC.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)<>"341" .AND. SUBSTR(SRA->RA_BCDEPSA,1,3)<>"409"
			lRet:=.F.	
		endif 
	//trata DOC - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341D1DO.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR>=5000
			lRet:=.F.	
		endif
	//trata TED - outros bancos	
	elseif alltrim(UPPER(cArqent))==UPPER("K341D1TE.2PE")
		if SUBSTR(SRA->RA_BCDEPSA,1,3)=="341" .OR. SUBSTR(SRA->RA_BCDEPSA,1,3)=="409"
			lRet:=.F.	
		elseif NVALOR<5000
			lRet:=.F.	
		endif
	endif
	
endif  
//RRP - 02/10/2013 - Inclusão do fonte abaixo conforme solicitado no Chamado: 014832. 
If cEmpAnt $ "22"
	//DEFINE A OPERACAO PELO NOME DO LAYOUT TED/DOC
	DO CASE
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONTED.2RE'
			nOP  := 1
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCONDOC.2RE'
			nOP  := 2
	    CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETTED.2RE'
			nOP  := 3
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNETDOC.2RE'  
			nOP  := 4 
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'HCON.2RE'
		    nOP  := 5 
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'HNET.2RE'  
			nOP  := 6		
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'SANTDOC.PAG'
		    nOP  := 7 
		CASE UPPER(ALLTRIM(MV_PAR21)) == 'SANTTED.PAG'  
			nOP  := 8		
	
	    OTHERWISE
	        nOP  := 0
	ENDCASE
	
	If nOp==0
	   lRet:=.t.
	Else
	   lRet:=.f.
	
		
		//SELECIONA OS REGISTROS VALIDOS
		DO CASE 
	
			CASE nOP == 1 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
			     lRet := .T. 
			CASE nOP == 2 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
			     lRet := .T. 
			CASE nOP == 3 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
			     lRet := .T. 	
			CASE nOP == 4 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
			     lRet := .T.
			CASE nOP == 5 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
			     lRet := .T.   
			CASE nOP == 6 .AND. NVALOR > 0000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) == '399' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
			     lRet := .T.
	   		CASE nOP == 7 .AND. NVALOR >= 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //TED
			     lRet := .T. 	
			CASE nOP == 8 .AND. NVALOR < 1000 .AND. SUBSTR(SRA->RA_BCDEPSA,1,3) <> '033' .AND. !EMPTY(SRA->RA_BCDEPSA,1,3) //DOC
			     lRet := .T.
		
			
			ENDCASE
	
	EndIf
EndIf

return(lRet)