#INCLUDE "SHELL.ch"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"     
#INCLUDE "colors.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SM0VIEWER ∫Autor Adriane Sayuri        ∫ Data ≥  19/04/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Apresenta tela com informaÁıes do Sigamat para consulta    ∫±±
±±∫          ≥ das informaÁıes da empresa que interferem nos livros       ∫±±
±±∫          ≥ fiscai, cont·beis e arquivos remetidos ao Governo.         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/                   

/*
Funcao      : SM0VIEWER
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Apresentar informaÁıes do Sigamat para consulta de endereÁo, cnpj, cnae e etc
Autor     	: Adriane Sayuri
Data     	: 19/04/2014 
MÛdulo      : Todos
*/
*---------------------------*
 User Function SM0VIEWER()  
*---------------------------*
Local cTGet1  

PRIVATE oDlg1

@ 100,001 to 425,550 Dialog oDlg1 Title "InformaÁıes da empresa"
@ 010,010 Say "Esta rotina tem como objetivo apresentar as informaÁıes da empresa para possibilitar conferencia" COLOR CLR_HRED, CLR_WHITE
@ 020,010 Say "dos livros e arquivos remetidos ao governo." COLOR CLR_HRED, CLR_WHITE
@ 035,010 Say "Estas informaÁıes s„o submetidas ÅEequipe de sistemas atravÈs de um formul·rio anexado no chamado"
@ 045,010 Say "da criaÁ„o da empresa no ERP. O acesso da informaÁ„o visualizada ÅEalterada somente pela equipe "
@ 055,010 Say "de suporte Protheus da HLB BRASIL atravÈs de chamado. "
@ 070,010 Say "Essas alteraÁıes dever„o ser analisadas com atenÁ„o pois podem influenciar nas entregas das equipes" 
@ 080,010 Say "fiscais, cont·bil e RH. AlteraÁıes como CNPJ, InscriÁ„o Estadual, EndereÁo e Raz„o Social se n„o" 
@ 090,010 Say "estiverem de acordo com a base do governo podem impossibilitar a conex„o e transmiss„o das Notas" 
@ 105,010 Say "Fiscais EletrÙnicas (Nf-e) feitas pelo Protheus."
@ 115,010 Say "Para as alteraÁıes mencionadas acima, ÅEobrigatÛrio anexar o cart„o do CNPJ da empresa no chamado."
@ 125,150 Say "Equipe de Sistemas HLB BRASIL."

@ 140,070 Button "_Empresas" Size 60,15 Action U_GTRELSM0()
@ 140,150 Button "_Sair" Size 40,15 Action Close(oDlg1)
Activate Dialog oDlg1 CENTERED

Return                                     

/*
Funcao      : GTRELSM0
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Carrega as informaÁıes do sigamat em uma tabela temporaria.
Autor     	: Anderson Arrais
Data     	: 01/05/2014 
MÛdulo      : Todos
*/
*----------------------*
User Function GTRELSM0()
*----------------------*
Local cTitulo := "Todas empresas"
Local cArqTmp := ""
Local aExibe   := {}

Private cMarca  := GetMark()

//Campos adicionais das tabelas temporarias
aCpEmp := {	{"WKMARCA"  	,"C",02,0},;
			{"M0_CODIGO"	,"C",02,0},;
	    	{"M0_CODFIL"	,"C",02,0},;
			{"M0_FILIAL"	,"C",15,0},;
			{"M0_NOME"  	,"C",15,0},;
			{"M0_CGC"   	,"C",14,0},;
			{"M0_NOMECOM"  	,"C",60,0},;
			{"M0_ENDCOB"  	,"C",60,0},;		
			{"M0_BAIRCOB"  	,"C",20,0},;
			{"M0_COMPCOB"  	,"C",25,0},;
			{"M0_CIDCOB"  	,"C",60,0},;
			{"M0_ESTCOB"  	,"C",02,0},;
			{"M0_CODMUN"  	,"C",07,0},;
			{"M0_CEPCOB"  	,"C",08,0},;
			{"M0_TEL"  		,"C",14,0},;
			{"M0_INSC"  	,"C",14,0},;
			{"M0_CNAE"  	,"C",07,0},;
			{"M0_FPAS"  	,"C",04,0},;
			{"M0_NATJUR"  	,"C",04,0},;
			{"M0_NIRE"  	,"C",25,0},;
			{"M0_DTRE"  	,"D",08,0}}

			//Campos de exibiÁ„o das MSSelect.
