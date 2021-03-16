#include 'totvs.ch'

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TTCTB001  ∫Autor  ≥Jo„o Silva			 ∫ Data ≥  26/10/2015 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥RelatÛrio de Raz„o Cont·bil Customizado.                    ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ HLB BRASIL                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

*-----------------------*                                         
User Function TTCTB001() 
*-----------------------*
Local lOk := .F.
Local cPerg := "TTCTB001"

Private cDataDe		:= ""
Private cDataAte	:= ""
Private cContaDe	:= ""
Private cContaAte	:= ""
Private cArq		:= ""
Private cMoeda		:= ""
Private cCCDe		:= ""
Private cCCAte		:= ""
Private cItemDe		:= ""
Private cItemAte	:= ""
Private cDescMoe	:= ""
Private cClasseDe 	:= ""
Private cClasseAte	:= ""

Private lSemMov		:= .F.
Private lImpSld		:= .F.
Private lCCusto		:= .F.
Private lItCont		:= .F.
Private lAbreExcel	:= .F.

Private aStru		:= {}  

If cEmpAnt $ "TT/GY/I5"//Verifica se ÅEa empresa Uber 
	MsgInfo("Este relatorio n„o esta disponivel para essa empresa! Favor entra em contato com a equipe de TI.","HLB BRASIL") 
	Return(.F.)
EndIf

//Verifica os par‚metros do relatÛrio
Funcao6(cPerg)

If Pergunte(cPerg,.T.)

	//Grava os par‚metros
	cDataDe   := DtoS(mv_par01)
	cDataAte  := DtoS(mv_par02)
	cContaDe  := mv_par03
	cContaAte := mv_par04
	cArq  := mv_par05
	lAbreExcel:= If(mv_par06==2,.F.,.T.)
	cMoeda    := mv_par07
	lSemMov   := If(mv_par08==2,.F.,.T.)
	lImpSld   := If(mv_par08==3,.T.,.F.)
	lCCusto   := If(mv_par09==2,.F.,.T.)
	cCCDe     := mv_par10
	cCCAte    := mv_par11
	lItCont   := If(mv_par12==2,.F.,.T.)
	cItemDe   := mv_par13
	cItemAte  := mv_par14
	cDescMoe  := mv_par15
	cClasseDe := mv_par16
	cClasseAte := mv_par17
	
	//Gera o RelatÛrio
	Processa({|| lOk := Funcao1()},"Gerando o relatÛrio...")

	If !lOk
		MsgInfo("N„o foram encontrados registros para os par‚metros informados.","AtenÁ„o")
		Return Nil
	EndIf

EndIf

Return Nil                           

/*
FunÁ„o  : Funcao1
Objetivo: Gera o relatÛrio
Autor   : Jo„o Silva
Data    : 27/10/2015
*/
*-----------------------*
Static Function Funcao1()
*-----------------------*
Local lGrvDados		:= .F.

Private nArqTrab	:= -1 //Quando a tabela n„o existe ÅEretornado valor negativo

//Cria a tabela tempor·ria para impress„o dos registros.
nArqTrab :=  Funcao2()

//Grava os Dados na tabela tempor·ria
If nArqTrab == 0
	lGrvDados := Funcao3()
EndIf

If lGrvDados
	//Imprime o relatÛrio
    Funcao4()
EndIf

Return lGrvDados

/*
FunÁ„o  : Funcao2
Objetivo: Cria a tabela tempor·ria que serÅEutilizada para a impress„o.
Autor   : Jo„o Silva
Data    : 27/10/2015
*/
*--------------------------*
Static Function Funcao2()
*--------------------------*
Local cQuery	:= ""

