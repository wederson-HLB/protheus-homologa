#Include "Protheus.ch"

/*
Funcao      : ExecCNTA
Parametros  : aCapaCN9,aCapaCNA,aItemCNB,aCapaCNF,nOpc
Retorno     : cErro
Objetivos   : Fun��o para simular o execauto de contratos, inclui contrato(CN9), planilha(CNA e CNB), cronograma(CNF) e acesso(CNN).
Autor       : Matheus Massarotto
Data/Hora   : 19/09/2013    10:14
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gest�o de Contratos
*/

*---------------------------------------------------------------*
User function ExecCNTA(aCapaCN9,aCapaCNA,aItemCNB,aCapaCNF,nOpc)
*---------------------------------------------------------------*
Local cErro	:= ""

//Valido o CN9
if !ValidCN9(aCapaCN9,@cErro,aCapaCNA,aItemCNB,aCapaCNF)
	Return(cErro)
endif

//Valida o CNA
if !ValidCNA(aCapaCNA,@cErro)
	Return(cErro)
endif

//Valida o CNB
if !ValidCNB(aItemCNB,@cErro)
	Return(cErro)
endif

//Valida o CNF
if !ValidCNF(aCapaCNF,@cErro)
	Return(cErro)
endif

BEGIN TRANSACTION

nCN9Fil	:= Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_FILIAL"})
nCN9Cli	:= Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_CLIENT"})
nCN9CLj	:= Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_LOJACL"})

	//<CN9>*INICIO* - Contrato
	DbSelectArea("CN9")
	Reclock("CN9",.T.)

		CN9->CN9_NUMERO	:= GETSXENUM("CN9","CN9_NUMERO")	//Numero do contrato
        CN9->CN9_REVISA	:= ""
        
	   	for i:=1 to len(aCapaCN9)

            if nCN9Cli == i
				CN9->CN9_CLIENT	:= aCapaCN9[i][2]	//Cliente - Busca do SA1
			endif
			               
			if nCN9CLj == i
				CN9->CN9_LOJACL	:= aCapaCN9[i][2]	//Loja do cliente - Busca do SA1

				if FieldPos("CN9_P_NOME")>0
					CN9->CN9_P_NOME	:= POSICIONE("SA1",1,xFilial("SA1")+aCapaCN9[nCN9Cli][2]+aCapaCN9[nCN9CLj][2],"A1_NOME")	//Nome do cliente - Campo Customizado pela GT
				endif	

			endif
			
			if FieldPos(aCapaCN9[i][1])>0
				CN9->&(aCapaCN9[i][1]):=aCapaCN9[i][2]
			endif
			
			//CN9->CN9_MOEDA	:=	//Moeda do contrato - Busca no CTO
			//CN9->CN9_CONDPG	:=	//Condi��o de pagamento - Busca do SE4
			
			//CN9->CN9_TPCTO	:=	//Tipo de contrato, Busca no CN1
	
			//CN9->CN9_VLINI := 0	//Valor inicial, Vem da somat�rios dos itens da planilha CNB, ou da capa da planilha CNA
			//CN9->CN9_VLATU := 0	//Valor inicial, Vem da somat�rios dos itens da planilha CNB, ou da capa da planilha CNA
			//CN9->CN9_SALDO := 0	//Valor inicial, Vem da somat�rios dos itens da planilha CNB, ou da capa da planilha CNA
	
		next
	    
		CN9->CN9_SITUAC := "02" //"Em elaboracao"	//Situa��o atual do contrato
  		
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_DTINIC"})<=0
  			CN9->CN9_DTINIC	:= dDataBase	//Data de Inicio
	    endif

		//vigencia indefinida
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_UNVIGE"})<=0
			CN9->CN9_UNVIGE	:= "4"
		endif
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_VIGE"})<=0
			CN9->CN9_VIGE	:= 0
    	endif
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_FLGREJ"})<=0    	
			CN9->CN9_FLGREJ:="1"	//Indica se o contrato ter� reajuste (1=Sim ; 2=Nao)
		endif
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_FLGCAU"})<=0
			CN9->CN9_FLGCAU:="2"	//Indica se o contrato controla Cau��o (1=Sim ; 2=Nao)
		endif	
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_TPCAUC"})<=0
 			CN9->CN9_TPCAUC:="1"	//Indica o tipo de cau��o (1=Manual)
		endif
  		if Ascan(aCapaCN9,{|x| alltrim(x[1]) = "CN9_DTULST"})<=0
			CN9->CN9_DTULST:=ddatabase	//Indica a data do ultimo status
		endif
			    
		if nCN9Fil<=0
			CN9->CN9_FILIAL := xFilial("CN9")
		endif
		
	MsUnlock()
	
	CN9->(ConfirmSx8())
	CN9->(FKCommit())
	//<CN9>*FIM* - Contrato

    
	//<CNA>*INICIO* - PLANILHAS - CAPA

