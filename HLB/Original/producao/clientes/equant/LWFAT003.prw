#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.Ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.ch"

/*
Funcao      : LWFAT003
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função para gerar a descriminação das faturas do grupo + boleto, baseado no fonte que a Orange já utilizava
Autor       : Matheus Massarotto
Data/Hora   : 03/02/2015    17:45
Revisão		:                    
Data/Hora   : 
Módulo      : Faturamento
*/

*--------------------------*
 User Function LWFAT003
*--------------------------*
Local nSalta	 := 12
Local nSpRow	 := 2
Local nSpCol	 := 4
Local nMgLine	 := 9
Local nTamLine	 := 2 
Local nLimBol	 := 210 //Limita a quantidade de linhas por paginas com boleto
Local nLimTot	 := 420 //Limita a quantidade de linhas por paginas sem boleto 
Local nLin2		 := 0

Local cPara		 := ""
Local cAssunto   := ""
Local cTexto	 := ""
Local cTexto2	 := ""
Local cPerg		 := "LWFAT003"//RRP - 16/12/2013 - Alterado pois estava com o mesmo nome do fonte NFSERV do cPerg SZNFSV.
Local cQuery	 := ""
Local cQuery2	 := ""
Local cCFOP	 	 := ""
Local cNatureza	 := ""
Local cHashCode	 := ""  
Local cAux       := ""

Local aFiles	 := {}
Local aDescrNF	 := {}

Private oMail
Private oMessage
Private cSMTPServer		:= GetMV("MV_RELSERV")
Private cSMTPUser		:= GetMV("MV_RELACNT")
Private cSMTPPass		:= GetMV("MV_RELPSW" )
Private cMailFrom		:= GetMV("MV_RELFROM")

Private nPagina			:= 0
Private cDirMail 		:= "\nfserv\"
Private cDirGer	 		:= "" //Criar um diretorio \NFSERV\ no drive informado
Private oNfServ
Private nErro   	    := 0
Private nPort			:= 587
Private lRetMail		:= .T.
Private lUseAuth		:= GetMv("MV_RELAUTH")
Private nLin  			:= 15
Private aCol		    := {10,25,200,300,400,500,580}
Private aCol2		    := {10,70,120,160,210,400,550}
Private cFonte			:= "Helvetica 65 Medium"
Private lSaltaBol	 	:= .F.
Private lSalta			:= .F.
Private nTamBox	 		:= 215
Private nLinhas			:= 0
Private nLinhaAtu		:= 0
Private nLinhaAux		:= 0
Private nSaltaLnIt 		:= 12
Private cLog			:= ""
//RRP - 24/06/2014 - Ajuste na impressão do Boleto da Agência e Conta para a Equant código LW e LX
Private cPortGrv		:= ""              	
Private cAgeGrv			:= ""
Private cContaGrv		:= ""


//EQUANT BRASIL
If Alltrim(SM0->M0_CODIGO)=="LW"
	cPortGrv    := "745"
	cAgeGrv     := "0001 "
	cContaGrv   := "049229011 "
//EQUANT SERVICE
ElseIf Alltrim(SM0->M0_CODIGO)=="LX"
	cPortGrv    := "745"
	cAgeGrv     := "0001 "
	cContaGrv   := "053809014 "
EndIf  

AtuX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return
End If

cDirGer	:= mv_par14+cDirMail
MakeDir(cDirGer) //Cria diretorio no local informado no parametro MV_PAR14 (DRIVE)
MakeDir(cDirMail)//Cria diretorio \NFSERV\ ROOTPATH

//Prepara o envio de email
If mv_par10 == 2

	//Exclui os arquivos pre-existentes nos diretorios
	aFilesDel := Directory(cDirMail+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirMail+ aFilesDel[i][1])
	Next i
	aFilesDel := Directory(cDirGer+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirGer+ aFilesDel[i][1])
	Next i

	oMail := TMailManager():New()
	oMail:SetUseSSL(.T.)
	oMail:Init( '', cSMTPServer , cSMTPUser, cSMTPPass, 0, nPort )
	oMail:SetSmtpTimeOut( 120 )
	nErro := oMail:SmtpConnect()
	
	If lUseAuth
		nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
	      
		If nErro <> 0
			// Recupera erro ...
			cMAilError := oMail:GetErrorString(nErro)
			DEFAULT cMailError := '***UNKNOW***'
			MsgAlert("Erro de Autenticacao "+str(nErro,4)+' ('+cMAilError+')',"AKRON")
			lRetMail := .F.
		EndIf
	EndIf
	
	If nErro <> 0
	      
		// Recupera erro
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := '***UNKNOW***'
		MsgAlert(cMAilError+CRLF+"Erro de Conexão SMTP "+str(nErro,4)+CRLF+'Desconectando do SMTP',"AKRON")
		oMail:SMTPDisconnect()
		lRetMail := .F.
	      
	EndIf

End If
//RRP - 16/12/2013 - Retirada a coluna C5.C5_MENNOT1, pois não existe em nossa base. 
/*cQuery := "SELECT C5.C5_MENNOTA,C5.C5_XNUMCTR,A1.*,F2.* FROM " + RetSqlName("SF2") + " F2 LEFT JOIN " + RetSqlName("SA1") + " A1 ON F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA "
cQuery += " LEFT JOIN " + RetSqlName("SC5") + " C5 ON C5.C5_CLIENTE = F2.F2_CLIENTE AND C5.C5_LOJACLI = F2.F2_LOJA AND C5.C5_NOTA = F2.F2_DOC AND C5.C5_SERIE = F2.F2_SERIE"
cQuery += " WHERE F2.F2_EMISSAO >= '" + DTOS(MV_PAR01) + "' AND F2.F2_EMISSAO <= '" + DTOS(MV_PAR02) + "' AND F2.F2_CLIENTE >= '" + MV_PAR03 + "'"
cQuery += " AND F2.F2_CLIENTE <= '" + MV_PAR04 + "' AND F2_LOJA >= '" + MV_PAR05 + "' AND F2_LOJA <= '" + MV_PAR06 + "' AND F2.F2_DOC >= '" + mv_par07 + "' AND F2.F2_DOC <= '" + mv_par08 + "' AND F2.F2_SERIE >= '" + mv_par09 + "' AND F2.F2_SERIE <= '" +  + "' AND F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = ''
cQuery += " ORDER BY F2.F2_CLIENTE, F2.F2_LOJA, F2.F2_DOC, F2.F2_SERIE"
*/
cQuery := " SELECT SE1.*,SA1.* FROM "+RetSqlName("SE1")+" SE1
cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA
cQuery += " WHERE SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_=''
cQuery += " AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' 
cQuery += " AND E1_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
cQuery += " AND E1_LOJA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
cQuery += " AND E1_NUM BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
cQuery += " AND E1_PREFIXO = "
	if MV_PAR09==1
		cQuery += "'FRP'"
	elseif MV_PAR09==2
		cQuery += "'FTE'"
	elseif MV_PAR09==3
		cQuery += "'FR '"
	endif
cQuery += " AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR15)+"' AND '"+DTOS(MV_PAR16)+"' 
cQuery += " AND E1_TIPO='FT'

cQuery := ChangeQuery(cQuery)

if select("SQLSE1")>0
	SQLSE1->(DbCloseArea())
endif

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQLSE1",.T.,.T.)