cQuery:= "CREATE TABLE ##RELTEMP ( "
cQuery+= "DATARD varchar(8)," 
cQuery+= "DATAPC varchar(8) ,"
cQuery+= "CURREN varchar(200)," 
cQuery+= "ENTITY varchar(4)," 
cQuery+= "CITY varchar(4)," 
cQuery+= "LINE varchar(4)," 
cQuery+= "DEPART varchar(5)," 
cQuery+= "ACCOUN varchar(20),"
cQuery+= "INTERC varchar(4)," 
cQuery+= "GLDESC varchar(100)," 
cQuery+= "DEBIT decimal(17,2),"
cQuery+= "CREDIT decimal(17,2))"

//Verifica se a tabela existe
If TcSqlExec("SELECT * FROM ##RELTEMP") == 0
	//Deleta a Tabela do Banco
	TcSqlExec("DROP TABLE ##RELTEMP")
	
	//Cria a tabela no banco
	TcSqlExec(cQuery)
Else
	//Cria a tabela no banco
	TcSqlExec(cQuery)
EndIf

nArqTrab := TcSqlExec("SELECT * FROM ##RELTEMP")

DbSelectArea("REL")

Return nArqTrab

/*
FunÁ„o  : Funcao3
Objetivo: Realiza a gravaÁ„o dos dados na tabela tempor·ria.
Autor   : Jo„o Silva
Data    : 27/10/2015
*/
*--------------------------*
Static Function Funcao3()
*--------------------------*
Local lRet := .F.

Local dDataRD	:= CtoD("  /  /  ")
Local dDataPC	:= CtoD("  /  /  ")
Local cCurren	:= ""
Local cEntity	:= ""
Local cCity		:= ""
Local cLine		:= ""
Local cDepart	:= ""
Local cAccoun	:= "" 
Local cInterc	:= ""
Local cGldesc	:= ""
Local nDebito	:= 0
Local nCredit	:= 0
Local cLike		:= "%'%C%'%"
Local cQuery	:= ""

//Apaga o arquivo de trabalho, se existir.
If Select("TMPCT2") > 0
	TMPCT2->(DbCloseArea())
EndIf

//Busca as movimentaÁıes de acordo com os par‚metros
BeginSql Alias 'TMPCT2'

	SELECT CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, 
           CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC ,
           CT2_ITEMC, CT2_ITEMD, CT2_SEQUEN, CT2_SEQLAN, CT2_CLVLDB, CT2_CLVLCR,CT2_ORIGEM
	FROM %table:CT2%
	WHERE %notDel%
	  AND CT2_DC <> '4'
	  AND CT2_FILIAL = %xFilial:CT2%
	  AND CT2_DATA >= %exp:cDataDe%
	  AND CT2_DATA <= %exp:cDataAte%
	  AND CT2_MOEDLC = %exp:cMoeda%
	  //AND CT2_ORIGEM NOT LIKE %exp:cLike%
	  AND ((CT2_DEBITO between %exp:cContaDe% and %exp:cContaAte%) or (CT2_CREDIT between %exp:cContaDe% and %exp:cContaAte%))           
      AND ((CT2_CCD between %exp:cCCDe% and %exp:cCCAte%)or (CT2_CCC between %exp:cCCDe% and %exp:cCCAte%))
      AND ((CT2_ITEMD between %exp:cITemDe% and %exp:cITemAte%) or (CT2_ITEMC between %exp:cITemDe% and %exp:cITemAte%))
      AND ((CT2_ITEMD between %exp:cITemDe% and %exp:cITemAte%) or (CT2_ITEMC between %exp:cITemDe% and %exp:cITemAte%))      
      AND ((CT2_CLVLDB between %exp:cClasseDe% and %exp:cClasseAte%) or (CT2_CLVLCR between %exp:cClasseDe% and %exp:cClasseAte%))                
	ORDER BY CT2_DATA,CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
EndSql