if !empty(aCapaCNA) .AND. !empty(aItemCNB) .AND. !empty(aCapaCNF) //Se n�o estiver em branco a capa da planilha, os itens da planilha e o cronograma

	cSeqCna	:=Replicate("0",TamSx3("CNA_NUMERO")[1])	
	nCNAFil	:= Ascan(aCapaCNA[1],{|x| alltrim(x[1]) = "CNA_FILIAL"})

	for nContCNA:=1 to len(aCapaCNA)	
		DbSelectArea("CNA")
		Reclock("CNA",.T.)
	
			cSeqCna:=SOMA1(cSeqCna)
				
			CNA->CNA_NUMERO	:=cSeqCna //N�mero da planilha - Sequ�ncial
	
	        for i:=1 to len(aCapaCNA[nContCNA])
	
				CNA->&(aCapaCNA[nContCNA][i][1]):=aCapaCNA[nContCNA][i][2]
				
				//CNA->CNA_TIPPLA	:=	//Tipo de planilha - Busca do cadastro CNL
	  
				//CNA->CNA_VLTOT	:=	//Valor - Vem da somat�ria dos itens CNB
				//CNA->CNA_SALDO	:=	//Saldo - Vem da somat�ria dos itnes CNB
				//CNA->CNA_VLCOMS	:=	//Valor comissionado da planilha - Igual ao valor total
		
				//CNA->CNA_CRONOG	:=	//Cronograma - Preenche do cadastro CNF
	        next
	
	        if nCNAFil<=0
				CNA->CNA_FILIAL := xFilial("CNA")	//Filial
	        endif
	
			CNA->CNA_CONTRA	:= CN9->CN9_NUMERO //Numero do contrato - Vem do cadastro CN9
			CNA->CNA_REVISA	:= CN9->CN9_REVISA //Revis�o - Vem do cadastro CN9
			CNA->CNA_CLIENT := CN9->CN9_CLIENT	//Cliente - Vem do cadastro CN9
			CNA->CNA_LOJACL := CN9->CN9_LOJACL	//Loja do Cliente - Vem do cadastro CN9
	
	  		if Ascan(aCapaCNA[nContCNA],{|x| alltrim(x[1]) = "CNA_FLREAJ"})<=0
				CNA->CNA_FLREAJ	:= "1"	//Indica se reajusta (1=Sim ; 2=Nao)
	     	endif
	  		if Ascan(aCapaCNA[nContCNA],{|x| alltrim(x[1]) = "CNA_DTINI"})<=0     	
				CNA->CNA_DTINI	:= ddatabase	//Data Inicial da planilha
			endif
	  		if Ascan(aCapaCNA[nContCNA],{|x| alltrim(x[1]) = "CNA_DTFIM"})<=0		
				CNA->CNA_DTFIM 	:= CTOD("01/01/49") //Data Final da planilha
			endif
	        
		MsUnlock() 
		CNA->(FKCommit())
	
		//<CNB>*INICIO* - PLANILHAS - ITENS  
		
		nCNBPro	:= Ascan(aItemCNB[nContCNA][1],{|x| alltrim(x[1]) = "CNB_PRODUT"})
		nCNBQtd	:= Ascan(aItemCNB[nContCNA][1],{|x| alltrim(x[1]) = "CNB_QUANT"})
		nCNBVlu	:= Ascan(aItemCNB[nContCNA][1],{|x| alltrim(x[1]) = "CNB_VLUNIT"})
		nCNBFlg	:= Ascan(aItemCNB[nContCNA][1],{|x| alltrim(x[1]) = "CNB_FLGCMS"})
		nCNBFil	:= Ascan(aItemCNB[nContCNA][1],{|x| alltrim(x[1]) = "CNB_FILIAL"})
	
		cSeqCnb	:=Replicate("0",TamSx3("CNB_ITEM")[1])	
	
		DbSelectArea("CNB")
		//nUsado := Len(aHeaderCNB)        
		cFilCod := xFilial("CNB")
		
		nTotComis := 0
		
		//�������������������������������������������������Ŀ
		//� Preenche campos dos itens da planilha           �
		//���������������������������������������������������
	   	for nCntFor := 1 to len(aItemCNB[nContCNA])
	
			DbSelectArea("CNB")
			Reclock("CNB",.T.)
	
				cSeqCnb:=SOMA1(cSeqCnb)
					
				CNB->CNB_ITEM	:=cSeqCnb //N�mero do item - Sequ�ncial
				
				for nConti:=1 to len(aItemCNB[nContCNA][nCntFor]) 
		
		
						if nCNBPro==nConti
							CNB->CNB_PRODUT	:= aItemCNB[nContCNA][nCntFor][nConti][2]	//Codigo do produto - Vem do SB1
						
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							if SB1->(DbSeek(xFilial("SB1")+aItemCNB[nContCNA][nCntFor][nConti][2]))
								
								CNB->CNB_DESCRI	:= SB1->B1_DESC	//Descri��o do produto - Vem do SB1
								CNB->CNB_UM		:= SB1->B1_UM	//Unidade de medida - Vem do SB1
								CNB->CNB_TS		:= SB1->B1_TS
							
							endif
											
						endif
						
						CNB->&(aItemCNB[nContCNA][nCntFor][nConti][1]):= aItemCNB[nContCNA][nCntFor][nConti][2]
						
						//CNB->CNB_QUANT	:=	//Quantidade do produto
						//CNB->CNB_VLUNIT	:=	//Valor unit�rio do produto
						//CNB->CNB_VLTOT	:=	//Valot total - Quantidade * Valor unit�rio
						
						
						//CNB->CNB_TS		:= //Tes - Vem do SB1(Com base na SF4)
						
						
						//CNB->CNB_FLGCMS	:=	//Informa se o item ser� comissionado (1=Sim ; 2=Nao)
						
		            
		        next
		        
		   		CNB->CNB_FILIAL := cFilCod
				CNB->CNB_NUMERO := CNA->CNA_NUMERO //Numero da planilha - Vem do CNA
				CNB->CNB_REVISA := CNA->CNA_REVISA //Numero da revis�o - Vem do contrato CN9
				CNB->CNB_CONTRA := CNA->CNA_CONTRA //Numero do contrato - Vem do contrato CN9
		        
		        if nCNBFil<=0
					CNB->CNB_FILIAL := xFilial("CNB")	//Filial
		        endif
		        
		        //Valor total
		        CNB->CNB_VLTOT:= aItemCNB[nContCNA][nCntFor][nCNBQtd][2]*aItemCNB[nContCNA][nCntFor][nCNBVlu][2]
		        
		        if nCNBFlg<=0
		        	CNB->CNB_FLGCMS := "1" //Informa se o item ser� comissionado (1=Sim ; 2=Nao)
		        endif
			
				CNB->CNB_DTCAD  := dDataBase	//Data do cadastro
				CNB->CNB_SLDMED := CNB->CNB_QUANT
				CNB->CNB_SLDREC := CNB->CNB_QUANT
	
			CNB->(MsUnlock())
	
		next
		
		CNB->(FKCommit())
		//<CNB>*FIM* - PLANILHAS - ITENS	
	

		//<CNF>*INICIO* - CRONOGRAMA
	
		nCNfFil	:= Ascan(aCapaCNF[nContCNA][1],{|x| alltrim(x[1]) = "CNF_FILIAL"})
		nCNfPer	:= Ascan(aCapaCNF[nContCNA][1],{|x| alltrim(x[1]) = "CNF_PERIOD"})
		nCNfPru	:= Ascan(aCapaCNF[nContCNA][1],{|x| alltrim(x[1]) = "CNF_PRUMED"})
		nCNfCom	:= Ascan(aCapaCNF[nContCNA][1],{|x| alltrim(x[1]) = "CNF_COMPET"})
		nCNfVlp	:= Ascan(aCapaCNF[nContCNA][1],{|x| alltrim(x[1]) = "CNF_VLPREV"})
	
		cSeqCnf	:=Replicate("0",TamSx3("CNF_PARCEL")[1])	
	
	
			cCron := GetSX8Num("CNF","CNF_NUMERO")
		   	
		   	for nCntCnf := 1 to len(aCapaCNF[nContCNA])
		
				RecLock("CNF",.T.)   	
		   	
					cSeqCnf:=SOMA1(cSeqCnF)
			
					CNF->CNF_PARCEL	:=cSeqCnf //N�mero do item - Sequ�ncial
		   		
					CNF->CNF_NUMERO := cCron
					CNF->CNF_CONTRA := CN9->CN9_NUMERO
					CNF->CNF_REVISA	:= CN9->CN9_REVISA
					CNF->CNF_MAXPAR := len(aCapaCNF[nContCNA])
		
			        for nCi:=1 to len(aCapaCNF[nContCNA][nCntCnf])
		
						CNF->&(aCapaCNF[nContCNA][nCntCnf][nCi][1]):=aCapaCNF[nContCNA][nCntCnf][nCi][2]
		
						//CNF->CNF_PERIOD	:=
						//CNF->CNF_VLPREV :=
						//CNF->CNF_SALDO  :=
						//CNF->CNF_DTVENC :=
		
		                if nCNfVlp==nCi
		                	CNF->CNF_SALDO	:= aCapaCNF[nContCNA][nCntCnf][nCi][2]
		                endif
		                
			        next
		
			        if nCNFFil<=0
						CNF->CNF_FILIAL := xFilial("CNF")	//Filial
			        endif
			        if nCNfPer<=0
			        CNF->CNF_PERIOD	:= "1"
			        endif
			        if nCNfPru<=0
			        	CNF->CNF_PRUMED	:= CTOD("01/"+STRZERO(MONTH(CNF->CNF_DTVENC),2)+"/"+cvaltochar(YEAR(CNF->CNF_DTVENC)))
			        endif
			        if nCNfCom<=0
			        	CNF->CNF_COMPET	:= STRZERO(MONTH(CNF->CNF_DTVENC),2)+"/"+cvaltochar(YEAR(CNF->CNF_DTVENC))
			        endif
				
				CNF->(MsUnlock())
		
		    next
		
			CNF->(ConfirmSx8())
			
			RecLock("CNA",.F.)
				CNA->CNA_CRONOG	:= cCron	//Cronograma - Preenche do cadastro CNF
			CNA->(MsUnlock())
		
		//<CNF>*FIM* - CRONOGRAMA
	
	
	next
	//<CNA>*FIM* - PLANILHAS - CAPA

