#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTGEN019
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fun��o para gerar relat�rio dos cadastros que n�o tem a conta cont�bil preenchida
			: 
Autor       : Matheus Massarotto
Revis�o		:
Data/Hora   : 25/09/2013    17:10
M�dulo      : Faturamento
*/

/*
Funcao      : GTGEN019()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execu��o da rotina principal do relat�rio
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013
*/
*----------------------------*
User Function GTGEN019()
*----------------------------*
Local aAllGroup	:= FWAllGrpCompany() //Empresas
Local aTabelas	:= {"SA1","SA2","SB1","SA6"}

Local cGet2		:= space(200)	����������������������������������

����DEFINE DIALOG oDlg TITLE "Par�metros" FROM 180,180 TO 350,700 PIXEL
        
��������// Usando o m�todo Create                //82
		oScr2 := TScrollBox():Create(oDlg,05,01,72,260,.T.,.T.,.T.)

		@ 07,05 SAY "Rotina para gerar relat�rio de cadastros que n�o tem conta cont�bil preenchida (todas as empresas)" SIZE 250,20 OF oScr2 PIXEL
						
		@ 27,05 SAY "Salvar em? " SIZE 100,10 OF oScr2 PIXEL
		oGet2:= TGet():New(25,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
		oTButton2 := TButton():New( 25, 190, "...",oScr2,{||AbreArq(@cGet2,oGet2)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

		oGet2:Disable()
		
		oTButton1 := TButton():New( 56, 110, "Gerar",oScr2,{||Precarre(aAllGroup,oDlg,cGet2,aTabelas)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

����ACTIVATE DIALOG oDlg CENTERED 

Return

*------------------------------------------------------*
Static Function Precarre(aAllGroup,oDlg,cGet2,aTabelas)
*------------------------------------------------------*
Local oExcel
Local cOpc		:= ""
Local cEmp		:= ""
Local lRet		:= .T.

	if empty(cGet2)
		Alert("Informe o diret�rio onde os relat�rios ser�o salvos!")
		return	
	endif


	For ni:=1 to len(aAllGroup)
	
	oExcel	:= FWMSEXCEL():New()
	
		cEmp:=aAllGroup[ni]
       
			lRet:=CarrBar(cEmp,@oExcel,aTabelas)			
	
			//Verifico se a planilha est� ativa
		if oExcel:lActivate==NIL .OR. oExcel:lActivate
			oExcel:SetBgColorHeader("#AA92C7") //Define a cor de preenchimento do estilo do Cabe�alho
			
			oExcel:SetLineBgColor("#C2C2DC")//Define a cor de preenchimento do estilo da Linha
			
			oExcel:Set2LineBgColor("#E6E6FA") //Define a cor de preenchimento do estilo da Linha 2
			
			oExcel:Activate()
			
			//Chama a fun��o para abrir o excel
			GExecl(oExcel,cEmp,cGet2)
			
		
		endif
		
	Next
	
	if lRet
		msginfo("Processo finalizado, verifique o local indicado nos par�metros!")
		oDlg:End()
	endif
	
Return


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02
Retorno     : 
Objetivos   : Fun��o para criar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2013	11:00
*/

*---------------------------------------------*
Static Function CarrBar(cEmp,oExcel,aTabelas)
*---------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

	//******************R�gua de processamento*******************
	                                           //retira o bot�o X
	  DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da r�gua
	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)
	    
	  ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=CarrPlan(cEmp,oExcel,oDlg1,oMeter,aTabelas))
	  
	//*************************************
	
	
Return(lRet)


/*
Funcao      : CarrPlan()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o preencher o objeto com as informa��es da planilha
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2013	11:00
*/
*---------------------------------------------------------*
Static Function CarrPlan(cEmp,oExcel,oDlg1,oMeter,aTabelas)
*---------------------------------------------------------*
Local aArea 	:= GetArea()
Local cQry1 	:= ""
Local cNomeEmp 	:= ""
Local nCurrent	:= 0
Local nAumenta	:= 0
Local lRet		:= .T.

DEFAULT cEmp:=""

DbSelectArea("SM0")
SM0->(DbSetOrder(1))
if DbSeek(cEmp)
	cNomeEmp:=SM0->M0_NOME
else
	Return()
endif
    

for i:=1 to len(aTabelas) 
    
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))
	if !SX2->(DbSeek(aTabelas[i]))
    	loop
	endif
	
	cNomeTab:= alltrim(X2NOME())
	
	//Montagem da Query  

	if aTabelas[i]=="SA1"
		cQry1 :=" SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_CONTA FROM SA1"+cEmp+"0
		cQry1 +=" WHERE D_E_L_E_T_='' AND A1_CONTA=''" 
    elseif aTabelas[i]=="SA2"
    	cQry1 :=" SELECT A2_FILIAL,A2_COD,A2_LOJA,A2_NOME,A2_CGC,A2_CONTA FROM SA2"+cEmp+"0
		cQry1 +=" WHERE D_E_L_E_T_='' AND A2_CONTA=''
    elseif aTabelas[i]=="SB1"
    	cQry1 :=" SELECT B1_FILIAL,B1_COD,B1_DESC,B1_CONTA FROM SB1"+cEmp+"0
		cQry1 +=" WHERE D_E_L_E_T_='' AND B1_CONTA=''
    elseif aTabelas[i]=="SA6"
    	cQry1 :=" SELECT A6_FILIAL ,A6_COD ,A6_AGENCIA,A6_NUMCON,A6_NOME,A6_CONTA FROM SA6"+cEmp+"0
		cQry1 +=" WHERE D_E_L_E_T_='' AND A6_CONTA=''
    endif
	

	//executado atrav�s do menu
	If tcsqlexec(cQry1)<0
		cError:=TCSQLError()
	
		Alert("Ocorreu um problema na busca das informa��es!!"+CRLF+;
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
	
	oExcel:AddworkSheet(cNomeTab)
	
		aStru:= TRBTEMP->(DbStruct())
		
		//Crio a tabela
		oExcel:AddTable (cNomeTab,cNomeTab)

		cCamps:=""
		
		for j:=1 to len(aStru)
			//Adiciono o cabe�alho de acordo com os campos do select
			oExcel:AddColumn(cNomeTab,cNomeTab,aStru[j][1],1,1)
			cCamps+= 'TRBTEMP->'+alltrim(aStru[j][1])+","
		next	

		//retiro a ultima virgula caso tenha sido preenchido os campos
		if !empty(cCamps)
			cCamps:=SUBSTR(cCamps,1,len(cCamps)-1)
		endif
	
	Count to nRecCount
	
	//de quanto em quanto a regua deve aumentar
	nAumenta:= 100/(nRecCount/100)
	
	if nRecCount>0
		TRBTEMP->(DbGoTop())
		
		While TRBTEMP->(!EOF())
		
		    //Processamento da r�gua
			nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da r�gua
			nCurrent+=nAumenta // atualiza r�gua
			oMeter:Set(nCurrent) //seta o valor na r�gua
		    
			aCampos:=STRTOKARR(cCamps,",")
			
			for k:=1 to len(aCampos)
				aCampos[k]:=&(aCampos[k])
			next
			
			oExcel:AddRow(cNomeTab,cNomeTab,aCampos)
	
			TRBTEMP->(DbSkip())
		Enddo
	endif

next

//Encerra o dialog da barra
oDlg1:end()

RestArea(aArea)
Return(lRet)

/*
Funcao      : GExecl()
Parametros  : 
Retorno     : 
Objetivos   : Fun��o para gerar o arquivo excel
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2013	11:10
*/
*---------------------------------------------*
Static Function GExecl(oExcel,cEmp,cGet2)
*---------------------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/
    
	//Nome do arquivo
	cArq := alltrim(FWGrpName(cEmp))+"-"+UPPER(alltrim(GetEnvServer()))+".xls"
		

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
Funcao      : AbreArq()
Parametros  : aAllGroup
Retorno     : 
Objetivos   : Fun��o para abrir tela com o selecionador do local onde ser� salvo
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2013	11:10
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