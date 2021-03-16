#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"    
#Include "topconn.ch"

/*
Fonte não finalizado devido a paralizaçaõ do Projeto, itens faltantes:

- Validação entre arquivo e Sistema.
	- Agrupamento dos itens do SB8.
	- Compare entre itens;
-Customizaçaõ da definição de cores do erros de MET.
	- Criação do Botao com a Legenda.
	- Ajuste do array com o tipo de erro.
- Criaçaõ do Relatorio de erro.
	- Impressão em excel do array de erros.

*/


/*
Funcao      : L5EST002
Parametros  : Nil
Retorno     : Nil
Objetivos   : MET - Ajuste de Inventario
Autor       : Jean Victor Rocha
Data/Hora   : 29/09/2014
*/
*----------------------*
User Function L5EST002()
*----------------------*
Private cPath 	:= GETMV("MV_P_FTP",,"")// "200.196.242.81"
Private clogin	:= GETMV("MV_P_USR",,"") // "tiago"
Private cPass 	:= GETMV("MV_P_PSW",,"") // "123" 

//Private cEmail 	:= GETMV("MV_P_00019",,"")  //E-mail que recebem notificação de novo arquivo no FTP, GTFAT010

Private cDirFtp := GETMV("MV_P_00021",,"/out/teste") //Diretorio no FTP para Download de arquivos MET,L5EST002

Private aArquivo := {}
Private aErroMET := {}

Return MainGt()

*----------------------*
Static Function MainGT()
*----------------------*
Private oDlg
Private aSize 	:= MsAdvSize()
Private oLayer	:= FWLayer():new()

Private nMax := 99999999999

Private aCposSB2 := {"B2_FILIAL","B2_COD","B2_LOCAL","B2_QATU"}
Private aCposSB8 := {"B8_FILIAL","B8_PRODUTO","B8_LOCAL","B8_QTDORI","B8_LOTECTL","B8_DTVALID","B8_SALDO"}

Private oSB2
Private oSB8
Private oArq

