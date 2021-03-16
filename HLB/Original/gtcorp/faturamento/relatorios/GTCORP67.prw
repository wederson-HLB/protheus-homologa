#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP67
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar relatório com o faturamento mensal por cliente
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 02/05/2013    10:28
Módulo      : Faturamento
*/

/*
Funcao      : GTCORP67()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013
*/
*----------------------------*
User Function GTCORP67()
*----------------------------*
Local aAllGroup	:= {} // FWAllGrpCompany() //Empresas
Local nLinha	:= 01	//linha inicial para apresentação do checkbox
Local nCol		:= 01	//Coluna inicial para apresentação do checkbox

Local lMacTd	:= .F.
Local oMacTd

Private lTpRel	:= .F.
Private lIncRamo:= .F.     

/*
	* Leandro Brito - Carrega todas empresas que o usuario tem acesso
*/
AEval( FWEmpLoad() , { | x | If( Ascan( aAllGroup , x[ 1 ] ) == 0 , Aadd( aAllGroup , x[ 1 ] ) , ) } )  
                                  
    DEFINE DIALOG oDlg TITLE "Parâmetros" FROM 180,180 TO 590,700 PIXEL
        
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
		oScr2 := TScrollBox():Create(oDlg,109,01,92,260,.T.,.T.,.T.)

		aItems	:= {'Sim','Nao'}
		cCombo	:= aItems[1]
		cGet1	:= space(4)	
		cGet2	:= space(100)	

		//@ 07,05 SAY "Separar filial por aba?" SIZE 100,10 OF oScr2 PIXEL

		//oCombo:= TComboBox():Create(oScr2,{|u|if(PCount()>0,cCombo:=u,cCombo)},05,70,aItems,100,20,,,,,,.T.,,,,,,,,,'cCombo')

		//@ 25,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL
		
		//oGet1:= TGet():New(23,25,{|u| if(PCount()>0,nGet1:=u,nGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'nGet1')

		@ 07,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL
		
		oGet1:= TGet():New(05,35,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')
		
		@ 27,05 SAY "Salvar em? " SIZE 100,10 OF oScr2 PIXEL
		oGet2:= TGet():New(25,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
		oTButton2 := TButton():New( 25, 190, "...",oScr2,{||AbreArq(@cGet2,oGet2)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

		oGet2:Disable()
        //RRP - 17/07/2013 - Alteração para incluir a opção abaixo
		oGet3 := TCheckBox():New(47,05,'Gerar relatório detalhado',{|u| if(PCount()>0,lTpRel:=u,lTpRel)},oScr2,100,07,,,,,,,,.T.,,,)
		
        //MSM - 03/12/2014 - Alteração para incluir a opção abaixo
		oGet4 := TCheckBox():New(57,05,'Incluir ramo de atividade',{|u| if(PCount()>0,lIncRamo:=u,lIncRamo)},oScr2,100,07,,,,,,,,.T.,,,)
		
		oTButton1 := TButton():New( 75, 110, "Gerar",oScr2,{||Precarre(aAllGroup,cGet1,oDlg,cGet2)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    ACTIVATE DIALOG oDlg CENTERED 

Return

Static Function Precarre(aAllGroup,cAno,oDlg,cGet2)
Local oExcel
Local cOpc		:= ""
Local cEmp		:= ""
Local lRet		:= .T.

	if empty(cAno)
		Alert("Informe o ano para geração do relatório!")
		return
	endif
	
	if empty(cGet2)
		Alert("Informe o diretório onde os relatórios serão salvos!")
		return	
	endif


	For i:=1 to len(aAllGroup)
	
	oExcel	:= FWMSEXCEL():New()
	
		cVar:="lCheck"+aAllGroup[i]
		if &(cVar)
			cEmp:=aAllGroup[i]
		else
			loop	
		endif
        
			aFils:=FWAllFilial(,,aAllGroup[i])

            if len(aFils)>1
				For j:=1 to len(aFils)
					//chama a barra de processamento
					lRet:=CarrBar(cEmp,@oExcel,cAno,aFils[j])
					
					if !lRet
						exit
					endif
				Next
			else
				lRet:=CarrBar(cEmp,@oExcel,cAno)			
				if !lRet
					exit
				endif
			endif
	
			//Verifico se a planilha está ativa
		if oExcel:lActivate==NIL .OR. oExcel:lActivate
			oExcel:SetBgColorHeader("#AA92C7") //Define a cor de preenchimento do estilo do Cabeçalho
			
			oExcel:SetLineBgColor("#C2C2DC")//Define a cor de preenchimento do estilo da Linha
			
			oExcel:Set2LineBgColor("#E6E6FA") //Define a cor de preenchimento do estilo da Linha 2
			
			oExcel:Activate()
			
			//Chama a função para abrir o excel
			GExecl(oExcel,cEmp,cAno,cGet2)
			
		
		endif
		
	Next
	
	if lRet
		msginfo("Processo finalizado, verifique o local indicado nos parâmetros!")
		oDlg:End()
	endif
	
Return


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02
Retorno     : 
Objetivos   : Função para criar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:00
*/

*---------------------------------------------*
Static Function CarrBar(cEmp,oExcel,cAno,cFil)
*---------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=CarrPlan(cEmp,oExcel,cAno,oDlg1,oMeter,cFil))
	  
	//*************************************
	
	
Return(lRet)


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02,oDlg1,oMeter
Retorno     : 
Objetivos   : Função preencher o objeto com as informações da planilha
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:00
*/
*---------------------------------------------------------*
Static Function CarrPlan(cEmp,oExcel,cAno,oDlg1,oMeter,cFil)
*---------------------------------------------------------*
Local aArea 	:= GetArea()
Local cQry1 	:= ""
Local cNomeEmp 	:= ""
Local nCurrent	:= 0
Local nAumenta	:= 0
Local lRet		:= .T. 
Local aDadTemp:={}
Local lA1CC		:= SA1->(FieldPos("A1_CC_CUST"))>0 


DEFAULT cEmp:=""

DbSelectArea("SM0")
SM0->(DbSetOrder(1))
if DbSeek(cEmp)
	cNomeEmp:=SM0->M0_NOME
else
	Return()
endif

//RRP - 10/07/2013 - Geração do relatório detalhado
If lTpRel == .T. 
	AADD(aDadTemp,{"COD_CLIENT","C",TamSX3("F2_CLIENTE")[1],0})
	AADD(aDadTemp,{"FILIAL","C",TamSX3("F2_FILIAL")[1],0})
	AADD(aDadTemp,{"CLIENTE","C",TamSX3("A1_NOME")[1],0})
	if lIncRamo //Inclui ramo de atividade
		AADD(aDadTemp,{"ATIVIDADE","C",TamSX3("A1_P_DRMAT")[1],2})
	endif
	AADD(aDadTemp,{"JANEIRO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"FEVEREIRO","N",TamSX3("F2_VALBRUT")[1],2})		
	AADD(aDadTemp,{"MARCO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"ABRIL","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"MAIO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"JUNHO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"JULHO","N",TamSX3("F2_VALBRUT")[1],2})		
	AADD(aDadTemp,{"AGOSTO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"SETEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"OUTUBRO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"NOVEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"DEZEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"TOTAL","N",TamSX3("F2_VALBRUT")[1],2})
	AADD(aDadTemp,{"N_FISCAL","C",TamSX3("F2_DOC")[1],0}) //MSM - Data: 18/11/2014 - chamado: 021598
	AADD(aDadTemp,{"SERIE","C",TamSX3("F2_SERIE")[1],0})
	AADD(aDadTemp,{"CONTRATO","C",TamSX3("CN9_NUMERO")[1],0})
	AADD(aDadTemp,{"PROPOSTA","C",TamSX3("CN9_P_NUM")[1],0})
	AADD(aDadTemp,{"SOCIO","C",TamSX3("A3_NOME")[1],0})
	AADD(aDadTemp,{"GERCONTA","C",TamSX3("A1_NOME")[1],0})   //MSM - Data: 18/11/2014 - chamado: 021598
	if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
		AADD(aDadTemp,{"CC","C",TamSX3("A1_CC_CUST")[1],0})
		AADD(aDadTemp,{"DESC_CC","C",TamSX3("CTT_DESC01")[1],0})
	endif
	
	if select("DADTRB")>0
  			DADTRB->(DbCloseArea())
	endif

	cNome := CriaTrab(aDadTemp,.T.)
	dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

	cIndex:=CriaTrab(Nil,.F.)
	IndRegua("DADTRB",cIndex,"FILIAL+CLIENTE",,,"Selecionando Registro...")

	DbSelectArea("DADTRB")
	DbSetIndex(cIndex+OrdBagExt())
	DbSetOrder(1)
        
	//Montagem da Query  
	//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
	cQry1 :=" SELECT 	D2.D2_FILIAL AS 'FILIAL', D2.D2_DOC AS 'N_FISCAL', D2.D2_SERIE AS 'SERIE',
	cQry1 +="			D2.D2_CLIENTE AS 'COD_CLIENT', D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE', 
	cQry1 +="			Substring(D2.D2_EMISSAO,1,6) AS 'MS' ,
	If cEmp $ "ZB/ZF/ZG"	            			
		cQry1 +="			(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else 'Nao Informado' end) AS 'SOCIO',		
	Else
		cQry1 +="			SA3.A3_NOME AS 'SOCIO',
			
	EndIf
	cQry1 +="			CN9.CN9_P_NUM AS 'PROPOSTA',
	cQry1 +="			CN9.CN9_NUMERO AS 'CONTRATO', SUM(D2.D2_TOTAL) AS TOTAL, RA_NOME AS 'GECTA'
			
		 
	if lIncRamo //Inclui ramo de atividade
		cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'
            
  	endif
  	if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
  		cQry1 +=" ,A1_CC_CUST AS CC,ISNULL( (SELECT TOP 1 CTT_DESC01 FROM CTT"+cEmp+"0 WHERE D_E_L_E_T_='' AND CTT_CUSTO=A1_CC_CUST "+ iif(!empty(cFil),"AND CTT_FILIAL='"+cFil+"'","")+" ),'') AS DESC_CC  		
  	endif
  	cQry1 +=" FROM SD2"+cEmp+"0 AS D2 
  	cQry1 +=" 	LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA
  	cQry1 +=" 	LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'
   	cQry1 +=" 	JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO
   	cQry1 +=" 	JOIN CN9"+cEmp+"0 AS CN9 ON SC5.C5_MDCONTR = CN9.CN9_NUMERO
  	cQry1 +=" 	JOIN SA3"+cEmp+"0 AS SA3 ON CN9.CN9_P_GER=SA3.A3_COD
	If cEmp $ "ZB/ZF/ZG"
	  	cQry1 += " 	left Outer Join(Select * From Z55"+cEmp+"0 Where Z55_REVATU = '') as Z55 on CN9.CN9_FILIAL = Z55.Z55_FILIAL AND
		cQry1 += " 																		 		CN9.CN9_P_NUM = Z55.Z55_NUM AND Z55.D_E_L_E_T_=''
		//cQry1 += " 											 					 				AND CN9.CN9_CLIENT = Z55.Z55_CLIENT
		//cQry1 += " 																 				AND CN9.CN9_LOJACL = Z55.Z55_LOJA     
				   
		//RPB - 21/06/2016 - Chamado 034444
		cTabAlca:="Z42"+cEmp+"0"
		OpenSxs(,,,,cEmp,"SX2TMP","SX2",,.F.)
		If Select("SX2TMP") > 0
			SX2TMP->(DbSetOrder(1))
           	if SX2TMP->(DbSeek("Z42"))
		    	cTabAlca:= SX2TMP->X2_ARQUIVO 
		 	endIf 
		   	SX2TMP->(DbCloseArea()) // GFP - 11/01/2017 - Chamado 038589
		EndIf 
   		cQry1 += " 	left Outer Join(Select * From "+cTabAlca+") as Z42 on Z42.Z42_CPF = Z55.Z55_SOCIO AND Z42.D_E_L_E_T_=''

	EndIf
	cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND CN9.CN9_REVATU = '' AND
	if !empty(cFil)
   		cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND CN9.CN9_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND
		cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
	endif 
	cQry1 +=" A1.D_E_L_E_T_<>'*' AND CN9.D_E_L_E_T_<>'*' AND SA3.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*'
	cQry1 +=" AND D2.D2_EMISSAO >= "+cAno+"0101 AND D2.D2_EMISSAO <= "+cAno+"1231
	cQry1 +=" GROUP BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,A1_NOME,D2_EMISSAO
	If cEmp $ "ZB/ZF/ZG" 
		cQry1 +=" ,Z42.Z42_NOUSER
	else
		cQry1 +=" ,A3_NOME
	endif
	cQry1 +=" ,CN9_P_NUM,CN9_NUMERO,RA_NOME
	if lIncRamo
		cQry1 +=" ,A1_P_DRMAT
	endif
    if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
		cQry1 +=" ,A1_CC_CUST
	endif
	
	cQry1 +=" UNION All
	cQry1 +=" SELECT D2.D2_FILIAL AS 'FILIAL', D2.D2_DOC AS 'N_FISCAL', D2.D2_SERIE AS 'SERIE', D2.D2_CLIENTE AS 'COD_CLIENT',
	cQry1 +="		D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE', Substring(D2.D2_EMISSAO,1,6) AS 'MS' ,
	If cEmp $ "ZB/ZF/ZG"
		cQry1 +="		(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else (Case when CN9.CN9_P_GER = '' then 'Nao Informado' else '*'+CN9.CN9_P_GER End) end) AS 'SOCIO',
	Else
		cQry1 +="		(Case when CN9.CN9_P_GER = '' then 'Nao Informado' else CN9.CN9_P_GER End) AS 'SOCIO',
	EndIf
	cQry1 +="		(Case when CN9.CN9_P_NUM = '' then 'Nao Informado' else CN9.CN9_P_NUM End) AS 'PROPOSTA',
	cQry1 +="		CN9.CN9_NUMERO AS 'CONTRATO', SUM(D2.D2_TOTAL) AS TOTAL, RA_NOME AS 'GECTA'
	if lIncRamo //Inclui ramo de atividade
		cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'
   	endif
    if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
  		cQry1 +=" ,A1_CC_CUST AS CC,ISNULL( (SELECT TOP 1 CTT_DESC01 FROM CTT"+cEmp+"0 WHERE D_E_L_E_T_='' AND CTT_CUSTO=A1_CC_CUST "+ iif(!empty(cFil),"AND CTT_FILIAL='"+cFil+"'","")+" ),'') AS DESC_CC
  	endif

   	cQry1 +=" FROM SD2"+cEmp+"0 AS D2 
   	cQry1 +=" 	LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA
   	cQry1 +=" 	LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'
   	cQry1 +=" 	JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO
   	cQry1 +=" 	JOIN CN9"+cEmp+"0 AS CN9 ON SC5.C5_MDCONTR = CN9.CN9_NUMERO
	If cEmp $ "ZB/ZF/ZG"
	  	cQry1 += " 	left Outer Join(Select * From Z55"+cEmp+"0 Where Z55_REVATU = '') as Z55 on CN9.CN9_FILIAL = Z55.Z55_FILIAL AND
		cQry1 += " 																		 		CN9.CN9_P_NUM = Z55.Z55_NUM AND Z55.D_E_L_E_T_=''
		//cQry1 += " 											 					 				AND CN9.CN9_CLIENT = Z55.Z55_CLIENT 
		//cQry1 += " 																 				AND CN9.CN9_LOJACL = Z55.Z55_LOJA      

		//RPB - 21/06/2016 - Chamado 034444
		
		cTabAlca:="Z42"+cEmp+"0"
		OpenSxs(,,,,cEmp,"SX2TMP","SX2",,.F.)
		If Select("SX2TMP") > 0
        	SX2TMP->(DbSetOrder(1))
            if SX2TMP->(DbSeek("Z42"))
		    	cTabAlca:= SX2TMP->X2_ARQUIVO 
			EndIf 
		    SX2TMP->(DbCloseArea()) // GFP - 11/01/2017 - Chamado 038589
		EndIf  
   		cQry1 += " 	left Outer Join(Select * From "+cTabAlca+") as Z42 on Z42.Z42_CPF = Z55.Z55_SOCIO AND Z42.D_E_L_E_T_=''
		
    EndIf
	cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND CN9.CN9_REVATU = '' AND CN9.CN9_P_GER = '' AND (CN9.CN9_P_GER = '' OR CN9.CN9_P_NUM = '') AND
	if !empty(cFil)
   		cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND CN9.CN9_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND
		cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
	endif 
	cQry1 +=" A1.D_E_L_E_T_<>'*' AND CN9.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*'
	cQry1 +=" AND D2.D2_EMISSAO >= "+cAno+"0101 AND D2.D2_EMISSAO <= "+cAno+"1231
	cQry1 +=" GROUP BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,A1_NOME,D2_EMISSAO
	If cEmp $ "ZB/ZF/ZG"
		cQry1 +=" ,Z42.Z42_NOUSER,CN9.CN9_P_GER
	else
		cQry1 +=" ,CN9_P_GER
	endif  
	cQry1 +=" ,CN9_P_NUM,CN9_NUMERO,RA_NOME
	if lIncRamo
		cQry1 +=" ,A1_P_DRMAT
	endif
	if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
		cQry1 +=" ,A1_CC_CUST
	endif
	
	cQry1 +=" UNION All
	cQry1 +=" SELECT D2.D2_FILIAL AS 'FILIAL', D2.D2_DOC AS 'N_FISCAL', D2.D2_SERIE AS 'SERIE',
	cQry1 +="		D2.D2_CLIENTE AS 'COD_CLIENT', D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE',
	cQry1 +="		Substring(D2.D2_EMISSAO,1,6) AS 'MS' , 

	If cEmp $ "ZB/ZF/ZG" 
		cQry1 +="		CASE WHEN Z42.Z42_NOUSER<>'' THEN Z42.Z42_NOUSER ELSE 'Nao Informado' END AS 'SOCIO',
		cQry1 +="		CASE WHEN Z55.Z55_NUM<>'' THEN Z55.Z55_NUM ELSE 'Nao Informado' END AS 'PROPOSTA', 
		cQry1 +="		CASE WHEN SC5.C5_MDCONTR<>'' THEN SC5.C5_MDCONTR ELSE 'Nao Informado' END AS 'CONTRATO', 
	else
		cQry1 +="		'Nao Informado' AS 'SOCIO',
		cQry1 +="		'Nao Informado' AS 'PROPOSTA', 
		cQry1 +="		'Nao Informado' AS 'CONTRATO',
	endif
	
	cQry1 +="		SUM(D2.D2_TOTAL) AS TOTAL, RA_NOME AS 'GECTA'
	if lIncRamo //Inclui ramo de atividade
		cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'
   	endif
    if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
  		cQry1 +=" ,A1_CC_CUST AS CC,ISNULL( (SELECT TOP 1 CTT_DESC01 FROM CTT"+cEmp+"0 WHERE D_E_L_E_T_='' AND CTT_CUSTO=A1_CC_CUST "+ iif(!empty(cFil),"AND CTT_FILIAL='"+cFil+"'","")+" ),'') AS DESC_CC
  	endif
   	cQry1 +=" FROM SD2"+cEmp+"0 AS D2 
   	cQry1 +=" LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA
   	cQry1 +=" LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'
   	cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO AND SC5.C5_MDCONTR = ''
	
	//MSM - 24/03/2016 -  Tratamento para trazer a proposta e sócio quando informado manualmente no pedido de venda - Chamado: 
	If cEmp $ "ZB/ZF/ZG"
		
		cTabAlc:="Z42"+cEmp+"0"
		OpenSxs(,,,,cEmp,"SX2TPM","SX2",,.F.)
		If Select("SX2TPM") > 0
            SX2TPM->(DbSetOrder(1))
            if SX2TPM->(DbSeek("Z42"))
	            cTabAlc:= SX2TPM->X2_ARQUIVO
			endif	  	
		    SX2TPM->(DbCloseArea()) // GFP - 11/01/2017 - Chamado 038589
		EndIf

		cQry1 += " 	LEFT JOIN (SELECT * FROM Z55"+cEmp+"0 WHERE Z55_REVATU = '' AND D_E_L_E_T_='' ) as Z55 on SC5.C5_FILIAL = Z55.Z55_FILIAL AND
		cQry1 += " 																		 		SC5.C5_P_NUM = Z55.Z55_NUM AND Z55.D_E_L_E_T_=''
		cQry1 += " 	LEFT JOIN (SELECT * FROM "+cTabAlc+" WHERE D_E_L_E_T_='' ) AS Z42 ON Z42.Z42_CPF = Z55.Z55_SOCIO AND Z42.D_E_L_E_T_=''
	
    EndIf

	cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND
	if !empty(cFil)
   		cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND
		cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
	endif 
	cQry1 +=" A1.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*'
	cQry1 +=" AND D2.D2_EMISSAO >= "+cAno+"0101 AND D2.D2_EMISSAO <= "+cAno+"1231
	cQry1 +=" GROUP BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,A1_NOME,D2_EMISSAO,RA_NOME
	
	If cEmp $ "ZB/ZF/ZG"
		cQry1 +=" ,Z42.Z42_NOUSER,Z55.Z55_NUM,SC5.C5_MDCONTR
	endif
	if lIncRamo
		cQry1 +=" ,A1_P_DRMAT
	endif
	if lA1CC  //MSM - 14/01/2016 -  Chamado: 031493
		cQry1 +=" ,A1_CC_CUST
	endif
	
	cQry1 +=" ORDER BY COD_CLIENT,MS 

Else
	//Montagem da Query  
	//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
	cQry1 :=" SELECT F2_CLIENTE AS 'COD_CLIENTE', F2_LOJA AS 'FILIAL', A1_NOME AS 'CLIENTE',
	if lIncRamo //Inclui ramo de atividade
		cQry1 +=" A1_P_DRMAT AS 'ATIVIDADE', 
	endif
	cQry1 +=" ISNULL(["+cAno+"01],0) AS 'JANEIRO',ISNULL(["+cAno+"02],0) AS 'FEVEREIRO',ISNULL(["+cAno+"03],0) AS 'MARCO', ISNULL(["+cAno+"04],0) AS 'ABRIL', ISNULL(["+cAno+"05],0) AS 'MAIO', ISNULL(["+cAno+"06],0) AS 'JUNHO',
	cQry1 +=" ISNULL(["+cAno+"07],0) AS 'JULHO', ISNULL(["+cAno+"08],0) AS 'AGOSTO', ISNULL(["+cAno+"09],0) AS 'SETEMBRO',ISNULL(["+cAno+"10],0) AS 'OUTUBRO',ISNULL(["+cAno+"11],0) AS 'NOVEMBRO',ISNULL(["+cAno+"12],0) AS 'DEZEMBRO'
	cQry1 +=" ,
  	cQry1 +=" ISNULL(["+cAno+"01],0)+ISNULL(["+cAno+"02],0)+ISNULL(["+cAno+"03],0)+ISNULL(["+cAno+"04],0)+ISNULL(["+cAno+"05],0)+ISNULL(["+cAno+"06],0)+
	cQry1 +=" ISNULL(["+cAno+"07],0)+ISNULL(["+cAno+"08],0)+ISNULL(["+cAno+"09],0)+ISNULL(["+cAno+"10],0)+ISNULL(["+cAno+"11],0)+ISNULL(["+cAno+"12],0) AS 'TOTAL_GERAL'
	cQry1 +=" FROM
	cQry1 +=" (SELECT F2.F2_FILIAL, F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,A1.A1_P_DRMAT, Substring(F2.F2_EMISSAO,1,6) AS 'MS' , SUM(F2.F2_VALBRUT) AS TOTAL
	cQry1 +=" FROM SF2"+cEmp+"0 F2 LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA
	cQry1 +=" WHERE F2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' 
	cQry1 +=" AND F2.F2_SERIE <> 'ND'
 	cQry1 +=" AND F2.F2_EMISSAO >= "+cAno+"0101 AND F2_EMISSAO <= "+cAno+"1231
	if !empty(cFil)
   		cQry1 +=" AND F2.F2_FILIAL = '"+cFil+"'
		cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
	endif
	cQry1 +=" GROUP BY F2.F2_FILIAL, F2.F2_CLIENTE, F2.F2_LOJA, A1.A1_NOME,A1.A1_P_DRMAT, Substring(F2.F2_EMISSAO,1,6)
	cQry1 +=" ) 
	cQry1 +=" P
	cQry1 +=" PIVOT
	cQry1 +=" (
	cQry1 +=" SUM(TOTAL)
	cQry1 +=" FOR MS IN (["+cAno+"01],["+cAno+"02],["+cAno+"03],["+cAno+"04],["+cAno+"05],["+cAno+"06],["+cAno+"07],["+cAno+"08],["+cAno+"09],["+cAno+"10],["+cAno+"11],["+cAno+"12])) AS PVT
	cQry1 +=" ORDER BY F2_FILIAL, A1_NOME

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
	lRet :=.F.
	return(lRet)
EndIf

if select("TRBTEMP")>0
	TRBTEMP->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBTEMP",.T.,.T.)

oExcel:AddworkSheet(cNomeEmp)
oExcel:AddTable (cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Cod. Cliente",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Filial",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Cliente",1,1)

if lIncRamo //Inclui ramo de atividade
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Atividade",1,1)
endif

oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Janeiro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Fevereiro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Março",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Abril",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Maio",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Junho",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Julho",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Agosto",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Setembro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Outubro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Novembro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Dezembro",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Total Geral",1,3)
//RRP - 10/07/2013 - Geração do relatório detalhado 
If lTpRel == .T. 
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Nota Fiscal",1,1)
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Serie",1,1)
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Contrato",1,1)
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Proposta",1,1)
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Sócio",1,1)
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Gerente Conta",1,1)
	if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
		oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Centro Custo",1,1)
		oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Descrição CC",1,1)
  	endif
EndIf

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
	    
		//RRP - 10/07/2013 - Geração do relatório detalhado 
		If lTpRel == .T.
		
	   		Reclock("DADTRB",.T.)
	   		
			DADTRB->COD_CLIENT  := TRBTEMP->COD_CLIENT
			DADTRB->FILIAL		:= TRBTEMP->FILIAL			
			DADTRB->CLIENTE		:= TRBTEMP->CLIENTE
			
			if lIncRamo //Inclui ramo de atividade
				DADTRB->ATIVIDADE	:= TRBTEMP->ATIVIDADE
            endif
			
			DADTRB->JANEIRO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '01',TRBTEMP->TOTAL,0)
			DADTRB->FEVEREIRO	:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '02',TRBTEMP->TOTAL,0)			
			DADTRB->MARCO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '03',TRBTEMP->TOTAL,0)
			DADTRB->ABRIL		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '04',TRBTEMP->TOTAL,0)
			DADTRB->MAIO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '05',TRBTEMP->TOTAL,0)
			DADTRB->JUNHO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '06',TRBTEMP->TOTAL,0)
			DADTRB->JULHO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '07',TRBTEMP->TOTAL,0)			
			DADTRB->AGOSTO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '08',TRBTEMP->TOTAL,0)
			DADTRB->SETEMBRO	:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '09',TRBTEMP->TOTAL,0)
			DADTRB->OUTUBRO		:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '10',TRBTEMP->TOTAL,0)
			DADTRB->NOVEMBRO	:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '11',TRBTEMP->TOTAL,0)
			DADTRB->DEZEMBRO	:= IIF(Right(Alltrim(TRBTEMP->MS),2) = '12',TRBTEMP->TOTAL,0)
			DADTRB->TOTAL		:= DADTRB->JANEIRO+DADTRB->FEVEREIRO+DADTRB->MARCO+DADTRB->ABRIL+DADTRB->MAIO+DADTRB->JUNHO+DADTRB->JULHO+DADTRB->AGOSTO+DADTRB->SETEMBRO+DADTRB->OUTUBRO+DADTRB->NOVEMBRO+DADTRB->DEZEMBRO				
			DADTRB->N_FISCAL	:= TRBTEMP->N_FISCAL  //MSM - Data: 18/11/2014 - chamado: 021598
			DADTRB->SERIE		:= TRBTEMP->SERIE
			DADTRB->CONTRATO	:= TRBTEMP->CONTRATO
			DADTRB->PROPOSTA	:= TRBTEMP->PROPOSTA
			DADTRB->SOCIO		:= Capital(TRBTEMP->SOCIO)
	   		DADTRB->GERCONTA	:= TRBTEMP->GECTA //MSM - Data: 18/11/2014 - chamado: 021598
	   		
	   		if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
				DADTRB->CC   	:= TRBTEMP->CC
				DADTRB->DESC_CC := TRBTEMP->DESC_CC
 		 	endif
	   		
			DADTRB->(MsUnlock())
			
			aRowTab:={}
			
			AADD(aRowTab,DADTRB->COD_CLIENT)
			AADD(aRowTab,DADTRB->FILIAL)
			AADD(aRowTab,DADTRB->CLIENTE)
			
			if lIncRamo //Inclui ramo de atividade
	   			AADD(aRowTab,DADTRB->ATIVIDADE)
	   		endif
	   		
	   		AADD(aRowTab,DADTRB->JANEIRO)
			AADD(aRowTab,DADTRB->FEVEREIRO)
	   		AADD(aRowTab,DADTRB->MARCO)
			AADD(aRowTab,DADTRB->ABRIL)
	   		AADD(aRowTab,DADTRB->MAIO)
	   		AADD(aRowTab,DADTRB->JUNHO)
	  		AADD(aRowTab,DADTRB->JULHO)
	  		AADD(aRowTab,DADTRB->AGOSTO)
	 		AADD(aRowTab,DADTRB->SETEMBRO)
			AADD(aRowTab,DADTRB->OUTUBRO)
   			AADD(aRowTab,DADTRB->NOVEMBRO)
  			AADD(aRowTab,DADTRB->DEZEMBRO)
  			AADD(aRowTab,DADTRB->TOTAL)
 			AADD(aRowTab,DADTRB->N_FISCAL)
 			AADD(aRowTab,DADTRB->SERIE)
 			AADD(aRowTab,DADTRB->CONTRATO)
  			AADD(aRowTab,DADTRB->PROPOSTA)
 			AADD(aRowTab,DADTRB->SOCIO)
	   		AADD(aRowTab,DADTRB->GERCONTA)
	   		if lA1CC //MSM - 14/01/2016 -  Chamado: 031493
	   			AADD(aRowTab,DADTRB->CC)
	   			AADD(aRowTab,DADTRB->DESC_CC)
	   		endif
	   					
			oExcel:AddRow(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,aRowTab)
    	
		Else  
  			
  			aRowTab:={}
			
			AADD(aRowTab,TRBTEMP->COD_CLIENTE)
  			AADD(aRowTab,TRBTEMP->FILIAL)
  			AADD(aRowTab,TRBTEMP->CLIENTE)

	  		if lIncRamo //Inclui ramo de atividade
		  		AADD(aRowTab,TRBTEMP->ATIVIDADE)
	  		endif

	  		AADD(aRowTab,TRBTEMP->JANEIRO)
	 		AADD(aRowTab,TRBTEMP->FEVEREIRO)
	 		AADD(aRowTab,TRBTEMP->MARCO)
	 		AADD(aRowTab,TRBTEMP->ABRIL)
	 		AADD(aRowTab,TRBTEMP->MAIO)
			AADD(aRowTab,TRBTEMP->JUNHO)
			AADD(aRowTab,TRBTEMP->JULHO)
	  		AADD(aRowTab,TRBTEMP->AGOSTO)
	  		AADD(aRowTab,TRBTEMP->SETEMBRO)
	 		AADD(aRowTab,TRBTEMP->OUTUBRO)
	  		AADD(aRowTab,TRBTEMP->NOVEMBRO)
	 		AADD(aRowTab,TRBTEMP->DEZEMBRO)
  			AADD(aRowTab,TRBTEMP->TOTAL_GERAL)
  			
  			oExcel:AddRow(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,aRowTab)
	  		
		EndIf

		TRBTEMP->(DbSkip())
	Enddo