While SQLSE1->(!EOF())      
    
	//Busca os títulos que compõe a fatura para imprimí-los
	
	cQry := " SELECT SE1.*,SA1.*,SF2.*,SC5.* FROM SE1LW0 SE1
	cQry += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA
	cQry += " LEFT JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = SE1.E1_FILORIG AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_SERIE AND SF2.F2_CLIENTE =SE1.E1_CLIENTE AND SF2.F2_LOJA = SE1.E1_LOJA AND SF2.D_E_L_E_T_='' 
	cQry += " LEFT JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_CLIENTE = SF2.F2_CLIENTE AND SC5.C5_LOJACLI = SF2.F2_LOJA AND SC5.C5_NOTA = SF2.F2_DOC AND SC5.C5_SERIE = SF2.F2_SERIE AND SC5.D_E_L_E_T_=''"
	cQry += " WHERE SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' 
	cQry += " AND E1_FATPREF = '"+SQLSE1->E1_PREFIXO+"'
	cQry += " AND E1_FATURA='"+SQLSE1->E1_NUM+"'
	cQry += " AND E1_TIPOFAT='"+SQLSE1->E1_TIPO+"'
	cQry += " AND E1_BAIXA<>'' AND E1_SALDO=0
	
	cQry := ChangeQUery(cQry)
	
	if select("SQLSF2")>0
		SQLSF2->(DbCloseArea())
	endif
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SQLSF2",.T.,.T.)
	
	COUNT TO nRecCount
	
	if nRecCount>0
		DbSelectArea("SQLSF2")
		SQLSF2->(DbGoTop())
	    
		While SQLSF2->(!EOF())
	        
	        //Se for RPS chamo a static function que processa as notas do fonte ORRFAT40
			if alltrim(UPPER(SQLSF2->F2_ESPECIE)) == 'RPS'
				lImpBol:=.F. //não imprime boleto
				Processa({|lEnd|;
				StaticCall(ORRFAT40,ImpCorpo,;
						   oNfServ,@cAux,nSalta,nSaltaLnIt,nLimBol,nLimTot,nTamLine,nSpRow,nLin2,SQLSF2->F2_FILIAL,SQLSF2->F2_DOC,SQLSF2->F2_SERIE,;
						   SQLSF2->F2_CLIENTE,SQLSF2->F2_LOJA,SQLSF2->C5_XNUMCTR,SQLSF2->F2_ESPECIE,SQLSF2->C5_MENNOTA,SQLSF2->F2_EMISSAO,;
						   SQLSF2->F2_VALBRUT,SQLSF2->F2_BASEICM,SQLSF2->F2_VALICM,lImpBol);
						   })
			   
			    AADD(aFiles,{"nfserv_"  + alltrim(SQLSF2->F2_CLIENTE)+alltrim(SQLSF2->C5_XNUMCTR)})
			
			//Se for nota de telecomunicação ou aluguel chamo a static function que processa as notas do fonte ORRFAT20   
	        else 
   				lImpBol:=.F. //não imprime boleto
				Processa({|lEnd|;
				StaticCall(ORRFAT20,ImpCorpo,;
						   oNfServ,@cAux,nSalta,nSaltaLnIt,nLimBol,nLimTot,nTamLine,nSpRow,nLin2,SQLSF2->F2_FILIAL,SQLSF2->F2_DOC,SQLSF2->F2_SERIE,;
						   SQLSF2->F2_CLIENTE,SQLSF2->F2_LOJA,SQLSF2->C5_XNUMCTR,SQLSF2->F2_ESPECIE,SQLSF2->C5_MENNOTA,SQLSF2->F2_EMISSAO,;
						   SQLSF2->F2_VALBRUT,SQLSF2->F2_BASEICM,SQLSF2->F2_VALICM,lImpBol);
						   })
						   
			    AADD(aFiles,{"nfserv_"  + alltrim(SQLSF2->F2_CLIENTE)+alltrim(SQLSF2->C5_XNUMCTR)+ALLTRIM(SQLSF2->F2_SERIE)})
			    
	        endif
        	
        	SQLSF2->(DbSKip())
        Enddo
	endif

	//TLM 20140122 - Tratamento para zerar as páginas para a próxima nota
	If cAux <> SQLSE1->E1_NUM
		nPagina:= 0 
		cAux   := SQLSE1->E1_NUM
	EndIf
		
	nLin := 25
	
	oBrush0 := TBrush():New(,RGB(255,102,000))
	oBrush1 := TBrush():New(,RGB(255,157,000))
	
	oNfServ:=FWMSPrinter():New("nfserv_" + alltrim(SQLSE1->E1_CLIENTE)+alltrim(SQLSE1->E1_NUM) + alltrim(SQLSE1->E1_SERIE),6,.F.,,.T.,,,,,,,.F.)
	
	oNfServ:SetPortrait()
	
	oNfServ:cPathPDF := cDirGer
	oNfServ:StartPage()
	
	//Inicia Impressao do Cabecalho
	KImpCab(cNatureza)
	//Finaliza impressao do cabecalho
	
	nLin += nSalta*2
	
	oNfServ:SetFontEX(9,cFonte,.F.,.T.,.F.)
	
	/*
	cQuery2 := "SELECT D2.D2_COD,B1.B1_GRUPO,B1.B1_DESC,D2.D2_TOTAL,D2.D2_BASEICM,D2.D2_PICM,D2.D2_VALICM FROM " + RetSqlName("SD2") + " D2 LEFT JOIN " + RetSqlName("SF2") + " F2 ON D2.D2_FILIAL = F2.F2_FILIAL AND D2.D2_DOC = F2.F2_DOC AND D2.D2_SERIE = F2.F2_SERIE"
	cQuery2 += " AND D2.D2_CLIENTE = F2.F2_CLIENTE AND D2.D2_LOJA = F2.F2_LOJA LEFT JOIN " + RetSqlName("SB1") + " B1 ON D2.D2_COD = B1.B1_COD "
	cQuery2 += " WHERE D2.D_E_L_E_T_ = '' and B1.D_E_L_E_T_ = '' and F2.D_E_L_E_T_ = '' AND D2.D2_FILIAL = '" + SQLSF2->F2_FILIAL + "' AND D2.D2_DOC = '" + SQLSF2->F2_DOC + "'"
	cQuery2 += " AND D2.D2_SERIE = '" + SQLSF2->F2_SERIE + "' AND D2.D2_CLIENTE = '" + SQLSF2->F2_CLIENTE + "' AND D2.D2_LOJA = '" + SQLSF2->F2_LOJA + "'"
	*/
	
	cQuery2 := " SELECT SE1.*,SA1.* FROM SE1LW0 SE1
	cQuery2 += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA
	cQuery2 += " WHERE SE1.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND E1_FATPREF = '"+SQLSE1->E1_PREFIXO+"'
	cQuery2 += " AND E1_FATURA='"+SQLSE1->E1_NUM+"'
	cQuery2 += " AND E1_TIPOFAT='"+SQLSE1->E1_TIPO+"'
	cQuery2 += " AND E1_BAIXA<>'' AND E1_SALDO=0
	
	cQuery2 := ChangeQUery(cQuery2)
	
	if select("SQLSE1_2")>0
		SQLSE1_2->(DbCloseArea())
	endif
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),"SQLSE1_2",.T.,.T.)
	
	DbSelectArea("SQLSE1_2")
	DbGoTop()

	COUNT TO nLinhas
	
	DbSelectArea("SQLSE1_2")
	DbGoTop()
	
	nTotal     := 0
	nTotalBase := 0
	nTotalIcm  := 0
	nTotalIss  := 0
	
	If nLinhas*nSaltaLnIt > nLimBol
		nTamBox := 435
		lSaltaBol := .T.
	Else
		nTamBox := 215
		lSaltaBol := .F.
	End If
	
	//Imprime o formulario
	KIMPFORM()
	
 	While SQLSE1_2->(!EOF())
		nLinhaAtu++
		nLinhaAux++
		
		If (nLinhas-nLinhaAux)*nSaltaLnIt > nLimBol
			lSaltaBol := .T.
		Else
			lSaltaBol := .F.
		End If	
	
		If nLinhaAtu*nSaltaLnIt > nLimTot
			SaltaPag(cNatureza)
		End If

		//oNfServ:SetFontEX(7,cFonte,.F.,.F.,.F.)
		oNfServ:SetFontEX(12,"Arial",.F.,.F.,.F.)
/*
		oNfServ:Say(nLin+20,aCol[1]+1 ,alltrim(SQLSE1_2->E1_NUM))
		oNfServ:Say(nLin+20,aCol[2]+55,alltrim(UPPER(SQLSE1_2->A1_NOME)))
		oNfServ:Say(nLin+20,aCol[3]+84,Transform(SQLSE1_2->A1_CGC ,"@R 99.999.999/9999-99"))

// 		If Alltrim(SQLSE1->F2_SERIE) # "R"
//			oNfServ:Say(nLin+20,aCol[6]-140 ,Transform(SQLSD2->D2_BASEICM,"@E 999,999,999.99"))
//			oNfServ:Say(nLin+20,aCol[6]-110 ,Transform(SQLSD2->D2_PICM,"@E 999,999,999.99"))
			oNfServ:Say(nLin+20,aCol[7]-70  ,Transform(SQLSE1_2->E1_VALOR,"@E 999,999,999.99"))
//		End If
*/                                                                      	

		oNfServ:Say(nLin+30,aCol2[1] , alltrim(SQLSE1_2->E1_NUM))
		oNfServ:Say(nLin+30,aCol2[2]-15 , DTOC(STOD(SQLSE1_2->E1_EMISSAO)))
		oNfServ:Say(nLin+30,aCol2[3]-7 , alltrim(UPPER(SQLSE1_2->A1_CODORA)))
		oNfServ:Say(nLin+30,aCol2[4] , alltrim(UPPER(SQLSE1_2->E1_SERIE)))
		oNfServ:Say(nLin+30,aCol2[5] , alltrim(UPPER(SUBSTR(SQLSE1_2->A1_NOME,1,30))))
		oNfServ:Say(nLin+30,aCol2[6] , Transform(SQLSE1_2->A1_CGC ,"@R 99.999.999/9999-99"))
		oNfServ:Say(nLin+30,aCol2[7]-45 , "R$ "+Transform(SQLSE1_2->E1_VALOR,"@E 999,999,999.99"))
									
		nLin    += nSaltaLnIt

		nTotal     += SQLSE1_2->E1_VALOR
		//nTotalBase += SQLSD2->D2_BASEICM
		//nTotalIcm  += SQLSD2->D2_VALICM

		SQLSE1_2->(DbSkip())
	End

	SQLSE1_2->(DbCloseArea())

	nLin := nTamBox+220

	//oNfServ:SetFontEX(12,"Verdana",.T.,.T.,.F.)
	