//Looping nos registros
TMPCT2->(DbGoTop())
If TMPCT2->(!EOF())
                            
	lRet  := .T.	

	While TMPCT2->(!EOF())
		
		cHist	:= ""
		cMatri	:= ""
  		
		//Ajuste na descriÁ„o para pegar da verba.			    
  		SRV->(DbSetOrder(1))
		If SRV->(DbSeek(xFilial("SRV")+SUBSTR(Alltrim(TMPCT2->CT2_ORIGEM),1,3)))
			cDescr := SRV->RV_COD+"-"+SRV->RV_DPAYROL
		EndIf
		  		
  			
  		//Buscando matr˙Äula do funcion·rio
		cHist := AllTrim(TMPCT2->CT2_HIST)
		cMatri:= Alltrim(SUBSTR(cHist, AT("MAT:",cHist)+4, 6))

		If AllTrim(TMPCT2->CT2_DC) == "1" .OR. Alltrim(TMPCT2->CT2_DC)=="3" //Debito

			cLine	:= "0000"
			cCity	:= "0000"
			cDepart	:= "00000"
			//cDescr	:= ""					    
			
			//Busca a descriÁ„o da conta
           	/*CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+TMPCT2->CT2_DEBITO))
				cDescr := &("CT1->CT1_DESC04")
       	    EndIf*/
       	    
       	    //Tratamento para as colunas City Code, Line of Business, Department do Gl File
			If !(Alltrim(SubStr(TMPCT2->CT2_DEBITO,1,1)))$"1/2"
		       	//De para customizado para o relatorio
				ZX1->(DbSetOrder(1))
				If ZX1->(DbSeek(xFilial("ZX1")+cMatri))
					cLine	:= ZX1->ZX1_LINE
					cCity	:= ZX1->ZX1_CITY
					cDepart	:= ZX1->ZX1_DEPART	
		       	EndIf
			EndIf
			    
			//Grava o arquivo tempor·rio.
			cQuery := "INSERT INTO ##RELTEMP (DATARD, DATAPC, CURREN, ENTITY, CITY, LINE, DEPART, ACCOUN, INTERC, GLDESC, DEBIT, CREDIT) VALUES( "
			cQuery += "'"+DtoS(DATE())+"', "
			cQuery += "'"+TMPCT2->CT2_DATA+"', "
			cQuery += "'BRL', "
			cQuery += "'4003', "
			cQuery += "'"+cCity+"', "
			cQuery += "'"+cLine+"', "
			cQuery += "'"+cDepart+"', "
			cQuery += "'"+AllTrim(TMPCT2->CT2_DEBITO)+"', "
			cQuery += "'0000', "
			cQuery += "'"+AllTrim(cDescr)+"', "
			cQuery += Alltrim(Str(TMPCT2->CT2_VALOR))+", "
			cQuery += "0 )"
			
			TcSqlExec(cQuery)
			
        EndIf
        
		If AllTrim(TMPCT2->CT2_DC) == "2" .OR. Alltrim(TMPCT2->CT2_DC)=="3" //Credito		   

			cLine	:= "0000"
			cCity	:= "0000"
			cDepart	:= "00000"
			//cDescr	:= ""
			
			//Busca a descriÁ„o da conta
           	/*CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+TMPCT2->CT2_CREDIT))
				cDescr := &("CT1->CT1_DESC04")
			EndIf*/
			 			
			//Tratamento para as colunas City Code, Line of Business, Department do Gl File
			If !(Alltrim(SubStr(TMPCT2->CT2_CREDIT,1,1)))$"1/2"
		       	//De para customizado para o relatorio
				ZX1->(DbSetOrder(1))
				If ZX1->(DbSeek(xFilial("ZX1")+cMatri))
					cLine	:= ZX1->ZX1_LINE
					cCity	:= ZX1->ZX1_CITY
					cDepart	:= ZX1->ZX1_DEPART	
		       	EndIf
			EndIf      	    
   
			//Grava o arquivo tempor·rio.
			cQuery := "INSERT INTO ##RELTEMP (DATARD, DATAPC, CURREN, ENTITY, CITY, LINE, DEPART, ACCOUN, INTERC, GLDESC, DEBIT, CREDIT) VALUES( "
			cQuery += "'"+DtoS(DATE())+"', "
			cQuery += "'"+TMPCT2->CT2_DATA+"', "
			cQuery += "'BRL', "
			cQuery += "'4003', "
			cQuery += "'"+cCity+"', "
			cQuery += "'"+cLine+"', "
			cQuery += "'"+cDepart+"', "
			cQuery += "'"+AllTrim(TMPCT2->CT2_CREDIT)+"', "
			cQuery += "'0000', "
			cQuery += "'"+AllTrim(cDescr)+"', "
			cQuery += "0, "
			cQuery += Alltrim(Str(TMPCT2->CT2_VALOR))+" )"
			
			TcSqlExec(cQuery)

		EndIf

		TMPCT2->(DbSkip())	
	EndDo
