#include "rwmake.ch"

/*
Funcao      : Chk_Rpt
Parametros  : 
Retorno     : 
Objetivos   : PRYOR CONSULTING SERVICES S/C LTDA. RELATÓRIO DE MOVIMENTO BANCÁRIO
Autor       : Adriano Nishikava
Data/Hora   : 25/07/2002
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 24/07/2012
Módulo      : Financeiro.
*/


*---------------------*
User Function Chk_Rpt()
*---------------------*

//*************************//
//  Variáveis de SetPrint  //
//*************************//
// mv_par01 - Data inicial //
// mv_par02 - Data final   //
// mv_par03 - Banco        //
// mv_par04 - Agencia      //
// mv_par05 - Conta        //
//*************************//

cTitulo  :="Check Report"
cDesc1   :="Este programa ira imprimir a movimentação bancária"
cDesc2   :="Por ordem de data da movimentação"
cDesc3   :="Do banco, conta e período selecionado"
aReturn  :={"Zebrado", 1,"Administracao", 1, 2, 1, "",1}
cRelat   :="CHKRPT"
cArquivo :="SE5"

*               012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*                         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20

cCabec2  :="                       Date          Check nº         Document nº     Payee                                        Description                          Inflow             Outflow            Balance"
cPerg    :="CHKRPT    "
cNomebanco:=""

validperg()

pergunte(cPerg,.f.)

dbselectarea("SA6")
dbsetorder(1)

m_pag    :=1
lBusca   :=.f.
cInicio  :=""
cSaldo   :=""
cNatureza:=""
cBenef	 :=""
dSaldoabe:=ctod("  /  /  ")
dDatamin :=ctod("  /  /  ")
dSubtotal:=ctod("  /  /  ")
nLin     :=0
nSdabert :=0
nSubpag  :=0
nSubrec  :=0
nTotalpag:=0
nTotalrec:=0
cTempo:=criatrab(nil,.f.)

cRelat:=setprint(cArquivo,cRelat,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,"G")

if nlastKey == 27
	return
endIf

setdefault(aReturn,cArquivo)

dbselectarea("SA6")
dbsetorder(1)

dtBegin:=ctod(space(8))

if dbseek(xfilial("SA6")+mv_par03+mv_par04+mv_par05)
	cNomebanco:=sa6->a6_nome
	cCabec1:=padc("Bank: "+alltrim(cNomebanco)+"  /  Agency: "+mv_par04+"  /  Account: "+mv_par05,220)

	setprc(000,000)

	dbselectarea("SE5")
	indregua("SE5",cTempo,"E5_FILIAL+DTOS(E5_DTDIGIT)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ",,,"Aguarde ordenação os registros...")

	cInicio:=xfilial("SE5")+dtos(mv_par01)
	lBusca:=dbseek(cInicio,.t.)
	
	cTemp :=""
	cChave:=""
	
	dbselectarea("SE8")
	
	dSaldoabe:=mv_par01 -1
	dbsetorder(1)
	nSdabert:=0
	
	if dbseek(xfilial("SE8")+mv_par03+mv_par04+mv_par05+dtos(dSaldoabe) )
		nSdabert:=se8->e8_salatua
		dtBegin:=e8_dtSalat
	else
		dbseek(xfilial("SE8")+mv_par03+mv_par04+mv_par05+dtos(dSaldoabe),.T.)
		do while !bof()
			if xfilial("SE8")+mv_par03+mv_par04+mv_par05 = e8_filial+e8_banco+e8_agencia+e8_conta .and. e8_dtSalat <= dSaldoabe
				nSdabert:=se8->e8_salatua 
				dtBegin:=e8_dtSalat
				exit
			endif
			dbskip(-1)
		enddo
	endif
else
	alert(" Banco Nao Encontrado ")
	return
endif

nLin:=cabec("CASH & BANK STATEMENT (CHECK REPORT) - "+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),7,2)+"/"+ ;
left(dtos(mv_par01),4)+" TO "+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),7,2)+ ;
"/"+left(dtos(mv_par02),4),cCabec1,cCabec2,"","G",15)

nLin:=nLin+1

@nLin,023 psay "Beginning Balance ("+dtoc(dtBegin)+")"
@nLin,186 psay nSdabert picture "999,999,999.99"
nLin:=nLin+2
                   
dbselectarea("SE5")