endif

	//<CNN>*INICIO* - PERMISS�ES
	//If AliasInDic("CNN")
		//Gera permiss�o de controle total sobre o contrato
		dbSelectArea("CNN")
		RecLock("CNN",.T.)
			CNN->CNN_FILIAL := xFilial("CNN")
			CNN->CNN_CONTRA := CN9->CN9_NUMERO	//Numero do contrato
			CNN->CNN_USRCOD := RetCodUsr()	//C�digo do usu�rio que ter� permiss�o
			CNN->CNN_TRACOD := "001" //Transacao de controle total do contrato
		MsUnlock()
	//EndIf
        
        //++Libero permiss�es automaticamente para os grupos ou usu�rios que est�o no par�metro
        cLibGrp	:= SUPERGETMV("MV_P_00004",.F.,"")
        cLibUsr	:= SUPERGETMV("MV_P_00005",.F.,"")
		
		if !empty(cLibGrp)	
        
        	aLibGrp:=STRTOKARR(cLibGrp,";")
        	
        	for aLibera:=1 to len(aLibGrp)
       			RecLock("CNN",.T.)
					CNN->CNN_FILIAL := xFilial("CNN")
					CNN->CNN_CONTRA := CN9->CN9_NUMERO	//Numero do contrato
					CNN->CNN_GRPCOD := aLibGrp[aLibera]	//Grupo de usu�rios que ter�o permiss�o
					CNN->CNN_TRACOD := "001" //Transacao de controle total do contrato
				MsUnlock()
            next
            
		endif
		
		if !empty(cLibUsr)	
        
        	aLibUsr:=STRTOKARR(cLibUsr,";")
        	
        	for aLibera:=1 to len(aLibUsr)
       			RecLock("CNN",.T.)
					CNN->CNN_FILIAL := xFilial("CNN")
					CNN->CNN_CONTRA := CN9->CN9_NUMERO	//Numero do contrato
					CNN->CNN_USRCOD := aLibUsr[aLibera]	//Grupo de usu�rios que ter�o permiss�o
					CNN->CNN_TRACOD := "001" //Transacao de controle total do contrato
				MsUnlock()
            next
            
		endif
        
		//++FIM Libero permiss�es

	CNN->(FKCommit())
	//<CNN>*FIM* - PERMISS�ES 
	
	

	