EndIf

TMPCT2->(DbCloseArea())

Return lRet

/*
Funcao  : Funcao4()
Objetivo: Imprime o relatÛrio
Autor   : Jo„o Silva
Data    : 27/10/2015
*/                   
*-----------------------*
Static Function Funcao4()
*-----------------------*
Local cHtml		:= ""
Local cLinha	:= ""
Local cQuery	:= ""
Local aTitCab	:= ""
Local lCor		:= .T.

//Para n„o causar estouro de variavel.
nHdl		:= FCREATE(cArq,0 )  //CriaÁ„o do Arquivo HTML.
nBytesSalvo	:= FWRITE(nHdl, cHtml ) // GravaÁ„o do seu Conteudo.
fclose(nHdl) // Fecha o Arquivo que foi Gerado

cHtml	:= ""
aTitCab	:= ""

//Apaga o arquivo de trabalho, se existir.
If Select("REL") > 0
	REL->(DbCloseArea())
EndIf
//Agrupando por ACCOUNT + City + Line + Depart
cQuery:= "SELECT DATARD,DATAPC,CURREN,ENTITY,CITY,LINE,DEPART,ACCOUN,INTERC,GLDESC " + CRLF
cQuery+= ",SUM(DEBIT)AS DEBIT,SUM(CREDIT) AS CREDIT " + CRLF
cQuery+= "  FROM ##RELTEMP " + CRLF
cQuery+= " GROUP BY DATARD,DATAPC,CURREN,ENTITY,CITY,LINE,DEPART,ACCOUN,INTERC,GLDESC " + CRLF
cQuery+= " ORDER BY ACCOUN " + CRLF

DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "REL", .F., .T.)
DbSelectArea("REL")

//CabeÁalho das colunas do relatÛrio
aTitCab1:= {'Report date',;
			'Pay cycle',;
			'Currency',;
			'Entity ID',;
			'City code',;
			'Line of Business',;
			'Department',;
			'GL account',;
			'Intercompany',;
			'GL description',;
			'Amount debit',;
			'Amount credit'} 
			