do while !eof() .and. dtos(se5->e5_dtdigit)>=dtos(mv_par01) .and. dtos(se5->e5_dtdigit)<=dtos(mv_par02)
	
		if (se5->e5_banco==mv_par03 .and. se5->e5_agencia==mv_par04 .and. se5->e5_conta==mv_par05 ;
		.and. alltrim(se5->e5_tipodoc)<>"BL" .and. alltrim(se5->e5_situaca)<>"C" .and. alltrim(se5->e5_tipodoc)<>"EC" ;
		.and. (at(alltrim(se5->e5_tipodoc),"CM#DC#JR#MT")=0 .or. empty(alltrim(se5->e5_tipodoc))) .and. se5->e5_recpag="R") ;
		.or. ; 
		(se5->e5_banco==mv_par03 .and. se5->e5_agencia==mv_par04 .and. se5->e5_conta==mv_par05 ;
		.and. alltrim(se5->e5_situaca)<>"C" .and. alltrim(se5->e5_tipodoc)<>"CH" .and. se5->e5_recpag="P")
		
		dbselectarea("SED")
		dbsetorder(1)

		if !dbseek(xfilial("SED")+se5->e5_naturez) //A função xfilial() não funciona neste caso. O SED é da empresa modelo, a qual não tem filial
			cNatureza:="NATUREZA NÃO CADASTRADA!!!"
		else
			cNatureza:=sed->ed_descing
		endif
		
		dbselectarea("SE5")

		if se5->e5_recpag="P" .and. se5->e5_tipodoc<>"ES"		
			nSubpag  :=nSubpag+se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco
			nTotalpag:=nTotalpag+se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco
			nSdabert :=nSdabert-(se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco)
		elseif se5->e5_recpag="P" .and. se5->e5_tipodoc="ES"		
			nSubpag  :=nSubpag+se5->e5_valor
			nTotalpag:=nTotalpag+se5->e5_valor
			nSdabert :=nSdabert-se5->e5_valor
		endif		
		nSubrec  :=nSubrec  +iif(se5->e5_recpag="R",se5->e5_valor,0)
		nSdabert :=nSdabert +iif(se5->e5_recpag="R",se5->e5_valor,0)
		nTotalrec:=nTotalrec+iif(se5->e5_recpag="R",se5->e5_valor,0)
		dSubtotal:=se5->e5_dtdigit
		
		@nLin,023 psay se5->e5_dtdigit
		
		if !empty(se5->e5_numcheq)
			@nLin,037 psay se5->e5_numcheq
		else
			@nLin,037 psay se5->e5_documen
		endif
		
		@nLin,054 psay se5->e5_numero
		
		if se5->e5_recpag="R"			
			if !empty(se5->e5_benef)
				cBenef=se5->e5_benef			
   			else
				dbselectarea("SA1")
				dbsetorder(1)				
				if dbseek(xfilial("SE5")+se5->e5_clifor)
					cBenef=sa1->a1_nome
   				elseif se5->e5_naturez="3003"
					cBenef=cNomebanco
       			else
               		cBenef="PAGADOR DESCONHECIDO!!!"
			  	endif
			endif
		else
			if !empty(se5->e5_benef)
				cBenef=se5->e5_benef			
   			else
				dbselectarea("SA2")
				dbsetorder(1)				
				if dbseek(xfilial("SE5")+se5->e5_clifor)
					cBenef=sa2->a2_nome
               	elseif se5->e5_naturez="3003"
					cBenef=cNomebanco
       			else
               		cBenef="BENEFICIÁRIO DESCONHECIDO!!!"
			  	endif
			endif
		endif

		dbselectarea("SE5")
		
		@nLin,070 psay cBenef
		@nLin,115 psay cNatureza
		
		if se5->e5_valor<>0 .and. se5->e5_recpag="R" //Quando tratar-se de recebimento, o valor impresso será líquido. Já para pagamentos, o valor impresso será o bruto e separadamente, seus descontos e acréscimos
			@nLin,148 psay se5->e5_valor picture "999,999,999.99"
		endif
		
		if se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco<>0 .and. se5->e5_recpag="P" .and. se5->e5_tipodoc<>"ES"
			@nLin,167 psay se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco picture "999,999,999.99"
		elseif se5->e5_valor-se5->e5_vlcorre-se5->e5_vljuros-se5->e5_vlmulta-se5->e5_vldesco<>0 .and. se5->e5_recpag="P" .and. se5->e5_tipodoc="ES"
			@nLin,167 psay se5->e5_valor picture "999,999,999.99"
		endif
		
		nLin:=nLin+1
		
		dbskip()
		
		if dtos(se5->e5_dtdigit)<>dtos(dSubtotal)
			@nLin,023 psay "Subtotal:"
			@nLin,148 psay nSubrec picture "999,999,999.99"
			@nLin,167 psay nSubpag picture "999,999,999.99"
			@nLin,186 psay nSdabert picture "999,999,999.99"
			
			nSubpag:=0
			nSubrec:=0
			nLin:=nLin+2
		endif
	else		
		dbskip()
		
		if dtos(se5->e5_dtdigit)<>dtos(dSubtotal) .and. (nSubpag<>0 .or. nSubrec<>0)
			@nLin,023 psay "Subtotal:"
			@nLin,148 psay nSubrec picture "999,999,999.99"
			@nLin,167 psay nSubpag picture "999,999,999.99"
			@nLin,186 psay nSdabert picture "999,999,999.99"
			
			nSubpag:=0
			nSubrec:=0
			nLin:=nLin+2
		endif
	endif
	
	if nLin>63
		nLin:=cabec("CASH & BANK STATEMENT (CHECK REPORT) - "+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),7,2)+"/"+ ;
		left(dtos(mv_par01),4)+" TO "+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),7,2)+ ;
		"/"+left(dtos(mv_par02),4),cCabec1,cCabec2,"","G",15)+1
	endif
	