/*	If Alltrim(SQLSE1->F2_SERIE) # "R"
		oNfServ:Say(nLin,aCol[6]-140,Transform(nTotalBase,"@E 999,999,999.99"))
		oNfServ:Say(nLin,aCol[6]-50 ,Transform(nTotalIcm ,"@E 999,999,999.99"))
		oNfServ:Say(nLin,aCol[3]+90 ,Transform(nTotal    ,"@E 999,999,999.99"))
	End If
*/
	oNfServ:Line(nLin-8,aCol[1],nLin-8,aCol[7])
	oNfServ:Line(nLin-9,aCol[1],nLin-9,aCol[7])
	oNfServ:Say(nLin+5,aCol2[7]-45 ,"R$ "+Transform(nTotal    ,"@E 999,999,999.99"))
	

	oNfServ:Say(nLin+5,aCol2[1],"TOTAL")
	
	oNfServ:Line(nLin+10,aCol[1],nLin+10,aCol[7])
	
	oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
	
	nLin += 20
/*
	oNfServ:Fillrect( {nLin-10,aCol[1],nLin-10 + (nTamLine*6), aCol[6]-150 }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[1]+100  ,"RESUMO SERVIÇOS PRESTADOS",,CLR_WHITE)
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 35, aCol[6]-150)
	oNfServ:Line(nLin+nSpRow,aCol[3]+80,nLin + 35,aCol[3]+80)
	
	oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)
	
	oNfServ:Box(nLin+nSpRow,aCol[6]-142,nLin  + 35 ,aCol[7])
	oNfServ:Line(nLin+nSpRow,aCol[6]-80,nLin + 35 ,aCol[6]-80)
	oNfServ:Line(nLin+nSpRow,aCol[6]-60,nLin  + 35 ,aCol[6]-60)
	oNfServ:Line(nLin+nSpRow,aCol[6]+10,   nLin  + 35 ,aCol[6]+10)
	oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)
	
	If SQLSE1->F2_SERIE == "NFC" .And. SQLSE1->F2_ESPECIE # "RPS"
		oNfServ:Say(nLin+11,aCol[1]+5,"TRIBUTADO ICMS")
		oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
		oNfServ:Say(nLin+11,aCol[3]+90,Transform(nTotalBase,"@E 999,999,999.99"))
	Else
		oNfServ:Say(nLin+11,aCol[1]+5,"TOTAL DA FATURA")
		oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
		oNfServ:Say(nLin+11,aCol[3]+90,Transform(nTotal,"@E 999,999,999.99"))
	End If
	
	oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
	oNfServ:Fillrect( {nLin-10,aCol[6]-142,nLin-10 + (nTamLine*6), aCol[7] }, oBrush0, "-2")
	oNfServ:Say(nLin,aCol[5]-40  ,"BASE CÁLCULO" + Space(16) + "ICMS",,CLR_WHITE)
	If Alltrim(SQLSE1->F2_SERIE) # "R"
		oNfServ:Say(nLin+10,aCol[5]-40 , Transform(nTotalBase,"@E 999,999,999.99") + Space(10) + Transform(nTotalIcm,"@E 999,999,999.99"))
	End If
	
	nLin += 35
	
	oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)
	//RRP - 30/10/2014 - Tratamento para as mensagens inclusão da variavel nLin2.
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 40, aCol[7])
	nLin2:= nLin+10
	oNfServ:Say(nLin2,aCol[1]+5  ,"DADOS ADICIONAIS" )
	nLin2+=10
	If SQLSE1->F2_SERIE == "NFC"
		oNfServ:Say(nLin2,aCol[1]+30  ,"FUST (1,00%)/FUNTTEL (0,50%) não repassadas aos serviços" )
		nLin2+=7
	End If
	If !Empty(Alltrim(SQLSE1->C5_MENNOTA))
		oNfServ:Say(nLin2,aCol[1]+30  ,Alltrim(SQLSE1->C5_MENNOTA))
		nLin2+=7
	EndIf
	oNfServ:Say(nLin2,aCol[1]+30  ,"Por favor, observe que em caso de inadimplemento poderá haver a cobrança de multas e juros ou outras medidas cabíveis.") //RRP - 22/10/2014 - Inclusão da Msg. Chamado 022118
	nLin2+=7
	If SQLSE1->F2_SERIE == "NFC"
		oNfServ:Say(nLin2,aCol[1]+30  ,"Valor aproximado dos tributos 28,65%, conforme lei 12.741/2012.") //RRP - 30/10/2014 - Inclusão da Msg. Chamado 022292.
	EndIf	
	//oNfServ:Say(nLin+31,aCol[1]+30  ,IIF(SQLSE1->C5_MENNOT1#"NIL",SQLSF2->C5_MENNOT1,"")) //RRP - 16/12/2013 - Campo C5_MENNOT1 não existe em nossa base. 
	
	//nLin += 45 
	//MSM - 26/11/2014 - Chamado:022777
	nLin:=nLin2+5
	
	oNfServ:Box(nLin+nSpRow,aCol[1],nLin + 35, aCol[7])
	
	If Alltrim(SQLSE1->F2_SERIE) # "R"
		oNfServ:Say(nLin+10,aCol[1]+5  ,"RESERVADO AO FISCO")
		cHashCode := RetMD5()
		oNfServ:Say(nLin+20,aCol[1]+30  ,UPPER( SUBSTR(cHashCode,1,4) + "." + SUBSTR(cHashCode,5,4) + "." + SUBSTR(cHashCode,9,4) + "." + SUBSTR(cHashCode,13,4) + "." + ;
		SUBSTR(cHashCode,17,4) + "." + SUBSTR(cHashCode,21,4) + "." + SUBSTR(cHashCode,25,4) + "." + SUBSTR(cHashCode,29,4) ) )
	End If
		
	nLin += 40
*/	
	oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)
//	oNfServ:Say(nLin,aCol[1]+5 ,"LEGENDA")
	
	If  SuperGetMv( "OR_XGERBOL" , .F. , .T. , Nil )
		if !KBLTCITI(cNatureza)
			Return
		endif
		//SQLSE1->(DbCloseArea())
	End If
	
	
	oNfServ:EndPage()  

	oNfServ:Print()
	
	cNFAnt		:= SQLSE1->E1_NUM
	//cNumCtr		:= SQLSE1->C5_XNUMCTR
	cSerAnt		:= SQLSE1->E1_SERIE
	cClienteAnt	:= SQLSE1->E1_CLIENTE
	cLojaAnt	:= SQLSE1->E1_LOJA
	cPara		:= SQLSE1->A1_EMAIL
	dEmissao	:= SQLSE1->E1_EMISSAO
	cTexto2		+= Alltrim(cNFAnt) + "<BR>" //+ " - Número de controle " + Alltrim(cNumCtr) + "<BR>"
	
	//RRP - 07/02/2014 - Ajuste para anexar o arquivo.
	//AADD(aFiles,{"nfserv_" + alltrim(SQLSF2->F2_CLIENTE) + alltrim(SQLSF2->F2_DOC) + alltrim(SQLSF2->F2_SERIE) })
	AADD(aFiles,{"nfserv_"  + alltrim(SQLSE1->E1_CLIENTE)+alltrim(SQLSE1->E1_NUM) + alltrim(SQLSE1->E1_SERIE)})
	
	SQLSE1->(DbSkip())
	
	If SQLSE1->E1_NUM <> cNFAnt .Or. SQLSE1->E1_SERIE <> cSerAnt
		lSaltaBol := .F.
		lSalta	  := .T.
		nLinhas   := 0
	End If
		
	If SQLSE1->E1_CLIENTE <> cClienteAnt .Or. SQLSE1->E1_LOJA <> cLojaAnt
		
		If mv_par10 == 2
			SEndMail(cPara,cAssunto,cTexto,cTexto2,cDirMail,aFiles)
			If !lRetMail
				MsgStop("Erro ao enviar email ref. NF.: " + cNFAnt)
				lRetMail := .T.
			End If
		End If
		aFiles := {}
		lSaltaBol := .F.
		lSalta	  := .T.
		nLinhas   := 0
		
	End If
	
End

SQLSE1->(DbCloseArea())