END TRANSACTION	
		
Return(cErro)


*-----------------------------------------------------------------*
Static function ValidCN9(ValidArr,cErro,aCapaCNA,aItemCNB,aCapaCNF)
*-----------------------------------------------------------------*
Local lRet		:= .T.
Local cCliente	:= ""	//cliente
Local cLoja		:= ""	//cliente
Local cCondPag	:= ""	//Condi��o pagamento
Local cTipoCt	:= ""	//Tipo contrato
Local nTipoMd	:= 0	//Moeda

if VALTYPE(ValidArr)<>"A"
	lRet:=.F.                                            
	cErro+="Erro --> CN9 > N�o � array"+CRLF
	Return(lRet)
endif
	
for i:=1 to len(ValidArr)
	if "CN9_CLIENT" $ alltrim(ValidArr[i][1])
		cCliente:=ValidArr[i][2]
	elseif "CN9_LOJACL" $ alltrim(ValidArr[i][1])
		cLoja:=ValidArr[i][2]
	elseif "CN9_CONDPG" $ alltrim(ValidArr[i][1])
		cCondPag:=ValidArr[i][2]
	elseif "CN9_TPCTO" $ alltrim(ValidArr[i][1])
		cTipoCt:=alltrim(ValidArr[i][2])
	elseif "CN9_MOEDA" $ alltrim(ValidArr[i][1])
		nTipoMd:=(ValidArr[i][2])		
	endif
