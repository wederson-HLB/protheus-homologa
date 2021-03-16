#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP94
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar relatório de contas a pagar mensal por fornecedor
			: 
Autor       : Leandro Brito (Adpatado atraves do relatorio GTCORP67.PRW)
Revisão		:
Data/Hora   : 27/04/2015 
Modulo      : Financeiro
*/

/*
Funcao      : GTCORP94()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execuço da rotina principal do relatório
Autor       : Leandro Brito
Data/Hora   : 27/04/2015
*/
*----------------------------*
User Function GTCORP94()
*----------------------------*
Local aAllGroup	:= {}  //FWAllGrpCompany() //Empresas
Local nLinha	:= 01	//linha inicial para apresentação do checkbox
Local nCol		:= 01	//Coluna inicial para apresentação do checkbox

Local lMacTd	:= .F.
Local oMacTd        

/*
	* Leandro Brito - Carrega todas empresas que o usuario tem acesso
*/
AEval( FWEmpLoad() , { | x | If( Ascan( aAllGroup , x[ 1 ] ) == 0 , Aadd( aAllGroup , x[ 1 ] ) , ) } )  

DEFINE DIALOG oDlg TITLE "Parametros" FROM 180,180 TO 590,700 PIXEL

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

		// Usando o método Create //82
		oScr2 := TScrollBox():Create(oDlg,109,01,92,260,.T.,.T.,.T.)

		aItems	:= {'Sim','Nao'}
		cCombo	:= aItems[1]
		cGet1	:= space(4)	
		cGet2	:= space(100)	

		@07,75 SAY "Quebra por Tipo?" SIZE 100,10 OF oScr2 PIXEL

	   	oCombo:= TComboBox():Create(oScr2,{|u|if(PCount()>0,cCombo:=u,cCombo)},05,120,aItems,25,20,,,,,,.T.,,,,,,,,,'cCombo')

		//@ 25,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL
		
		//oGet1:= TGet():New(23,25,{|u| if(PCount()>0,nGet1:=u,nGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'nGet1')

		@ 07,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL
		
		oGet1:= TGet():New(05,35,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')
		
		@ 27,05 SAY "Salvar em? " SIZE 100,10 OF oScr2 PIXEL
		oGet2:= TGet():New(25,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
		oTButton2 := TButton():New( 25, 190, "...",oScr2,{||AbreArq(@cGet2,oGet2)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

		oGet2:Disable()
		
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
		msginfo('Processo finalizado, arquivo salvo em ' + cGet2 + ' .')
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
Autor       : Leandro Brito
Data/Hora   : 27/04/2015
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

DEFAULT cEmp:=""

DbSelectArea("SM0")
SM0->(DbSetOrder(1))
if DbSeek(cEmp)
	cNomeEmp:=SM0->M0_NOME
else
	Return()
endif

cQry1 := "SELECT E2_FORNECE AS 'COD_FORNECEDOR', E2_LOJA  AS 'FILIAL', A2_NOME AS 'FORNECEDOR', A2_CGC AS 'CNPJ_CPF'"
If ( cCombo == aItems[ 1 ] )
	cQry1 += ",E2_TIPO AS 'TIPO'"
EndIf
cQry1 += ",ISNULL(["+cAno+"01],0) AS 'JANEIRO',ISNULL(["+cAno+"02],0) AS 'FEVEREIRO',ISNULL(["+cAno+"03],0) AS 'MARCO', ISNULL(["+cAno+"04],0) AS 'ABRIL', ISNULL(["+cAno+"05],0) AS 'MAIO',"
cQry1 += "ISNULL(["+cAno+"06],0) AS 'JUNHO', ISNULL(["+cAno+"07],0) AS 'JULHO', ISNULL(["+cAno+"08],0) AS 'AGOSTO', ISNULL(["+cAno+"09],0) AS 'SETEMBRO',"
cQry1 += "ISNULL(["+cAno+"10],0) AS 'OUTUBRO',ISNULL(["+cAno+"11],0) AS 'NOVEMBRO',ISNULL(["+cAno+"12],0) AS 'DEZEMBRO' ,"
cQry1 += "ISNULL(["+cAno+"01],0)+ISNULL(["+cAno+"02],0)+ISNULL(["+cAno+"03],0)+ISNULL(["+cAno+"04],0)+ISNULL(["+cAno+"05],0)+ISNULL(["+cAno+"06],0)+ ISNULL(["+cAno+"07],0)+ISNULL(["+cAno+"08],0)+ISNULL(["+cAno+"09],0)+ISNULL(["+cAno+"10],0)+ISNULL(["+cAno+"11],0)+ISNULL(["+cAno+"12],0) AS 'TOTAL_GERAL'"
cQry1 += "FROM (SELECT E2.E2_FILIAL, E2.E2_FORNECE, E2.E2_LOJA, A2.A2_NOME, A2.A2_CGC,"+If( cCombo == aItems[ 1 ] ,"E2.E2_TIPO,","")+"Substring(E2.E2_EMISSAO,1,6) AS 'MS' "
cQry1 += ", SUM(E2.E2_VALOR) AS TOTAL "
cQry1 += "FROM SE2"+cEmp+"0 E2 "
cQry1 += "LEFT JOIN SA2"+cEmp+"0 A2 ON A2.A2_COD = E2.E2_FORNECE AND A2.A2_LOJA = E2.E2_LOJA "
cQry1 += "WHERE E2.D_E_L_E_T_ = '' "
cQry1 += "AND A2.D_E_L_E_T_ = '' "    
cQry1 += "AND E2.E2_EMISSAO >= "+cAno+"0101 AND E2_EMISSAO <= "+cAno+"1231 "

if !empty(cFil)
	cQry1 +=" AND E2.E2_FILIAL = '"+cFil+"'
	cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
endif
   		
cQry1 += "GROUP BY E2.E2_FILIAL, E2.E2_FORNECE, E2.E2_LOJA, A2.A2_NOME,A2.A2_CGC,"+If( cCombo == aItems[ 1 ] ,"E2.E2_TIPO,","")+"Substring(E2.E2_EMISSAO,1,6) )  "
cQry1 += "P PIVOT ( SUM(TOTAL) FOR MS IN (["+cAno+"01],["+cAno+"02],["+cAno+"03],["+cAno+"04],["+cAno+"05],["+cAno+"06],["+cAno+"07],["+cAno+"08],["+cAno+"09],["+cAno+"10],["+cAno+"11],["+cAno+"12])) AS PVT "
cQry1 += "ORDER BY E2_FILIAL, A2_NOME "

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
oExcel:AddTable (cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Cod. Fornecedor",1,1)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Filial",1,1)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Fornecedor",1,1)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Cnpj_Cpf",1,1)

If ( cCombo == aItems[ 1 ] )                                                                            
	oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Tipo",1,1)
EndIf                                                                                           

oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Janeiro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Fevereiro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Março",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Abril",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Maio",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Junho",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Julho",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Agosto",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Setembro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Outubro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Novembro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Dezembro",1,3)
oExcel:AddColumn(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,"Total Geral",1,3)


Count to nRecCount

//de quanto em quanto a regua deve aumentar
nAumenta:= 100/(nRecCount/100)

if nRecCount>0
	TRBTEMP->(DbGoTop())
	
	While TRBTEMP->(!EOF())
	
	    //Processamento da regua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da regua
		nCurrent+=nAumenta // atualiza regua
		oMeter:Set(nCurrent) //seta o valor na regua
	    
  			
		aRowTab:={}
			
		AADD(aRowTab,TRBTEMP->COD_FORNECEDOR)
		AADD(aRowTab,TRBTEMP->FILIAL)
		AADD(aRowTab,TRBTEMP->FORNECEDOR)
		AADD(aRowTab,TRBTEMP->CNPJ_CPF)		

		If ( cCombo == aItems[ 1 ] )                                                                            
			AADD(aRowTab,TRBTEMP->TIPO)		
		EndIf

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
 			
		oExcel:AddRow(cNomeEmp,"Contas_Pagar "+Capital(Alltrim(FWGrpName(cEmp)))+" - "+cAno,aRowTab)
	  		

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

	//cArq := "Contas_Pagar_"+alltrim(CriaTrab(NIL,.F.))+".xls"

	cArq := "Contas_Pagar-"+alltrim(FWGrpName(cEmp))+"-"+cAno+".xls"
		

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