//Ajusta a Pasta de Origem no Servidor - Temporaria
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		If !ExistDir("\FTP\"+cEmpAnt+"\MET")
			MakeDir("\FTP\"+cEmpAnt+"\MET")
 		EndIf
 	Else
 		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\MET")
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
	MakeDir("\FTP\"+cEmpAnt+"\MET")
EndIf

If !ExistDir("\FTP\"+cEmpAnt+"\MET")
	MsgInfo("Falha ao carregar diretório FTP no Servidor!","HLB BRASIL")
	Return .F.
EndIf

cDir := "\FTP\"+cEmpAnt+"\MET"

//Interface
oDlg := MSDialog():New( aSize[7],0,aSize[6],aSize[5],"HLB BRASIL - Integração LOJA",,,.F.,,,,,,.T.,,,.T. )

oLayer:Init(oDlg,.F.)

oLayer:addLine( '1', 100 , .F. )

oLayer:addCollumn('1',05,.F.,'1')
oLayer:addCollumn('2',65,.F.,'1')
oLayer:addCollumn('3',30,.F.,'1')

oLayer:addWindow('1','Win11','Menu'				,100,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('2','Win21','Sistema'			,100,.F.,.T.,{|| },'1',{|| })
oLayer:addWindow('3','Win31','Arquivo'			,100,.F.,.T.,{|| },'1',{|| })

//Definição das janelas para objeto.
oWin11 := oLayer:getWinPanel('1','Win11','1')
oWin21 := oLayer:getWinPanel('2','Win21','1')
oWin31 := oLayer:getWinPanel('3','Win31','1')

//Menu
oBtn10 := TBtnBmp2():New(aSize[6]-84	,03,26,26,'FINAL'   	   	,,,,{|| oDlg:end()}		, oWin11,"Sair"				,,.T.)
oBtn11 := TBtnBmp2():New(004			,03,26,26,'HISTORIC'   	  	,,,,{|| GetArqFTP()}	, oWin11,"Atu.Arq.Server"	,,.T.)
oBtn12 := TBtnBmp2():New(044			,03,26,26,'BMPVISUAL'  		,,,,{|| GERAEXCEL()}	, oWin11,"Relatorio"		,,.T.)

//Criação de Browses 
//SB2
oSaySB2	:= TSay():New( 02,01,{|| "Saldo Fisico HLB:"},oWin21,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHSB2   := {}
aCSB2	:= {}
SX3->(DbSetOrder(1))
If SX3->(DbSeek("SB2"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SB2"
		If aScan(aCposSB2,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SB2->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHSB2,{ TRIM(SX3->X3_TITULO),"WK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
									SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aASB2	:= {}
oSB2 := MsNewGetDados():New(10,01,(oWin21:NHEIGHT/2)-2,(((oWin21:NRIGHT/2)/5)*2)-2,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
							"", aASB2,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHSB2, aCSB2, {|| AtuMet()})

oSB2:oBrowse:SetBlkBackColor({|| GETDCLR(oSB2:ACOLS,oSB2:NAT,oSB2:aHeader,.T.)})

oSB2:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oSB2:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oSB2:ForceRefresh()

//SB8
oSaySB8	:= TSay():New( 02,((oWin21:NRIGHT/2)/5)*2,{|| "Saldo Lote HLB:"},oWin21,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHSB8 := {}
aCSB8	:= {}
If SX3->(DbSeek("SB8"))
	While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "SB8"
		If aScan(aCposSB8,{|X| ALLTRIM(X) == ALLTRIM(SX3->X3_CAMPO) }) <> 0 .And. SB8->(FieldPos(SX3->X3_CAMPO)) <> 0
			AADD(aHSB8,{ TRIM(SX3->X3_TITULO),"WK"+SUBSTR(SX3->X3_CAMPO,AT("_",SX3->X3_CAMPO),50),;
											SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"","",SX3->X3_TIPO,"",""})
		EndIf
		SX3->(DbSkip())
	EndDo
EndIf
aASB8	:= {}
oSB8 := MsNewGetDados():New(10,((oWin21:NRIGHT/2)/5)*2,(oWin21:NHEIGHT/2)-2,(oWin21:NRIGHT/2),;
									GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aASB8,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin21,aHSB8, aCSB8)

oSB8:oBrowse:SetBlkBackColor({|| GETDCLR(oSB8:ACOLS,oSB8:NAT,oSB8:aHeader,.T.)})
oSB8:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oSB8:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oSB8:ForceRefresh()

//Arquivo
oSayArq	:= TSay():New( 02,01,{|| "Saldo Lote LUFT:"},oWin31,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
aHArq := {}
aCArq	:= {}

AADD(aHArq,{ "Remetente","ARQ_REMET","@!",10,00,"","","C","",""})
AADD(aHArq,{ "Arquivo"	,"ARQ_ARQ"	,"@!",04,00,"","","C","",""})
AADD(aHArq,{ "Interface","ARQ_INTER","@!",08,00,"","","C","",""})
AADD(aHArq,{ "Site"		,"ARQ_SITE"	,"@!",03,00,"","","C","",""})
AADD(aHArq,{ "Estoque"	,"ARQ_ESTOQ","@!",12,00,"","","C","",""})
AADD(aHArq,{ "Produto"	,"ARQ_PROD"	,"@!",40,00,"","","C","",""})
AADD(aHArq,{ "Ind.Ajust","ARQ_AJUST","@!",01,00,"","","C","",""})
AADD(aHArq,{ "Qtde Inv.","ARQ_QTDE"	,"@!",18,00,"","","C","",""})
AADD(aHArq,{ "Indicador","ARQ_INDIC","@!",02,00,"","","C","",""})
AADD(aHArq,{ "Mtv. Bloq","ARQ_BLOQ"	,"@!",30,00,"","","C","",""})
AADD(aHArq,{ "Lote"		,"ARQ_LOTE"	,"@!",20,00,"","","C","",""})
AADD(aHArq,{ "Dt Lote"	,"ARQ_DTLOT","@!",08,00,"","","C","",""})
AADD(aHArq,{ "Endereço"	,"ARQ_END"	,"@!",40,00,"","","C","",""})

aAArq	:= {}
oArq := MsNewGetDados():New(10,01,(oWin31:NHEIGHT/2)-3,(oWin31:NRIGHT/2)-2,;
									GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",;
									"", aAArq,,nMax, "AllwaysTrue()", "AllwaysTrue()","AllwaysTrue()", oWin31,aHArq, aCArq)

oArq:oBrowse:SetBlkBackColor({|| GETDCLR(oArq:ACOLS,oArq:NAT,oArq:aHeader,.T.)})
oArq:LCANEDITLINE	:= .F.//não possibilita troca de tipo de edição.
oArq:LEDITLINE		:= .F.//Não abre linha de edição de linha quando clicar na linha.
oArq:ForceRefresh()

LoadSB2()
LoadArqFis()
AtuMet()

oDlg:Activate(,,,.T.)

Return .T.

/*
Funcao      : GETDCLR()  
Parametros  : aLinha,nLinha,aHeader,lCtrl
Retorno     : Nil
Objetivos   : Função para tratamento das regras de cores para a grid da MsNewGetDados
*/
*--------------------------------------------------*
Static Function GETDCLR(aLinha,nLinha,aHeader,lCtrl)
*--------------------------------------------------*
Local nCor  := RGB(240,128,128)//Vermelho claro
Local nCor2 := RGB(192,192,192)//Cinza claro
Local nCor3 := RGB(222,184,135)//marrom claro
Local nCor4 := RGB(255,255,255)//Branco
Local nRet := nCor4

If lCtrl

EndIf

Return nRet

/*
Funcao      : LoadSB2()  
Parametros  :
Retorno     : Nil
Objetivos   : Função responsavel por carregar os dados da SB2.
*/
*------------------------*
Static Function LoadSB2()
*------------------------*
Local i
Local aAux := {}

SB1->(DbSetOrder(1))

SB2->(DbSetOrder(1))
SB2->(DbGoTop())
While SB2->(!EOF())
	//If SB1->(DbSeek(xFilial("SB1")+SB2->B2_COD)) .and. SB1->B1_RASTRO == "S"
		aAux := {}
		For i:=1 to Len(aHSB2)
			aAdd(aAux,SB2->(&(STRTRAN(aHSB2[i][2],"WK","B2") )) )
		Next i
		If Len(aAux) <> 0
			aAdd(aAux,.F.)
			aAdd(aCSB2,aAux)
		EndIf
	//EndIf
	SB2->(DbSkip())
EndDo

oSB2:ACOLS := aCSB2
oSB2:ForceRefresh()

Return .T.

/*
Funcao      : LoadSB8()  
Parametros  :
Retorno     : Nil
Objetivos   : Função responsavel por carregar os dados da SB8.
*/
*------------------------*
Static Function LoadSB8()
*------------------------*
Local i
Local aAux := {}

oSB8:ACOLS := {}
aCSB8 := {}

SB8->(DbSetOrder(1))
If SB8->(DbSeek(oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_FILIAL"})]+;
				oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_COD"})]+;
				oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_LOCAL"})]				))

	While SB8->(!EOF()) .and.	oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_FILIAL"})]+;
			   					oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_COD"})]+;
			   					oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_LOCAL"})] ==;
			   					SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL
		aAux := {}
		For i:=1 to Len(aHSB8)
			aAdd(aAux,SB8->(&(STRTRAN(aHSB8[i][2],"WK","B8") )) )
		Next i
		If Len(aAux) <> 0
			aAdd(aAux,.F.)
			aAdd(aCSB8,aAux)
		EndIf
		SB8->(DbSkip())
	EndDo
EndIf

oSB8:ACOLS := aCSB8
oSB8:ForceRefresh()

Return .T.

/*
Funcao      : AtuMet()  
Parametros  :
Retorno     : Nil
Objetivos   : Função responsavel por Atualizar a visualização do MET.
*/
*------------------------*
Static Function AtuMet()
*------------------------*
LoadSB8()
LoadArq()
Return .T.

/*
Funcao      : GetArqFTP()  
Parametros  :
Retorno     : Nil
Objetivos   : Função responsavel por Atualizar os arquivos no servidor conectando no FTP.
*/
*-------------------------*
Static Function GetArqFTP()
*-------------------------*
Local aArqServer	:= DIRECTORY(cDir+"\INVE*.TXT" , ) 
Local aArqFTP		:= {}

//Conexao do FTP interno
For i:=1 to 3// Tenta 3 vezes.
	lConnect := ConectaFTP()
	If lConnect
 		i:=3
   	EndIf
Next   
If !lConnect
	MsgAlert("Não foi possivel estabelecer conexão com FTP.","HLB BRASIL")
 	Return .F.
EndIf   

// Monta o diretório do FTP, será gravado na raiz "/"
FTPDirChange(cDirFtp)

aArqFTP := FTPDIRECTORY( "INVE*.TXT" , ) 

If Len(aArqServer) <> 0
	For i:=1 to Len(aArqServer)
		//Colocar no ZIP para deixar apenas 1 arquivo.
		compacta(cDir+"\"+aArqServer[i][1],cDir+"\BACKUP.ZIP")
	Next i
EndIf	

For i:=1 to Len(aArqFTP)
	FTPDownLoad(cDir+"\"+aArqFTP[i][1],aArqFTP[i][1])
	//FTPERASE(aArqFTP[i][1])
Next i

//Encerra conexão com FTP
FTPDisconnect()

If LoadArqFis()
	AtuMet()
	MsgInfo("Atualização do Arquivos e dados concluida com sucesso!","HLB BRASIL")
EndIf

Return .T.

/*
Funcao      : ConectaFTP
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para conectar no FTP
Obs         :
*/          
*--------------------------*
Static Function ConectaFTP()
*--------------------------*
Local lRet		:= .F.

cPath  := Alltrim(cPath)
cLogin := Alltrim(cLogin)
cPass  := Alltrim(cPass) 

// Conecta no FTP
lRet := FTPConnect(cPath,,cLogin,cPass) 
   
Return (lRet)

/*
Funcao      : LoadArqFis
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para Carregar o Arquivo Fisico da pasta FTP do Server
Obs         :
*/          
*--------------------------*
Static Function LoadArqFis()
*--------------------------*
Local oFT			:= fT():New()//FUNCAO GENERICA
Local aArqServer	:= DIRECTORY(cDir+"\INVE*.TXT" , ) 
Local cArqServer	:= ""
Local cLinha		:= ""

//Reinicia a Variavel para carregar novos dados.
aArquivo := {}

For i:=1 to Len(aArqServer)
	If i == 1
		cArqServer := cDir+"\"+aArqServer[i][1]
	Else
		//Colocar no ZIP para deixar apenas 1 arquivo.
		compacta(cDir+"\"+aArqServer[i][1],cDir+"\BACKUP.ZIP")
	EndIf
Next i

If Len(aArqServer) == 0
	MsgInfo("Não foi encontrado arquivo no servidor, execute a opção 'Atu.Arq.Server'!","HLB BRASIL")
	Return .F.
EndIf

If oFT:FT_FUse(cArqServer) < 0
	MsgInfo("Não foi possivel abrir o arquivo no servidor!","HLB BRASIL")
	Return .F.
EndIf

oFT:FT_FGOTOP()// Posiciona no inicio do arquivo
While !oFT:FT_FEof()
	oFT:NBUFFERSIZE := 9999999
   	cLinha := oFT:FT_FReadln()
	aAux := {}
	aAdd(aAux,SUBSTR(cLinha,001,10))//Remetente
	aAdd(aAux,SUBSTR(cLinha,011,04))//Nome do arquivo
	aAdd(aAux,SUBSTR(cLinha,015,08))//Nome da Interface
	aAdd(aAux,SUBSTR(cLinha,023,03))//Site
	aAdd(aAux,SUBSTR(cLinha,026,12))//Proprietário de estoque
	aAdd(aAux,SUBSTR(cLinha,038,40))//Produto
	aAdd(aAux,SUBSTR(cLinha,078,01))//Indicador do Ajuste
	aAdd(aAux,SUBSTR(cLinha,079,18))//Quantidade de inventários
	aAdd(aAux,SUBSTR(cLinha,097,02))//Indicador (Status)
	aAdd(aAux,SUBSTR(cLinha,099,30))//Motivo Bloqueio / Desbloqueio
	aAdd(aAux,SUBSTR(cLinha,129,20))//Lote
	aAdd(aAux,SUBSTR(cLinha,149,08))//Data de Validade
	aAdd(aAux,SUBSTR(cLinha,157,40))//Endereço
	aAdd(aArquivo,aAux)
	oFT:FT_FSkip()	//Proxima linha
Enddo

oFT:FT_FUse()//Fecha o arquivo
				
If Len(aArquivo) == 0
	MsgInfo("Não foi possivel carregar informações do Arquivo!","HLB BRASIL")
	Return .F.
EndIf

//Ordenar o Array de acordo com:
//Produto > Lote > Data Validade
ASORT(aArquivo, , , {|x,y| x[6]>y[6] .and. x[11]>y[11] .and. x[12]>y[12] } )

//Validações do MET para apresentação de Erro, caso exista.
ValidMet()

Return .T.

/*
Funcao      : LoadArq
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Funcão para Carregar o do array de arquivo para a tela.
Obs         :
*/          
*-----------------------*
Static Function LoadArq()
*-----------------------*
Local nPos	:= 0

oArq:ACOLS	:= {}
aCArq		:= {}

If (nPos := aScan(aArquivo, {|x|	ALLTRIM(x[aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) == ;
									ALLTRIM(oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_COD"})]) } ) ) <> 0
	For i:=nPos to Len(aArquivo)
		If	ALLTRIM(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) ==;
			ALLTRIM(oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_COD"})])
			/*If LEN(oSB8:ACOLS) <> 0
				If	aScan(oSB8:ACOLS,{|x| ALLTRIM(x[aScan(oSB8:AHEADER,{|x| ALLTRIM(x[2])=="WK_LOTECTL"})]) ==;
										 ALLTRIM(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_LOTE"})]) })  <> 0 .and.;
					aScan(oSB8:ACOLS,{|x| ALLTRIM(x[aScan(oSB8:AHEADER,{|x| ALLTRIM(x[2])=="B8_DTVALID"})]) ==;
										 ALLTRIM(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_DTLOT"})]) })  <> 0

					aAux := aArquivo[i]
					aAdd(aAux,.F.)//Adiciona a posição de deletado.
					aAdd(aCArq,aAux)
				EndIf
			Else */
				aAux := aArquivo[i]
				aAdd(aAux,.F.)//Adiciona a posição de deletado.
				aAdd(aCArq,aAux)
			//EndIf
		Else//Finaliza quando trocar o produto. Chave principal.
			i := Len(aArquivo)
		EndIf
	Next i
EndIf

oArq:ACOLS := aCArq
oArq:ForceRefresh()

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : ValidMet
Parametros  : 
Retorno     : 
Objetivos   : Função Responsavel pelas validações do MET.
*/
*------------------------*
Static Function ValidMet()
*------------------------*
Local i
Local npos := 0
Local lCompart := .F.
Local nTotProdArq := 0
Local aTotProdArq := {}

aErroMET := {}

//Valida o Se o SB1 é compartilhada ou não.
SX2->(DbSetOrder(1))
SX2->(DbSeek("SB1"))
lCompart := SX2->X2_MODO == "C"

SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
SB8->(DbSetOrder(1))//B8_FILIAL+B8_PRODUTO+B8_LOCAL

For i:=1 to len(oSB2:ACOLS)
    //Definição das chaves de busca
	If lCompart
		cFilSB1 := "  "
	Else
		cFilSB1 := oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_FILIAL"})]
	EndIf
	cFilSB2 := oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_FILIAL"})]
	cCodSB2 := oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_COD"})]
	cLocSB2 := oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_LOCAL"})]	
	nQtdSB2 := oSB2:ACOLS[oSB2:NAT][aScan(oSB2:AHEADER,{|x| ALLTRIM(x[2])=="WK_QATU"})]

	//Valida se Encontrou o Cadastro do Produto.
	If SB1->(DbSeek(cFilSB1+cCodSB2))
		//Valida se controle Lote ou não
		If EMPTY(SB1->B1_RASTRO) .or. SB1->B1_RASTRO $ "N"
			//Validação da Quantidade do Arquivo X Sistema SB2
			If (nPos := aScan(aArquivo, {|x| ALLTRIM(x[aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) == ALLTRIM(cCodSB2) } ) ) <> 0
				nTotProdArq := 0
				For i:=nPos to Len(aArquivo)
					If	ALLTRIM(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) == ALLTRIM(cCodSB2)
						nTotProdArq += VAL(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_QTDE"})])
						lTemInfo := .T.
					Else
						i := Len(aArquivo)
					EndIf
				Next i
				If nQtdSB2 <> nTotProdArq
					aAdd(aErroMET, {cFilSB1+cCodSB1+cLocSB1,1,"Produto com quantidade diferente!"})				
				EndIf
			Else
				aAdd(aErroMET, {cFilSB1+cCodSB1+cLocSB1,1,"Produto não encontrado no arquivo para efetuar o MET!"})
			EndIf

		Else
			//Validação da Quantidade do Arquivo X Sistema SB8
			If (nPos := aScan(aArquivo, {|x| ALLTRIM(x[aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) == ALLTRIM(cCodSB2) } ) ) <> 0
				For i:=nPos to Len(aArquivo)
					If	ALLTRIM(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_PROD"})]) == ALLTRIM(cCodSB2)
						If (nPos := aScan(aTotProdArq,{|x| ALLTRIM(x[1]) == ALLTRIM(x[aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_LOTE"})]) }) ) <> 0
					   		aAdd(aTotProdArq,{ALLTRIM(x[aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_LOTE"})]),;//Lote do Arquivo
					   						 VAL(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_QTDE"})]),;//Valor no Arquivo
					   						 0 } )//Valor no Sistema
						Else
					   		aTotProdArq[nPos][2] += VAL(aArquivo[i][aScan(oArq:AHEADER,{|x| ALLTRIM(x[2])=="ARQ_QTDE"})])
						EndIf
					Else
						i := Len(aArquivo)
					EndIf
				Next i
				For i:=1 to len(oSB8:ACOLS)
					//Criar Array com as quantidades agrupada.
				Next i

			Else
				aAdd(aErroMET, {cFilSB1+cCodSB1+cLocSB1,1,"Produto não encontrado no arquivo para efetuar o MET!"})
			EndIf
		
		EndIf	
	Else
		aAdd(aErroMET, {cFilSB1+cCodSB1+cLocSB1,1,"Cadastro do produto não encontrado!"})
	EndIf	
Next i

Return(lRet)