next
 
//**Valida o cliente
if !empty(cCliente+cLoja)
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	if !DbSeek(xFilial("SA1"+cCliente+cLoja))
		lRet:=.F.
		cErro+="Erro --> CN9_CLIENT+CN9_LOJACL >SA1 - Cliente n�o encontrado:"+cCliente+cLoja+CRLF
	endif
else
	lRet:=.F.                                            
	cErro+="Erro --> CN9_CLIENT+CN9_LOJACL >N�o informado(s)"+CRLF
endif

//**Valida a condi��o pagamento
if !empty(cCondPag)
     
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	if !DbSeek(xFilial("SE4")+cCondPag)    
 		lRet:=.F.
		cErro+="Erro --> CN9_CONDPG >SE4 - Condi��o de pagamento n�o encontrada:"+cCondPag+CRLF
	endif

else
	lRet:=.F.
	cErro+="Erro --> CN9_CONDPG >N�o informado(s)"+CRLF
endif

//**Valido o tipo de contrato
if !empty(cTipoCt)

	DbSelectArea("CN1")
	CN1->(DbSetOrder(1))
	if !DbSeek(xFilial("CN1")+cTipoCt)    
 		lRet:=.F.
		cErro+="Erro --> CN9_TPCTO >CN1 - Tipo de contrato n�o encontrado:"+cTipoCt+CRLF
	else
		if CN1->CN1_CTRFIX=="1" //Informa se o contrato possui planilha 1=(fixo), ou se os produtos/servi�os ser�o informados no momento da medi��o 2=(flex�vel)
	    	if empty(aCapaCNA) .OR. empty(aItemCNB) .OR. empty(aCapaCNF)
				lRet:=.F.
				cErro+="Erro --> CN9_TPCTO >Informado tipo fixo, contrato deve conter planilha(capa e item) e cronograma"+CRLF	    	
	    	endif
		endif
		
	endif
	
else
	lRet:=.F.
	cErro+="Erro --> CN9_TPCTO >N�o informado(s)"+CRLF
endif

