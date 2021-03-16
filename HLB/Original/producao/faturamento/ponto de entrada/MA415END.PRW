#include "protheus.ch" 
#include "topconn.ch"

/*
Funcao      : MA415END
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : P.E. após inclusão/alteração de orçamento, fonte trata campo customizado para receber o valor do icms st.
Autor       : Marheus Massarotto
Data/Hora   : 07/07/11     
Obs         :          

TDN         : Disparado após o encerramento das operações da rotina de orçamentos ( inclusão, alteração, exclusão )
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/02/2012
Obs         :               

Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 27/06/2012
Obs         : Tratamento de email Victaulic 

Módulo      : Faturamento.
Cliente     : Neogen / Victaulic
*/

*-----------------------*
 User function MA415END   
*-----------------------*


If cEmpAnt $ "LN" 
   
	LNMA415()

EndIf
 
If cEmpAnt $ "TM"    

	TMMA415()

EndIf

 
   
Return

/*
Função  : LNMA415
Objetivo: Caclular ICMS ST - Neogen
Autor   : Marheus Massarotto
Data    : 15/02/2012
*/ 

*-------------------------*
 Static function LNMA415()   
*-------------------------*

local cQry:=""
local cQry1:=""
//local lIcmREt:=SUPERGETMV("MV_ICMS271",.F.,.F.)
local nAliquota:=0
local nRecnoCK:=SCK->(recno())

