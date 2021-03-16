#include "PROTHEUS.CH"
#Include "Topconn.Ch"
#Include "TbiConn.Ch"

/*
Funcao  : GTFIN043
Objetivo: Relatorio de Validacao dos campos obrigatorios e dados bancarios, de Cliente ou Fornecedores (para o projeto CNAB via FINNET)
Autor   : Cesar Alves
Data    : 25/06/2020
*/
*------------------------* 
 User Function GTFIN043()
*------------------------*
Local oDlg1,oGrp1,oSay1,oBtn1,oBtn2 

//Definicao do Dialog e todos os seus componentes.
oDlg1      := MSDialog():New( 227,514,332,772,"Validacao de Fornecedores",,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 004,004,027,124,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

//oSay	   := TSay():New( 008,004,{||"Selecione: Fornecedores/Clientes:"},oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,112,008)
oSay1      := TSay():New( 012,018,{||"Validacao cadastral de Fornecedores"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)

oBtn1      := TButton():New( 034,012,"Gerar"   ,oDlg1,{|| GeraRelatorio(),oDlg1:end() },037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 034,080,"Cancelar",oDlg1,{|| oDlg1:end()                 },037,012,,,,.T.,,"",,,,.F. )

//oBtn1    := TButton():New( 044,012,"Salvar"  ,oDlg1,{|| SalvaFl(nGet1),oDlg1:end()),) )) },037,012,,,,.T.,,"",,,,.F. )
//oBtn2    := TButton():New( 044,080,"Cancelar",oDlg1,{|| IIF(MsgYesNo("Deseja realmente cancelar?")                                                                                ,oDlg1:end(),)},037,012,,,,.T.,,"",,,,.F. )
//oSBtn	   := SButton():New( 008,124,1                 ,{|| (IIF(cCombo1==aItens1[2],nForCli:=1,nForCli:=2)),oDlg:end() },oDlg,,"", )

oDlg1:Activate(,,,.T.)

Return


/*
Funcao      : GeraRelatorio 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Relatorio de Validacao, por Fornecedor ou Cliente
*/
*------------------------------*
Static Function GeraRelatorio()
*------------------------------*
	
Local aArea   		:= GetArea()
Local cQuery        := ""
Local oFWMsExcel
Local oExcel
Local cArquivo
Local cPlanImp
Local cTitPlan
__cDiretorio := "C:\TEMP\"

	cArquivo    := GetTempPath()+Alltrim( RetSQLName("SA2") )+"_FORNECEDOR_"+GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)+".xml"
	cPlanImp :="SA2"
	cTitPlan :=""
	cCampos:= ""

	If Select('SA2TRB') > 0
		(SA2TRB)->(DbCloseArea())
	Endif

	//SA2TRB 	:= GetNextAlias() - TMS - 25/02/2020
	cQuery 		:= "SELECT SA2.A2_COD, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_BANCO, SA2.A2_AGENCIA, SA2.A2_DVAGE, SA2.A2_NUMCON, SA2.A2_DVCTA " + CRLF
	cQuery 		+= "FROM "+RetSQLName("SA2")+" SA2 " + CRLF
	cQuery 		+= "WHERE " + CRLF
	cQuery 		+= "     SA2.D_E_L_E_T_ <> '*' " + CRLF
	cQuery 		+= " AND (A2_CGC='' OR A2_BANCO='' OR A2_AGENCIA='' OR A2_DVAGE='' OR A2_NUMCON='' OR A2_DVCTA='') " + CRLF
	TCQuery cQuery New Alias "SA2TRB"
	
	//TCSetField("SA2TRB","E1_EMISSAO","D",8,0)
	//TCSetField("SA2TRB","E1_VENCTO","D",8,0)
	
	//Criando o objeto que ira gerar o conteudo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba 01
	oFWMsExcel:AddworkSheet(cPlanImp) //Nao utilizar numero junto com sinal de menos. Ex.: 1-
	//Criando a Tabela
	oFWMsExcel:AddTable(cPlanImp,cTitPlan)
			
	//Criando Colunas
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Codigo",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Nome",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"CNPJ_CPF",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Banco",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Agencia",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"DV Agencia",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"Conta",1)
	oFWMsExcel:AddColumn(cPlanImp,cTitPlan,"DV Conta",1)
	
	SA2TRB->(dbGoTop())
	Do while SA2TRB->(!Eof())

		oFWMsExcel:AddRow(cPlanImp,cTitPlan,{;			
			SA2TRB->A2_COD,;
			Alltrim(SA2TRB->A2_NOME),;
			Alltrim(SA2TRB->A2_CGC),;
			SA2TRB->A2_BANCO,;
			SA2TRB->A2_AGENCIA,;
			SA2TRB->A2_DVAGE,;
			SA2TRB->A2_NUMCON,;
			SA2TRB->A2_DVCTA;
			})		
			SA2TRB->(dbskip())
	EndDo
		
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             	//Abre uma nova conexao com Excel
	oExcel:WorkBooks:Open(cArquivo)     	//Abre uma planilha
	oExcel:SetVisible(.T.)                	//Visualiza a planilha
	oExcel:Destroy()

	SA2TRB->(DbCloseArea())
	

RestArea(aArea)

MsgAlert("Exportacao de planilha concluida !")

Return  