//**Valido a moeda
Private nCnt

if nTipoMd<>0
	if ( nCnt == Nil )
		nCnt := 1
		While SM2->(FieldPos("M2_MOEDA"+Alltrim(Str(nCnt)))) <> 0
			nCnt++
		EndDo
	endif
	nCnt:= nCnt - 1
	
	if nTipoMd>nCnt
		lRet:=.F.
		cErro+="Erro --> CN9_MOEDA >SM2 - Moeda n�o encontrada:"+cvaltochar(nTipoMd)+CRLF
	endif

else
	lRet:=.F.
	cErro+="Erro --> CN9_MOEDA >N�o informado(s)"+CRLF
endif

	
Return(lRet)


*---------------------------------------*
Static function ValidCNA(ValidArr,cErro)
*---------------------------------------*
Local lRet		:= .T.
Local cTipoPla	:= ""

if VALTYPE(ValidArr)<>"A"
	lRet:=.F.                                            
	cErro+="Erro --> CNA > N�o � array"+CRLF
	Return(lRet)
endif

for j:=1 to len(ValidArr)		
	for i:=1 to len(ValidArr[j])
		if "CNA_TIPPLA" $ alltrim(ValidArr[j][i][1])
			cTipoPla:=ValidArr[j][i][2]
		endif
	next
	 
	//**Valida o tipo da planilha
	if !empty(cTipoPla)
	
		DbSelectArea("CNL")
		CNL->(DbSetOrder(1))
		if !DbSeek(xFilial("CNL")+cTipoPla)
			lRet:=.F.
			cErro+="Erro --> CNA_TIPPLA >CNL - Planilha n�o encontrada:"+cTipoPla+CRLF
		endif
	else
		lRet:=.F.                                            
		cErro+="Erro --> CNA_TIPPLA >N�o informado(s)"+CRLF
	endif
next

Return(lRet)


*---------------------------------------*
Static function ValidCNB(ValidArr,cErro)
*---------------------------------------*
Local lRet		:= .T.
Local cProd		:= ""

if VALTYPE(ValidArr)<>"A"
	lRet:=.F.                                            
	cErro+="Erro --> CNB > N�o � array"+CRLF
	Return(lRet)
endif

for k:=1 to len(ValidArr)
	for j:=1 to len(ValidArr[k])	
		for i:=1 to len(ValidArr[k][j])
			if "CNB_PRODUT" $ alltrim(ValidArr[k][j][i][1])
				cProd:=ValidArr[k][j][i][2]
			endif
		next
		 
		//**Valida o tipo da planilha
		if !empty(cProd)
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			if !DbSeek(xFilial("SB1")+cProd)
				lRet:=.F.
				cErro+="Erro --> CNB_PRODUT >CNB - Produto n�o encontrado:"+cProd+CRLF
			endif
		else
			lRet:=.F.                                            
			cErro+="Erro --> CNB_PRODUT >N�o informado(s)"+CRLF
		endif
	next
next

Return(lRet)


*---------------------------------------*
Static function ValidCNF(ValidArr,cErro)
*---------------------------------------*
Local lRet		:= .T.
Local nValPre	:= 0
Local nValDtv	:= ""

if VALTYPE(ValidArr)<>"A"
	lRet:=.F.                                            
	cErro+="Erro --> CNF > N�o � array"+CRLF
	Return(lRet)
endif
for k:=1 to len(ValidArr)				
	for j:=1 to len(ValidArr[k])	
		for i:=1 to len(ValidArr[k][j])
			if "CNF_VLPREV" $ alltrim(ValidArr[k][j][i][1])
				nValPre:=ValidArr[k][j][i][2]
			elseif "CNF_DTVENC" $ alltrim(ValidArr[k][j][i][1])
				nValDtv:=ValidArr[k][j][i][2]
			endif
		next
		 
		//**valida o valor previsto esta preenchido
		if empty(nValPre)
			lRet:=.F.                                            
			cErro+="Erro --> CNF_VLPREV >N�o informado(s)"+CRLF
		endif
		
		//**valida a data de vencimento
		if empty(nValDtv)
			lRet:=.F.                                            
			cErro+="Erro --> CNF_DTVENC >N�o informado(s)"+CRLF
		endif
		
	next
next
	
Return(lRet)