//if lIcmREt 
cQry:=" SELECT SCK.CK_VALOR,SCK.R_E_C_N_O_,B1_PICMRET,B1_GRTRIB,B1_PICM,B1_IPI,A1_GRPTRIB,A1_TIPO,A1_EST,F4_BASEICM,F4_INCSOL,F4_ICM,F4_IPI,F4_CONSUMO,F4_INCIDE FROM "+RETSQLNAME("SCK")+" SCK "+CRLF
cQry+=" JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_COD=CK_PRODUTO AND SB1.B1_FILIAL='"+xFilial("SB1")+"'"+CRLF
cQry+=" JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD = SCK.CK_CLIENTE  AND SA1.A1_LOJA = SCK.CK_LOJA AND SA1.A1_FILIAL='"+xFilial("SA1")+"'"+CRLF
cQry+=" JOIN "+RETSQLNAME("SF4")+" SF4 ON SF4.F4_CODIGO = SCK.CK_TES"+CRLF
cQry+=" WHERE SCK.D_E_L_E_T_='' AND SB1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND SF4.D_E_L_E_T_='' AND CK_NUM='"+SCK->CK_NUM+"' AND CK_FILIAL='"+SCK->CK_FILIAL+"'"

	if select("TRBSCK_")>0
		TRBSCK_->(DbCloseArea())	
	endif
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBSCK_" ,.T.,.F.)
			
	COUNT to nRecCount                                           
	
	if nRecCount>0
		TRBSCK_->(DbGotop())	
		
		while TRBSCK_->(!EOF())
			//Verifica se o tipo de cliente possui calculo de icms solidario
			if !(TRBSCK_->A1_TIPO $ alltrim(SUPERGETMV("MV_TPSOLCF",.F.,"")))
					
					SCK->(DbGoto(TRBSCK_->R_E_C_N_O_))                    
					
					RECLOCK("SCK",.F.) 
						SCK->CK_P_VLRST:=0
						SCK->CK_P_TOTST:=0
					SCK->(MsUnlock())
				
				TRBSCK_->(DbSkip())
				loop
			endif 
			//verifica se tem grupo de exceção fiscal ou margem de lucro para calculo do icms st
			if EMPTY(TRBSCK_->B1_GRTRIB) .AND. TRBSCK_->B1_PICMRET==0
					SCK->(DbGoto(TRBSCK_->R_E_C_N_O_))                    
					
					RECLOCK("SCK",.F.) 
						SCK->CK_P_VLRST:=0
						SCK->CK_P_TOTST:=0
					SCK->(MsUnlock())
			
				TRBSCK_->(DbSkip())
				loop
			endif   
		    
		    cQry1:=" SELECT F7_ALIQINT,F7_ALIQEXT,F7_ALIQIPI,F7_ALIQDST,F7_MARGEM FROM "+RETSQLNAME("SF7")+" SF7 "+CRLF
			cQry1+=" WHERE F7_GRTRIB = '"+TRBSCK_->B1_GRTRIB+"' AND F7_GRPCLI='"+TRBSCK_->A1_GRPTRIB+"' AND SF7.F7_EST='"+TRBSCK_->A1_EST+"' AND SF7.F7_FILIAL='"+xFilial("SF7")+"' AND (SF7.F7_TIPOCLI='"+TRBSCK_->A1_TIPO+"' OR SF7.F7_TIPOCLI='*') AND D_E_L_E_T_=''"
			
			if select("TRBSF7_")>0
				TRBSF7_->(DbCloseArea())	
			endif
					
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1), "TRBSF7_" ,.T.,.F.)
					
			COUNT to nRecCount
			
			//->> calculo das aliquotas icms e icmsst
			nAliqST:=0
			if nRecCount>0
				TRBSF7_->(DbGotop())	
				//aliquota do icms st
				if TRBSF7_->F7_ALIQDST<>0
					nAliqST:=TRBSF7_->F7_ALIQDST
				endif
				
				//aliquota do icms
				if alltrim(GETMV("MV_ESTADO"))==alltrim(TRBSCK_->A1_EST)
					nAliquota:=TRBSF7_->F7_ALIQINT	
				else
					nAliquota:=TRBSF7_->F7_ALIQEXT
				endif
				
				
			elseif TRBSCK_->B1_PICM<>0
				//aliquota do icms st
				if nAliqST==0
					nAliqST:=TRBSCK_->B1_PICM
				endif
				//aliquota do icms
				nAliquota:=TRBSCK_->B1_PICM
			else

				//aliquota do icms st
				if nAliqST==0
					//nAliqST:=VAL(SUBSTR(GETMV("MV_ESTICM"),AT(ALLTRIM(GETMV("MV_ESTADO")),ALLTRIM(GETMV("MV_ESTICM")))+2,2))
					nAliqST:=VAL(SUBSTR(GETMV("MV_ESTICM"),AT(alltrim(TRBSCK_->A1_EST),ALLTRIM(GETMV("MV_ESTICM")))+2,2))
				endif

				//aliquota do icms				
				if alltrim(GETMV("MV_ESTADO"))==alltrim(TRBSCK_->A1_EST)
					nAliquota:=VAL(SUBSTR(GETMV("MV_ESTICM"),AT(ALLTRIM(GETMV("MV_ESTADO")),ALLTRIM(GETMV("MV_ESTICM")))+2,2))	
				else //Tratamento para aliquota interestadual, com verificação dos estados do norte					
					If ( alltrim(GETMV("MV_ESTADO")) $ ALLTRIM(GETMV("MV_NORTE")) )
						nAliquota := 12 //MV_ICMTRF
					Else
						nAliquota := IIf( alltrim(TRBSCK_->A1_EST) $ ALLTRIM(GETMV("MV_NORTE")) , 7 , 12 ) 
					EndIf						
				endif
				
			endif              
			
			//->> verifica a margem de lucro
			if TRBSF7_->F7_MARGEM==0 .AND. TRBSCK_->B1_PICMRET==0
			
					SCK->(DbGoto(TRBSCK_->R_E_C_N_O_))                    
					
					RECLOCK("SCK",.F.) 
						SCK->CK_P_VLRST:=0
						SCK->CK_P_TOTST:=0
					SCK->(MsUnlock())
					
				TRBSCK_->(DbSkip())				
				loop
			else
				if TRBSF7_->F7_MARGEM<>0
					nMargem:=TRBSF7_->F7_MARGEM
				else
					nMargem:=TRBSCK_->B1_PICMRET
				endif
			endif
			
			//->> aliquota do ipi
			nAliqIPI:=0
			if TRBSCK_->F4_IPI=='S'			
				if TRBSF7_->F7_ALIQIPI<>0
					nAliqIPI:=TRBSF7_->F7_ALIQIPI
				elseif TRBSCK_->B1_IPI<>0
					nAliqIPI:=TRBSCK_->B1_IPI
				endif         
			endif
			
			//->> Valor do ICMS
			nVlrICMS:=0
			if TRBSCK_->F4_ICM=='S'
				//se utiliza o IPI na base do icmsst
				if TRBSCK_->F4_INCIDE=='S'
					nVlrICMS:=( TRBSCK_->CK_VALOR+(TRBSCK_->CK_VALOR*( iif(TRBSCK_->F4_BASEICM==0,1,TRBSCK_->F4_BASEICM/100))) * (nAliqIPI/100) ) *(nAliquota/100)
				else
					nVlrICMS:=(TRBSCK_->CK_VALOR*( iif(TRBSCK_->F4_BASEICM==0,1,TRBSCK_->F4_BASEICM/100)))*(nAliquota/100)
				endif
			endif
			
			//->> Valor do ICMSST
			nVlrST:=0
			nVlrLucro:=0
						
			//->> Verifica se é consumo para n considerar margem de lucro
			if TRBSCK_->F4_CONSUMO=='S' .AND. alltrim(GETMV("MV_ESTADO"))<>alltrim(TRBSCK_->A1_EST)
				nMargem:=0
			endif
			//se for consumidor final não considera margem de lucro
			if TRBSCK_->A1_TIPO=='F'
            	nMargem:=0
 			endif
				
				nVlrLucro:=TRBSCK_->CK_VALOR+(TRBSCK_->CK_VALOR*(nMargem/100))	
				
				if nAliqIPI<>0
					nVlrLucro:=nVlrLucro+(nVlrLucro*(nAliqIPI/100))
				endif
				
				nVlrST:= (nVlrLucro*(nAliqST/100)) 
			//endif
			nValor:=0
			nValor:=TRBSCK_->CK_VALOR
			
			TRBSF7_->(DbCloseArea())	    
		
			SCK->(DbGoto(TRBSCK_->R_E_C_N_O_))                    
			    //nValBase:=SCK->CK_VALOR
				//nValor:=SCK->CK_VALOR+(SCK->CK_VALOR *(TRBSCK_->B1_PICMRET/100))
				//nBaseICMS:=(nValBase*( iif(TRBSCK_->F4_BASEICM==0,1,TRBSCK_->F4_BASEICM/100)))
			RECLOCK("SCK",.F.) 
				//SCK->CK_P_VLRST:=nValBase + ( (nValor*(nAliquota/100)) - ( nBaseICMS * (nAliquota/100)) )
				SCK->CK_P_VLRST:=nVlrST-nVlrICMS
				SCK->CK_P_TOTST:=nValor+(nVlrST-nVlrICMS)
			SCK->(MsUnlock())	

		
			TRBSCK_->(DbSkip())
		enddo
		SCK->(Dbgoto(nRecnoCK))
		TRBSCK_->(DbCloseArea())
	endif
	
