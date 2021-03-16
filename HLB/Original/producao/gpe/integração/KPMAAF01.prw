#Include "Protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Empresa  � AKRON Projetos e Sistemas                                  ���
���          � Rua Jose Oscar Abreu Sampaio, 113 - Sao Paulo - SP         ���
���          � Fone: (11) 3853-6470                                       ���
���          � Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ���
�������������������������������������������������������������������������Ĵ��
���Programa  � KPMAAF01  � Autor � Larson Zordan        � Data �10/06/2013���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gera um arquivo TXT com os lancamentos contabeis           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � KPMAAF01(void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � KPMG - AAF                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/ 

/*
Funcao      : KPMAAF01()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Gera um arquivo TXT com os lancamentos contabeis.
Autor       : AKRON Projetos e Sistemas
Data/Hora   : 10/06/2013
Revis�o		: Renato Rezende
Data/Hora   : 16/04/2014
*/ 
*--------------------------*
 User Function KPMAAF01()
*--------------------------*

Local cPerg  		:= "KPMAAF01"
Local cFunction		:= "KPMAAFP"
Local cTitle		:= "Gera Arquivo TXT dos Lan�amentos Cont�beis"
Local bProcess		:= { |oSelf| KPMAAFPROC(oSelf) }
Local cDescription	:= "Esta rotina ir� gerar um arquivo padr�o TXT dos lan�amentos cont�beis (Tabela CT2), conforme os par�metros definidos pelo usu�rio."+CRLF+"Independente do per�odo informado, a rotina ir� gerar um arquivo separado por m�s/ano."

PutSx1(cPerg,"01","Da Data do La�amento          ","","","mv_ch1","D",08,0,1,"G","","","","S","mv_par01","","","","","","","","","","","","","","","","",{"Informe a Data Inicial dos","Lan�amentos Cont�beis a ser","considerado no filtro da rotina."},{},{})
PutSx1(cPerg,"02","At� a Data do La�amento       ","","","mv_ch2","D",08,0,1,"G","","","","S","mv_par02","","","","","","","","","","","","","","","","",{"Informe a Data Final dos"  ,"Lan�amentos Cont�beis a ser","considerado no filtro da rotina."},{},{})
PutSx1(cPerg,"03","Informe o Local do Arquivo    ","","","mv_ch3","C",50,0,1,"G","","","","S","mv_par03","","","","","","","","","","","","","","","","",{"Informe o Local onde ser�" ,"gerado o arquivo TXT dos"   ,"Lan�amentos Cont�beis.          "},{},{})

tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � KPMAAFPROC � Autor � Larson Zordan         � Data �10/06/2013���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Executa o processamento para a geracao do aquivo TXT         ��� 
���������������������������������������������������������������������������Ĵ��                  
��� Uso      � KPMG - AAF                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
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
	
	oSelf:IncRegua1(" Processando Ano/M�s: "+Transform(aMesAno[nX,1],"@R 9999/99") )	

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