If mv_par10 == 2
	//Exclui os arquivos pre-existentes nos diretorios
	aFilesDel := Directory(cDirMail+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirMail+ aFilesDel[i][1])
	Next i
	aFilesDel := Directory(cDirGer+"*.*", "D")
	For i := 1 to len(aFilesDel)
		Ferase(cDirGer+ aFilesDel[i][1])
	Next i
End If

MsgInfo("Processo finalizado")

If mv_par10 == 2
	memowrite(cDirGer+"LogMail.txt",cLog)
	ShellExecute("open",cDirGer+"LogMail.txt","","",5)
End If

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ SEndMail  ³ Autor ³ Larson Zordan        ³ Data ³20/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envio de E-Mail                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Conta de E-mail                                     ³±±
±±³          ³ ExpC2: Assunto                                             ³±±
±±³          ³ ExpC3: Corpo de Texto                                      ³±±
±±³          ³ ExpC4: Diretorio Arquivos Anexos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico - .T. - Operacao realizada                          ³±±
±±³          ³        - .F. - Operacao NAO realizada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function SEndMail(cPara,cAssunto,cTexto,cTexto2,cDirMail,aFiles)

cAssunto := "Nota Fiscal Orange " + STRZERO(Month(STOD(dEmissao)),2)+"/"+STRZERO(Year(STOD(dEmissao)),4)

/*cTexto := "<p>Prezado Cliente,</p>"
cTexto += "<p>Informamos a emissão da(s) Nota(s) Fiscal(is):<br>"
cTexto += cTexto2+"</p>
cTexto += "<p>Em caso de dúvidas, favor entrar em contato com:</p>"
cTexto += "<p>Faturamento: faturamento.orange@orange.com"
cTexto += "<br>Cobrança:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;jaqueline.xavier@orange.com</p>"
cTexto += "<p>Para outras dúvidas e esclarecimentos por favor entre em contato com seu Account Manager na Orange."
cTexto += "<br>Este e-mail foi enviado automaticamente.</p>"
cTexto += "<p>&nbsp</p>"
cTexto += "<p>Atenciosamente,</p>"
cTexto += "<p>Orange Business Services</p>"
cTexto += "<img src='http://www.orange.com/extension/orange/design/orangecom/images/logo_40px.png'>"
*/                                                              

cTexto := '<div>
cTexto += ' <img src="http://www.grantthornton.com.br/orange_business.jpg" width="124" height="50" class="CToWUd">
cTexto += '<p style="font-family:Helvetica 65 Medium;">Prezado Cliente,</p>
cTexto += '<p style="font-family:Helvetica 65 Medium; max-width: 450px;">
cTexto += 'Levamos ao seu conhecimento que procedemos a emissão do(s) 
cTexto += 'documento(s) fiscal(is) conforme anexo(s).
cTexto += '</p>
cTexto += '<p style="font-family:Helvetica 65 Medium;max-width: 450px;">
cTexto += 'Aproveitamos para informar que o(s) boleto(s) para pagamento(s) 
cTexto += 'também encontra(m)-se anexo(s) e pedimos a gentileza de atentar 
cTexto += 'para a data de vencimento.
cTexto += '</p>
cTexto += '<p style="font-family:Helvetica 65 Medium; max-width: 450px;">
cTexto += 'Agradecemos e colocamo-nos à disposição para esclarecimentos 
cTexto += 'adicionais, através dos endereços eletrônicos mencionados abaixo: 
cTexto += '</p>
cTexto += '<p style="font-family:Helvetica 65 Medium; max-width: 450px;">Faturas: <a href="mailto:faturamento.orange@orange.com"><font color = "#FF6600">faturamento.orange@orange.com</font> </a>  </p>
cTexto += '<p style="font-family:Helvetica 65 Medium; max-width: 450px;">Pagamento: <a href="mailto:contas.receber@orange.com"> <font color = "#FF6600">contas.receber@orange.com</font> </a> </p>
cTexto += '<p style="font-family:Helvetica 65 Medium; max-width: 450px;">Orange Business Services </p>
cTexto += '<hr align="left" width="450" size="1" color=DarkSlateGray>
cTexto += '<p style="max-width: 450px;"><font color = "#2F4F4F" style="font-family:Helvetica 65 Medium;">
cTexto += 'Este é um email automático enviado pela HLB BRASIL a serviço 
cTexto += 'da Orange Business Services Brasil. Por favor não responda. 
cTexto += '</font>
cTexto += '</p>

cTexto += '</div>

if "TESTE" $ GetEnvServer()
	cPara	:= UsrRetMail ( __cUserID ) //email do usuário logado
endif

If lRetMail
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := '<orange.faturamento@orange.com>'+cMailFrom
	oMessage:cTo      := alltrim(cPara) 
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cTexto
	oMessage:MsgBodyType( "text/html" )
	
	For i := 1 to len(aFiles)	
		CpyT2S( cDirGer + aFiles[i][1] + ".pdf", cDirMail, .F. )
	Next i
	
	For i := 1 to Len(aFiles)
		oMessage:AttachFile ( cDirMail + aFiles[i][1] + ".pdf" )
	Next i
	
	Processa( {|| nErro := oMessage:Send( oMail ) }, "Aguarde...", "Processando envio de emails...",.F.)
           
	If nErro <> 0
		xError := oMail:GetErrorString(nErro)
		MsgAlert("Erro de Envio SMTP "+str(nErro,4)+" ("+xError+")","AKRON")
		lRetMail := .F.
	Else
		cLog += "Email enviado para " + Alltrim(cPara) + " ref. NF " + Replace(cTexto2,"<BR>"," - NF ") + CRLF
	Endif
	
	oMail:SMTPDisconnect()           
EndIf

Return(lRetMail)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BLTCITI  ³ Autor ³ Totvs                 ³ Data ³ 24/08/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ IMPRESSAO DO BOLETO CITIBANK COM CODIGO DE BARRAS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GERAL                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function KBLTCITI(cNatureza)
Local lRet:=.F.
Private lEnd     := .F.


Processa({|lEnd|lRet:=MontaRel(cNatureza)})

Return lRet

Static Function MontaRel(cNatureza)

Local cAlphabt := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local _nParcela
Local nX := 0
Local cNroDoc :=  " "
Local aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
								Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
								Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local aBolText := { MV_PAR19,MV_PAR20,MV_PAR21 }					   
Local nI           := 1
Local aCB_RN_NN    := {}

PRIVATE nVlrAbat   := 0

//RRP - 24/06/2014 - Preenchendo os dados do banco no título caso esteja em branco 
DbSelectArea("SE1")
SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1")+SQLSE1->E1_PREFIXO+SQLSE1->E1_NUM+SQLSE1->E1_PARCELA+SQLSE1->E1_TIPO))
	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO)
		DbSelectArea("SA6")
		DbSetOrder(1)
		IF DbSeek(xFilial("SA6") + cPortGrv + cAgeGrv + cContaGrv)
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnLock()
		EndIf
	EndIf
else
	alert("Erro na geração do boleto"+CRLF)
	Return(.F.)
EndIf         

//TLM 20140122 -  Ajuste do E1_PREFIXO de acordo com parametro MV_1DUPREF
//cQueryBol := "SELECT TOP 1 * FROM " + RetSqlName("SE1") + " WHERE E1_NUM = '" + SQLSF2->F2_DOC + "' AND E1_PREFIXO = '" + SQLSF2->F2_SERIE + "' AND "
//cQueryBol := "SELECT TOP 1 * FROM " + RetSqlName("SE1") + " WHERE E1_NUM = '" + SQLSE1->F2_DOC + "' AND E1_PREFIXO = '" + SQLSF2->F2_FILIAL+Alltrim(Substr(Alltrim(SQLSF2->F2_SERIE),1,1))  + "' AND "
//cQueryBol += " E1_CLIENTE = '" + SQLSF2->F2_CLIENTE + "' AND E1_LOJA = '" + SQLSF2->F2_LOJA + "' AND E1_SALDO > 0 AND E1_VENCREA >= '" + DTOS(mv_par15) + "' AND E1_VENCREA <= '" + DTOS(mv_par16) + "'"
//cQueryBol += " AND D_E_L_E_T_ = ''"

//DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryBol),"SQLSE1",.T.,.T.)