cHtml+='	<style type="text/css">'
cHtml+='	<!--'
cHtml+='	.Header {'
cHtml+='		color: #FFFFFF;'
cHtml+='		font-weight: bold;'
cHtml+='		background:#7E64A1;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='	}'
cHtml+='	.Linha1 {'
cHtml+='		color: #000000;'
cHtml+='		background:#C4B5D2;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para n„o quebrar a linha 
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	.Linha2 {'
cHtml+='		color: #000000;'
cHtml+='		background:#E0DCED;'
cHtml+='		font-family:Verdana;'
cHtml+='		font-size:9pt;
cHtml+='		white-space:nowrap;'//Para n„o quebrar a linha
cHtml+='		text-align: left;'
cHtml+='	}'
cHtml+='	-->'
cHtml+='	</style>'	
cHtml+='	<table border="1" bordercolor="#FFFFFF">'
cHtml+='		<tr>'

//Incluindo o cabeÁalho no relatÛrio
For xR := 1 to Len(aTitCab1)
	cHtml+='			<td class="Header"><p align="center"><strong>'+aTitCab1[xR]+'</strong></p></td>'
Next xR
cHtml+='		</tr>'

REL->(DbGoTop())
While REL->(!EOF()) 

	//Alterar cor da linha
	If lCor
		cLinha := "Linha1"
	Else
		cLinha := "Linha2"
	EndIf            
	
	lCor := !lCor

	cHtml+='		<tr>'             
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(DtoC(StoD(REL->DATARD)))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+Alltrim(DtoC(StoD(REL->DATAPC)))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+REL->CURREN+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+REL->ENTITY+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+REL->CITY+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+REL->LINE+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+'="'+REL->DEPART+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+REL->ACCOUN+'</td>' 
	cHtml+='			<td class="'+cLinha+'">'+'="'+REL->INTERC+'"</td>'
	cHtml+='			<td class="'+cLinha+'">'+REL->GLDESC+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+IIF(REL->DEBIT<=0,"",Alltrim(TRANSFORM((REL->DEBIT),"@R 99,999,999,999.99")))+'</td>'
	cHtml+='			<td class="'+cLinha+'">'+IIF(REL->CREDIT<=0,"",Alltrim(TRANSFORM((REL->CREDIT),"@R 99,999,999,999.99")))+'</td>'
	cHtml+='		</tr>'
	
	If LEN(cHtml) >= 50000
		cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	EndIf
		        
	REL->(DbSkip())
EndDo

cHtml+='		</tr>'
cHtml+='	</table>'

cHtml := Grv(cHtml) //Grava e limpa memoria da variavel.
	
//Abre o excel
GeraExcel()

Return

/*
Funcao      : Grv
Parametros  : cHtml
Retorno     : Nenhum
Objetivos   : Grava o conteudo da vari·vel cHtml em partes para n„o causar estouro de variavel
Autor     	: Renato Rezende  	 	
Data     	: 05/04/2016
*/
*------------------------------*
 Static Function Grv(cHtml)
*------------------------------*
Local nHdl	:= Fopen(cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cHtml )
fclose(nHdl)

Return ""

/*
Funcao  : GeraExcel()
Objetivo: FunÁ„o para abrir o excel
Autor   : Renato Rezende
Data    : 05/04/2016
*/                   
*-------------------------------*
Static Function GeraExcel()
*-------------------------------*

//VerificaÁ„o do arquivo (GRAVADO OU NAO) e definiÁ„o de valor de Bytes retornados.
If nBytesSalvo <= 0
	if ferror()	== 516
		MsgStop("Erro de gravaÁ„o do Destino, o arquivo deve estar aberto. Error = "+ str(ferror(),4),'Erro')
	Else
		MsgStop("Erro de gravaÁ„o do Destino. Error = "+ str(ferror(),4),'Erro')
    EndIf
Else
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	
	SHELLEXECUTE("open",(cArq),"","",5)   // Gera o arquivo em Excel ou Html
EndIf
 
REL->(DbSkip())
REL->(DbCloseArea())

Return

/*
FunÁ„o  : Funcao6
Objetivo: Verificar se os parametros est„o criados corretamente.
Autor   : Jo„o Silva
Data    : 27/10/2015
*/
*------------------------------*
Static Function Funcao6(cPerg)
*------------------------------*
Local lAjuste := .F.

Local nI := 0

Local aHlpPor := {}
Local aHlpEng := {}
Local aHlpSpa := {}
Local aSX1    := {	{"01","Data De ?"            },;
  					{"02","Data Ate ?"           },;
  					{"03","Da Conta ?"           },;
  					{"04","Ate Conta ?"          },;
  					{"05","Arquivo?"             },;
  					{"06","Abre Excel ?"         },;
  					{"07","Moeda ?"              },;
  					{"08","Impr. Cta S/ Movim ?" },;
  					{"09","Imprime C. Custo ?"   },;
  					{"10","Do Centro Custo ?"    },;
  					{"11","Ate Centro Custo ?"   },;
  					{"12","Imprime Item Contab ?"},;
  					{"13","Do Item Contabil ?"   },;
  					{"14","Ate Item Contabil ?"  },;
  					{"15","DescriÁ„o na Moeda ?" },;
  					{"16","Da Classe Valor ?"    },;
  					{"17","Ate Classe Valor ?"   }}
//Verifica se o SX1 estÅEcorreto
SX1->(DbSetOrder(1))
For nI:=1 To Len(aSX1)
	If SX1->(DbSeek(PadR(cPerg,10)+aSX1[nI][1]))
		If AllTrim(SX1->X1_PERGUNT) <> AllTrim(aSX1[nI][2])
			lAjuste := .T.
			Exit	
		EndIf
	Else
		lAjuste := .T.
		Exit
	EndIf	
Next

If lAjuste

    SX1->(DbSetOrder(1))
    If SX1->(DbSeek(AllTrim(cPerg)))
    	While SX1->(!EOF()) .and. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)

			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(MsUnlock())
    	
    		SX1->(DbSkip())
    	EndDo
	EndIf	

	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja o relatÛrio.") 
	
	U_PUTSX1(cPerg,"01","Data De ?","Data De ?","Data De ?","mv_ch1","D",08,0,0,"G","","","","S","mv_par01","","","","01/01/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Data Final a partir da qual ")
	Aadd( aHlpPor, "se deseja o relatÛrio.")
	
	U_PUTSX1(cPerg,"02","Data Ate ?","Data Ate ?","Data Ate ?","mv_ch2","D",08,0,0,"G","","","","S","mv_par02","","","","31/12/11","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Inicial a partir da qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio.") 
	Aadd( aHlpPor, "Caso queira imprimir todas as contas,") 
	Aadd( aHlpPor, "deixe esse campo em branco.") 
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"03","Da Conta ?","Da Conta ?","Da Conta ?","mv_ch3","C",20,0,0,"G","","CT1","","S","mv_par03","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a Conta Final atÅEa qual")
	Aadd( aHlpPor, "se desejÅEimprimir o relatÛrio.")
	Aadd( aHlpPor, "Caso queira imprimir todas as contas ")
	Aadd( aHlpPor, "preencha este campo com 'ZZZZZZZZZZZZZZZZZZZZ'.")
	Aadd( aHlpPor, "Utilize <F3> para escolher.")
	
	U_PUTSX1(cPerg,"04","Ate Conta ?","Ate Conta ?","Ate Conta ?","mv_ch4","C",20,0,0,"G","","CT1","","S","mv_par04","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor,"Diretorio e nome do Arquivo que ")
	Aadd( aHlpPor,"serÅEserÅEgerado.")
	
	U_PUTSX1(cPerg,"05","Arquivo?","Arquivo ?","Arquivo ?","mv_ch5","C",60,0,0,"G","","","","S","mv_par05","","","","D:\GTCTB001.xls","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Define se o arquivo serÅEaberto")
	Aadd( aHlpPor, "automaticamente no excel.")      
	
	U_PUTSX1(cPerg,"06","Abre Excel ?","Abre Excel ?","Abre Excel ?","mv_ch6","N",01,0,1,"C","","","","S","mv_par06","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe a moeda desejada para este")
	Aadd( aHlpPor, "relatÛrio.")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.") 
	
	U_PUTSX1(cPerg,"07","Moeda ?","Moeda ?","Moeda ?","mv_ch7","C",02,0,0,"G","","CTO","","S","mv_par07","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir ou n„o as")
	Aadd( aHlpPor, "contas sem movimento.")      
	Aadd( aHlpPor, "'Sim' - Imprime contas mesmo sem saldo ")
	Aadd( aHlpPor, "ou movimento.")   
	Aadd( aHlpPor, "'Nao' - Imprime somente contas com ")
	Aadd( aHlpPor, "movimento no periodo.   ")   
	Aadd( aHlpPor, "'Nao c/ Sld.Ant.' - Imprime somente  ")
	Aadd( aHlpPor, "contas com movimento ou com saldo")   
	Aadd( aHlpPor, "anterior.")   
	
	U_PUTSX1(cPerg,"08","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","Impr. Cta S/ Movim ?","mv_ch8","N",01,0,1,"C","","","","S","mv_par08","Sim","Sim","Sim","","Nao","Nao","Nao","Nao c/Sld Ant.","Nao c/Sld Ant.","Nao c/Sld Ant.","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Centros")
	Aadd( aHlpPor, "de Custo.")      
	
	U_PUTSX1(cPerg,"09","Imprime C. Custo ?","Imprime C. Custo ?","Imprime C. Custo ?","mv_ch9","N",01,0,1,"C","","","","S","mv_par09","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Centros")
	Aadd( aHlpPor, "de Custo, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime C. Custo?'")      
	
	U_PUTSX1(cPerg,"10","Do Centro Custo ?","Do Centro Custo ?","Do Centro Custo ?","mv_cha","C",09,0,0,"G","","CTT","","S","mv_par10","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Centro de Custo final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Centros ")    
	Aadd( aHlpPor, "de Custo, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime C. Custo?'")          
	
	U_PUTSX1(cPerg,"11","Ate Centro Custo ?","Ate Centro Custo ?","Ate Centro Custo ?","mv_chb","C",09,0,0,"G","","CTT","","S","mv_par11","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe se deseja imprimir os Itens")
	Aadd( aHlpPor, "Cont·beis.")      
	
	U_PUTSX1(cPerg,"12","Imprime Item Contab ?","Imprime Item Contab ?","Imprime Item Contab ?","mv_chc","N",01,0,1,"C","","","","S","mv_par12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil inicial a partir")
	Aadd( aHlpPor, "do qual se deseja imprimir o relatÛrio.")      
	Aadd( aHlpPor, "Caso queira imprimir todos os Itens")
	Aadd( aHlpPor, "Cont·beis, deixe esse campo em branco. ")      
	Aadd( aHlpPor, "Utilize <F3> para escolher.    ")
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta ")      
	Aadd( aHlpPor, "'Imprime Item Contab?'")      
	
	U_PUTSX1(cPerg,"13","Do Item Contabil ?","Do Item Contabil ?","Do Item Contabil ?","mv_chd","C",09,0,0,"G","","CTD","","S","mv_par13","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	Aadd( aHlpPor, "Informe o Item Cont·bil final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")          
	
	U_PUTSX1(cPerg,"14","Ate Item Contabil ?","Ate Item Contabil ?","Ate Item Contabil ?","mv_che","C",09,0,0,"G","","CTD","","S","mv_par14","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	aHlpPor := {}
	
	U_PUTSX1(cPerg,"15","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","DescriÁ„o na Moeda ?","mv_chf","C",02,0,0,"G","","CTO","","S","mv_par15","","","","01","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	aHlpPor := {}
	U_PUTSX1(cPerg,"16","Da Classe de Valor ?","Da Classe de Valor ?","Da Classe de Valor ?","mv_chg","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par16","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
	
	Aadd( aHlpPor, "Informe o Item Cont·bil final atÅEo qual")
	Aadd( aHlpPor, "se deseja imprimir o relatÛrio. Caso")
	Aadd( aHlpPor, "queira imprimir todos os Itens ")    
	Aadd( aHlpPor, "Cont·beis, preencha este campo com ")
	Aadd( aHlpPor, "'ZZZZZZZZZ'. ")
	Aadd( aHlpPor, "Utilize <F3> para escolher.   ")    
	Aadd( aHlpPor, "Obs: Esta pergunta depende da pergunta")
	Aadd( aHlpPor, "'Imprime Item Contab?'")     
   
	U_PUTSX1(cPerg,"17","Ate Classe de Valor ?","Ate Classe de Valor ?","Ate Classe de Valor ?","mv_chh","C",Len( CTH->CTH_CLVL ),0,0,"G","","CTH","","S","mv_par17","","","","","","","","","","","","","","","","",aHlpPor,aHlpEng,aHlpSpa)
EndIf
	
Return Nil
