#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#include "Fileio.ch"
#Include "MsOle.Ch"
/*
Funcao      : USX1001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Update para personalização do termo de abertura e encerramento
Autor       : Jean Victor Rocha
Data/Hora   : 28/02/12
Revisao     :
Obs.        :
*/  
*--------------------------------*
User Function USX1001(lAmbiente)
*--------------------------------*  
cArqEmp := "SigaMat.Emp"
__cInterNet := Nil
                                   	
Private cMessage
Private aArqUpd	 := {}
Private aREOPEN	 := {}
Private oMainWnd 
Private lOnlyTRM := .F.

Begin Sequence
   Set Dele On

   lHistorico := MsgYesNo("Deseja efetuar a atualização do Dicionário? Esta rotina deve ser utilizada em modo exclusivo ! Faça um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !", "Atenção")
   lOnlyTRM   := MsgYesNo("Deseja Atualizar apenas os arquivos TRM?", "Atenção")
   lEmpenho	  := .F.
   lAtuMnu	  := .F.

   Define Window oMainWnd From 0,0 To 01,30 Title "Atualização do Dicionário"

   Activate Window oMainWnd ;
       On Init If(lHistorico,(Processa({|lEnd| UPDProc(@lEnd)},"Processando","Aguarde, processando preparação dos arquivos...",.F.) , Final("Atualização efetuada!")),oMainWnd:End())

End Sequence
	   
Return     

/*
Funcao      : UPDProc
Objetivos   : Função de processamento da gravação dos arquivos.
*/
*---------------------------*
Static Function UPDProc(lEnd)
*---------------------------*
Local cTexto := "" ,cFile :="", cMask := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno := 0  , nI    := 0, nX    := 0, aRecnoSM0 := {}
Local lOpen  := .F., i     := 0

Local aChamados := {{05, {|| AtuSX1()}},;
			   		{05, {|| AtuSX6()}}}

Private NL := CHR(13) + CHR(10)

Begin Sequence

	ProcRegua(1)
	IncProc("Verificando integridade dos dicionários...")

   If ( lOpen := MyOpenSm0Ex() )
      dbSelectArea("SM0")
	  dbGotop()
	  If lOnlyTRM  
			cTexto += " - Selecionado apenas recriação do arquivo TRM."+CHR(13)+CHR(10)
			If SM0->(DBSEEK("YY")) .and. Ascan(aRecnoSM0,{ |x| x[2] == "YY"}) == 0 
				Aadd(aRecnoSM0,{Recno(),"YY"})
			EndIf
			If SM0->(DBSEEK("99")) .and. Ascan(aRecnoSM0,{ |x| x[2] == "99"}) == 0 
				Aadd(aRecnoSM0,{Recno(),"99"})
			EndIf
	  Else
		  While !Eof()
	  	     If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0 
				Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
			 EndIf
			 dbSkip()
		  EndDo
	  EndIf
	  


	  If lOpen
	     For nI := 1 To Len(aRecnoSM0)
		     SM0->(dbGoto(aRecnoSM0[nI,1]))
			 RpcSetType(2)
			 RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)  //Abre ambiente em rotinas automáticas
			 lMsFinalAuto := .F.
			 cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			 cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

	  		 /* Neste ponto o sistema disparará as funções
	  		    contidas no array aChamados para cada módulo. */

	  		 For i := 1 To Len(aChamados)
  	  		    nModulo := aChamados[i,1]
  	  		    ProcRegua(1)
			    IncProc("Analisando Dicionario de Dados...")
			    cTexto += EVAL( aChamados[i,2] )
			 Next

			 __SetX31Mode(.F.)
			 For nX := 1 To Len(aArqUpd)
			     IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				 If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				 EndIf
				 X31UpdTable(aArqUpd[nx])
				 If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+;
					      aArqUpd[nx] +;
					      ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2) 
					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				 EndIf
			 Next nX
			 RpcClearEnv()
			 If !( lOpen := MyOpenSm0Ex() )
				Exit 
			 EndIf 
		 Next nI 

		 If lOpen

			cTexto := "Log da atualizacao "+CHR(13)+CHR(10)+cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

			Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
			Define MsDialog oDlg Title "Atualizacao concluida." From 3,0 to 340,417 Pixel

			@ 5,5 Get oMemo  Var cTexto MEMO Size 200,145 Of oDlg Pixel
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
			Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			Activate MsDialog oDlg Center
		 EndIf
	  EndIf
   EndIf
End Sequence

Return(.T.)     
 