//While SQLSE1->(!EOF()) 
    
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	
	aDadosBanco  := {"745",; 																     // [1]Numero do Banco
				     SA6->A6_NREDUZ,;  																  // [2]Nome do Banco
	                 "0001",; // [3]Agência
                    SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10),; 	     // [4]Conta Corrente
                    ""  ,;    	  // [5]Dígito da conta corrente
                    "100"}																		   	  // [6]Codigo da Carteira 

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SQLSE1->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SQLSE1->A1_COD )+" - "+SQLSE1->A1_LOJA           ,;      	// [2]Código
		AllTrim(SQLSE1->A1_END )+" - "+AllTrim(SQLSE1->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SQLSE1->A1_MUN )                            ,;  			// [4]Cidade
		SQLSE1->A1_EST                                      ,;     		// [5]Estado
		SQLSE1->A1_CEP                                      ,;      	// [6]CEP
		SQLSE1->A1_CGC										          ,;  			// [7]CGC
		SQLSE1->A1_PESSOA										}       				// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SQLSE1->A1_NOME)            	 ,;   	// [1]Razão Social
		AllTrim(SQLSE1->A1_COD )+" - "+SQLSE1->A1_LOJA              ,;   	// [2]Código
		AllTrim(SQLSE1->A1_ENDCOB)+" - "+AllTrim(SQLSE1->A1_BAIRROC),;   	// [3]Endereço
		AllTrim(SQLSE1->A1_MUNC)	                             ,;   	// [4]Cidade
		SQLSE1->A1_ESTC	                                     ,;   	// [5]Estado
		SQLSE1->A1_CEPC                                        ,;   	// [6]CEP
		SQLSE1->A1_CGC												 		 ,;		// [7]CGC
		SQLSE1->A1_PESSOA												 }				// [8]PESSOA
	Endif
	
	nVlrAbat   :=  SomaAbat(SQLSE1->E1_PREFIXO,SQLSE1->E1_NUM,SQLSE1->E1_PARCELA,"R",1,,SQLSE1->E1_CLIENTE,SQLSE1->E1_LOJA)

	//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 

	If AllTrim(SQLSE1->E1_PARCELA) $ cAlphabt
		_nParcela := at(AllTrim(SQLSE1->E1_PARCELA),cAlphabt)
	Else
		_nParcela := val(AllTrim(SQLSE1->E1_PARCELA))
	EndIf

	//JSS - Alterado para solucionar o caso 022316
	//Inicio Alteração...
		//cNroDoc	:= Strzero(Val(Alltrim(SQLSE1->E1_NUM)),9)+StrZERO(_nParcela,2)               
		//cDigNNum:=KCALCDp(ALLTRIM(cNroDoc),"1")     
		//cNroDoc	:=cNroDoc+""+cDigNNum   
	If Empty(SQLSE1->E1_NUMBCO)
		DbSelectArea("SEE")
		SEE->(DbSetOrder(1))
		SEE->(DbGoTop())
		//EE_FILIAL + EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
		if SEE->(DbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]))
			RecLock("SEE",.F.)
				cNroDoc			:= AllTrim (SEE->EE_FAXATU)
				SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
			MsUnLock()
		
			DbSelectArea("SE1")
			SE1->(RecLock("SE1",.f.))
				SE1->E1_NUMBCO 	:=	cNroDoc  
			SE1->(MsUnlock())
		endif
	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	//Fim Alteração.
	
	//Monta codigo de barras
	aCB_RN_NN    := Ret_cBarra( SQLSE1->E1_PREFIXO	,SQLSE1->E1_NUM	,SQLSE1->E1_PARCELA	,SQLSE1->E1_TIPO	,;
						       Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[4] ,aDadosBanco[5]	,;
						       cNroDoc		,(SQLSE1->E1_VALOR-nVlrAbat)	, "18"	,"9"	)
	aDadosTit	:= {AllTrim(SQLSE1->E1_NUM)+AllTrim(SQLSE1->E1_PARCELA)		,;  // [1] Número do título
						SQLSE1->E1_EMISSAO                              	,;  // [2] Data da emissão do título
						dDataBase                    					,;  // [3] Data da emissão do boleto
						SQLSE1->E1_VENCTO                               	,;  // [4] Data do vencimento
						(SQLSE1->E1_SALDO - nVlrAbat)                  	,;  // [5] Valor do título
						cNroDoc                             ,; //aCB_RN_NN[3],;  // [6] Nosso número (Ver fórmula para calculo)
						SQLSE1->E1_PREFIXO                               	,;  // [7] Prefixo da NF
						SQLSE1->E1_TIPO	                           		}   // [8] Tipo do Titulo

	nDataBase 	:= CtoD("07/10/1997") // data base para calculo do fator
	nFatorVen	:= STOD(SQLSE1->E1_VENCTO) - nDataBase // acha a diferenca em dias para o fator de vencimento
			
	Impress(oNfServ,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNatureza)
	nX := nX + 1

//	SQLSE1->(dbSkip())
	nI++
	
//EndDo

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress | Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO COM CODIGO DE BARRAS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga Protheus                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oNfServ,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNatureza)

Local nI := 0
Local nTamLinBol := 17
nLin += 20

// TLM 20140122 - Tratametno de impressão de boleto na primeita pagina   
If nPagina == 1 .And. nLinhas < 30
	If lSaltaBol
		oNfServ:EndPage()
		oNfServ:StartPage()
		KIMPCAB(cNatureza)
		nLin += 40
	else
		if nLin<555
			nLin:=580
		endif
	End If  
// TLM 20140122 - Caso tenha mais de uma página imprimi o boleto em um página nova na próxima.	
Else
	oNfServ:EndPage()
	oNfServ:StartPage()
	nLin := 25 
EndIf

oNfServ:SetFontEX(5,cFonte,.F.,.T.,.F.)
oNfServ:SayBitmap(nLin-5,aCol[1]+2,"tesoura.bmp",10,7.5)
oNfServ:Say(nLin,aCol[2]-5,Replicate("-",210))
oNfServ:SetFontEX(7,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin-5,aCol[6]-20,"AUTENTICAÇÃO MECÂNICA")
oNfServ:SetFontEX(8,cFonte,.F.,.T.,.F.)

nLin += 12

nTamBol := 178

oNfServ:Box(nLin,aCol[1],nLin+nTamBol,aCol[7])
oNfServ:SayBitmap(nLin+1,aCol[1]+3,"logo_citibank.bmp",70,20)
oNfServ:Line(nLin,aCol[1]+100,nLin+nTamLinBol+8,aCol[1]+100) //"linha vertical"
oNfServ:SetFontEX(12,cFonte,.F.,.T.,.F.)
oNfServ:Say(nLin+20,aCol[1]+105,aDadosBanco[1]+"-5") //"Numero do Banco"
oNfServ:Line(nLin,aCol[1]+150,nLin+nTamLinBol+8,aCol[1]+150) //"linha vertical"
oNfServ:Say(nLin+20,aCol[1]+155,aCB_RN_NN[2]) //"Linha Digitavel do Codigo de Barras"

nLin+=25
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VENCIMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,alltrim(DTOC(STOD(SQLSE1->E1_VENCTO))))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1]+5,"LOCAL DE PAGAMENTO")
oNfServ:Line(nLin,aCol[6]-50,nLin+(nTamLinBol*9)-5,aCol[6]-50) //"linha vertical grande"
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],alltrim(mv_par11))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"AGENCIA / CODIGO DO CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+aDadosBanco[5]))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],"EQUANT DO BRASIL LTDA")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"NOSSO NÚMERO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,Alltrim(aDadosTit[6]))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"DATA DO DOCUMENTO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol*2),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"N. DO DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,alltrim(aDadosTit[7])+aDadosTit[1])
oNfServ:Line(nLin,aCol[2]+130,nLin+nTamLinBol,aCol[2]+130) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-40,"ESPÈCIE DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-40,"DM")
oNfServ:Line(nLin,aCol[4]-55,nLin+(nTamLinBol),aCol[4]-55) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-50,"ACEITE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[4]-50,"N")
oNfServ:Line(nLin,aCol[3]+120,nLin+(nTamLinBol*2),aCol[3]+120) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[5]-75,"DATA PROCESSAMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[5]-75,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4))
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[1],alltrim(DTOC(STOD(SQLSE1->E1_VENCREA))))

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"VALOR DO DOCUMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"USO DO BANCO")
oNfServ:Line(nLin,aCol[1]+70,nLin+(nTamLinBol),aCol[1]+70) //"linha vertical"
oNfServ:Say(nLin+6,aCol[2]+60,"CARTEIRA")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[2]+60,aDadosBanco[6])
oNfServ:Line(nLin,aCol[2]+100,nLin+nTamLinBol,aCol[2]+100) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[3]-70,"ESPÉCIE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[3]-70,"R$")
oNfServ:Line(nLin,aCol[3]-18,nLin+nTamLinBol,aCol[3]-18) //"linha vertical"
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[4]-112,"QUANTIDADE")

oNfServ:Say(nLin+6,aCol[5]-75,"VALOR")

nLin+=nTamLinBol
oNfServ:Line(nLin,aCol[1],nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) DESCONTOS / ABATIMENTO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(nVlrAbat,"@E 999,999,999.99")))
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[1],"INSTRUCOES (TEXTO DE RESPONSABILIDADE DO CEDENTE")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+20,aCol[1],alltrim(mv_par12))
oNfServ:Say(nLin+30,aCol[1],alltrim(mv_par13))