aExibe  := {{"EMPRESA",,"Empresa","@!"},;
			{"FILDES" ,,"Filial" ,"@!"},;
			{"CNPJ"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

If SELECT ("TMPEMP") > 0
	//Se tiver aberta fecha a tabela
	TMPEMP->(DbCloseArea())
EndIf

//Cria o arquivo tempor·rio das empresas
cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)

//Carrega o browse com as empresas
SM0->(DbGoTop())
While SM0->(!EOF())
    
	If SM0->M0_CODIGO <> "YY"
		TMPEMP->(DbAppend())
	
		TMPEMP->WKMARCA    	:= cMarca
		TMPEMP->M0_CODIGO  	:= SM0->M0_CODIGO
		TMPEMP->M0_CODFIL  	:= SM0->M0_CODFIL
		TMPEMP->M0_FILIAL  	:= SM0->M0_FILIAL
		TMPEMP->M0_NOME    	:= SM0->M0_NOME	        
		TMPEMP->M0_NOMECOM 	:= SM0->M0_NOMECOM
	    TMPEMP->M0_CGC 	   	:= SM0->M0_CGC
		TMPEMP->M0_ENDCOB	:= SM0->M0_ENDCOB
		TMPEMP->M0_BAIRCOB	:= SM0->M0_BAIRCOB
		TMPEMP->M0_COMPCOB	:= SM0->M0_COMPCOB
		TMPEMP->M0_CIDCOB  	:= SM0->M0_CIDCOB
		TMPEMP->M0_CODMUN	:= SM0->M0_CODMUN
		TMPEMP->M0_ESTCOB	:= SM0->M0_ESTCOB
		TMPEMP->M0_CEPCOB	:= SM0->M0_CEPCOB
		TMPEMP->M0_TEL 		:= SM0->M0_TEL
		TMPEMP->M0_INSC 	:= SM0->M0_INSC
		TMPEMP->M0_CNAE 	:= SM0->M0_CNAE
		TMPEMP->M0_FPAS  	:= SM0->M0_FPAS
		TMPEMP->M0_NATJUR 	:= SM0->M0_NATJUR
		TMPEMP->M0_NIRE  	:= SM0->M0_NIRE
		TMPEMP->M0_DTRE  	:= SM0->M0_DTRE

		EndIf
	SM0->(DbSkip())	
EndDo

//Chama a tela de paramentros
TelaParam()

Return Nil

/*
Funcao      : TelaParam
Objetivos   : Exibe a tela de parametros.
Autor       : Anderson Arrais
Data        : 01/05/2014 
*/
*-------------------------*
Static Function TelaParam()
*-------------------------*
Local lInverte := .T.

Local aExibe  := {}

Local oDlg
Local oGrp
Local oSel

//Campos de exibiÁ„o das MSSelect.
aExibe  := {{"WKMARCA"  ,,""       ,""  },;
			{"M0_NOME"  ,,"Empresa","@!"},;
			{"M0_FILIAL",,"Filial" ,"@!"},;
			{"M0_CGC"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

oDlg := MSDialog():New( 091,232,606,841,"Par‚metros",,,.F.,,,,,,.T.,,,.T. )

oGrp := TGroup():New( 008,008,220,300,"Marque as empresas/filiais",oDlg,,,.T.,.F. )

TMPEMP->(DbGoTop())
oSel := MsSelect():New("TMPEMP","WKMARCA","",aExibe,@lInverte,@cMarca,{020,016,210,290},,, oGrp ) 
oSel:oBrowse:lHasMark := .T.
oSel:oBrowse:lCanAllMark:=.T.
oSel:oBrowse:bAllMark := {|| MarkAll("TMPEMP",cMarca,@oDlg)}

@ 230,170 Button "_Visualizar" Size 50,15 Action U_AbreSM0()
@ 230,250 Button "_Sair" Size 40,15 Action Close(oDlg)

oDlg:Activate(,,,.T.)

Return Nil 

/*
Funcao      : MarkAll
Objetivos   : Inverter a marcaÁ„o do MSSelect.
Autor       : Anderson Arrais
Data        : 01/05/2014 
*/
*--------------------------------------------*
Static Function MarkAll(cAlias, cMarca, oDlg)
*--------------------------------------------*
Local nReg := (cAlias)->(RecNo())

(cAlias)->(dbGoTop())
While (cAlias)->(!EOF())

    (cAlias)->(RecLock(cAlias,.F.))
	
	If Empty((cAlias)->WKMARCA)
		(cAlias)->WKMARCA := cMarca
	Else
		(cAlias)->WKMARCA := "  "
	EndIf
	
	(cAlias)->(MsUnlock())
	
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(dbGoto(nReg))

oDlg:Refresh()

Return Nil  
  
/*
Funcao      : AbreSM0
Objetivos   : Gera relatÛrio em excel das empresas selecionadas do sigamat.
Autor       : Anderson Arrais
Data        : 01/05/2014
*/              
/*----------------------------------------------------------------------------------*/
User Function AbreSM0()
/*----------------------------------------------------------------------------------*/
Local aSays:={ }	//Arrays locais
Local oExcel := FWMSEXCEL():New()
Local cDest :=  GetTempPath()

//Gerar relatÛrio em excel
oExcel:AddworkSheet("Empresas")
oExcel:AddTable ("Empresas","Dados da empresa")
oExcel:AddColumn("Empresas","Dados da empresa","Raz„o social",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","CNPJ",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Nome filial",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","CÛdigo da empresa",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Filial",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","EndereÁo",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Bairro",1,1) 
oExcel:AddColumn("Empresas","Dados da empresa","Complemento",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Cidade",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","CÛdigo Municipio",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Estado",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Cep",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Telefone",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","InscriÁ„o Estadual",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Cnae",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Fpas",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Natureza Juridica",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Nire",1,1)
oExcel:AddColumn("Empresas","Dados da empresa","Data Nire",1,1)

//Gera a lista das empresas selecionadas e adiciona as linhas do excel
TMPEMP->(dbgotop())
While TMPEMP->(!EOF())
    If !Empty(TMPEMP->WKMARCA)
    	TMPEMP->(DbSkip())
    	Loop
    EndIf
	AADD(aSays,Alltrim(TMPEMP->M0_NOMECOM))//Raz„o social
	AADD(aSays,Alltrim(TMPEMP->M0_CGC))//CNPJ      
	AADD(aSays,Alltrim(TMPEMP->M0_NOME)+" / "+Alltrim(TMPEMP->M0_FILIAL))//Nome Filial
	AADD(aSays,Alltrim(TMPEMP->M0_CODIGO))//CÛdigo Empresa
	AADD(aSays,Alltrim(TMPEMP->M0_CODFIL))//CÛdigo Filial
	AADD(aSays,Alltrim(TMPEMP->M0_ENDCOB))//EndereÁo
	AADD(aSays,Alltrim(TMPEMP->M0_BAIRCOB))//Bairro
	AADD(aSays,Alltrim(TMPEMP->M0_COMPCOB))//Complemento
	AADD(aSays,Alltrim(TMPEMP->M0_CIDCOB))//Cidade
	AADD(aSays,Alltrim(TMPEMP->M0_CODMUN))//CÛdigo Municipio
	AADD(aSays,Alltrim(TMPEMP->M0_ESTCOB))//Estado
	AADD(aSays,Alltrim(TMPEMP->M0_CEPCOB))//CEP  
	AADD(aSays,Alltrim(TMPEMP->M0_TEL))//Telefone  
	AADD(aSays,Alltrim(TMPEMP->M0_INSC))//InscriÁ„o Estadual
	AADD(aSays,Alltrim(TMPEMP->M0_CNAE))//Cnae
	AADD(aSays,Alltrim(TMPEMP->M0_FPAS))//Fpas
	AADD(aSays,Alltrim(TMPEMP->M0_NATJUR))//Natureza Juridica
	AADD(aSays,Alltrim(TMPEMP->M0_NIRE))//Nire
	AADD(aSays,Alltrim(TMPEMP->M0_DTRE))//Data Nire

	oExcel:AddRow("Empresas","Dados da empresa",{aSays[1],aSays[2],aSays[3],aSays[4],aSays[5],aSays[6],aSays[7],aSays[8],aSays[9],aSays[10],aSays[11],aSays[12],aSays[13],aSays[14],aSays[15],aSays[16],aSays[17],aSays[18],aSays[19]})//Gera linha com as informaÁıes da empresa que foi marcada na tela de par‚metro.
	aSays:={ }//Limpa o array

TMPEMP->(DbSkip())
EndDo

//Verifica se o arquivo Empresa.xml estÅEaberto em uso
oExcel:Activate()
If FILE(cDest+"Empresa.xml")
	If FErase(cDest+"Empresa.xml") <> 0
		Msginfo("N„o foi poss˙ìel gerar arquivo Empresa.xml, verifique se o mesmo estÅEem uso!")
		Return
	EndIf
EndIf
oExcel:GetXMLFile(cDest+"Empresa.xml")//Gera arquivo .xml 
SHELLEXECUTE("open",(cDest+"Empresa.xml"),"","",5)//Abre no excel o arquivo gerado

Return .T. 