enddo

if nLin>50
	nLin:=cabec("CASH & BANK STATEMENT (CHECK REPORT) - "+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),7,2)+"/"+ ;
	left(dtos(mv_par01),4)+" TO "+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),7,2)+ ;
	"/"+left(dtos(mv_par02),4),cCabec1,cCabec2,"","G",15)+1
endif

@nLin,023 psay "Total:"
@nLin,148 psay nTotalrec picture "999,999,999.99"
@nLin,167 psay nTotalpag picture "999,999,999.99"
@nLin,186 psay nSdabert picture "999,999,999.99"

roda(0,"","P")

setpgeject(.F.)

if areturn[5] == 1 //Apresenta na tela preview do que estiver em crelat
	ourspool(crelat)
endif

ms_flush()

return

//***************************************************************************************
//******** Função para localização do saldo início do período selecionado
//***************************************************************************************

static function saldo_abertura()

cTemp :=""
cChave:=""

dbselectarea("SE8")

dSaldoabe:=mv_par01 -1
cChave:="E8_FILIAL+DTOS(E8_DTSALAT)"
cTemp:=criatrab(Nil,.f.)

indregua("SE8",cTemp,cChave)

dbgotop("SE8")

dDatamin:=dtos(se8->e8_dtsalat)

lBusca:=dbseek(xfilial("SE8")+dDatamin,.f.)

do while bof()
	!lBusca .and. dtos(dSaldoabe)>dtos(dDatamin)
	dSaldoabe:=dSaldoabe-1
	cSaldo:=xfilial("SE8")+mv_par03+mv_par04+mv_par05+dtos(dSaldoabe)
	lBusca:=dbseek(cSaldo,.f.)
enddo

nSdabert:=se8->e8_salatua

dbselectarea("SE5")

return

//***************************************************************************************
//******** Função p/ verificar se o arquivo SX1 possui os parâmetros necessários
//***************************************************************************************

Static Function validperg()

_aPerg := {}&&	  01    02         03            04  05    06     07   08 09 10  11   12      13      14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38

aadd( _aPerg, { cPerg, "01", "Do Periodo    ?",  "", "","mv_ch1", "D", 08, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""} )
aadd( _aPerg, { cPerg, "02", "Até o periodo ?",  "", "","mv_ch2", "D", 08, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""} )
aadd( _aPerg, { cPerg, "03", "Banco         ?",  "", "","mv_ch3", "C", 03, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA6"} )
aadd( _aPerg, { cPerg, "04", "Agencia       ?",  "", "","mv_ch4", "C", 05, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""} )
aadd( _aPerg, { cPerg, "05", "Conta         ?",  "", "","mv_ch5", "C", 10, 0, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""} )

dbSelectArea("SX1")
dbSetOrder(1)

if !dbSeek(cPerg)
	for _nCont1 := 1 To Len(_aPerg)
		recLock("SX1",.T.)		
		for _nCont2 := 1 To 38
			fieldPut(_nCont2,_aPerg[_nCont1,_nCont2])
		next
		msunlock()
	next
endIf

pergunte(cPerg,.F.)

Return