nLin += nTamLinBol
//Linhas Verticais (direita)
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(-) OUTRAS DEDUÇÕES")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) MORA / MULTA")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(+) OUTROS ACRÉSCIMOS")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+6,aCol[6]-46,"(=) VALOR COBRADO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin+15,aCol[6]-46,AllTrim(Transform(0,"@E 999,999,999.99")))
nLin += nTamLinBol
oNfServ:Line(nLin,aCol[6]-50,nLin,aCol[7])

nLin += nTamLinBol
oNfServ:Box(nLin-51,aCol[1],nLin-17,aCol[6]-50)
oNfServ:SetFontEX(6,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin-45,aCol[1],"SACADO")
oNfServ:SetFontEX(8,cFonte,.F.,.F.,.F.)
oNfServ:Say(nLin-35,aCol[1],aDatSacado[1] + " - CPF/CNPJ: " + IIF(Len(aDatSacado[7])==11,Transform(aDatSacado[7],"@R 999.999.999-99"),Transform(aDatSacado[7],"@R 99.999.999/9999-99")) )
oNfServ:Say(nLin-27,aCol[1],aDatSacado[3] + aDatSacado[4] + " - " + aDatSacado[5] + " - " + aDatSacado[6])


If nPagina == 1 .And. nLinhas < 30
	If lSaltaBol
		oNfServ:FWMSBAR("INT25" /*cTypeBar*/,35/*nRow*/ ,1/*nCol*/,aCB_RN_NN[1]/*cCode*/,oNfServ/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	Else
		oNfServ:FWMSBAR("INT25" /*cTypeBar*/,63.8/*nRow*/ ,1/*nCol*/,aCB_RN_NN[1]/*cCode*/,oNfServ/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	End If
Else
	oNfServ:FWMSBAR("INT25" /*cTypeBar*/,17/*nRow*/ ,1/*nCol*/,aCB_RN_NN[1]/*cCode*/,oNfServ/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.8/*nHeigth*/,.F./*lBanner*/,cFonte/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
EndIf   

oNfServ:Say(nLin,aCol[5]+50,"FICHA DE COMPENSAÇÃO")

DbSelectArea("SE1")
DbGoTo(SQLSE1->R_E_C_N_O_)
RecLock("SE1",.f.)
   SE1->E1_NUMBCO 	:=	aDadosTit[6] //aCB_RN_NN[3]  // Nosso número (Ver fórmula para calculo)
   //SE1->E1_PORTADO := "745" //RRP - 24/06/2014 - Tratamento efetuado na linha 512
   SE1->E1_HIST := "BOLETO CITIBANK GERADO"
MsUnlock()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra| Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO COM CODIGO DE BARRAS                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga Protheus                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
						cBanco		,cAgencia	,cConta		,cDacCC	,;
						cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local cDigNosso	:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra	:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}

cAgencia:=STRZERO(Val(cAgencia),4)
cCart := "18"		
cNosso := ""
       
cNosso:= cNroDoc
nNum  := cNroDoc

If nValor > 0
	cFatorValor  := Kfator1347()+Strzero(nValor*100,10)
Else
	cFatorValor  := Kfator1347()+strzero(SQLSE1->E1_VALOR*100,10)
EndIf

cConvenio := ALLTRIM(SA6->A6_NUMBCO) 

DO CASE 
  CASE LEN(ALLTRIM(cConvenio)) == 6
     cCampoL := cConvenio+alltrim(NNUM)+"21"
  CASE LEN(ALLTRIM(cConvenio)) == 7
     cCampoL := "000000"+alltrim(NNUM)+cCart   
ENDCASE
  
cLivre := cBanco+cMoeda+cFatorValor+"3"+"100"+SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),2,10)+nNum 

// campo do codigo de barra
cDigBarra := KCALCDp(alltrim(cLivre),"2" )

cBarra    := Substr(cLivre,1,4)+cDigBarra+cFatorValor+Substr(cLivre,19,25)
//MSGALERT(cBarra,"Codigo de Barras")

// composicao da linha digitavel
cParte1  := cBanco+cMoeda+"3"+"100"+"0"
cDig1    := KDIGIT0347( cParte1,1 )
//cParte2  := "49229"+"01"+"1"+SUBSTR(nNum,1,2 ) 
cParte2  := SUBSTR(STRZERO(VAL(SA6->A6_NUMCON),10),3,10)+SUBSTR(nNum,1,2) 
cDig2    := KDIGIT0347( cParte2,2 )
cParte3  := SUBSTR(nNum,3,10 )
cDig3    := KDIGIT0347( cParte3,2 )
cParte4  := cDigBarra 
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+" "+;                                              
			cParte5
//MSGALERT(cDigital,"Linha Digitavel")

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)		

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALCdiE   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do Citibank                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALCdiE(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT0347 ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Citibank                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function KDIGIT0347(cVariavel,nOp)

Local aMultiplic := {}  // Resultado das Multiplicacoes de cada algarismo
Local _cRet      := " "
Local aBaseNum   := {}
Local cDigVer    := 0 
Local nB         := 0  
Local nC         := 0 
Local nSum       := 0 
Local _cNossoNum := ""
Local _cCalcdig  := ""
cbase  := cVariavel 
IF nOp == 1 
  aBaseNum   := { 2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
ELSE
  aBaseNum   := { 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
ENDIF

For nB := 1 To Len(cbase)
		
		nMultiplic := Val(Subs(cbase,nB,1) ) * aBaseNum[nB]
		Aadd(aMultiplic,StrZero(nMultiplic,2) )
		
next nB
For nC := 1 To Len(aMultiplic)
		nAlgarism1 := Val(Subs(aMultiplic[nC],1,1) )
		nAlgarism2 := Val(Subs(aMultiplic[nC],2,1) )
		nSum       := nSum + nAlgarism1 + nAlgarism2
Next nC

cDigVer := 10 - Mod(nSum,10)

IF cDigVer == 10 
   cDigVer := 0 
Endif

Return(str(cDigVer,1,0))

Static function KFator1347()
If Len(ALLTRIM(SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4))) = 4
	cData := SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,4)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
Else
	cData := "20"+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),7,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),4,2)+SUBSTR(DTOC(STOD(SQLSE1->E1_VENCTO)),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |CALCDp    ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Citibank                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function KCALCDp(cVariavel,_cRegra)
Local Auxi := 0, sumdig := 0
Local aBasecalc := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2}
Local aBaseNNum := {4,3,2,9,8,7,6,5,4,3,2}
Local nMult     := 0
Local nD        := 0      
Local nE        := 0      
Local aMult     := {}
Local nDigbar   := 0
Local nSoma     := 0
cbase  := cVariavel