//endif

return 

/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/ 

*-------------------------*
 Static function TMMA415()   
*-------------------------*


Local aOrd	:= SaveOrd({"SCK","SA1","SCJ"})
 
If cEmpAnt $ "TM"

	aHeader := {}
	aDetail := {}
	        
	
	aAdd(aHeader,{"CJ_NUM"		,SCJ->CJ_NUM})
	aAdd(aHeader,{"CJ_USERLGI"	,SCJ->CJ_USERLGI})
	aAdd(aHeader,{"CJ_CLIENTE"	,SCJ->CJ_CLIENTE})
	
	SCK->(DbSetorder(1))
	If SCK->(DbSeek(xFilial("SCK")+SCJ->CJ_NUM))
		While SCK->(!Eof()) .And. SCK->CK_FILIAL==xFilial("SCK") .And.;
				SCK->CK_NUM == SCJ->CJ_NUM
		    aAux := {}
		    aAdd(aAux,{"CK_PRODUTO"	,SCK->CK_PRODUTO})
		    aAdd(aAux,{"CK_DESCRI"	,SCK->CK_DESCRI})
		    aAdd(aAux,{"CK_QTDVEN"	,SCK->CK_QTDVEN})
		    aAdd(aAux,{"CK_PRCVEN"	,SCK->CK_PRCVEN})
		    aAdd(aAux,{"CK_VALOR"	,SCK->CK_VALOR})
		    aAdd(aAux,{"CK_NUMPV"	,SCK->CK_NUMPV})
		    aAdd(aDetail,aAux)
		    
			SCK->(dbSkip())
		EndDo
	EndIf
	
	SendWorkFlow(aHeader,aDetail)            
	
EndIf

Restord(aOrd)

Return .T.      

