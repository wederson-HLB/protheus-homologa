#Include "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Rua Jose Oscar Abreu Sampaio, 113 - Sao Paulo - SP         ³±±
±±³          ³ Fone: (11) 3853-6470                                       ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa  ³ KPMAAF01  ³ Autor ³ Larson Zordan        ³ Data ³10/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera um arquivo TXT com os lancamentos contabeis           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ KPMAAF01(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ KPMG - AAF                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

/*
Funcao      : KPMAAF01()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera um arquivo TXT com os lancamentos contabeis.
Autor       : AKRON Projetos e Sistemas
Data/Hora   : 10/06/2013
Revisão		: Renato Rezende
Data/Hora   : 16/04/2014
*/ 
*--------------------------*
 User Function KPMAAF01()
*--------------------------*

Local cPerg  		:= "KPMAAF01"
Local cFunction		:= "KPMAAFP"
Local cTitle		:= "Gera Arquivo TXT dos Lançamentos Contábeis"
Local bProcess		:= { |oSelf| KPMAAFPROC(oSelf) }
Local cDescription	:= "Esta rotina irá gerar um arquivo padrão TXT dos lançamentos contábeis (Tabela CT2), conforme os parâmetros definidos pelo usuário."+CRLF+"Independente do período informado, a rotina irá gerar um arquivo separado por mês/ano."

PutSx1(cPerg,"01","Da Data do Laçamento          ","","","mv_ch1","D",08,0,1,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",{"Informe a Data Inicial dos","Lançamentos Contábeis a ser","considerado no filtro da rotina."},{},{})
PutSx1(cPerg,"02","Até a Data do Laçamento       ","","","mv_ch2","D",08,0,1,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",{"Informe a Data Final dos"  ,"Lançamentos Contábeis a ser","considerado no filtro da rotina."},{},{})
PutSx1(cPerg,"03","Informe o Local do Arquivo    ","","","mv_ch3","C",50,0,1,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",{"Informe o Local onde será" ,"gerado o arquivo TXT dos"   ,"Lançamentos Contábeis.          "},{},{})

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ KPMAAFPROC ³ Autor ³ Larson Zordan         ³ Data ³10/06/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o processamento para a geracao do aquivo TXT         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                  
±±³ Uso      ³ KPMG - AAF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
*-----------------------------------*                                                                        
 Static Function KPMAAFPROC(oSelf)
*-----------------------------------* 
 
Local aMesAno := {}
Local cArqTXT := ""
Local cLinha  := ""
Local cQuery  := ""
Local cPath   := If(Empty(mv_par03), GetTempPath(), AllTrim(mv_par03) )
Local dData   := mv_par01
Local nHdl    := 0
Local nPos    := 0
Local nX      := 0

//--> Cria aMesAno para controle dos lancamentos contabeis para a geracao do arquivo TXT separado por Mes/Ano
While dData <= mv_par02
	nPos := aScan( aMesAno , { |x| x[1] == Str(Year(dData),4)+StrZero(Month(dData),2) })
	If nPos == 0
		aAdd( aMesAno , { Str(Year(dData),4)+StrZero(Month(dData),2), DtoS(dData), DtoS(dData) })
	Else
		aMesAno[nPos,3] := DtoS(dData)
	EndIf
	dData ++
EndDo

//--> Inicia a Geracao do TXT
oSelf:SetRegua1(Len(aMesAno))

For nX := 1 To Len(aMesAno)
	
	oSelf:IncRegua1(" Processando Ano/Mês: "+Transform(aMesAno[nX,1],"@R 9999/99") )	

	If oSelf:lEnd
		lEnd := .T.
		Exit
	EndIf
	
	cQuery := "SELECT * FROM "+RetSqlName("CT2")+" WHERE CT2_FILIAL = '"+xFilial("CT2")+"' AND CT2_DATA BETWEEN '"+aMesAno[nX,2]+"' AND '"+aMesAno[nX,3]+"' AND LEFT(CT2_ROTINA,4) = 'GPEM' AND D_E_L_E_T_ = ' '" 

	oSelf:SetRegua2(1)
	oSelf:IncRegua2("Executando Filtro..." )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.F.,.T.)
	
	oSelf:SetRegua2(1)
	oSelf:IncRegua2("Validando Registros..." )
	nPos := 0
	dbEval({|| nPos++},,{|| !TRB->(Eof())})
	
	TRB->(dbGoTop())
	
	cArqTXT := cPath + If(Right(cPath,1)<>"\","\","") + "CTB"+aMesAno[nX,1]+".TXT"
	
	nHdl := fCreate(cArqTXT,0)

	oSelf:SetRegua2(nPos)
	While !TRB->(Eof())
		oSelf:IncRegua2("Gerando Arquivo "+cArqTXT )
		
		//--> Define o Tipo de Partida
		If     TRB->CT2_DC == "1"
			cLinha := "200"
		ElseIf TRB->CT2_DC == "2"	
			cLinha := "300"
		ElseIf TRB->CT2_DC == "3"
			cLinha := "400"
		EndIf
		                                                                                  
		//--> Data do Lancamento
		cLinha += Right(TRB->CT2_DATA,2)+SubStr(TRB->CT2_DATA,5,2)+Left(TRB->CT2_DATA,4)
		
		//--> Conta Contabil
		If     TRB->CT2_DC == "1"
			cLinha += PadR(TRB->CT2_DEBITO,20)+Space(20)+PadR(TRB->CT2_CCD,13)+Space(13)
		ElseIf TRB->CT2_DC == "2"	
			cLinha += Space(20)+PadR(TRB->CT2_CREDIT,20)+Space(13)+PadR(TRB->CT2_CCC,13)
		ElseIf TRB->CT2_DC == "3"
			cLinha += PadR(TRB->CT2_DEBITO,20)+PadR(TRB->CT2_CREDIT,20)+PadR(TRB->CT2_CCD,13)+PadR(TRB->CT2_CCC,13)
		EndIf

		//--> Space em Branco		
		cLinha += Space(52)

		//--> Historico
		cLinha += PadR(TRB->CT2_HIST,40)
		
		//--> Valor
		cLinha += StrZero((TRB->CT2_VALOR*100),17)
		
		//--> Item Contabil (187,009) (196,009)
		cLinha += TRB->CT2_ITEMD + TRB->CT2_ITEMC
		
		//--> Classe Valor  (205,009) (214,009)
		cLinha += TRB->CT2_CLVLDB + TRB->CT2_CLVLCR
		
		//--> Pulo da Linha
		cLinha += CRLF
		
		fWrite(nHdl,cLinha,Len(cLinha))

		TRB->(dbSkip())
	EndDo
	TRB->(dbCloseArea())
	fClose(nHdl)
	
	oSelf:SaveLog("Arquivo gerado com sucesso ("+"CTB"+aMesAno[nX,1]+".TXT"+").")

Next nX

MsgAlert("Processamento Finalizado !","KPMG BPO")

Return