If _cRegra == "1"  
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBaseNNum[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Else
For nD := 1 To Len(cbase)
		nMult := Val(Subs(cbase,nD,1) ) * aBasecalc[nD]
		Aadd(aMult,StrZero(nMult,2) )
next nD          
Endif
	
nSoma := 0 
nAlgarism1 := 0 
nAlgarism2 := 0 
For nE := 1 To Len(aMult)                         
    	nAlgarism1 := Val(aMult[nE])
		nSoma      := nSoma + nAlgarism1 // + nAlgarism2
Next nC
nDigbar := 11 - Mod(nSoma,11)

IF nDigbar == 0  .or. nDigbar == 1 .or. nDigbar == 10 .or. nDigbar == 11   
   nDigbar := 1 
Endif
  
Return(str(nDigbar,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |KImpCab   ºAutor  ³Andre Minelli       º Data ³  27/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para impressao do cabecalho do relatorio             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFSERV                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function KImpCab(cNatureza)

Local nTamLine 	:= 2
Local nSpRow	:= 2
Local nSalta	:= 12
Local nMgLine	:= 9
Local nSpCol	:= 4
Local cDescFat	:= ""
Local cFont2	:= "Arial"
Local aColCab	:= {10,52,181,287,311,361,414,450}
//Local aColCab	:= {44,52,181,287,311,361,414,450}
//oFontTe:= TFont():New('Arial',,15.5,.T.)

nPagina++

If lSalta
	nLin := 25
End If

nVlrAbat   :=  SomaAbat(SQLSE1->E1_PREFIXO,SQLSE1->E1_NUM,SQLSE1->E1_PARCELA,"R",1,,SQLSE1->E1_CLIENTE,SQLSE1->E1_LOJA)

oNfServ:SetFontEX(6,cFont2,.F.,.T.,.F.)
oNfServ:Say(10,aCol[4]+240,"Pagina " + StrZero(nPagina,2))
oNfServ:SayBitmap(nLin-10,aColCab[2],"logo_orange.bmp",173,77)
oNfServ:SetFontEX(15.5,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin+20,aColCab[4],SM0->M0_NOMECOM,,,RGB(255,102,000))
oNfServ:SetFontEX(6,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin+32,aColCab[4],PADR("CNPJ: " + SM0->M0_CGC  ,40)  			 )
oNfServ:Say(nLin+45,aColCab[4],PADR("INSCR. ESTADUAL:  " + SM0->M0_INSC ,35)  )
oNfServ:Say(nLin+55,aColCab[4],PADR("INSCR. MUNICIPAL: " + SM0->M0_INSCM,35)  )

oNfServ:Say(nLin+32,aColCab[8], alltrim(SM0->M0_ENDCOB))
oNfServ:Say(nLin+45,aColCab[8], alltrim(SM0->M0_BAIRCOB) + " CEP: " + alltrim(SM0->M0_CEPCOB))
oNfServ:Say(nLin+55,aColCab[8], alltrim(SM0->M0_CIDCOB)  + ", " + alltrim(SM0->M0_ESTCOB))

oNfServ:SetFontEX(9,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin+65,aColCab[4],PADR("FONE: " + SM0->M0_TEL,35),,,RGB(255,102,000))

nLin+=16
oNfServ:SetFontEX(14,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin+75,aColCab[4],PADR("Vencimento",10) ,,,RGB(255,102,000))
oNfServ:Say(nLin+75,aColCab[8],alltrim("Valor à Pagar"),,,RGB(255,102,000))

cValPag:=AllTrim(Transform(SQLSE1->E1_SALDO - nVlrAbat,"@E 999,999,999,999.99"))

//nAumTam:=IIF(len(cValPag)>12,len(cValPag)-12,0)
nAumTam:=IIF(len(cValPag)>8,len(cValPag)-8,0)
//oNfServ:Box(nLin+79,aCol[3]-2,nLin+93,aCol[3]+69)
//oNfServ:Box(nLin+79,aCol[3]+135,nLin+93,aCol[3]+229)

//Retangulo no vencimento
/*
oNfServ:Line(nLin+79,aColCab[4]-2,nLin+79,aColCab[4]+69,RGB(255,102,000))  //Linha cima
oNfServ:Line(nLin+107,aColCab[4]-2,nLin+107,aColCab[4]+69,RGB(255,102,000))  //Linha baixo
oNfServ:Line(nLin+79,aColCab[4]-2,nLin+107,aColCab[4]-2,RGB(255,102,000))  //Linha esquerda
oNfServ:Line(nLin+79,aColCab[4]+69,nLin+107,aColCab[4]+69,RGB(255,102,000))  //Linha direita
*/
oNfServ:SetFontEX(18,cFont2,.F.,.T.,.F.)

oNfServ:Line(nLin+79,aColCab[4]-2,nLin+79,aColCab[4]+85,RGB(255,102,000))  //Linha cima
oNfServ:Line(nLin+107,aColCab[4]-2,nLin+107,aColCab[4]+85,RGB(255,102,000))  //Linha baixo
oNfServ:Line(nLin+79,aColCab[4]-2,nLin+107,aColCab[4]-2,RGB(255,102,000))  //Linha esquerda
oNfServ:Line(nLin+79,aColCab[4]+85,nLin+107,aColCab[4]+85,RGB(255,102,000))  //Linha direita

//Retangulo no Valor à pagar
/*
oNfServ:Line(nLin+79,aColCab[4]+135,nLin+79,aColCab[4]+229+(nAumTam*6),RGB(255,102,000))  //Linha cima
oNfServ:Line(nLin+93,aColCab[4]+135,nLin+93,aColCab[4]+229+(nAumTam*6),RGB(255,102,000))  //Linha baixo
oNfServ:Line(nLin+79,aColCab[4]+135,nLin+93,aColCab[4]+135,RGB(255,102,000))  //Linha esquerda
oNfServ:Line(nLin+79,aColCab[4]+229+(nAumTam*6),nLin+93,aColCab[4]+229+(nAumTam*6),RGB(255,102,000))  //Linha direita
*/
/*
oNfServ:Line(nLin+79,aColCab[8]-2,nLin+79,aColCab[8]+69,RGB(255,102,000))  //Linha cima
oNfServ:Line(nLin+107,aColCab[8]-2,nLin+107,aColCab[8]+69,RGB(255,102,000))  //Linha baixo
oNfServ:Line(nLin+79,aColCab[8]-2,nLin+107,aColCab[8]-2,RGB(255,102,000))  //Linha esquerda
oNfServ:Line(nLin+79,aColCab[8]+69+(nAumTam*6),nLin+107,aColCab[8]+69+(nAumTam*6),RGB(255,102,000))  //Linha direita
*/
oNfServ:Line(nLin+79,aColCab[8]-2,nLin+79,aColCab[8]+85+(nAumTam*7),RGB(255,102,000))  //Linha cima
oNfServ:Line(nLin+107,aColCab[8]-2,nLin+107,aColCab[8]+85+(nAumTam*7),RGB(255,102,000))  //Linha baixo
oNfServ:Line(nLin+79,aColCab[8]-2,nLin+107,aColCab[8]-2,RGB(255,102,000))  //Linha esquerda
oNfServ:Line(nLin+79,aColCab[8]+85+(nAumTam*7),nLin+107,aColCab[8]+85+(nAumTam*7),RGB(255,102,000))  //Linha direita

//oNfServ:Say(nLin+90,aColCab[4]+3,PADR(DTOC(STOD(SQLSE1->E1_VENCTO)),10) + space(11) + space((13+nAumTam)-len(cValPag)) + cValPag,,,RGB(255,102,000))
oNfServ:Say(nLin+98,aColCab[4]+6,PADR(DTOC(STOD(SQLSE1->E1_VENCTO)),10) ,,,RGB(255,102,000))
oNfServ:Say(nLin+98,aColCab[8]+((22+nAumTam)-len(cValPag)),cValPag ,,,RGB(255,102,000))

nLin += nSalta*9 + 33

oNfServ:SetFontEX(15.5,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin,aColCab[3]-10,"CONTA RESUMO DE FATURAMENTO")

nLin += nSalta*3
nLin += 5
/*
If SQLSE1->E1_PREFIXO == "FTE"
	cDescFat:="TELECOMUNICAÇÃO"
Else
	cDescFat:="RECIBO PROVISÓRIO DE SERVIÇOS - RPS"
Endif
*/

cDescFat:="TELECOMUNICAÇÃO"

oNfServ:SetFontEX(11.5,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin,aColCab[1],"TIPO DE FATURA: " + cDescFat,,,RGB(255,102,000))
oNfServ:Say(nLin+10,aColCab[1],"FATURA Nº: " + SQLSE1->E1_PREFIXO+SQLSE1->E1_NUM ,,,RGB(255,102,000))
oNfServ:Say(nLin+20,aColCab[1],"DATA DE EMISSÃO: " + DTOC(STOD(SQLSE1->E1_EMISSAO)),,,RGB(255,102,000))

//oNfServ:Say(nLin,aCol[4],"DATA DE EMISSÃO BOLETO:" + " " + DTOC(STOD(SQLSE1->E1_EMISSAO)))

nLin += nSalta+30
nLin += nSalta

oNfServ:SetFontEX(15.5,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin,aColCab[1],"CLIENTE:" + " " + SUBSTR(UPPER(SQLSE1->A1_NOME),1,24))
//oNfServ:Line(nLin-nMgLine,aCol[4]-nSpCol,nLin+(nTamLine*13),aCol[4]-nSpCol)
//nLin += nSalta
oNfServ:SetFontEX(9,cFont2,.F.,.T.,.F.)
oNfServ:Say(nLin,aColCab[5],"ENDEREÇO:" + " " + UPPER(SQLSE1->A1_END))
nLin += nSalta
oNfServ:Say(nLin,aColCab[1],"CNPJ:" + " " + Transform(SQLSE1->A1_CGC,"@R 99.999.999/9999-99"))
oNfServ:Say(nLin,aColCab[5],"BAIRRO:" + " " + SUBSTR(UPPER(SQLSE1->A1_BAIRRO),1,15))
oNfServ:Say(nLin,aColCab[7],"CEP:" + " " + Transform(SQLSE1->A1_CEP,"@R 99999-999"))
nLin += nSalta
oNfServ:Say(nLin,aColCab[1],"I.E.:" + " " + SQLSE1->A1_INSCR)
//oNfServ:Say(nLin,aCol[3],"BAN:" + " "  + SQLSE1->A1_CODORA)
//oNfServ:Say(nLin,aCol[4],"CEP:" + " " + Transform(SQLSE1->A1_CEP,"@R 99999-999"))
oNfServ:Say(nLin,aColCab[5],"CIDADE" + " " + SUBSTR(SQLSE1->A1_MUN,1,15))
oNfServ:Say(nLin,aColCab[7],"ESTADO" + " " + UPPER(SQLSE1->A1_EST))
nLin += nSalta
oNfServ:Say(nLin,aColCab[1],"CONTROLE INTERNO:",,,RGB(255,102,000))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |KIMPFORM  ºAutor  ³Andre Minelli       º Data ³  27/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para impressao do formulario de impressao            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFSERV                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function KIMPFORM()

Local nTamLine 	:= 15
Local nSpRow	:= 15
Local nSalta	:= 12
Local nMgLine	:= 9
Local nSpCol	:= 4
Local lLastPag	:= .F.

// TLM 20140122 - Tratametno de impressão de boleto na primeita pagina               
If nPagina == 1 .And. nLinhas < 30
	If lSaltaBol
		nTamBox := 435
		lSaltaBol := .F.
	Else
		nTamBox 	:= 215
		lLastPag	:= .T.
	End If
// TLM 20140122 - Caso tenha mais d9e uma página imprimi o boleto em um página nova na próxima.
Else   
	nTamBox := 435
	lSaltaBol := .F.
EndIf

If lSalta
	nLin := 210
End If

oNfServ:Fillrect( {nLin-10,aCol[1],nLin-10 + (nTamLine+10), aCol[7] }, oBrush0, "-2")
oNfServ:Line(nLin-10,aCol[1],nLin-10,aCol[7])
oNfServ:Line(nLin+nSpRow,aCol[1],nLin+nSpRow,aCol[7])

oNfServ:SetFontEX(12,"Arial",.F.,.T.,.F.)

oNfServ:Say(nLin,aCol2[1],"Nº da ",,,CLR_WHITE)
oNfServ:Say(nLin+10,aCol2[1],"NF",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[2]-15,"Data",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[3]-7,"BAN",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[4],"Série",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[5],"Unidade",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[6],"CNPJ",,,CLR_WHITE)
oNfServ:Say(nLin+5,aCol2[7],"Valor",,,CLR_WHITE)
/*
oNfServ:Say(nLin-2,aCol[3]+80,"Notas",,,CLR_WHITE)

oNfServ:Fillrect( {nLin+nSpRow,aCol[1],nLin + (nTamLine*6), aCol[7] }, oBrush1, "-2")
oNfServ:Line(nLin+nSpRow,aCol[1],nLin + nTamBox,aCol[1])
oNfServ:Line(nLin+nSpRow,aCol[7],nLin + nTamBox,aCol[7])
oNfServ:Line(nLin+nSpRow,aCol[1],nLin+nSpRow,aCol[7])
oNfServ:Line(nLin + nTamBox,aCol[1],nLin + nTamBox,aCol[7])

oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)

oNfServ:Say(nLin+10,aCol[1]+15,"Número da NF")
oNfServ:Say(nLin+10,aCol[2]+130,"Unidade")
oNfServ:Say(nLin+10,aCol[4]+49,"CNPJ")
oNfServ:Say(nLin+10,aCol[6]-10,"Total da Nota")
*/
/*
oNfServ:SetFontEX(9,cFonte,.F.,.T.,.F.)

oNfServ:Line(nLin+nSpRow,aCol[2]+50,nLin + nTamBox,aCol[2]+50)
oNfServ:Line(nLin+nSpRow,aCol[3]+80,nLin + nTamBox,aCol[3]+80)
oNfServ:Line(nLin+nSpRow,aCol[6]-55,nLin + nTamBox,aCol[6]-55)
*/

//oNfServ:Fillrect( {nLin-10,aCol[6]-142,nLin-10 + (nTamLine*6), aCol[7] }, oBrush0, "-2")
//oNfServ:Say(nLin,aCol[5]-15,"DEMONSTRATIVO DE CARGA TRIBUTÁRIA",,CLR_WHITE)

//oNfServ:Fillrect( {nLin+nSpRow,aCol[6]-142,nLin + (nTamLine*6), aCol[7] }, oBrush1, "-2")
//oNfServ:Line(nLin+nSpRow,aCol[6]-142,nLin + nTamBox,aCol[6]-142)
//oNfServ:Line(nLin+nSpRow,aCol[7],nLin + nTamBox,aCol[7])
//oNfServ:Line(nLin+nSpRow,aCol[6]-142,nLin+nSpRow,aCol[7])
//oNfServ:Line(nLin + nTamBox,aCol[6]-142,nLin + nTamBox,aCol[7])

//oNfServ:SetFontEX(6,cFonte,.F.,.T.,.F.)

//oNfServ:Say(nLin+10,aCol[6]-135, "BASE CÁLCULO")
//oNfServ:Say(nLin+10,aCol[6]-70,"%")
//oNfServ:Say(nLin+10,aCol[6]-35,"ICMS")
//oNfServ:Say(nLin+10,aCol[6]+18,"LEG TRIBUTÁRIA")

//oNfServ:Line(nLin+nSpRow,aCol[6]-80,nLin + nTamBox,aCol[6]-80)
//oNfServ:Line(nLin+nSpRow,aCol[6]-55,nLin + nTamBox,aCol[6]-55)
//oNfServ:Line(nLin+nSpRow,aCol[6]+10,nLin + nTamBox,aCol[6]+10)

nLinhaAtu := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |SaltaPag  ºAutor  ³Andre Minelli       º Data ³  27/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para salto de pagina na impressao dos itens          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³NFSERV                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SaltaPag(cNatureza)

lSalta := .T.

oNfServ:EndPage()
oNfServ:StartPage()

//Inicia Impressao do cabecalho e formulario da segunda pagina
KImpCab(cNatureza)
KImpForm()
//Finaliza impressao
lSaltaBol := .F.

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |AtuX1     ºAutor  ³Andre Minelli       º Data ³  02/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para atualizacao do arquivo de perguntas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ NFSERV                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuX1(cPerg)                            

U_PUTSX1(cPerg, "01", "Da Emissao",        "Da Emissao",        	"Da Emissao",        "mv_ch01","D",10,0,1,"G","","",   "","","mv_par01","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "02", "Ate Emissao",       "Ate Emissao",       	"Ate Emissao",       "mv_ch02","D",10,0,1,"G","","",   "","","mv_par02","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "03", "Do Cliente",        "Do Cliente",        	"Do Cliente",        "mv_ch03","C",9,0,1, "G","","SA1"	,"","","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "04", "Ate Cliente",       "Ate Cliente",       	"Ate Cliente",       "mv_ch04","C",9,0,1, "G","","SA1"	,"","","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "05", "Da Loja",           "Da Loja",           	"Da Loja",    	   	 "mv_ch05","C",2,0,1, "G","","","",	"","mv_par03","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "06", "Ate Loja",          "Ate Loja",           	"Ate Loja",          "mv_ch06","C",2,0,1, "G","","","",	"","mv_par04","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "07", "Do Titulo",         "Do Titulo",          	"Do Titulo",         "mv_ch07","C",12,0,1,"G","","",   "","","mv_par07","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "08", "Ate Titulo",        "Ate Titulo",         	"Ate Titulo",        "mv_ch08","C",12,0,1,"G","","",   "","","mv_par08","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "09", "Especie?"	,		 "Especie?",			"Especie?",			 "mv_ch09","N",1, 0,1,"C","","",   "","","mv_par09","RPS","RPS","RPS","","Telecomunicação","Telecomunicação","Telecomunicação","Aluguel","Aluguel","Aluguel","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "10", "Envia por E-mail ?","Envia por E-mail ?",	"Envia por E-mail ?","mv_ch10","N",1, 0,1,"C","","",   "","","mv_par10","Nao","Nao","Nao","","Sim","Sim","Sim","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "11", "Local de Pagamento","Local de Pagamento",	"Local de Pagamento","mv_ch11","C",60,0,1,"G","","",   "","","mv_par11","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "12", "Instrucao 1",       "Instrucao 1",       	"Instrucao 1",       "mv_ch12","C",60,0,1,"G","","",   "","","mv_par12","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "13", "Instrucao 2",       "Instrucao 2",       	"Instrucao 2",       "mv_ch13","C",60,0,1,"G","","",   "","","mv_par13","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "14", "Drive de Impressao","Drive de Impressao",	"Drive de Impressao","mv_ch14","C",2,0,1, "G","","",   "","","mv_par14","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "15", "Do Vecnto",         "Do Vecnto",         	"Do Vecnto",         "mv_ch15","D",10,0,1,"G","","",   "","","mv_par15","","","","","","","","","","","","","","","","",{},{},{},"")
U_PUTSX1(cPerg, "16", "Ate Vecnto",        "Ate Vecnto",        	"Ate Vecnto",        "mv_ch16","D",10,0,1,"G","","",   "","","mv_par16","","","","","","","","","","","","","","","","",{},{},{},"")

Return