/*
Função  : SendWorkFlow
Objetivo: Envia email de worflow
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/
*-------------------------------------------*
Static Function SendWorkFlow(aHeader,aDetail)
*-------------------------------------------* 

Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local cEmail	:= Email(aHeader,aDetail)
 

oEmail          := DEmail():New()
oEmail:cFrom   	:= "totvs@hlb.com.br"
oEmail:cTo		:= PADR(ALLTRIM(GetMv("MV_P_EMAI3",,"")),400)  

If PARAMIXB[1] == 1  .AND. PARAMIXB[2] == 1
  
	oEmail:cSubject	:= padr("Orcamento '"+ALLTRIM(aHeader[nPosNum][2])+"' incluido.",200)  
	oEmail:cBody   	:= cEmail
	oEmail:Envia()

ElseIf PARAMIXB[1] == 1 .AND. PARAMIXB[2] == 2
	
	oEmail:cSubject	:= padr("Orcamento '"+ALLTRIM(aHeader[nPosNum][2])+"' alterado.",200)   
	oEmail:cBody   	:= cEmail
	oEmail:Envia()           
	
EndIf


Return .T.  

/*
Função  : Email
Objetivo: Monta o email a ser enviado no workflow.
Autor   : Tiago Luiz Mendonça
Data    : 27/06/2014
*/
*------------------------------------*
Static Function Email(aHeader,aDetail)
*------------------------------------*  
Local cAux := ""
Local cHtml := ""

Local nPosNum	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_NUM" })
Local nPosCol	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_USERLGI" })
Local nPosCli	:= aScan(aHeader, {|x| ALLTRIM(x[1]) == "CJ_CLIENTE" })

SA1->(DbSetorder(1))
SA1->(DbSeek(xFilial("SA1")+aHeader[nPosCli][2])) 

cHtml+='<html xmlns:v="urn:schemas-microsoft-com:vml"'
cHtml+='xmlns:o="urn:schemas-microsoft-com:office:office"'
cHtml+='xmlns:w="urn:schemas-microsoft-com:office:word" '
cHtml+='xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"'
cHtml+='xmlns="http://www.w3.org/TR/REC-html40">'

cHtml+='<head>
cHtml+='	<meta http-equiv=Content-Type content="text/html; charset=windows-1252">'
cHtml+='	<meta name=ProgId content=Word.Document> '
cHtml+='	<meta name=Generator content="Microsoft Word 12"> '
cHtml+='	<meta name=Originator content="Microsoft Word 12">'
cHtml+='</head>
cHtml+='<body bgcolor="#FFFFFF" lang=PT-BR link=blue vlink=purple style="tab-interval:35.4pt">'
cHtml+='<div class=WordSection1>'
cHtml+="	<p class=MsoNormal  align=center style='text-align:center'> "
cHtml+='		<a href="http://www.grantthornton.com.br/">'
cHtml+="			<span style='text-decoration:none; text-underline:none'>"
//cHtml+='				<center><img width=680 border=0 id="_x0000_i1025" src="http://assets.finda.co.nz/images/thumb/zc/9/x/5/4y39x5/790x97/grant-thornton.jpg" nosend=1>'
cHtml+="			</span>"
cHtml+="		</a>"  
cHtml+="    </p>"
cHtml+="</div>"
cHtml+="<h1>"
cHtml+="<div align=center>"
cHtml+="	<table class=MsoNormalTable border=0 cellpadding=0 width=800 style='width:525.0pt;mso-cellspacing:1.5pt;background:white;mso-yfti-tbllook:1184'>"
cHtml+="		<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="			<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="				<div align=center>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+="						<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="							<td style='background:#4D1174;padding:0cm 0cm 0cm 0cm'>"
cHtml+="								<p class=MsoNormal align=center style='text-align:center'><b> "
cHtml+= TipoString(10.0,2)
If PARAMIXB[2] == 1
cHtml+="										Orcamento: "+ALLTRIM(aHeader[nPosNum][2])+" incluido"
ElseIf PARAMIXB[2] == 2 
cHtml+="										Orcamento: "+ALLTRIM(aHeader[nPosNum][2])+" alterado"
EndIf

cHtml+="									</span></b>"
cHtml+="								</p>"
cHtml+="							</td>"
cHtml+="						</tr>"
cHtml+="					</table>"
cHtml+="				</div>"
cHtml+="				<div align=center>"
cHtml+="					<Br>"
cHtml+="					<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=700 style='width:510.0pt;mso-cellspacing:0cm;mso-yfti-tbllook:1184;mso-padding-alt:0cm 0cm 0cm 0cm'>"
cHtml+='						<tr bgcolor="#FCFCFC">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Numero:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosNum][2])
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Colaborador:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(cUserName)
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"