endif

//Encerra o dialog da barra
oDlg1:end()

RestArea(aArea)
Return(lRet)

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     : 
Objetivos   : Função para abrir o excel
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*------------------------------*
Static Function GExecl(oExcel,cEmp,cAno,cGet2)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

	//cArq := "Faturamento_"+alltrim(CriaTrab(NIL,.F.))+".xls"

	cArq := "Faturamento-"+alltrim(FWGrpName(cEmp))+"-"+cAno+".xls"
		

	IF FILE (cGet2+cArq)
		FERASE (cGet2+cArq)
	ENDIF

	//oExcel:GetXMLFile(cDest+cArq) // Gera o arquivo em Excel
	oExcel:GetXMLFile(cGet2+cArq) // Gera o arquivo em Excel	
	
	//SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel
	
/***********************GERANDO EXCEL************************************/          
    //sleep(2000)
	//FERASE (cDest+cArq)

Return

/*
Funcao      : MarcTodo()
Parametros  : aAllGroup,lMacTd
Retorno     : 
Objetivos   : Função para marcar todas as empresas
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*----------------------------------------*
Static Function MarcTodo(aAllGroup,lMacTd)
*----------------------------------------*

for j:=1 to len(aAllGroup)
	&("lCheck"+aAllGroup[j]):=lMacTd
	&("oCheck"+aAllGroup[j]):Refresh()
next

Return


/*
Funcao      : MarcTodo()
Parametros  : aAllGroup,lMacTd
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet2,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY

//Exibe tela para gravar o arquivo.
cGet2 := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return