/*
Funcao      : MyOpenSM0Ex
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua a abertura do SM0 exclusivo
Autor       : Julio de Paula Paz
Data/Hora   : 18/12/2006 - 14:05
Revisao     :
Obs.        :
*/ 
*---------------------------*
Static Function MyOpenSM0Ex()                 	
*---------------------------*
Local lOpen := .F. 
Local nLoop := 0 

Begin Sequence
   For nLoop := 1 To 20
       dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. ) 
	   If !Empty( Select( "SM0" ) ) 
	      lOpen := .T. 
		  dbSetIndex("SIGAMAT.IND") 
		  Exit	
	   EndIf
	   Sleep( 500 ) 
   Next nLoop 

   If !lOpen
      Aviso( "Atencao !", "Não foi possível a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
   EndIf                                 
End Sequence

Return( lOpen )              

*------------------------------*
Static Function AtuSX1(oProcess)
*------------------------------*
Local cTexto	:= "" 
Local aGrupos	:= {}
Local i, j
Local nPos		:= 0
Local nTam		:= 0
Local aSx1		:= {}

Local aHelpP  := {}
Local aHelpE  := {}
Local aHelpS  := {}

aAdd(aGrupos, "MTR930")
aAdd(aGrupos, "MTR984")
aAdd(aGrupos, "MTR910")
aAdd(aGrupos, "MTR470")
aAdd(aGrupos, "MTR460")
aAdd(aGrupos, "MTR943")
aAdd(aGrupos, "MTR941")

U_PUTSX1("MTR930"		,"36"				,"Operações a imprimir?"	,"Operações a imprimir?"	,"Operações a imprimir?"	,"mv_chz","N",1	,0,1,"C",""						,"","","","mv_par36"				,"Estaduais","Estaduais","Estaduais",""								,"Interestaduais","Interestaduais","Interestaduais"	,"Totalidade"	,"Totalidade"	,"Totalidade"	,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"37"		 		,"Imprime Mapa Resumo ?"	,"Emite Mapa Resumo ?"		,"Printed Map Summary ?"	,"mv_chz","N",01,0,2,"C","MatxRValPer(mv_par37)","","","","mv_par37"				,"Sim"		,"Si"		,"Yes"		,""					   			,"Nao"	   		,"No"			,"No"				,""				,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"38"				,"Imprime Imposto Res/Comp?","Emite Impuesto Res/Comp?"	,"Print Tax Res/Comp?"		,"mv_chz","N",01,0,2,"C",""						,"","","","mv_par38"				,"Sim"		,"Sim"		,"Sim"		,""					   			,"Nao"	   		,"Nao"			,"Nao"				,""				,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"39"		 		,"Artigo para Impressão"	,"Artigo para Impressão"	,"Artigo para Impressão"	,"mv_chz","N",01,0,1,"C",""						,"","","","mv_par39"				,"Artigo 25","Artigo 25","Artigo 25",""						   		,"Artigo 26"	,"Artigo 26"	,"Artigo 26"		,"Artigo 80"	,"Artigo 80"	,"Artigo 80"	,"Artigo 81","Artigo 81","Artigo 81","","","",aHelpP,aHelpE,aHelpS) 
U_PUTSX1("MTR930"		,"40"				,"Seleciona Filiais ?"		,"Seleciona Filiais ?"		,"Seleciona Filiais ?"		,"mv_chz","N",01,0,2,"C",""						,"","","","mv_par40"				,"Sim"		,"Si"		,"Yes"		,""						   		,"Nao"	   		,"No"			,"No"				,""		   		,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"41"				,"Série no Termo ?"			,"Série no Termo  ?"		,"Série no Termo ?"			,"mv_chz","N",1	,0,2,"C",""						,"","","","mv_par41"				,"Sim"		,"Si"		,"Yes"		,""						   		,"Nao"	   		,"No"			,"No"				,""		   		,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"42"				,"Série/SubSérie"			,"Série/SubSérie"			,"Série/SubSérie"	   		,"mv_chz","C",5	,0,0,"G",""						,"","","","mv_par42"				,""			,""	   		,""	   		,""						  		,""		   		,""				,""					,""		   		,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR930"		,"43"				,"Impr. ICMS/IPI Zerado ?"	,"Impr. ICMS/IPI Zerado ?"	,"Impr. ICMS/IPI Zerado ?"	,"mv_chz","N",1	,0,0,"C",""						,"","","","mv_par43"				,"Sim"		,"Si"		,"Yes"		,""						  		,"Nao"	  		,"No"	  		,"No"	 			,""		   		,""				,""				,""			,""			,""			,"","","",aHelpP,aHelpE,aHelpS)
cTexto += "Atualizado os Perguntes Padrões para o Grupo MTR930"+CHR(13)+CHR(10)

U_PUTSX1("MTR984"		,"01"				,"Data Inicial "	 		,"?Fecha Inicial ?"					,"Initial Date ?" 			,"mv_ch1"	,"D"	,08, 0 , ,"G","","","","","mv_par01","","",""         ,"01/01/2009","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"02"				,"Data Final "				,"?Fecha Final ?"   				,"Final Date ?"				,"mv_ch2"	,"D"	,08, 0 , ,"G","","","","","mv_par02","","",""         ,"31/12/2009","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"03"				,"Pagina Inicial "			,"?De Pagina ?"						,"Initial Page ?"			,"mv_ch3"	,"N"	,05, 0 , ,"G","","","","","mv_par03","","",""         ,"1","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"04"				,"Numero do Livro "			,"?Numero del Libro ?"				,"Book Number ?"			,"mv_ch4"	,"C"	,02, 0 , ,"G","","","","","mv_par04","","","","01","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"05"				,"Imprime "					,"?Imprime ?"   					,"Print ?"					,"mv_ch5"	,"N"	,01, 0 ,1,"C","","","","","mv_par05","So Livro","So Livro","So Livro","","Livro e Termos","Livro e Termos","Livro e Termos","So Termos","So Termos","So Termos","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"06"				,"Livro Selecionado " 		,"?Libro Seleccionado ?"			,"Selected Book ?"			,"mv_ch6"	,"C"	,01, 0 , ,"G","","","","","mv_par06","","","","*","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"07"				,"Nro. C.C.M. ?"			,"?Num. C.C.M. ?"					,"C.C.M. Number ?"			,"mv_ch7"	,"C"	,18, 0 , ,"G","","","","","mv_par07","","","","12121212121212","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"08"				,"Total Diario ?"			,"?Total Diario ?"					,"Daily Total ?"			,"mv_ch8"	,"N"	,01, 0 ,2,"C","","","","","mv_par08","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"09"				,"Tipo de Totalizacao "		,"?Tipo de totalizacion ?"			,"Total Type ?"				,"mv_ch9"	,"N"	,01, 0 , ,"C","","","","","mv_par09","Decendial","Decendial","Decendial","","Quinzenal","Quinzenal","Quinzenal","Mensal","Mensal","Mensal","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"10"				,"Imp. Guia Recolhimento ?"	,"?Imp. Formulario Recaudacion ?"	,"Tax Payment Form ?"		,"mv_cha"	,"N"	,01, 0 , ,"C","","","","","mv_par10","Sim","Sim","Sim",""          ,"Nao","Nao","Nao","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"11"				,"Modelo do Registro "		,"?Modelo del Registro ?"			,"Record Model ?"			,"mv_chb"	,"N"	,01, 0 , ,"C","","","","","mv_par11","132 Colunas","132 Colunas","132 Colunas","","220 Colunas","220 Colunas","220 Colunas","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"12"				,"No.Processo Reg.Esp "		,"?No.Proceso Reg.Esp ?"			,"Sp. Reg. Process Nbr. ?"	,"mv_chc"	,"C"	,20, 0 , ,"G","","","","","mv_par12","","","","","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"13"				,"Pagina Final "            ,"?Pagina Final ?"					,"Final page ?"				,"mv_chd"	,"N"	,04, 0 ,1,"G","","","","","mv_par13","","","","","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"14"				,"Quantidade de Folhas "    ,"?Cantidad de hojas ?"				,"Number of pages ?"		,"mv_che"	,"N"	,04, 0 ,1,"G","","","","","mv_par14","","","","","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"15"				,"Imprime Mapa Resumo ?"    ,"Emite Mapa Resumo ?"              ,"Printed Map Summary ?"    ,"mv_chf"   ,"N"    ,01, 0 ,2,"C","MatxRValPer(mv_par15)","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR984"		,"16"				,"Aglutina lançamentos ? "	,"Aglutina lançamentos ? "			,"Aglutina lançamentos ? "	,"mv_chg"	,"N"	,01, 0 , ,"C","","","","","mv_par16","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",aHelpP,aHelpE,aHelpS)
cTexto += "Atualizado os Perguntes Padrões para o Grupo MTR984"+CHR(13)+CHR(10)
 
nTam := TamSX3("B2_LOCAL")[1]
U_PUTSX1("MTR470", "01", "Do Produto ?",           "¿De Producto ?",                 "From Product ?",        "mv_ch1", "C", 15, 0, 0, "G", "",           "SB1", "", "S", "mv_par01", "",          "",           "",           "",                    "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "02", "Até o Produto ?",        "¿A Producto ?",                  "To Product ?",          "mv_ch2", "C", 15, 0, 0, "G", "",           "SB1", "", "S", "mv_par02", "",          "",           "",           "ZZZZZZZZZZZZZZZ",     "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "03", "Do tipo ?",              "¿De Tipo ?",                     "From Type ?",           "mv_ch3", "C",  2, 0, 0, "G", "",           "02",  "", "S", "mv_par03", "",          "",           "",           "",                    "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "04", "Até o Tipo ?",           "¿A Tipo ?",                      "To Type ?",             "mv_ch4", "C",  2, 0, 0, "G", "",           "02",  "", "S", "mv_par04", "",          "",           "",           "ZZ",                  "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "05", "Do Período ?",           "¿De Periodo ?",                  "From Period ?",         "mv_ch5", "D",  8, 0, 0, "G", "",           "",    "", "S", "mv_par05", "",          "",           "",           "'01/01/06'",          "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "06", "Até o Período ?",        "¿A Periodo ?",                   "To Period ?",           "mv_ch6", "D",  8, 0, 0, "G", "",           "",    "", "S", "mv_par06", "",          "",           "",           "'31/12/06'",          "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "07", "Lista Prods S/Movim ?",  "¿Lista Prod.sin Mov ?",          "List Prod.w/no Mov. ?", "mv_ch7", "N",  1, 0, 2, "C", "",           "",    "", "S", "mv_par07", "Sim",       "Si",         "Yes",        "",                    "Nao",            "No",             "No",              "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "08", "Do Armazem ?",           "¿De Deposito ?",                 "From Warehouse ?",      "mv_ch8", "C",  nTam, 0, 0, "G", "MTR470VAlm", "",    "", "S", "mv_par08", "",          "",           "",           "01",                  "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "09", "Até o Armazem ?",        "¿A Deposito ?",                  "To Warehouse ?",        "mv_ch9", "C",  nTam, 0, 0, "G", "",           "",    "", "S", "mv_par09", "",           "",          "",           "01",                  "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "10", "Doc / Sequência ?",      "¿Doc. / Secuencia ?",            "Document/Sequence ?",   "mv_cha", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par10", "Documento", "Documento",  "Document",   "",                    "Sequencia",      "Secuencia",      "Sequence",        "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "11", "Qual a Moeda ?",         "¿Que Moneda ?",                  "Which Currency ?",      "mv_chb", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par11", "1a Moeda",  "1ª Moneda",  "Currency 1", "",                    "2a Moeda",       "2ª Moneda",      "Currency 2",      "3a Moeda", "3ª Moneda", "Currency 3", "4a Moeda", "4ª Moneda", "Currency 4", "5a Moeda", "5ª Moneda", "Currency 5",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "12", "Página Inicial ?",       "¿De Pagina ?",                   "Initial Page ?",        "mv_chc", "N",  6, 0, 0, "G", "",           "",    "", "S", "mv_par12", "",          "",           "",           "1",                   "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "13", "Quant. Páginas ?",       "¿Cantidad Paginas ?",            "Total No.of Pages ?",   "mv_chd", "N",  6, 0, 0, "G", "",           "",    "", "S", "mv_par13", "",          "",           "",           "500",                 "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "14", "Número do Livro ?",      "¿Numero del Libro ?",            "Tax Record Number ?",   "mv_che", "C",  2, 0, 0, "G", "",           "",    "", "S", "mv_par14", "",          "",           "",           "01",                  "",               "",               "",                "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "15", "Imprimir ?",             "¿Imprimir ?",                    "Print ?",               "mv_chf", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par15", "So Livro",  "Solo Libro", "Only Book",  "", "Livro e Termos",  "Libros y Actas", "Book and Terms", "So Termos",       "Solo Actas", "Terms Only", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "16", "Totaliza por dia ?",     "¿Calc.Total por Dia ?",          "Total per Day ?",       "mv_chg", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par16", "Sim",       "Si",         "Yes",        "",                    "Nao",            "No",             "No",              "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "17", "Prod s/Mov c/ Saldo ?",  "¿Prod.  s/Mov. c/Saldo ?",       "Pr.w/No Mov. w/Bal. ?", "mv_chh", "C",  1, 0, 2, "C", "",           "",    "", "S", "mv_par17", "Lista",     "Lista",      "List",       "",                    "Nao Lista",      "No Lista",       "Do Not List",     "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "18", "Outras Moedas ?",        "¿Otras Monedas ?",               "Other Currencies ?",    "mv_chi", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par18", "Converter", "Convertir",  "Convert",    "",                    "Nao imprimir",   "No imprimir",    "Do Not Print",    "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "19", "Quebrar Paginas ?",      "¿Saltar Paginas ?",              "Page Break ?",          "mv_chj", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par19", "Por Feixe", "Por Fajo",   "Per Sheaf",  "",                    "Por Mes/Feixe",  "Por Mes/Fajo",   "Per Month/Sheaf", "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "20", "Desp nas NFs sem IPI ?", "¿Gastos en las Fact. sin IPI ?", "Invoics.Exp.w/o IPI ?", "mv_chl", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par20", "Nao Soma",  "No Suma",    "Do Not Add", "",                    "Soma",           "Suma",           "Add",             "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", "21", "Reiniciar Paginas ?",    "¿Reiniciar Paginas ?",           "Restart Page ?",        "mv_chm", "N",  1, 0, 1, "C", "",           "",    "", "S", "mv_par21", "Sim",       "Si", 	       "Yes",        "",                    "Nao",            "No",             "No",              "", "", "", "", "", "", "", "", "",aHelpP,aHelpE,aHelpS)
U_PUTSX1("MTR470", '22',	'Seleciona Filiais ?',	'¿Selecciona sucursales?',	'Select branch offices?', 		'mv_chn', 'N',	1,0,  2, 'C', '',			'',		'',	'',	'mv_par22',	'Sim' 	,	'Si',  			'Yes', 		'',						'Nao', 				'No',  			'No',  				'',	'',	'',	'',	'',	'',	'',	'',	'',aHelpP,aHelpE,aHelpS)
cTexto += "Atualizado os Perguntes Padrões para o Grupo MTR470"+CHR(13)+CHR(10)

U_PUTSX1( "MTR460","11","Qtd Páginas/Feixes?"		,"Ctd. Paginas/Resma?","Qtty Pages/Bundle"					,"mv_chb","N",5,0,0,"G","","","",""							,"mv_par11","","","","","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1( "MTR460","19","Quanto a quebra por aliquota ?","",""												,"mv_chj","N",1,0,1,"C","","","",""							,"mv_par19","Nao Quebrar","","","","Icms Produto","","","Icms Reducao","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1( "MTR460","20","Lista MOD Processo?"		,"¨Lista MOD Processo?","Lista MOD Processo?"				,"mv_chk","N",1,0,2,"C","","","",""							,"mv_par20","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1(	'MTR460','21','Seleciona filiais?'		,'¿Selecciona sucursales?','Select branch offices?'			,'mv_chl','N',1,0,2,'C','','','',''							,'mv_par21','Sim','Si','Yes','','Nao','No','No','','','','','','','','','',aHelpP,aHelpE,aHelpS)
U_PUTSX1( "MTR460","22","Quebrar por Sit.Tributaria?","",""													,"mv_chn","N",1,0,2,"C","","","",""							,"mv_par22","Sim","","","","Nao","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1( "MTR460","23","Gerar Arq. Exportacao?"	,"",""														,"mv_cho","N",1,0,2,"C","","","",""							,"mv_par23","Sim","","","","Nao","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
U_PUTSX1( "MTR460","24","Arquivo Exp. Sped Fiscal?","",""														,"mv_chp","C",8,0,0,"G","","","",""							,"mv_par24","","","","","","","","","","","","","","","","",aHelpP,aHelpE,aHelpS)
cTexto += "Atualizado os Perguntes Padrões para o Grupo MTR460"+CHR(13)+CHR(10)

SX1->(DbSetOrder(1))
SET DELETE OFF
For i:=1 to Len(aGrupos)
	If SX1->(DbSeek(aGrupos[i]))
		While SX1->(!EOF()) .and. ALLTRIM(SX1->X1_GRUPO) == aGrupos[i]
			If	!(AllTrim(SX1->X1_PERGUNT) == "Admin 1 ?"		.or. AllTrim(SX1->X1_PERGUNT) == "Admin 2 ?"		.or.;
				AllTrim(SX1->X1_PERGUNT) == "Contador 1?"	.or. AllTrim(SX1->X1_PERGUNT) == "Contador 2?"	.or. AllTrim(SX1->X1_PERGUNT) == "Contador 3?")
				nPos := VAL(SX1->X1_ORDEM)
			Else
				SX1->(RecLock("SX1",.F.))
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
			SX1->(DbSkip())
		EndDo
	EndIf
	aAdd(aSX1, {aGrupos[i]	,STRZERO(nPos+1,2)	, "Admin 1 ?"	, "Admin 1 ?"	, "Admin 1 ?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par"+STRZERO(nPos+1,2),""		,""	,""	,"JOSÉ TAVARES DE LUCENA       .","","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
	aAdd(aSX1, {aGrupos[i]	,STRZERO(nPos+2,2)	, "Admin 2 ?"	, "Admin 2 ?"	, "Admin 2 ?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par"+STRZERO(nPos+2,2),""		,""	,""	,"CPF: 918.938.528-49          .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
	aAdd(aSX1, {aGrupos[i]	,STRZERO(nPos+3,2)	, "Contador 1?"	, "Contador 1?"	, "Contador 1?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par"+STRZERO(nPos+3,2),""		,""	,""	,"JOBELINO VITORIANO LOCATELI  .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
	aAdd(aSX1, {aGrupos[i]	,STRZERO(nPos+4,2)	, "Contador 2?"	, "Contador 2?"	, "Contador 2?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par"+STRZERO(nPos+4,2),""		,""	,""	,"CPF: 035.964.518-68          .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})
	aAdd(aSX1, {aGrupos[i]	,STRZERO(nPos+5,2)	, "Contador 3?"	, "Contador 3?"	, "Contador 3?"		,"mv_chz","C",30,0,0,"G",""	,"mv_par"+STRZERO(nPos+5,2),""		,""	,""	,"CRC: 1SP073639/0-0           .","","","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", "", "", "S", "", "", "", ""})

	If SM0->M0_CODIGO == "YY" .or. SM0->M0_CODIGO == "99"//Cria apena 1 vez...para todas empresas. Considera que todas as empresas irão possuir X1 igual a empresa modelo.
		CriaTRM(aGrupos[i],nPos)
		cTexto += "Criado arquivo .TRM para o Grupo '"+aGrupos[i]+"'"+CHR(10)+CHR(13)
	EndIf
Next i

aSX1Estrut:= { "X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA" ,"X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL",;
               "X1_PRESEL" ,"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01"  ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02",;
               "X1_DEF02"  ,"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03"  ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
               "X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05"  ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5",;
               "X1_CNT05"  ,"X1_F3"     ,"X1_PYME"   ,"X1_GRPSXG" ,"X1_HELP"   ,"X1_PICTURE","X1_IDFIL" }

DbSelectArea("SX1")
SX1->(DbSetOrder(1))

For i:= 1 To Len(aSX1)
	RecLock("SX1",.T.)
	For j:=1 To Len(aSX1[i])
		If FieldPos(aSX1Estrut[j])>0 .And. aSX1[i,j] != NIL
			FieldPut(FieldPos(aSX1Estrut[j]),aSX1[i,j])
		EndIf
	Next j
	dbCommit()
	MsUnLock()
	cTexto += "Pergunte atualizado: "+aSX1[i][1]+aSX1[i][2]+CHR(13)+CHR(10)
Next i
	
Return cTexto

*------------------------------*
Static Function AtuSX6(oProcess)
*------------------------------*
Local cTexto := "" 
Local aDefine:= {}
Local i
                                                            
If lOnlyTRM
	Return cTexto
EndIf

IncProc("Atualizando Parametros!")

aAdd(aDefine, {"LENTAB"	,"MV_LENTAB","LENTAB_P.TRM"})//"MTR930"
aAdd(aDefine, {"LENTEN"	,"MV_LENTEN","LENTEN_P.TRM"})//"MTR930"
aAdd(aDefine, {"LISSAB"	,"MV_LISSAB","LISSAB_P.TRM"})//"MTR984"
aAdd(aDefine, {"LISSEN"	,"MV_LISSEN","LISSEN_P.TRM"})//"MTR984"
aAdd(aDefine, {"LSAIAB"	,"MV_LSAIAB","LSAIAB_P.TRM"})//"MTR930"
aAdd(aDefine, {"LSAIEN"	,"MV_LSAIEN","LSAIEN_P.TRM"})//"MTR930"
aAdd(aDefine, {"LMOD3AB","MV_LMOD3AB","LMOD3AB_P.TRM"})//"MTR470" "MTR910"
aAdd(aDefine, {"LMOD3EN","MV_LMOD3EN","LMOD3EN_P.TRM"})//"MTR470" "MTR910"
aAdd(aDefine, {"LMOD7AB","MV_LMOD7AB","LMOD7AB_P.TRM"})//"MTR460"
aAdd(aDefine, {"LMOD7EN","MV_LMOD7EN","LMOD7EN_P.TRM"})//"MTR460"
aAdd(aDefine, {"LMOD8AB","MV_LMOD8AB","LMOD8AB_P.TRM"})//"MTR943"
aAdd(aDefine, {"LMOD8EN","MV_LMOD8EN","LMOD8EN_P.TRM"})//"MTR943" 
aAdd(aDefine, {"LMOD9AB","MV_LMOD9AB","LMOD9AB_P.TRM"})//"MTR941"
aAdd(aDefine, {"LMOD9EN","MV_LMOD9EN","LMOD9EN_P.TRM"})//"MTR941"

SX6->(DbSetOrder(1))
For i:=1 to Len(aDefine)
	If SX6->(DbSeek(xFilial() + aDefine[i][2]))
		If SX6->(RecLock("SX6",.F.))
			SX6->X6_CONTEUD := aDefine[i][3]
			SX6->X6_CONTSPA := aDefine[i][3]
			SX6->X6_CONTENG := aDefine[i][3]
			cTexto += "Atualizado Parametro '"+aDefine[i][2]+"' atualizado para '"+aDefine[i][3]+"'"+CHR(10)+CHR(13)
			SX6->(MSUNLOCK())
		EndIf
	EndIf
Next i

Return cTexto

*-------------------------------------*
Static Function CriaTRM(cPergunte,npos)
*-------------------------------------*
Private cTextoAb	:= ""
Private cTextoEn  := ""

Do Case
	Case cPergunte == "MTR930"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Saidas nr. MV_PAR05, contem MV_PAR07 folhas, "	+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "												+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"										+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE,    "					+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Fazenda"						+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."																	+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Saidas nr. MV_PAR05, com MV_PAR07 folhas, "			+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LSAIAB_P.TRM","LSAIEN_P.TRM")
		cTextoAb := ""
		cTextoEn := ""
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Entradas nr. MV_PAR05, contem MV_PAR07 folhas, "+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE,"+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Entradas nr. MV_PAR05, com MV_PAR07 folhas,"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LENTAB_P.TRM","LENTEN_P.TRM")

	Case cPergunte == "MTR984"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Imposto Sobre Servicos nr. MV_PAR05,"+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE,"+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Imposto Sobre Servicos nr. MV_PAR05,"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LISSAB_P.TRM","LISSEN_P.TRM")
		
	Case cPergunte == "MTR910"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Controle de Producao e Estoque Mod.3 nr. MV_PAR13, contem MV_PAR12, "+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE,"+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Controle de Producao e Estoque mod. 3 nr. MV_PAR13, com MV_PAR12,"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LMOD3AB_P.TRM","LMOD3EN_P.TRM")		

	Case cPergunte == "MTR460"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Invetario mod. 7 nr. MV_PAR12, contem MV_PAR11, "+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE,"+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Inventario mod. 7 nr. MV_PAR12, com MV_PAR11,"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LMOD7AB_P.TRM","LMOD7EN_P.TRM")

	Case cPergunte == "MTR943"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Apuracao de IPI nr. MV_PAR10, contem MV_PAR08,"+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE."+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Secretaria da Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC."+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Apuracao de IPI nr. MV_PAR10, com MV_PAR08"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LMOD8AB_P.TRM","LMOD8EN_P.TRM")		

	Case cPergunte == "MTR941"
		cTextoAb += "                                   Este Livro servira como Livro de Registro de Apuracao de ICMS nr. MV_PAR15, contem MV_PAR13,"+CHR(13)+CHR(10)
		cTextoAb += "                                   numeradas tipograficamente, da M0_NOMECOM, "+CHR(13)+CHR(10)
		cTextoAb += "                                   sita na M0_ENDENT, na Cidade de M0_CIDENT-M0_ESTENT,"+CHR(13)+CHR(10)
		cTextoAb += "                                   registrada na Junta Comercial sob nr. M0_NIRE, na secao de M0_DTRE."+CHR(13)+CHR(10)
		cTextoAb += "                                   inscrita no Cadastro Geral de Contribuintes sob nr.M0_CGC e na Secretaria da Fazenda"+CHR(13)+CHR(10)
		cTextoAb += "                                   Estadual sob o nr.M0_INSC.  "+CHR(13)+CHR(10)
		cTextoEn += "                                   O presente Livro serviu de Registro de Apuracao de ICMS nr. MV_PAR15, com MV_PAR13"+CHR(13)+CHR(10)
		cTextoEn += "                                   numeradas tipograficamente, da M0_NOMECOM."+CHR(13)+CHR(10)
		CriaArq(CriaTRMAB(npos,cTextoAb),CriaTRMEN(npos,cTextoEn),"LMOD9AB_P.TRM","LMOD9EN_P.TRM")
		
EndCase

Return .T.

*----------------------------------------------------*
Static Function CriaArq(cContAB,cContEn,cArqAB,cArqEn)
*----------------------------------------------------*
Private cDir		:="\SYSTEM\"
Private nHdl
Private cNameArqAB := cArqAB
Private cNameArqEn := cArqEn

Private cTermo:= ""
Private cFile := ""
Private cCpt  := "XXXXXXXXXX"
Private nOpca := 0

If File(Alltrim(cDir)+cNameArqAB)
	fErase(Alltrim(cDir)+cNameArqAB)
EndIf  
nHdl:= MSFCREATE(Alltrim(cDir)+cNameArqAB,0)
FWrite(nHdl, cContAB)
FClose(nHdl)

cTermo:= ""
cFile := cDir + cNameArqAB
RestFile()

If File(Alltrim(cDir)+cNameArqEN)
	fErase(Alltrim(cDir)+cNameArqEN)
EndIf
nHdl:= MSFCREATE(Alltrim(cDir)+cNameArqEN,0)
FWrite(nHdl, cContEN)
FClose(nHdl) 

cTermo:= ""
cFile := cDir + cNameArqEN
RestFile()

Return .T.
 
*------------------------------------*
Static Function CriaTRMAB(nPos,cTextoAB)
*------------------------------------*
Local cRet := ""
Local i
       
For i:=1 to 19
	cRet += CHR(10)+CHR(13)
Next i
cRet += "                                                                     Termo de Abertura"+CHR(13)+CHR(10)
cRet += "                                                                     ================="+CHR(13)+CHR(10)
For i:=1 to 7
	cRet += CHR(10)+CHR(13)
Next i
cRet += cTextoAB
For i:=1 to 6
	cRet += CHR(10)+CHR(13)
Next i
cRet += "                                         ___________________________________      ___________________________________         "+CHR(13)+CHR(10)
cRet += "                                           MV_PAR"+STRZERO(nPos+1, 2)+"           MV_PAR"+STRZERO(nPos+3, 2)+"     "+CHR(13)+CHR(10)
cRet += "                                           MV_PAR"+STRZERO(nPos+2, 2)+"           MV_PAR"+STRZERO(nPos+4, 2)+"     "+CHR(13)+CHR(10)
cRet += "                                                                                     MV_PAR"+STRZERO(nPos+5, 2)+"     "+CHR(13)+CHR(10)

Return cRet

*------------------------------------*
Static Function CriaTRMEN(nPos,cTextoEN)
*------------------------------------*
Local cRet := ""
Local i

For i:=1 to 19
	cRet += CHR(10)+CHR(13)
Next i
cRet += "                                                                    Termo de Encerramento"+CHR(13)+CHR(10)
cRet += "                                                                    ====================="+CHR(13)+CHR(10)
For i:=1 to 7
	cRet += CHR(10)+CHR(13)
Next i
cRet += cTextoEN
For i:=1 to 6
	cRet += CHR(10)+CHR(13)
Next i
cRet += "                                         ___________________________________      ___________________________________         "+CHR(13)+CHR(10)
cRet += "                                           MV_PAR"+STRZERO(nPos+1, 2)+"           MV_PAR"+STRZERO(nPos+3, 2)+"     "+CHR(13)+CHR(10)
cRet += "                                           MV_PAR"+STRZERO(nPos+2, 2)+"           MV_PAR"+STRZERO(nPos+4, 2)+"     "+CHR(13)+CHR(10)
cRet += "                                                                                     MV_PAR"+STRZERO(nPos+5, 2)+"     "+CHR(13)+CHR(10)

Return cRet

//Utilizado estas funções abaixo para compatibilizar o tipo de arquivo, pois caso não execute-as o arquivo é criado com o tipo
//UNIX, sendo que deve ser criado com o tipo DOS/WINDOWS
*------------------------*
Static Function RestFile()
*------------------------*
Local xBuffer
Local nTamArq
Local cFileback :=cFile
Local oDlg 

nTerHdl :=FOPEN(cFile,2+64)
nTamArq :=FSEEK(nTerHdl,0,2)
xBuffer :=Space(nTamArq)
FSEEK(nTerHdl,0,0)
FREAD(nTerHdl,@xBuffer,nTamArq)
cTermo  :=xBuffer
FCLOSE(nTerHdl)

DEFINE MSDIALOG oDlg FROM 134,10  TO 400,612 TITLE OemToAnsi(cCpt+" "+"Termos de Abertura e Encerramento"+Space(05)+cFile) PIXEL
	
DEFINE FONT oFontTST NAME "Courier New" SIZE 6,15   
@ 02,01 GET oTermo VAR cTermo SIZE 299, 116 OF oDlg FONT oFontTST PIXEL MEMO
oTermo:bRClicked := {||AllwaysTrue()}
DEFINE SBUTTON FROM 121, 273 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
ACTIVATE MSDIALOG oDlg //on init (oDlg:End())

nTerHdl:=MSFCREATE(cFile,0)
FSEEK(nTerHdl,0,0)
If  !Empty(cTermo)
	FWRITE(nTerHdl,cTermo)
Endif
FCLOSE(nTerHdl)
Commit

Return