cHtml+='						<tr bgcolor="#F3F3F3">'
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									Cliente:"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"+ALLTRIM(aHeader[nPosCli][2])+" - "+ALLTRIM(SA1->A1_NOME)
cHtml+="								</span>"
cHtml+="							</td> " 
cHtml+="							<td>" 
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"
cHtml+="							<td>"
cHtml+= TipoString(8.5,1)
cHtml+="									"
cHtml+="								</span>"
cHtml+="							</td>"  
cHtml+="						</tr>"



cHtml+="					</table>" 
cHtml+="				</Div>"
cHtml+="			</td>"  
cHtml+="		</tr>"						
cHtml+="   	</table>"
cHtml+="</div>"	
cHtml+="<tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>"
cHtml+="	<H1>"
cHtml+="	<td style='padding:0cm 0cm 0cm 0cm'>"
cHtml+="		<div align=center>"
cHtml+="			<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=679 style='width:509.25pt;mso-cellspacing:0cm;border:outset #CCCCCC 1.0pt;"
cHtml+="			mso-border-alt:outset #CCCCCC .75pt;mso-yfti-tbllook:1184;mso-padding-alt:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="				<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>"
cHtml+="					<td width='4%' style='width:4.0%;order:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Produto<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='9%' style='width:9.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Descrição<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='7%' style='width:7.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Quantidade<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='49%' style='width:49.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Unitário<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="									Vlr. Total<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="					<td width='11%' style='width:11.0%;border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;background:#4D1174;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
cHtml+="						<p class=MsoNormal>"
cHtml+="							<b>"
cHtml+= TipoString(7.5,2)
cHtml+="								Orcamento<o:p></o:p>"
cHtml+="								</span>"
cHtml+="							</b>"
cHtml+="						</p>"
cHtml+="					</td>"
cHtml+="				</tr>"

For i:=1 to Len(aDetail)
	cHtml+="				<tr style='mso-yfti-irow:1'>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)                                             
	cHtml+="					"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRODUTO" })][2])+"<o:p></o:p>"	
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="				"+ALLTRIM(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_DESCRI" })][2])+"<o:p></o:p>"
 	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(STR(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_QTDVEN" })][2]))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_PRCVEN" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="					"+ALLTRIM(Transform(aDetail[i][aScan(aDetail[i], {|x| ALLTRIM(x[1]) == "CK_VALOR" })][2],"@E 99,999,999.9999"))+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="					<td style='border:inset #CCCCCC 1.0pt;mso-border-alt:inset #CCCCCC .75pt;padding:2.25pt 2.25pt 2.25pt 2.25pt'>"
	cHtml+="						<p class=MsoNormal>"
	cHtml+= TipoString(8.5,1)
	cHtml+="				"+ALLTRIM(aHeader[1][2])+"<o:p></o:p>"
	cHtml+="							</span>"
	cHtml+="						</p>"
	cHtml+="					</td>"
	cHtml+="				</tr>"

Next i

cHtml+="			</table>"
cHtml+="		</div>"
cHtml+="		<p class=MsoNormal>&nbsp;</p>"
cHtml+="    </td>" 
cHtml+="</tr>"	
cHtml+="<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>"
cHtml+="	<td style='padding:.75pt .75pt .75pt .75pt'>"
cHtml+="		<p class=MsoNormal align=center style='text-align:center'>"
cHtml+="			<span class=tituloatencao1>"
cHtml+="				<span style='font-size:9.5pt;mso-fareast-font-family:"
cHtml+='				"Times New Roman"'
cHtml+="				;color:red'>"
cHtml+="						HLB BRASIL - Mensagem automática, favor não responder este e-mail."
cHtml+="				</span>"
cHtml+="			</span>"
cHtml+="		</p>"
cHtml+="    </td>"
cHtml+="</tr>"
cHtml+="</body>"
cHtml+="</html>"                       

Return cHtml

/*
Funcao      : TipoString
Objetivos   : 
Autor       : 
Data/Hora   : 
*/            
*----------------------------------------*
 Static Function TipoString(nTam,nColor)
*-----------------------------------------*
                               
Local cAux:=""
      			     			
cAux:="<span style='font-size:"+Alltrim(Str(nTam))+"pt;font-family:"
cAux+='"Verdana","sans-serif"'
cAux+=";mso-fareast-font-family:"
cAux+='"Times New Roman"'
cAux+=";color:"+IIf(nColor==1,"Black","white")+"'>"
               
               
Return cAux

