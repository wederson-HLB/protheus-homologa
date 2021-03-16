#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP65
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar relatório com os títulos vencidos com e sem seus contratos e sócios relacionados
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 12/04/2013    10:28
Módulo      : Financeiro
*/

/*
Funcao      : GTCORP65()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012
*/
*----------------------------*
User Function GTCORP65()
*----------------------------*
Local aAllGroup	:= FWAllGrpCompany() //Empresas
Local nLinha	:= 01	//linha inicial para apresentação do checkbox
Local nCol		:= 01	//Coluna inicial para apresentação do checkbox

Local lMacTd	:= .F.
Local oMacTd

Private dDataDe := AvCtoD("  /  /  ")
Private dDataAte:= AvCtoD("  /  /  ")
Private nStaTit	:= 3
                                  
    DEFINE DIALOG oDlg TITLE "Parâmetros" FROM 180,180 TO 550,700 PIXEL
        
		@ 02,03 CHECKBOX oMacTd VAR lMacTd PROMPT "Marca todos" SIZE 50, 10	OF oDlg PIXEL;
		ON CLICK(MarcTodo(aAllGroup,lMacTd))
		@ 02,80 SAY UPPER("Selecione a(s) empresa(s):") SIZE 100,10 OF oDlg PIXEL
		
		// Scroll da parte superior
		oScr1 := TScrollBox():New(oDlg,11,01,92,260,.T.,.T.,.T.)

		// Cria painel 
		@ 000,000 MSPANEL oPanel OF oScr1 SIZE 400,len(aAllGroup)*10 COLOR CLR_HRED


			for i:=1 to len(aAllGroup)
			
				cVar:="lCheck"+aAllGroup[i]
				cObj:="oCheck"+aAllGroup[i]
			
				&(cVar)	:= .F.                       //nome da empresa
				&(cObj)	:= TCheckBox():New(nLinha,nCol,aAllGroup[i]+" - "+FWGrpName(aAllGroup[i]),,oPanel,100,210,,,,,,,,.T.,,,)
		
				// Seta Eventos do Check
				&(cObj):bSetGet := &("{|| "+&("cVar")+"}")
				//&(cObj):bLClicked := {|| &(&("cVar")):=!&(cVar) }
				&(cObj):bLClicked := &("{|| "+&("cVar")+":= !"+&("cVar")+"}")
				nLinha+=10
                
				//tratamento para dividir as empresas em 2 colunas
				if i == INT(len(aAllGroup)/2)
					nLinha	:=01
					nCol	:=150
				endif

	        next
         
        // Usando o método Create                //82
		oScr2 := TScrollBox():Create(oDlg,109,01,72,260,.T.,.T.,.T.)
        
		aItems:= {'Sim','Nao'}
		cCombo:= aItems[1]

		@ 07,05 SAY "Exibe ND?" SIZE 100,10 OF oScr2 PIXEL

		oCombo:= TComboBox():Create(oScr2,{|u|if(PCount()>0,cCombo:=u,cCombo)},05,40,aItems,100,20,,,,,,.T.,,,,,,,,,'cCombo')

 
		// MSM - 13/08/2015 - Chamado: 028429
		oGrp2 := TGroup():New( 18,005,54,125,"Status dos títulos:",oScr2,CLR_BLACK,CLR_WHITE,.T.,.F. )
		// Variavel numerica que guarda o item selecionado do Radio
		nStaTit := 3
		// Cria o Objeto
		oRadio := TRadMenu():New(26,11,{'Em Aberto','Baixados','Ambos'},,oScr2,,,,,,,,100,100,,,,.T.)
		// Seta Eventos
		oRadio:bchange := {|| iif(nStaTit==1,(oGet1:Disable(),oGet2:Disable(),dDataDe:=CTOD("//"),oGet1:Refresh(),dDataAte:=CTOD("//"),oGet2:Refresh()) , (oGet1:Enable(),oGet2:Enable()) )}
		oRadio:bSetGet := {|u|Iif (PCount()==0,nStaTit,nStaTit:=u)}
		oRadio:bWhen := {|| .T. }
		
		oGrp4 := TGroup():New( 18,129,54,249,"Data da Baixa:",oScr2,CLR_BLACK,CLR_WHITE,.T.,.F. )
		
		oSay1 := TSay():New( 28,135,{||"De:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
		oGet1 := TGet():New( 26,160,{|u| If(PCount()>0,dDataDe:=u,dDataDe)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","","dDataDe",)
		
		oSay2 := TSay():New( 42,135,{||"Ate:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
		oGet2 := TGet():New( 40,160,{|u| If(PCount()>0,dDataAte:=u,dDataAte)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","","dDataAte",)
        

		
		oTButton1 := TButton():New( 60, 110, "Gerar",oScr2,{||Precarre(aAllGroup,cCombo,oDlg)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    ACTIVATE DIALOG oDlg CENTERED 



/*
Local oExcel := FWMSEXCEL():New()

Private cPerg   	:="GTCORP65_P"
Private aEmps		:={}

conout("Entrou na GTCORP65")

	//Definição das perguntas.
	PutSx1( cPerg, "01", "Empresa(s)?"		, "Empresa(s)?"		, "Empresa(s)?"		, "", "N",1 ,00,00,"C","" , "","","","MV_PAR01","Auditores - ZB","","","","Corporate - ZF","","","Ambas")
	PutSx1( cPerg, "02", "Exibe ND?"		, "Exibe ND?"		, "Exibe ND?"		, "", "N",1 ,00,00,"C","" , "","","","MV_PAR02","Sim","","","","Não")
	
	If !Pergunte(cPerg,.T.)
		Return()
	EndIf
	
	if MV_PAR01=1
		aEmps:={"ZB"}
	elseif MV_PAR01=2
		aEmps:={"ZF"}	
	elseif MV_PAR01=3
		aEmps:={"ZB","ZF"}
	else
		return()
	endif

	For i:=1 to len(aEmps)
		//chama a barra de processamento
		CarrBar(aEmps[i],@oExcel,MV_PAR02)
	Next

oExcel:SetBgColorHeader("#AA92C7") //Define a cor de preenchimento do estilo do Cabeçalho

oExcel:SetLineBgColor("#C2C2DC")//Define a cor de preenchimento do estilo da Linha

oExcel:Set2LineBgColor("#E6E6FA") //Define a cor de preenchimento do estilo da Linha 2

oExcel:Activate()

//Chama a função para abrir o excel
GExecl(oExcel)
*/
Return

Static Function Precarre(aAllGroup,cCombo,oDlg)
Local oExcel	:= FWMSEXCEL():New()
Local cOpc		:= ""
Local cEmp		:= ""

	if alltrim(UPPER(cCombo))='SIM'
		cOpc:="1"
	elseif alltrim(UPPER(cCombo))='NAO'
		cOpc:="2"
	endif

	For i:=1 to len(aAllGroup)
	
		cVar:="lCheck"+aAllGroup[i]
		if &(cVar)
			cEmp:=aAllGroup[i]
		else
			loop	
		endif

		//chama a barra de processamento
		CarrBar(cEmp,@oExcel,cOpc)

		//Se estiver desativado
		if oExcel:lActivate<>NIL .AND. !oExcel:lActivate
			exit
		endif
		
	Next

	//Verifico se a planilha está ativa
	if oExcel:lActivate==NIL .OR. oExcel:lActivate
		oExcel:SetBgColorHeader("#AA92C7") //Define a cor de preenchimento do estilo do Cabeçalho
		
		oExcel:SetLineBgColor("#C2C2DC")//Define a cor de preenchimento do estilo da Linha
		
		oExcel:Set2LineBgColor("#E6E6FA") //Define a cor de preenchimento do estilo da Linha 2
		
		oExcel:Activate()
		
		//Chama a função para abrir o excel
		GExecl(oExcel)
		
		oDlg:End()
	
	endif

Return


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02
Retorno     : 
Objetivos   : Função para criar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 11/04/2013	17:17
*/

*---------------------------------------------*
Static Function CarrBar(cEmp,oExcel,MV_PAR02)
*---------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter := 0

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(CarrPlan(cEmp,oExcel,MV_PAR02,oDlg1,oMeter))
	  
	//*************************************
	
	
Return


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02,oDlg1,oMeter
Retorno     : 
Objetivos   : Função preencher o objeto com as informações da planilha
Autor       : Matheus Massarotto
Data/Hora   : 11/04/2013	17:17
*/
*---------------------------------------------------------*
Static Function CarrPlan(cEmp,oExcel,MV_PAR02,oDlg1,oMeter)
*---------------------------------------------------------*
Local aArea 	:= GetArea()
Local cQry1 	:= ""
Local cNomeEmp 	:= ""
Local nCurrent	:= 0
Local nAumenta	:= 0
Local cMot		:= ""

DEFAULT cEmp:=""

DbSelectArea("SM0")
SM0->(DbSetOrder(1))
if DbSeek(cEmp)
	cNomeEmp:=SM0->M0_CODIGO+"-"+capital(SM0->M0_NOME)
else
	Return()
endif

	//Validação de Campo Customizado    
	cQry1 :=" select name as NAME from syscolumns where id = object_id('CN9"+cEmp+"0') and name in ('CN9_P_NOME','CN9_P_NUM','CN9_P_GER')
	If select("TRBTEMP")>0
		TRBTEMP->(DbCloseArea())
	Endif
	DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQry1),"TRBTEMP",.F.,.F.)
	aColsSQL := {}	
	TRBTEMP->(DbGoTop())
	While TRBTEMP->(!EOF())
		aAdd(aColsSQL,TRBTEMP->NAME)
		TRBTEMP->(DbSkip())
	EndDo
     

	If AllTrim(cEmp) $ "ZB|ZF|ZG"
	
		//MSM - 13/04/2016 -  Tratamento para retornar o Z42 de acordo com SX2 da empresa - Chamado: 032117
		cTabAlc:="Z42"+cEmp+"0
		
		//AOA - 22/08/2016 - Verifica se o dicionário está aberto e fecha antes de continuar.
		If Select("SX2TPM") > 0
			SX2TPM->(DbCloseArea())
		EndIf  
		
		OpenSxs(,,,,cEmp,"SX2TPM","SX2",,.F.)
		If Select("SX2TPM") > 0
            SX2TPM->(DbSetOrder(1))
            if SX2TPM->(DbSeek("Z42"))
	            cTabAlc:= SX2TPM->X2_ARQUIVO
			endif	  	
		    
		EndIf

		//Montagem da Query para empresas de Auditoria
		//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
		cQry1 :=" SELECT '"+cEmp+"' AS 'EMPRESA',CN9_FILIAL AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,CN9_CLIENT AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR_REAL'"+CRLF
		cQry1 +=" ,ROUND( (E1_SALDO - E1_DECRESC) * (E1_VLCRUZ/E1_VALOR),2) AS 'SALDO_REAL'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND( ((E1_VLCRUZ* (E1_SALDO-E1_DECRESC) )/E1_VALOR) - (CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,CN9_NUMERO AS 'CONTRATO'"+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CASE WHEN Z55.Z55_NUM IS NULL THEN CN9.CN9_P_NUM ELSE Z55.Z55_NUM END AS 'PROPOSTA'"+CRLF
		Else
			cQry1 +=" ,'' AS 'PROPOSTA'"+CRLF
		EndIf
		cQry1 +=" ,CASE WHEN Z42.Z42_NOMEFU IS NULL THEN SA3.A3_NOME ELSE Z42.Z42_NOMEFU END AS 'SOCIO'"+CRLF
		cQry1 +=" ,SE1.E1_VENCREA"+CRLF
		cQry1 +=" ,SE1.E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,SE1.E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,SE1.E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,SE1.E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,SE1.E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,SF2.F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,Z55.Z55_NOMEGE AS 'GERENT'"+CRLF//RRP - 14/04/2015 - Inclusão do gerente do projeto. Chamado 025231.
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM CN9"+cEmp+"0 AS CN9"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_MDCONTR=CN9.CN9_NUMERO AND SC5.C5_FILIAL=CN9.CN9_FILIAL"+CRLF
		cQry1 +=" JOIN SE1"+cEmp+"0 AS SE1 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN Z55"+cEmp+"0 AS Z55 ON Z55.Z55_NUM = CN9.CN9_P_NUM AND Z55.Z55_FILIAL = CN9.CN9_FILIAL AND Z55.Z55_STATUS = 'E' AND Z55.D_E_L_E_T_ <> '*'"+CRLF
		cQry1 +=" LEFT JOIN "+cTabAlc+" AS Z42 ON Z42.Z42_CPF = Z55.Z55_SOCIO AND Z42.D_E_L_E_T_ <> '*'"+CRLF
		//cQry1 +=" LEFT JOIN SA1"+cEmp+"0 AS SA1 ON SA1.A1_COD=CN9.CN9_CLIENT"+CRLF 
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=CN9.CN9_CLIENT AND SA1.A1_LOJA=CN9.CN9_LOJACL "+CRLF 
		cQry1 +=" LEFT JOIN SA3"+cEmp+"0 AS SA3 "+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ON CN9.CN9_P_GER=SA3.A3_COD"+CRLF
		Else
			cQry1 +=" ON ''=SA3.A3_COD"+CRLF
		EndIf
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF                                         
		cQry1 +=" WHERE SC5.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''"+CRLF
		//cQry1 +=" AND SE1.E1_VENCREA<CONVERT(VARCHAR(10),GETDATE(),112) "+CRLF
		
        // -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( E1_BAIXA >= '"+DtoS(dDataDe)+"' OR E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( E1_BAIXA <= '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND CN9.CN9_SITUAC<>'10'"+CRLF
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
		cQry1 +=" GROUP BY CN9_FILIAL,E1_PREFIXO,E1_NUM,CN9_CLIENT,E1_MOEDA,E1_VALOR,E1_SALDO,E1_DECRESC,E1_VLCRUZ/E1_VALOR,SA1.A1_NOME,SA1.A1_NREDUZ,SE1.E1_SITUACA,"+CRLF
		cQry1 +=" E1_VLCRUZ,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,E1_EMISSAO,E1_VENCREA,SE1.E1_VENCORI,CN9_NUMERO,Z55_NUM,Z42_NOMEFU,A3_NOME,SE1.E1_VENCREA,SC5.C5_NUM,SE1.E1_CCC,SE1.E1_CCD,SE1.E1_PORTADO,SE1.E1_AGEDEP,SE1.E1_CONTA,Z55_NOMEGE,SE1.E1_BAIXA,E1_PARCELA,E1_TIPO,E1_LOJA,SF2.F2_NFELETR"+CRLF 
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CN9_P_NUM"+CRLF
		EndIf
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ,CN9_P_GER"+CRLF
		EndIf
	
		cQry1 +=" UNION "+CRLF
	
		//--QUERY COM O FINANCEIRO DO TIPO NF QUE NÃO TEM CONTRATO
		cQry1 +=" SELECT '"+cEmp+"' AS 'EMPRESA',E1_FILORIG AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,E1_CLIENTE AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR R$'"+CRLF
		cQry1 +=" ,ROUND( (E1_SALDO - E1_DECRESC) *(E1_VLCRUZ/E1_VALOR),2) AS 'SALDO R$'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND((E1_VLCRUZ*(E1_SALDO-E1_DECRESC))/E1_VALOR -(CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF	
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,'' AS 'CONTRATO',ISNULL(Z55.Z55_NUM,'') AS 'PROPOSTA'"+CRLF
 	 	cQry1 +=" ,CASE
		cQry1 +=" 	WHEN Z42PRO.Z42_NOMEFU IS NOT NULL THEN Z42PRO.Z42_NOMEFU
		cQry1 +=" 	WHEN Z42CLI.Z42_NOMEFU IS NOT NULL THEN Z42CLI.Z42_NOMEFU
		cQry1 +=" 	ELSE ISNULL(SA3.A3_NOME,'')
		cQry1 +=" END AS 'SOCIO'
		cQry1 +=" ,E1_VENCREA"+CRLF
		cQry1 +=" ,E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,SA3.A3_NOME AS 'GERENT'"+CRLF//RRP - 14/04/2015 - Inclusão do gerente do projeto. Chamado 025231.
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM SE1"+cEmp+"0 SE1"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA "+CRLF
		cQry1 +=" LEFT JOIN Z55"+cEmp+"0 AS Z55 ON Z55.Z55_NUM = SC5.C5_P_NUM AND SC5.C5_FILIAL = Z55.Z55_FILIAL AND Z55.Z55_STATUS = 'E' AND Z55.D_E_L_E_T_ <> '*'
	 	cQry1 +=" LEFT JOIN "+cTabAlc+" AS Z42PRO ON Z42PRO.Z42_CPF = Z55.Z55_SOCIO AND Z42PRO.D_E_L_E_T_ <> '*'
 		cQry1 +=" LEFT JOIN "+cTabAlc+" AS Z42CLI ON Z42CLI.Z42_CPF = SA1.A1_P_SOCIO AND Z42CLI.D_E_L_E_T_ <> '*'
		cQry1 +=" LEFT JOIN SA3"+cEmp+"0 AS SA3 ON SA3.A3_COD = SA1.A1_P_VEND AND SA3.D_E_L_E_T_ <> '*'
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF
		cQry1 +=" WHERE SE1.D_E_L_E_T_='' AND SC5.D_E_L_E_T_='' AND E1_TIPO IN ('NF')"+CRLF
		//cQry1 +=" AND SE1.E1_VENCREA<CONVERT(VARCHAR(10),GETDATE(),112) "+CRLF

        // -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( E1_BAIXA >= '"+DtoS(dDataDe)+"' OR E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( E1_BAIXA <= '"+DtoS(dDataAte)+"' OR E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND C5_MDCONTR ='' "+CRLF
		
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
	
	    cQry1 +=" ORDER BY E1_VENCREA"
	//RRP - 03/11/2014 - Inclusão do tratamento para as empresas da Directa. Chamado 021596.
	ElseIf AllTrim(cEmp) $ 'MP|MQ|MW|MY|PN'
		//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
		cQry1 :=" SELECT '"+cEmp+"' AS 'EMPRESA',CN9_FILIAL AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,CN9_CLIENT AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR_REAL'"+CRLF
		cQry1 +=" ,ROUND((E1_SALDO-E1_DECRESC) *(E1_VLCRUZ/E1_VALOR),2) AS 'SALDO_REAL'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND((E1_VLCRUZ* (E1_SALDO-E1_DECRESC) )/E1_VALOR -(CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF	
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,CN9_NUMERO AS 'CONTRATO'"+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CN9_P_NUM AS 'PROPOSTA'"+CRLF
		Else
			cQry1 +=" ,'' AS 'PROPOSTA'"+CRLF
		EndIf
		cQry1 +=" ,ISNULL(SA3.A3_NOME,'') AS 'SOCIO'"+CRLF
		cQry1 +=" ,SE1.E1_VENCREA"+CRLF
		cQry1 +=" ,SE1.E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,SE1.E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,SE1.E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,SE1.E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,SE1.E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,SF2.F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF		
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM CN9"+cEmp+"0 AS CN9"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_MDCONTR=CN9.CN9_NUMERO AND SC5.C5_FILIAL=CN9.CN9_FILIAL"+CRLF
		cQry1 +=" JOIN SE1"+cEmp+"0 AS SE1 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=CN9.CN9_CLIENT AND SA1.A1_LOJA=CN9.CN9_LOJACL "+CRLF
		cQry1 +=" LEFT JOIN SA3"+cEmp+"0 AS SA3 "+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ON (CASE CN9.CN9_P_GER WHEN '' THEN SA1.A1_P_VEND ELSE CN9.CN9_P_GER END) = SA3.A3_COD "+CRLF
		Else
			cQry1 +=" ON ''=SA3.A3_COD "+CRLF
		EndIf  
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF                                       
		cQry1 +=" WHERE SC5.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''"+CRLF
		
        // -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND SE1.E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND SE1.E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND CN9.CN9_SITUAC<>'10'"+CRLF
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
		cQry1 +=" GROUP BY CN9_FILIAL,E1_PREFIXO,E1_NUM,CN9_CLIENT,E1_MOEDA,E1_VALOR,E1_SALDO,E1_DECRESC,E1_VLCRUZ/E1_VALOR,SA1.A1_NOME,SA1.A1_NREDUZ,SE1.E1_SITUACA,"+CRLF
		cQry1 +=" E1_VLCRUZ,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,E1_EMISSAO,E1_VENCREA,SE1.E1_VENCORI,CN9_NUMERO,A3_NOME,SE1.E1_VENCREA,SC5.C5_NUM,SE1.E1_CCC,SE1.E1_CCD,SE1.E1_PORTADO,SE1.E1_AGEDEP,SE1.E1_CONTA,SE1.E1_BAIXA,E1_PARCELA,E1_TIPO,E1_LOJA,SF2.F2_NFELETR"+CRLF 
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CN9_P_NUM"+CRLF
		EndIf
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ,CN9_P_GER"+CRLF
		EndIf
	
		cQry1 +=" UNION "+CRLF
	
		//--QUERY COM O FINANCEIRO DO TIPO NF QUE NÃO TEM CONTRATO COM SOCIO DO CADASTRO DE VENDEDOR
		cQry1 +=" SELECT '"+cEmp+"' AS 'EMPRESA',E1_FILORIG AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,E1_CLIENTE AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR R$'"+CRLF
		cQry1 +=" ,ROUND( (E1_SALDO - E1_DECRESC) *(E1_VLCRUZ/E1_VALOR),2) AS 'SALDO R$'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND((E1_VLCRUZ* (E1_SALDO-E1_DECRESC) )/E1_VALOR -(CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,'' AS 'CONTRATO','' AS 'PROPOSTA'"+CRLF
		cQry1 +=" ,ISNULL(SA3.A3_NOME,'') AS 'SOCIO'"+CRLF
		cQry1 +=" ,E1_VENCREA"+CRLF
		cQry1 +=" ,E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,SF2.F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM SE1"+cEmp+"0 SE1"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=CN9.CN9_LOJACL "+CRLF
		cQry1 +=" LEFT JOIN SA3"+cEmp+"0 AS SA3 ON SA3.A3_COD = SA1.A1_P_VEND AND SA3.D_E_L_E_T_ <> '*'
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF
		cQry1 +=" WHERE SE1.D_E_L_E_T_='' AND SC5.D_E_L_E_T_='' AND E1_TIPO IN ('NF')"+CRLF
        // -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND SE1.E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND SE1.E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND C5_MDCONTR ='' "+CRLF
		
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
	
	    cQry1 +=" ORDER BY E1_VENCREA"	
	
	
	Else
		//Montagem da Query para empresas que não são de Auditoria e Advisory 
		//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
		cQry1 :=" SELECT '"+cEmp+"' AS 'EMPRESA',CN9_FILIAL AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,CN9_CLIENT AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR_REAL'"+CRLF
		cQry1 +=" ,ROUND( (E1_SALDO-E1_DECRESC) *(E1_VLCRUZ/E1_VALOR),2) AS 'SALDO_REAL'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND((E1_VLCRUZ* (E1_SALDO-E1_DECRESC) )/E1_VALOR -(CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF	
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,CN9_NUMERO AS 'CONTRATO'"+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CN9_P_NUM AS 'PROPOSTA'"+CRLF
		Else
			cQry1 +=" ,'' AS 'PROPOSTA'"+CRLF
		EndIf
		cQry1 +=" ,ISNULL(SA3.A3_NOME,'') AS 'SOCIO'"+CRLF
		cQry1 +=" ,SE1.E1_VENCREA"+CRLF
		cQry1 +=" ,SE1.E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,SE1.E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,SE1.E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,SE1.E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,SE1.E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,SF2.F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM CN9"+cEmp+"0 AS CN9"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_MDCONTR=CN9.CN9_NUMERO AND SC5.C5_FILIAL=CN9.CN9_FILIAL"+CRLF
		cQry1 +=" JOIN SE1"+cEmp+"0 AS SE1 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN SA3"+cEmp+"0 AS SA3 "+CRLF
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ON CN9.CN9_P_GER=SA3.A3_COD"+CRLF
		Else
			cQry1 +=" ON ''=SA3.A3_COD"+CRLF
		EndIf
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF                                         
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=CN9.CN9_CLIENT AND SA1.A1_LOJA=CN9.CN9_LOJACL "+CRLF //AND SA1.A1_FILIAL=CN9.CN9_FILIAL "+CRLF
		cQry1 +=" WHERE SC5.D_E_L_E_T_='' AND CN9.D_E_L_E_T_='' AND SE1.D_E_L_E_T_='' AND ISNULL(SA3.D_E_L_E_T_,'')=''"+CRLF
	//	cQry1 +=" AND SE1.E1_VENCREA<CONVERT(VARCHAR(10),GETDATE(),112) "+CRLF
		
		// -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND SE1.E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND SE1.E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND CN9.CN9_SITUAC<>'10'"+CRLF
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
		cQry1 +=" GROUP BY CN9_FILIAL,E1_PREFIXO,E1_NUM,CN9_CLIENT,E1_MOEDA,E1_VALOR,E1_SALDO,E1_DECRESC,E1_VLCRUZ/E1_VALOR,SA1.A1_NOME,SA1.A1_NREDUZ,SE1.E1_SITUACA,"+CRLF
		cQry1 +=" E1_VLCRUZ,E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS,E1_IRRF,E1_EMISSAO,E1_VENCREA,SE1.E1_VENCORI,CN9_NUMERO,A3_NOME,SE1.E1_VENCREA,SC5.C5_NUM,SE1.E1_CCC,SE1.E1_CCD,SE1.E1_PORTADO,SE1.E1_AGEDEP,SE1.E1_CONTA,SE1.E1_BAIXA,E1_PARCELA,E1_TIPO,E1_LOJA,SF2.F2_NFELETR"+CRLF 
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_NUM"} ) <> 0
			cQry1 +=" ,CN9_P_NUM"+CRLF
		EndIf
		If aScan(aColsSQL, {|x| ALLTRIM(UPPER(x)) == "CN9_P_GER"} ) <> 0
			cQry1 +=" ,CN9_P_GER"+CRLF
		EndIf
	
		cQry1 +=" UNION "+CRLF
	
		//--QUERY COM O FINANCEIRO DO TIPO NF QUE NÃO TEM CONTRATO
		cQry1 +=" SELECT '"+cEmp+"' AS 'EMPRESA',E1_FILORIG AS 'FILIAL'"+CRLF
		cQry1 +=" ,E1_PREFIXO AS 'PREFIXO',E1_NUM AS 'TITULO'"+CRLF
		cQry1 +=" ,SC5.C5_NUM AS 'PED_VENDA'"+CRLF
		cQry1 +=" ,E1_CLIENTE AS 'COD_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NOME AS 'NOME_CLIENTE'"+CRLF
		cQry1 +=" ,SA1.A1_NREDUZ AS 'NOME_FANT'"+CRLF
		cQry1 +=" ,E1_MOEDA AS 'MOEDA'"+CRLF
		cQry1 +=" ,E1_VALOR AS 'VALOR'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_DECRESC ELSE 0 END AS 'SALDO'"+CRLF
		cQry1 +=" ,ROUND(E1_VLCRUZ/E1_VALOR,2) AS 'TAXA'"+CRLF
		cQry1 +=" ,E1_VLCRUZ AS 'VLR R$'"+CRLF
		cQry1 +=" ,ROUND( (E1_SALDO-E1_DECRESC) *(E1_VLCRUZ/E1_VALOR),2) AS 'SALDO R$'"+CRLF
		cQry1 +=" ,CASE WHEN E1_SALDO > 0 THEN ROUND((E1_VLCRUZ* (E1_SALDO-E1_DECRESC) )/E1_VALOR -(CASE WHEN E1_VALOR>=215.27 THEN E1_IRRF+E1_INSS+E1_PIS+E1_CSLL+E1_COFINS ELSE E1_IRRF END) ,2) ELSE 0 END AS 'SALDO_RE_LIQ'"+CRLF
		cQry1 +=" ,E1_VLCRUZ-ROUND(E1_SALDO*(E1_VLCRUZ/E1_VALOR),2) AS 'VLR_RECEBIDO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_EMISSAO, 103),103) AS 'EMISSAO'"+CRLF
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCREA, 103),103) AS 'VENCIMENTO_REAL'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCREA,getdate()) AS DIAS"+CRLF	
		cQry1 +=" ,CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_VENCORI, 103),103) AS 'VENC_ORIG'"+CRLF
		cQry1 +=" ,datediff(day,SE1.E1_VENCORI,getdate()) AS DIAS_ORIG"+CRLF	
		cQry1 +=" ,SE1.E1_SITUACA AS 'SITUACA'"+CRLF
		cQry1 +=" ,'' AS 'CONTRATO','' AS 'PROPOSTA'"+CRLF
		cQry1 +=" ,'' AS 'SOCIO'"+CRLF
		cQry1 +=" ,E1_VENCREA"+CRLF
		cQry1 +=" ,E1_CCC AS 'CCUSTOC'"+CRLF//RRP - 18/02/2015 - Inclusão do centro de custo
		cQry1 +=" ,E1_CCD AS 'CCUSTOD'"+CRLF
		cQry1 +=" ,E1_PORTADO AS 'BANCO'"+CRLF
		cQry1 +=" ,E1_AGEDEP AS 'AGENCIA'"+CRLF
		cQry1 +=" ,E1_CONTA AS 'CONTA'"+CRLF
		cQry1 +=" ,SF2.F2_NFELETR AS 'NFSE'"+CRLF
		cQry1 +=" ,CASE WHEN E1_BAIXA='' THEN '' ELSE CONVERT(VARCHAR(10),CONVERT(DateTime, SE1.E1_BAIXA, 103),103) END AS 'BAIXA'"+CRLF
		cQry1 +=" ,E1_PARCELA,E1_TIPO,E1_LOJA
		cQry1 +=" FROM SE1"+cEmp+"0 SE1"+CRLF
		cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SE1.E1_PEDIDO=SC5.C5_NUM AND SC5.C5_FILIAL=SE1.E1_FILORIG"+CRLF
		cQry1 +=" LEFT JOIN (Select * From SA1"+cEmp+"0 Where D_E_L_E_T_ <> '*') AS SA1 ON SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA "+CRLF
		cQry1 +=" LEFT JOIN SF2"+cEmp+"0 AS SF2 ON SF2.F2_FILIAL = SE1.E1_FILIAL AND SF2.F2_DUPL = SE1.E1_NUM AND SF2.F2_PREFIXO = SE1.E1_PREFIXO AND SF2.D_E_L_E_T_ <> '*'"+CRLF
		cQry1 +=" WHERE SE1.D_E_L_E_T_='' AND SC5.D_E_L_E_T_='' AND E1_TIPO IN ('NF')"+CRLF
	//  	cQry1 +=" AND SE1.E1_VENCREA<CONVERT(VARCHAR(10),GETDATE(),112) "+CRLF
		
		// -- MSM -- 24/08/2015 - Tratamento do status de título e data de venciemtno, Chamado: 028429 
		Do Case
			Case nStaTit==1 //em aberto
				cQry1 += " AND SE1.E1_SALDO > 0"
			Case nStaTit==2 //baixado
				cQry1 += " AND SE1.E1_SALDO = 0"
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"'"
				elseif !Empty(dDataDe)
					cQry1 += " AND SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"'"
				elseif !Empty(dDataAte)
					cQry1 += " AND SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"'"
				endif
			Case nStaTit==3 //ambos
				if !Empty(dDataDe) .and. !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataDe)
					cQry1 += " AND ( SE1.E1_BAIXA >= '"+DtoS(dDataDe)+"' OR SE1.E1_BAIXA='')"
				elseif !Empty(dDataAte)
					cQry1 += " AND ( SE1.E1_BAIXA <= '"+DtoS(dDataAte)+"' OR SE1.E1_BAIXA='')"
				endif
		EndCase		
		
		cQry1 +=" AND C5_MDCONTR ='' "+CRLF
		
		if MV_PAR02="2"
			cQry1 +=" AND SE1.E1_SERIE <>'ND' "+CRLF
	    endif
	
	    cQry1 +=" ORDER BY E1_VENCREA"
	EndIf	    

//executado através do menu
If tcsqlexec(cQry1)<0
	cError:=TCSQLError()

	Alert("Ocorreu um problema na busca das informações!!"+CRLF+;
	"Empresa: "+cNomeEmp+;
	CRLF+CRLF+ SUBSTR(cError,1,AT("THREAD ID",UPPER(cError))-1 ) )
	
	//Encerra a barra e o dialog da barra
	//oMeter:end()
	oDlg1:end()
	oExcel:DeActivate()
	return
EndIf

if select("TRBTEMP")>0
	TRBTEMP->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBTEMP",.T.,.T.)

oExcel:AddworkSheet(cNomeEmp)
oExcel:AddTable (cNomeEmp,"Títulos")
oExcel:AddColumn(cNomeEmp,"Títulos","Empresa",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Filial",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Prefixo",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Título",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Ped.Venda",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Cod.Cliente",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Nome Cliente",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Nome Fantasia",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Moeda",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Valor",1,3,.T.)
oExcel:AddColumn(cNomeEmp,"Títulos","Saldo",1,3,.T.)
oExcel:AddColumn(cNomeEmp,"Títulos","Taxa",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Valor R$",1,3,.T.)
oExcel:AddColumn(cNomeEmp,"Títulos","Valor Baixado R$",1,3,.T.) 
oExcel:AddColumn(cNomeEmp,"Títulos","Saldo R$",1,3,.T.) 
oExcel:AddColumn(cNomeEmp,"Títulos","Saldo Liq R$",1,3,.T.) 
oExcel:AddColumn(cNomeEmp,"Títulos","Emissão",1,4)
oExcel:AddColumn(cNomeEmp,"Títulos","Vencimento Real",1,4)
oExcel:AddColumn(cNomeEmp,"Títulos","Dias",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Vencimento Orig.",1,4)
oExcel:AddColumn(cNomeEmp,"Títulos","Dias Orig.",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Situação",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Contrato",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Proposta",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Sócio",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","C. Custo Créd.",1,1)//RRP - 18/02/2015 - Inclusão do centro de custo 
oExcel:AddColumn(cNomeEmp,"Títulos","C. Custo Déb.",1,1)
oExcel:AddColumn(cNomeEmp,"Títulos","Gerente Proj.",1,1) //RRP - 14/04/2015 - Inclusão do Gerente do Projeto Chamado 025231.
oExcel:AddColumn(cNomeEmp,"Títulos","Data Baixa",1,4)
oExcel:AddColumn(cNomeEmp,"Títulos","Motivo",1,4)
oExcel:AddColumn(cNomeEmp,"Títulos","Banco",1,4)  // GFP - 23/02/2017 - Inclusão do Banco
oExcel:AddColumn(cNomeEmp,"Títulos","Agencia",1,4)  // GFP - 23/02/2017 - Inclusão do Agencia
oExcel:AddColumn(cNomeEmp,"Títulos","Conta Corrente",1,4)  // GFP - 23/02/2017 - Inclusão do Conta
oExcel:AddColumn(cNomeEmp,"Títulos","Nota Fiscal de Serviços Eletronica",1,4)  // GFP - 15/03/2017 - Inclusão NFS-e

Count to nRecCount

//de quanto em quanto a regua deve aumentar
nAumenta:= 100/(nRecCount/100)

if nRecCount>0
	TRBTEMP->(DbGoTop())
	
	While TRBTEMP->(!EOF())
	
	    //Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=nAumenta // atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua

		cSituaca := ""
		Do Case
			Case TRBTEMP->SITUACA == "0"
				cSituaca := "Carteira"
			Case TRBTEMP->SITUACA == "1"
				cSituaca := "Cob.Simples"
			Case TRBTEMP->SITUACA == "2"
				cSituaca := "Descontada"
			Case TRBTEMP->SITUACA == "3"
				cSituaca := "Caucionada"
			Case TRBTEMP->SITUACA == "4"
				cSituaca := "Vinculada"
			Case TRBTEMP->SITUACA == "5"
				cSituaca := "Advogado"
			Case TRBTEMP->SITUACA == "6"
				cSituaca := "Judicial"
			Case TRBTEMP->SITUACA == "7"
				cSituaca := "Caucionada Descontada"
			//RRP - 03/12/2015 - Inclusão da nova situação. Chamado 030949
			Case TRBTEMP->SITUACA == "G"
				cSituaca := "PECLD"				
		EndCase
	    
	    cMot:= ""
	    
	    if !empty(TRBTEMP->BAIXA)
	    
	    	cQryBx:=" SELECT TOP 1 E5_MOTBX FROM SE5"+cEmp+"0 SE5
			cQryBx+=" WHERE SE5.D_E_L_E_T_='' AND 
			cQryBx+=" E5_FILORIG='"+TRBTEMP->FILIAL+"' AND E5_PREFIXO='"+TRBTEMP->PREFIXO+"' AND E5_NUMERO='"+TRBTEMP->TITULO+"' AND E5_PARCELA='"+TRBTEMP->E1_PARCELA+"' AND E5_TIPO='"+TRBTEMP->E1_TIPO+"' AND E5_DATA='"+ DTOS(CTOD(TRBTEMP->BAIXA)) +"' AND E5_CLIFOR='"+TRBTEMP->COD_CLIENTE+"' AND E5_LOJA='"+TRBTEMP->E1_LOJA+"'
			cQryBx+=" ORDER BY R_E_C_N_O_ DESC

			if select("TRBBX")>0
				TRBBX->(DbCloseArea())
			endif
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryBx),"TRBBX",.T.,.T.)	    	
	    	
	    	Count to nRecCount
	    	
	    	if nRecCount>0
	    		TRBBX->(DbGoTop())
		    	cMot:= alltrim(TRBBX->E5_MOTBX)
	    	endif

		endif

		oExcel:AddRow(cNomeEmp,"Títulos",{TRBTEMP->EMPRESA,TRBTEMP->FILIAL,TRBTEMP->PREFIXO,TRBTEMP->TITULO,;
		TRBTEMP->PED_VENDA,;
		TRBTEMP->COD_CLIENTE,;
		TRBTEMP->NOME_CLIENTE,;
		TRBTEMP->NOME_FANT,;
		TRBTEMP->MOEDA,;
		TRBTEMP->VALOR,;
		TRBTEMP->SALDO,;
		TRBTEMP->TAXA,;
		TRBTEMP->VLR_REAL,;
		TRBTEMP->VLR_RECEBIDO,;
		TRBTEMP->SALDO_REAL,;
		TRBTEMP->SALDO_RE_LIQ,;
		TRBTEMP->EMISSAO,;
		TRBTEMP->VENCIMENTO_REAL,;
		IIF( empty(TRBTEMP->BAIXA) .OR. TRBTEMP->SALDO>0 ,TRBTEMP->DIAS,0),;
		TRBTEMP->VENC_ORIG,;
		IIF( empty(TRBTEMP->BAIXA) .OR. TRBTEMP->SALDO>0 ,TRBTEMP->DIAS_ORIG,0),;
		cSituaca,;
		TRBTEMP->CONTRATO,;
		TRBTEMP->PROPOSTA,;
		TRBTEMP->SOCIO,;
		TRBTEMP->CCUSTOC,;//RRP - 18/02/2015 - Inclusão do centro de custo
		TRBTEMP->CCUSTOD,;
		IIF(AllTrim(cEmp) $ "ZB|ZF",TRBTEMP->GERENT,''),;//RRP - 14/04/2015 - Inclusão do Gerente do Projeto Chamado 025231.
		TRBTEMP->BAIXA,;
		cMot,;
		TRBTEMP->BANCO,;	// GFP - 23/02/2017 - Inclusão do Banco
		TRBTEMP->AGENCIA,;	// GFP - 23/02/2017 - Inclusão do Agencia
		TRBTEMP->CONTA,;	// GFP - 23/02/2017 - Inclusão do Conta
		TRBTEMP->NFSE})		// GFP - 15/03/2017 - Inclusão de Nota Fiscal de Serviços Eletronica

		TRBTEMP->(DbSkip())
	Enddo
endif

//Encerra o dialog da barra
oDlg1:end()

RestArea(aArea)
Return

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para abrir o excel
Autor       : Matheus Massarotto
Data/Hora   : 11/04/2013	17:17
*/
*------------------------------*
Static Function GExecl(oExcel)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	cArq := "Titulos_em_aberto_"+alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	oExcel:GetXMLFile(cDest+cArq) // Gera o arquivo em Excel
	
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel
	
/***********************GERANDO EXCEL************************************/          
    sleep(2000)
	FERASE (cDest+cArq)

Return

*----------------------------------------*
Static Function MarcTodo(aAllGroup,lMacTd)
*----------------------------------------*

for j:=1 to len(aAllGroup)
	&("lCheck"+aAllGroup[j]):=lMacTd
	&("oCheck"+aAllGroup[j]):Refresh()
next

Return