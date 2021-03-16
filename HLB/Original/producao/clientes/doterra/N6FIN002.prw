#INCLUDE "FINA910A.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE TOT_DATA		1
#DEFINE TOT_CONC		2
#DEFINE TOT_QTDCONC	3
#DEFINE TOT_CPAR		4
#DEFINE TOT_QTDCPAR	5
#DEFINE TOT_CMAN		6
#DEFINE TOT_QTDCMAN	7
#DEFINE TOT_CNAO		8
#DEFINE TOT_QTDCNAO	9
#DEFINE TOT_GERAL		10
#DEFINE _CRLF			Chr(13)+Chr(10)

#Define BMPCAMPO        "BMPCPO.PNG"
#Define BMPSAIR         "FINAL.PNG"
#Define BMPVISUAL       "BMPVISUAL.PNG"

Static nCodTimeOut	:= 90  

Static lPontoF		:= .F.//ExistBlock("FINA910F")		//Variavel que verifica se ponto de entrada esta' compilado no ambiente

Static __nThreads 
Static __nLoteThr 
Static __lProcDocTEF
Static __lDefTop		:= NIL
Static __lConoutR		:= FindFunction("CONOUTR")
Static __aBancos		:= {}
Static __cFilSA6		:= Nil
Static __lDocTef		:= FieldPos("ZX3_DOCTEF") > 0

Static nTamBanco
Static nTamAgencia
Static nTamCC
Static nTamCheque
Static nTamNatureza

Static nTamParc
Static nTamParc2
Static nTamWLDPA
Static nTamDOCTEF

Static lMEP := .F.
Static lTamParc
Static lA6MSBLQL

Static cAdmFinanIni		:= ""												//Codigo Inicial da Administradora Financeira que esta' efetuando o pagamento para a empresa
Static cAdmFinanFim		:= ""												//Codigo Final da Administradora Financeira que esta' efetuando o pagamento para a empresa
Static cConcilia		:= ""												//Tipos de Baixa: 1- Baixa individual / 2-Baixa por lote
Static nQtdDias			:= 0												//O numero de dias anteriores ao da data de cr้dito que sera' utilizada como referencia de pesquisa nos titulos
Static nMargem			:= 0												//Parametro utilizado para que titulos que estao com valores a menor no SITEF possam entrar na pasta de conciliados mediante tolerancia em percentual informada
Static dDataCredI		:= cTod("")										    //Data de credito inicial que a administradora credita o valor para a empresa
Static dDataCredF		:= cTod("")										    //Data de credito final que a administradora credita o valor para a empresa
	
Static lUseZX3DtCred	:= .F.

Static lZX3RecSE1
Static lUsaMep          := .F.
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณFINA910A  ณ Autor ณ Rafael Rosa da Silva  ณ Data ณ05/08/2009ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLocacao   ณ CSA              ณContato ณ 								    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณRotina que efetua a conciliacao entre os dados recebidos    ณฑฑ
ฑฑณDescricao ณpelo arquivo do SITFEF e os dados do Contas a Receber       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAplicacao ณ Somente em Banco de Dados com uso de TopConnect            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista Resp.ณ  Data  ณ Bops ณ Manutencao Efetuada                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ  /  /  ณ      ณ                                        ณฑฑ
ฑฑณ              ณ  /  /  ณ      ณ                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function N6FIN002()

Local aButtons			:= {}												//Variavel para a inclusao de botoes na EnchoiceBar
Local aHeadTot			:= {}												//Array que guarda os nomes dos campos que aparecerao no Folder Totais
Local aHeader    	 		:= {}												//Array que guarda os nomes dos campos que aparecerao nos Folders Conciliadas, Conc. Parcialmente e Nใo Conciliadas
Local aHeadIndic 		 	:= {}												//Array que guarda os nomes dos campos que aparecerao no Rodape Conciliados Parcialmente
Local aHeadMan			:= {}												//Array que guarda os nomes dos campos que aparecerao no Folder Conc. Manualmente
Local aHeadSE1			:= {}												//Array que guarda os campos padroes da tabela SE1
Local aColsAux			:= {}												//Array auxiliar que guarda os valores padroes
Local aConc				:= {}												//Array que contem todos os registros que estao disponiveis no Folder Conciliar
Local aConcPar			:= {}												//Array que contem todos os registros que estao disponiveis no Folder Conc. Parcialmente
Local aConcMan			:= {}												//Array que contem todos os registros que estao disponiveis no Folder Conc. Manualmente
Local aNaoConc			:= {}												//Array que contem todos os registros que estao disponiveis no Folder Nao Conciliadas
Local aTitulos			:= {}												//Array que contem todos os titulos que se assemelham aos registros do Folder Nao Conciliadas
Local aTotais			:= {}												//Array que contem todos os registros que estao disponiveis no Folder Totais
Local aFolder			:= {}												//Nome dos Folders
Local aIndic			:= {}												//Array que armazena os itens parecidos para Conciliacao Parcial
	
Local oSelec			:= LoadBitmap(GetResources(), "BR_VERDE")		//Objeto de tela para mostrar como marcado um registro
Local oNSelec			:= LoadBitmap(GetResources(), "BR_BRANCO")	//Objeto de tela para mostrar como desmarcado um registro
Local oRedSelec			:= LoadBitmap(GetResources(), "BR_VERMELHO")	//Objeto de tela para mostrar como desmarcado um registro
Local oAmaSelec			:= LoadBitmap(GetResources(), "BR_AMARELO")	//Objeto de tela para mostrar como Divergente um registro
Local oBlcSelec			:= LoadBitmap(GetResources(), "BR_PRETO")		//Objeto de tela para mostrar registro com BANCO/CONTA bloqueado
Local oConc				:= Nil												//Objeto da funcao TWBrowse usado no Folder Conciliar
Local oConcPar			:= Nil												//Objeto da funcao TWBrowse usado no Folder Conc. Parcialmente
Local oConcMan			:= Nil												//Objeto da funcao TWBrowse usado no Folder Conc. Manualmente
Local oNaoConc			:= Nil												//Objeto da funcao TWBrowse usado no Folder Nao Conciliadas (Registros a serem conciliados)
Local oTitulos			:= Nil												//Objeto da funcao TWBrowse usado no Folder Nao Conciliadas (Registros do Contas a Receber)
Local oIndic			:= Nil												//Objeto da funcao TWBrowse usado no Folder Nao Conciliados
Local oTotais			:= Nil												//Objeto da funcao TWBrowse usado no Folder Totais
Local oDlg				:= Nil												//Objeto da tela principal
Local oFolder			:= Nil												//Objeto que cria os Folders
Local lRet				:= .T.		 										//Variavel para tratamento dos retornos de funcoes
Local cPerg				:= "N6FIN002"										//Grupo de Perguntas para filtro de informacoes para a Tela de Conciliacao do SITEF
Local cArqTMP			:= ""												// Arquivo Temp para melhora de perfomance, retirando ascan
Local cArqINDEX			:= CriaTrab(,.F.)
Local aCampos			:= {}
Local bEncCan			:= {|| Iif( MsgNoYes( 'Deseja sair da concilia็ใo?' ) ,oDlg:End(),.F.) }

Private lMsErroAuto		:= .F.												//Variavel logica de retorno do MsExecAuto
Private cMsgErrorSilent	:= ""
	
Private nRandThread := 0
Private lParcAlfa   := GetMV( 'MV_1DUP' ) == 'A'
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa o log de processamento                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcLogIni( aButtons )
    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApresenta a tela de parametros para o usuario para delimitarณ
//ณos dados que serao apresentados em tela.                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Pergunte(cPerg,.T.)
    Return
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza o log de processamento   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcLogAtu(STR0137)

A910aIniVar()

ProcLogAtu(STR0138,STR0139)
AADD(aCampos, {"SOURCE","C",10,0})
AADD(aCampos, {"RECNO ","C",10,0})
CreateTMP(aCampos,@cArqTMP,"TMP",cArqINDEX,"SOURCE+RECNO")

ProcLogAtu(STR0138,STR0140)

//Montagem do Header dos Folders Conciliadas, Conciliadas Parcialmente, Conciliadas Manualmente, Nao Conciliadas
aFolder	   := {STR0001,STR0002,STR0003,STR0004,STR0005} 										 	//"Conciliadas"   ### "Conc. Parcialmente"	### "Conc. Manualmente"	### "Nao Conciliadas"	### "Totais"
aHeadTot   := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015}		//"Data Credito"  ### "Conciliados"			### "  Qtd.Conciliados"	### "  Conc. Parc."		### " Qtd.Conc.Parc."	### "  Conc.Man."	### " Qtd.Conc.Man."	### "  Nao Conc."	### " Qtd.Nao Conc." ###	"  Total Geral"
	
aHeader	   := {""     ,STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022,;					//"Cod Estab"	  ### "Nome do Estab"	    ### "Adminis"	     	### "Prefixo"	    	### "Titulo"			### "Tipo"			### "Nro Parc"
					   STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0080,;			//"Nro Comp"	  ### "DT Emissao"	        ### "DT Credito"	    ### "Valor"		    	### "Valor Sitef"		### "NSU"			### "Parc Sitef"	    ### "DocTef E1"
					   STR0081,STR0082,STR0079,STR0083,STR0084,STR0085,STR0086}						//"NSU E1"		  ### "Dt Cr้dito E1"	    ### "Bco/Ag/Conta"	    ### "Status Conta"  	### "Origem Trans"		### "RECNO SE1"		### "RECNO ZX3"

aHeadIndic := {STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0029,;					//"Vl Protheus"   ### "Vl Sitef"		    ### "NSU Protheus"	    ### "NSU Sitef"	    	### "Emissใo Protheus"	### "Emissใo Sitef"	### "Parc Protheus"   	### "Parc Sitef"
			   STR0019,STR0020,STR0021}																//"Prefixo"		  ### "Titulo"		        ### "Tipo"
	
aHeadSE1   := {	""	   ,STR0024,STR0037,STR0030,STR0032,STR0038,STR0019,STR0020,;					//"DT Emissao"	  ### "Vcto Protheus"	    ### "Vl Protheus"	    ### "NSU Protheus"  	### "Comp Protheus"		### "Prefixo"		### "Titulo"
				     	STR0036,STR0021,STR0018,STR0029, STR0039, STR0087,STR0088} 					//"Parc Protheus" ### "Tipo"				### "Adminis"	     	### "Parc Sitef"        ### "Loja"			    ### "Filial"		### "RECNO"

aHeadMan   := aClone(aHeader)
	
aColsAux   := {{	"",;				//1-Status oNSelec
					"", ;				//2-Codigo do Estabelecimento Sitef
					"", ;				//3-Codigo da Loja Sitef
					"", ;				//4-Codigo do Cliente (Administradora)
					"", ;				//5-Prefixo do titulo Protheus
					"", ;				//6-Numero do titulo Protheus
					"", ;				//7-Tipo do titulo Protheus
					"", ;				//8-Numero da parcela Protheus
					"", ;				//9-Numero do Comprovante Sitef
					cTod("  /  /  "),;//10-Data da Venda Sitef
					cTod("  /  /  "),;//11-Data de Credito Sitef
					0,  ;				//12-Valor do titulo Protheus
					0,  ;				//13-Valor liquido Sitef
					"", ;				//14-Numero NSU Sitef
					"", ;				//15-Numero da parcela Sitef
					"", ;				//16-Documento TEF Protheus
					"", ;				//17-NSU Sitef Protheus
					cTod("  /  /  "),;//18-Vencimento real do titulo
					"", ;				//19-banco/agencia/conta
					"", ;				//20-Informa็ใo de conta nใo cadastrada ou cadastrada
					"", ;				//21 - (0,2 ou 3 - Transa็ใo Sitef),(1 ou 4 - Outros/POS)
					0,  ;				//22 - RECNO do SE1
					0,  ;				//23 - RECNO do ZX3
					"", ;				//24 - Agencia
					"", ;				//25 - Conta
					"", ;				//26 - Banco
					"" }}				//27 - Codigo da Loja

dDataCredI		:= MV_PAR03
dDataCredF		:= If(Empty(MV_PAR04), MV_PAR03, MV_PAR04)
cConcilia		:= 1 //MV_PAR07
nQtdDias		:= MV_PAR09
//cAdmFinanIni	:= MV_PAR11
//cAdmFinanFim	:= MV_PAR12
lUseZX3DtCred   := .T. //( MV_PAR13 == 2 ) // "Credito SITEF"
		
/*If Empty(MV_PAR10)
	MsgInfo(STR0076)
	nMargem := 0
Else
	nMargem = MV_PAR10
EndIf */  

nMargem := 10
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza os dados de itens de acordo com os filtros ณ
//ณmostrados inicialmente, onde caso nao exista dados, ณ
//ณo retorno serแ Falso e sai da rotina                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                    
ProcLogAtu("MENSAGEM","INI -> Filtrando os Registros")
LjMsgRun(	STR0041,,{||lRet := A910AtuDados(	@aConc,		@aConcPar,	@aNaoConc,	@aConcMan,;			//"Filtrando os Registros..."
													@aIndic, 	oNSelec, oRedSelec)})
If !lRet
	Return()
EndIf

	//Atualiza o array totalizador
LjMsgRun(STR0042,,{||A910Total(	aConc,		aConcPar,	aNaoConc,	aConcMan,;							//"Gerando os totalizadores..."
									@aTotais,	aHeader,	aHeadMan)})

ProcLogAtu(STR0138,STR0141)

//Verifica se existem informacoes para cada um dos arrays
If Len(aConc) == 0
	aColsAux[1][1] := oSelec	 // BR_VERDE
	aConc := aClone(aColsAux)
EndIf
	
If Len(aConcPar) == 0
	aColsAux[1][1] := oSelec	 // BR_VERDE
	aConcPar := aClone(aColsAux)
EndIf
	
If Len(aConcMan) == 0
	aColsAux[1][1] := oNSelec	 // BR_BRANCO
	aConcMan := aClone(aColsAux)
EndIf
	
If Len(aNaoConc) == 0
	aColsAux[1][1] := oNSelec	 // BR_BRANCO
	aNaoConc := aClone(aColsAux)
EndIf
	
//DEFINE MSDIALOG oDlg TITLE STR0043 FROM C(180),C(181) TO C(665),C(967) PIXEL //"Conciliador SITEF"
DEFINE MSDIALOG oDlg TITLE STR0043 FROM C(170),C(220) TO C(665),C(977) PIXEL //"Conciliador SITEF"
	
//Adiciona as barras dos bot๕es
DEFINE BUTTONBAR oBaroDlg SIZE 10,10 3D TOP OF oDlg

oButtTree   := TBtnBmp():NewBar( BMPSAIR,BMPSAIR,,,,bEncCan,.T.,oBaroDlg,,,STR0142)
oButtTree:cTitle := STR0142  
oButtTree:Align := CONTROL_ALIGN_RIGHT 

oButtTree   := TBtnBmp():NewBar( BMPVISUAL,BMPVISUAL,,,,{|| ProcLogView()  },.T.,oBaroDlg,,,STR0143)
oButtTree:cTitle := STR0143
oButtTree:Align := CONTROL_ALIGN_RIGHT 

// Cria as Folders do Sistema
oFolder	:= TFolder():New(C(012),C(002),aFolder,{},oDlg,,,,.T.,.F.,C(386),C(230),)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT 
	
//Tratamento do Folder -> Totais
oTotais := TWBrowse():New(C(000),C(000),C(000),C(000),,aHeadTot,,oFolder:aDialogs[5],,,,,,,,,,,,,,,,,,,)
oTotais:Align := CONTROL_ALIGN_ALLCLIENT
oTotais:SetArray(aTotais)
oTotais:bLine := {||aEval( aTotais[oTotais:nAt],{|z,w|aTotais[oTotais:nAt,w]})}
oTotais:bHeaderClick := {|x,y,z|A910SelReg(@aTotais,@oTotais,oSelec,oNSelec,y,,.F.)}
	
	//Tratamento do Folder -> Conciliadas
oConc := TWBrowse():New(C(000),C(000),C(380),C(200),,aHeader,,oFolder:aDialogs[1],,,,,,,,,,,,,,,,,,,)
oConc:SetArray(aConc)
oConc:bLine :=	{||{	    aConc[oConc:nAt,01],aConc[oConc:nAt,02],;
							aConc[oConc:nAt,03],aConc[oConc:nAt,04],aConc[oConc:nAt,05],aConc[oConc:nAt,06],aConc[oConc:nAt,07],;
							aConc[oConc:nAt,08],aConc[oConc:nAt,09],aConc[oConc:nAt,10],aConc[oConc:nAt,11],;
							aConc[oConc:nAt,12],aConc[oConc:nAt,13],aConc[oConc:nAt,14],aConc[oConc:nAt,15],;
							aConc[oConc:nAt,16],aConc[oConc:nAt,17],aConc[oConc:nAt,18],aConc[oConc:nAt,19],;
							aConc[oConc:nAt,20],Iif(aConc[oConc:nAt,21] == '1' .OR. aConc[oConc:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aConc[oConc:nAt,22],aConc[oConc:nAt,23]}}
							
oConc:bHeaderClick := {|x,y,z|A910SelReg(@aConc,@oConc,oSelec,oNSelec,y)}
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se existem informacoes Conciliadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aConc[1][2] <> ""
	oConc:bLDblClick := {||A910SelReg(@aConc,@oConc,oSelec,oNSelec,1,oConc:nAt)}
EndIf
	
@ C(205),C(002) Button STR0044 Size C(073),C(012) Action A910Efetiva(@aConc, @oConc, oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 1,,oDlg) PIXEL OF oFolder:aDialogs[1]		//"&Efetiva Concilia็ใo"
	
//Tratamento do Folder -> Conciliadas Parcialmente
oConcPar := TWBrowse():New(C(000),C(000),C(380),C(140),,aHeader,,oFolder:aDialogs[2],,,,,,,,,,,,,,,,,,,)
oConcPar:SetArray(aConcPar)
oConcPar:bLine :=	{||{	aConcPar[oConcPar:nAt,01],aConcPar[oConcPar:nAt,02],;
							aConcPar[oConcPar:nAt,03],aConcPar[oConcPar:nAt,04], aConcPar[oConcPar:nAt,05],aConcPar[oConcPar:nAt,06],aConcPar[oConcPar:nAt,07],;
							aConcPar[oConcPar:nAt,08],aConcPar[oConcPar:nAt,09],aConcPar[oConcPar:nAt,10],aConcPar[oConcPar:nAt,11],;
							aConcPar[oConcPar:nAt,12],aConcPar[oConcPar:nAt,13],aConcPar[oConcPar:nAt,14],aConcPar[oConcPar:nAt,15],;
							aConcPar[oConcPar:nAt,16],aConcPar[oConcPar:nAt,17],aConcPar[oConcPar:nAt,18],aConcPar[oConcPar:nAt,19],;
							aConcPar[oConcPar:nAt,20],Iif(aConcPar[oConcPar:nAt,21] == '1' .OR. aConcPar[oConcPar:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aConcPar[oConcPar:nAt,22],aConcPar[oConcPar:nAt,23]}}

oConcPar:bHeaderClick := {|x,y,z|A910SelReg(@aConcPar,@oConcPar,oSelec,oNSelec,y)}
	
//Verifica se existem informacoes Conciliadas Parcialmente
If aConcPar[1][2] <> ""
	oConcPar:bLDblClick := {||A910SelReg(@aConcPar,@oConcPar,oSelec,oNSelec,1,oConcPar:nAt)}
EndIf
oConcPar:bChange := {||A910AtuDiv(aConcPar,@aIndic,oConcPar:nAt,oIndic)}

@ C(145),C(300) Button STR0135 Size C(073),C(012) Action Processa({|| U_N6FIN05A(aConcPar, aIndic, aHeader, aHeadIndic, 1)},STR0047) PIXEL OF oFolder:aDialogs[2] 	//"&Nao Conc Excel"###"Processando ..."
	
//Tratamento Divergencias
oIndic := TWBrowse():New(C(012),C(000),C(380),C(040),,aHeadIndic,,oFolder:aDialogs[2],,,,,,,,,,,,,,,,,,,)
oIndic:SetArray(aIndic)
oIndic:bLine := {||aEval(aIndic[oIndic:nAt],{|z,w| aIndic[oIndic:nAt,w]})}
/*	
@ C(205),C(002) Button STR0044 Size C(073),C(012) Action A910Efetiva(@aConcPar, @oConcPar,oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 2,,oDlg) PIXEL OF oFolder:aDialogs[2]		//"&Efetiva Concilia็ใo"
*/
@ C(205),C(300) Button STR0136 Size C(073),C(012) Action Processa({||U_N6FIN05A(aConcPar, aIndic, aHeader, aHeadIndic, 2)},STR0047) PIXEL OF oFolder:aDialogs[2] 	//"&Nao Conc Excel"###"Processando ..."
	
//Tratamento do Folder -> Nao Conciliadas
oNaoConc := TWBrowse():New(C(000),C(000),C(380),C(090),,aHeader,,oFolder:aDialogs[4],,,,,,,,,,,,,,,,,,,)

oNaoConc:SetArray(aNaoConc)
oNaoConc:bLine :=	{||{	aNaoConc[oNaoConc:nAt,01],aNaoConc[oNaoConc:nAt,02],;
							aNaoConc[oNaoConc:nAt,03],aNaoConc[oNaoConc:nAt,04], aNaoConc[oNaoConc:nAt,05],aNaoConc[oNaoConc:nAt,06],aNaoConc[oNaoConc:nAt,07],;
							aNaoConc[oNaoConc:nAt,08],aNaoConc[oNaoConc:nAt,09],aNaoConc[oNaoConc:nAt,10],aNaoConc[oNaoConc:nAt,11],;
							aNaoConc[oNaoConc:nAt,12],aNaoConc[oNaoConc:nAt,13],aNaoConc[oNaoConc:nAt,14],aNaoConc[oNaoConc:nAt,15],;
							aNaoConc[oNaoConc:nAt,16],aNaoConc[oNaoConc:nAt,17],aNaoConc[oNaoConc:nAt,18],aNaoConc[oNaoConc:nAt,19],;
							aNaoConc[oNaoConc:nAt,20],Iif(aNaoConc[oNaoConc:nAt,21] == '1' .OR. aNaoConc[oNaoConc:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aNaoConc[oNaoConc:nAt,22],aNaoConc[oNaoConc:nAt,23]}}
						
oNaoConc:bHeaderClick := {|x,y,z|A910SelReg(@aNaoConc,@oNaoConc,oSelec,oNSelec,y,,.F.)}

//"Selecionar item correspondente no Rodape'"
oNaoConc:bLDblClick	  := {||MsgInfo(STR0045)}
	
//tratamento Rodape Nao Conciliadas
oTitulos := TWBrowse():New(C(008),C(000),C(380),C(090),,aHeadSE1,,oFolder:aDialogs[4],,,,,,,,,,,,,,,,,,,)
	
LjMsgRun(STR0091,,{||A910Titulos(aNaoConc,oNaoConc:nAt,oSelec,@aTitulos,oTitulos,oNSelec,aConc, aConcPar)})			//"Carregando os Tํtulos..."
		
	//Verifica se existem informacoes Nao Conciliadas
If aTitulos[1][5] <> ""
	oTitulos:bLDblClick	:= {||A910SelReg(@aTitulos,@oTitulos,oSelec,oNSelec,1,oTitulos:nAt,.T.,@aNaoConc,oNaoConc:nAt,oNaoConc)}
EndIf

	
@ C(095),C(300) Button STR0046 Size C(073),C(012) Action Processa({||Fina910D(aNaoConc, aTitulos, aHeader, aHeadSE1, 1)},STR0047) PIXEL OF oFolder:aDialogs[4] 	//"&Nao Conc Excel"###"Processando ..."
/*	
@ C(205),C(002) Button STR0044 Size C(073),C(012) Action A910Efetiva(	@aNaoConc,	@oNaoConc,	oRedSelec,	oAmaSelec,;												//"&Efetiva Concilia็ใo"
																				aTitulos,	@aConcMan,	oConcMan,	@aTotais,;
																				@oTotais, 	3,			@oTitulos,	oDlg) PIXEL OF oFolder:aDialogs[4]
*/	
@ C(205),C(300) Button STR0048 Size C(073),C(012) Action Processa({||Fina910D(aNaoConc, aTitulos, aHeader, aHeadSE1, 2)},STR0047) PIXEL OF oFolder:aDialogs[4] 	//"&Titulos Excel"###"Processando ..."
	
//Tratamento do Folder -> Conciliadas Manualmente
oConcMan := TWBrowse():New(C(000),C(000),C(000),C(000),,aHeader,,oFolder:aDialogs[3],,,,,,,,,,,,,,,,,,,)
oConcMan:Align := CONTROL_ALIGN_ALLCLIENT
oConcMan:SetArray(aConcMan)
oConcMan:bLine     := {|| A910Browse(aConcMan[oConcMan:nAt])}
	
oConc:Refresh()
oConcPar:Refresh()
oNaoConc:Refresh()
oTitulos:Refresh()
 
ACTIVATE MSDIALOG oDlg CENTERED //ON INIT Eval( bInitDlg )
                            
A910CLOSEAREA("TMP", cArqTMP)

aConc		:= aSize(aConc,0)
aConcPar	:= aSize(aConcPar,0)
aNaoConc	:= aSize(aNaoConc,0)
aConcMan	:= aSize(aConcMan,0)
aIndic		:= aSize(aIndic,0)
	
aConc		:= {}
aConcPar	:= {}
aNaoConc	:= {}
aConcMan	:= {}
aIndic		:= {}
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza o log de processamento   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ProcLogAtu("FIM")

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  	ณA910AtuDadosบAutor ณRafael Rosa da Silvaบ Data ณ 08/05/09   บฑฑ
ฑฑฬอออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     	ณRotina que retorna os dados de conciliacao de acordo com o  บฑฑ
ฑฑบ          	ณvinculo com o contas a receber                              บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros	ณ aConc    - Array do Folder Conciliados                     บฑฑ
ฑฑบ				ณ aConcPar - Array do Folder Conc. Parcialmente              บฑฑ
ฑฑบ			 	ณ aNaoConc - Array do Folder Nใo Conciliadas                 บฑฑ
ฑฑบ			 	ณ aTotais  - Array do Folder Totais                          บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno	 	ณ lRet	- .T. (Ok) ou .F. (Divergencia)                       บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910AtuDados(aConc, aConcPar, aNaoConc, aConcMan, aIndic, oNSelec, oRedSelec) 

Local cQry				:= ""							//Instrucao de query no banco
Local cAliasSitef		:= GetNextAlias()         		//Variavel que recebe o proximo Alias disponivel
Local cSubstring		:= ""							//Variavel para tratar a comando "SUBSTRING" no banco de dados
Local cValConta		    := ""							//Informacao de conta nao cadastrada ou cadastrada
Local cFilSitef	     	:= ""							//Filial informada no Sitef
Local cIdioma			:= ""							//Verifica qual idioma esta' em uso (Portugues, Espanhol ou Ingles)
	
Local aColsAux		:= {}								//Array auxiliar para carregar arrays de trabalho
Local aArea			:= GetArea()						//Array que armazena a ultima area utilizada
	
Local lRet				:= .T.							//Retorno da funcao
Local aDados			:= {}
Local cMSFIL			:= ""
Local cCodBco			:= ""
Local cCodAge			:= ""
Local cNumCC			:= ""
Local lUsaMep           := .F.

//Zero as variaveis antes de atualizar
aConc		:= {}
aConcPar	:= {}
aNaoConc	:= {}
aConcMan	:= {}
aIndic		:= {}
	       
If ( AllTrim( Upper( TcGetDb() ) ) $ "ORACLE_INFORMIX" )
	cSubstring := "SUBSTR"
ElseIf ( AllTrim( Upper( TcGetDb() ) ) $ "DB2|DB2/400")
	cSubstring := "SUBSTR"
Else
	cSubstring := "SUBSTRING"
EndIf


        cQry := "SELECT ZX3.ZX3_CODEST, ZX3.ZX3_CODLOJ, SE1.E1_CLIENTE, ZX3.ZX3_NUCOMP, ZX3.ZX3_DTTEF, SE1.E1_VALOR,SE1.E1_SALDO, "
        cQry += "ZX3.ZX3_VLLIQ,ZX3.ZX3_VLBRUT,ZX3.ZX3_VLCOM, ZX3.ZX3_WLDPA, SE1.E1_PARCELA, ZX3.ZX3_PARCEL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_TIPO, SE1.E1_MSFIL,SE1.E1_FILORIG, "
        cQry += "ZX3.ZX3_DTCRED, SE1.E1_DOCTEF, E1_P_WLDPA, SE1.E1_VENCREA, E1_EMISSAO,ZX3.ZX3_STATUS, ZX3.ZX3_PREFIX, ZX3.ZX3_NUM, "
        cQry += "ZX3.ZX3_CODRED ,ZX3.ZX3_PARC, ZX3.ZX3_TIPO, ZX3.R_E_C_N_O_ RECNO_ZX3,ZX3_PARALF, ZX3.ZX3_CODBCO, ZX3.ZX3_CODAGE, ZX3.ZX3_NUMCC, ZX3.ZX3_CAPTUR, SE1.R_E_C_N_O_ RECNO_SE1, SE1.E1_LOJA "
	
        cQry += "FROM " + AllTrim(RetSqlName("ZX3")) + " ZX3 "
        cQry += "LEFT JOIN " + RetSqlName("SE1") + " SE1 "
        cQry += "ON  (" + cSubstring + "(SE1.E1_PARCELA,1, 2) = ZX3.ZX3_PARCEL OR SE1.E1_PARCELA = ZX3.ZX3_PARCEL OR " + cSubstring + "(SE1.E1_PARCELA,1, "+AllTrim(Str(nTamParc2))+") = ZX3_PARALF) "
		
        cQry += "AND SE1.E1_P_WLDPA = ZX3.ZX3_WLDPA "

        cQry += "AND SE1.E1_SALDO > 0 "
	
        cQry += "AND SE1.D_E_L_E_T_ = ' ' "
		
		If !empty(dTos(dDataCredI)) .and. !empty(dTos(dDataCredF))
			cQry += "WHERE ZX3.ZX3_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "' AND ZX3.ZX3_STATUS IN ('1','3','4') "
		Else
		    cQry += "WHERE ZX3.ZX3_STATUS IN ('1','3','4') "
		EndIf    
			
        cQry += "AND ZX3.D_E_L_E_T_=' ' "
        cQry += "ORDER BY RECNO_SE1"
   

    cQry := ChangeQuery(cQry)
		
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasSitef,.F.,.T.)
				
    DbSelectArea("SX6")
    SX6->(DbSetOrder(1))
                       
    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))

    dbSelectArea("ZX3")
    ZX3->(dbSetOrder(5))
		
    If !(cAliasSitef)->(Eof())
			
        While !(cAliasSitef)->(Eof())
			//Limpa o array auxiliar
            aColsAux := {}		
            cValConta := ''
            
            If !Empty((cAliasSitef)->ZX3_CODBCO) .And. !Empty((cAliasSitef)->ZX3_CODAGE) .And. !Empty((cAliasSitef)->ZX3_NUMCC)
                    If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"1")
                        cValConta := STR0104     //'OK'
                    Else
                        cValConta := STR0103     //'CONTA NAO CADASTRADA'
                    EndIf
            Else
                  cValConta := STR0103 + "/Vazio"    //'CONTA NAO CADASTRADA'  
            EndIf
				
            aAdd(aColsAux,'')							   //1-Status oNSelec
            aAdd(aColsAux,(cAliasSitef)->ZX3_CODEST)       //2-Codigo do Estabelecimento Sitef
            aAdd(aColsAux,(cAliasSitef)->ZX3_CODLOJ)       //3-Codigo da Loja Sitef
            aAdd(aColsAux,(cAliasSitef)->E1_CLIENTE)       //4-Codigo do Cliente (Administradora)
            aAdd(aColsAux,(cAliasSitef)->E1_PREFIXO)       //5-Prefixo do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_NUM)           //6-Numero do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_TIPO)          //7-Tipo do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_PARCELA)       //8-Numero da parcela Protheus
            aAdd(aColsAux,(cAliasSitef)->ZX3_NUCOMP)       //9-Numero do Comprovante Sitef
            aAdd(aColsAux,Stod((cAliasSitef)->ZX3_DTTEF))  //10-Data da Venda Sitef
            aAdd(aColsAux,StoD((cAliasSitef)->ZX3_DTCRED)) //11-Data de Credito Sitef
            aAdd(aColsAux,(cAliasSitef)->E1_SALDO)         //12-Valor do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->ZX3_VLLIQ)        //13-Valor liquido Sitef
            aAdd(aColsAux,(cAliasSitef)->ZX3_WLDPA)       //14-Numero NSU Sitef
            aAdd(aColsAux,(cAliasSitef)->ZX3_PARCEL)       //15-Numero da parcela Sitef
            aAdd(aColsAux,(cAliasSitef)->E1_DOCTEF)        //16-Documento TEF Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_P_WLDPA)        //17-NSU Sitef Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_VENCREA)       //18-Vencimento real do titulo
			aAdd(aColsAux,(cAliasSitef)->ZX3_CODBCO +' / '+(cAliasSitef)->ZX3_CODAGE+' / '+(cAliasSitef)->ZX3_NUMCC)//19-banco/agencia/conta
            aAdd(aColsAux,cValConta)       				   //20-Informa็ใo de conta nใo cadastrada ou cadastrada
            aAdd(aColsAux,(cAliasSitef)->ZX3_CAPTUR)       //21 - (0,2 ou 3 - Transa็ใo Sitef),(1 ou 4 - Outros/POS)
            aAdd(aColsAux,(cAliasSitef)->RECNO_SE1)        //22 - RECNO do SE1
            aAdd(aColsAux,(cAliasSitef)->RECNO_ZX3)        //23 - RECNO do ZX3
			aAdd(aColsAux,(cAliasSitef)->ZX3_CODAGE)      //24 - Agencia
            aAdd(aColsAux,(cAliasSitef)->ZX3_NUMCC)       //25 - Conta
            aAdd(aColsAux,(cAliasSitef)->ZX3_CODBCO)      //26 - Banco	
            aAdd(aColsAux,(cAliasSitef)->E1_LOJA)          //27 - Codigo da Loja
            aAdd(aColsAux,(cAliasSitef)->E1_FILORIG)	   //28 - FILIAL
            aAdd(aColsAux,(cAliasSitef)->ZX3_VLCOM)	   //29 - Taxa            
				
			//Tratamento para Conciliados Manualmente
            If (cAliasSitef)->ZX3_STATUS == '4'
            	
            	//Valido se a conta estแ bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"2") .And.  AllTrim(Upper(cValConta)) == "OK"
                   
                    aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                Else
                    aColsAux[1] := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"

                    If AllTrim(Upper(cValConta)) == "OK"
                        aColsAux[20] := STR0131
                    EndIf
                EndIf
				
                aColsAux[5] := (cAliasSitef)->ZX3_PREFIX //Rastro Prefixo SE1
                aColsAux[6] := (cAliasSitef)->ZX3_NUM    //Rastro Num SE1
                aColsAux[8] := (cAliasSitef)->ZX3_PARC   //Rastro Parcela SE1
                aColsAux[7] := (cAliasSitef)->ZX3_TIPO   //Rastro Tipo SE1
					
                aAdd(aConcMan,aColsAux)
                If RecLock("TMP",.T.)
                    TMP->SOURCE	:= PadR('CONCMAN',10,' ')
                    TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                    TMP->(MSUNLOCK())
                EndIf
					
            Else
				//Tratamento para os Nao Conciliados
                If Empty((cAliasSitef)->E1_P_WLDPA)
						
                    aColsAux[22] := 0   //limpa o recno do se1
					
					//Valido se a conta estแ bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA	
                    If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"2") .And. AllTrim(Upper(cValConta)) == "OK"
                        aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                    Else
                        aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                        If AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[20] := STR0131
                        EndIf
                    EndIf

                    aAdd(aNaoConc,aColsAux)
						
				//Tratamento para os Conciliados
                ElseIf ( ;
                 		((cAliasSitef)->ZX3_VLLIQ >= (cAliasSitef)->E1_SALDO - ((cAliasSitef)->E1_SALDO * (nMargem/100)) );
 						) .And. ;  
 						AllTrim((cAliasSitef)->ZX3_WLDPA)   ==  AllTrim((cAliasSitef)->E1_P_WLDPA)  .AND.;
 						AllTrim(If( lParcAlfa , (cAliasSitef)->ZX3_PARALF , (cAliasSitef)->ZX3_PARCEL ) )  ==  AllTrim((cAliasSitef)->E1_PARCELA)

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณExiste a possibilidade de existir um registro na ZX3 com os dados iguais   ณ
					//ณZX3_FILIAL / ZX3_DTTEF / ZX3_WLDPA / ZX3_PARCEL E ZX3_CODLOJ              ณ
					//ณIsto ocorre por causa das transacoes feitas em POS, com isso, teremos      ณ
					//ณdois ou mais registros na ZX3 com referencia ao mesmo registro da SE1.     ณ
					//ณNeste caso, so iremos conciliar o primeiro que foi encontrado e o outro(s) ณ
					//ณira(ao) para a pasta de nใo conciliados.                                   ณ
					//ณProcura no array de conciliados o recno do SE1                             ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                    If Empty(aConc) .or. (aConc[Len(aConc)][22] <> aColsAux[22])
						//Valido se a conta estแ bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                        If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"2") .And. AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[1] := LoadBitmap(GetResources(), "BR_VERDE") //"BR_BRANCO"
                        
                        ElseIf StoD((cAliasSitef)->ZX3_DTCRED) < StoD((cAliasSitef)->E1_EMISSAO)
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                            aColsAux[20] := "Data de emissao maior que a data de credito."                        

                        Else
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                            If AllTrim(Upper(cValConta)) == "OK"
                                aColsAux[20] := STR0131
                            EndIf
                        EndIf
						
                        aAdd(aConc,aColsAux)
						
                        If RecLock("TMP",.T.)
                            TMP->SOURCE	:= PadR('CONC',10,' ')
                            TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                            TMP->(MSUNLOCK())
                        EndIf
                    Else
						//Valido se a conta estแ bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                        If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"2") .And. AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"                  
                            
                        ElseIf StoD((cAliasSitef)->ZX3_DTCRED) < StoD((cAliasSitef)->E1_EMISSAO)
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                            aColsAux[20] := "Data de emissao maior que a data de credito."                        
                        
                        Else
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
							
                            If AllTrim(Upper(cValConta)) == "OK"
                                aColsAux[20] := STR0131
                            EndIf
                        EndIf
					
                        aAdd(aNaoConc,aColsAux)
                    EndIf
						
					//Tratamento para os Conciliados Parcialmente
                Else
					//Valido se a conta estแ bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                    If A910VLDBCO((cAliasSitef)->ZX3_CODBCO,(cAliasSitef)->ZX3_CODAGE,(cAliasSitef)->ZX3_NUMCC,"2") .And. AllTrim(Upper(cValConta)) == "OK"
                        aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                    Else
                        aColsAux[1] := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
						
                        If AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[20] := STR0131
                        EndIf
                    EndIf
					
                    	If AllTrim((cAliasSitef)->ZX3_PARC)  ==  AllTrim((cAliasSitef)->E1_PARCELA)
					   		aAdd(aConcPar,aColsAux)   
						Endif
					
                    If RecLock("TMP",.T.)
                        TMP->SOURCE	:= PadR('CONCPAR',10,' ')
                        TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                        TMP->(MSUNLOCK())
                    EndIf
						
					//Armazena os indicadores para exibir as divergencias (Rodape Conciliados Parcialmente)
                    aAdd(aIndic,{	(cAliasSitef)->E1_SALDO			,;
                        (cAliasSitef)->ZX3_VLLIQ			,;
                        (cAliasSitef)->E1_P_WLDPA			,;
                        (cAliasSitef)->ZX3_WLDPA		,;
                        StoD((cAliasSitef)->E1_EMISSAO)	,;
                        StoD((cAliasSitef)->ZX3_DTTEF)	,;
                        (cAliasSitef)->E1_PARCELA		,;
                        (cAliasSitef)->ZX3_PARCEL		,;
                        (cAliasSitef)->E1_PREFIXO		,;
                        (cAliasSitef)->E1_NUM			,;
                        (cAliasSitef)->E1_TIPO			})
                EndIf
            EndIf
            (cAliasSitef)->(dbSkip())
        EndDo
    EndIf

    (cAliasSitef)->(dbCloseArea())

    RestArea(aArea)
		
//Carrega o array de Divergencias
If Len(aIndic) == 0
	aAdd(aIndic,{0,0,"","",cTod("  /  /  "),cTod("  /  /  "),"","","","",""})
EndIf
	
If Len(aConc) == 0 .AND. Len(aConcPar) == 0 .AND. Len(aNaoConc) == 0
	MsgInfo(STR0049) 			//"Nใo foram encontradas informacoes com os parametros repassados, favor verificar novamente"
	lRet := .F.
EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910Total บAutor  ณRafael Rosa da Silvaบ Data ณ  08/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o array com o valor total dos registros            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aConc	- Array do Folder Conciliados                        บฑฑ
ฑฑบ          ณ aConcPar - Array do Folder Conc. Parcialmente              บฑฑ
ฑฑบ          ณ aNaoConc - Array do Folder Nใo Conciliadas                 บฑฑ
ฑฑบ          ณ aTotais  - Array do Folder Totais                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet	- .T. (Ok) ou .F. (Divergencia)                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910Total(aConc,aConcPar,aNaoConc,aConcMan,aTotais,aHeader,aHeadMan)

Local nI   	:= 0						//Variavel para incrementar intervalo selecionado
Local nPos 	:= 0						//Variavel para verificar se existe valor no array aTotais
Local dData	:= CTOD("  /  /    ")

//Percorre o array aConc somando os registros de acordo com a data
For nI := 1 to Len(aConc)
	
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConc[nI][11]
		dData := aConc[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConc[nI][11] })
	EndIf
					
	If nPos == 0
		aAdd(aTotais,{aConc[nI][11],;		//Data de Credito
						aConc[nI][13],;		//Valor Total da Coluna Conciliados
						1,;						//Quantidade de registros da coluna Conciliados
						0,;						//Valor Total da Coluna Conciliados Parcialmente
						0,;						//Quantidade de registros da coluna Conciliados Parcialmente
						0,;						//Valor Total da Coluna Conciliados Manualmente
						0,;						//Quantidade de registros da coluna Conciliados Manualmente
						0,;						//Valor Total da Coluna Nao Conciliados
						0,;						//Quantidade de registros da coluna Nao Conciliados
						0})						//Total Geral
	Else
		aTotais[nPos][TOT_CONC] += aConc[nI][13] //Somatorio Conciliados
		aTotais[nPos][TOT_CONC] := Round(aTotais[nPos][TOT_CONC],2)
		aTotais[nPos][TOT_QTDCONC] += 1
	EndIf
Next nI
	
	//Percorre o array aConcPar somando os registros de acordo com a data
dData:= CTOD("  /  /    ")
nPos := 0

For nI := 1 to Len(aConcPar)
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConcPar[nI][11]
		dData := aConcPar[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConcPar[nI][11] })
	EndIf

	If nPos == 0
		aAdd(aTotais,{aConcPar[nI][11],;	//Data de Credito
						0,;						//Valor Total da Coluna Conciliados
						0,;						//Quantidade de registros da Coluna Conciliados
						aConcPar[nI][13],;	//Valor Total da Coluna Conciliados Parcialmente
						1,;						//Quantidade de registros da coluna Conciliados Parcialmente
						0,;						//Valor Total da Coluna Conciliados Manualmente
						0,;						//Quantidade de registros da coluna Conciliados Manualmente
						0,;						//Valor Total da Coluna Nao Conciliados
						0,;						//Quantidade de registros da coluna Nao Conciliados
						0})						//Total Geral
	Else
		aTotais[nPos][TOT_CPAR] += aConcPar[nI][13] //Somatorio Conciliados Parcialmente
		aTotais[nPos][TOT_CPAR] := Round(aTotais[nPos][TOT_CPAR],2)
		aTotais[nPos][TOT_QTDCPAR] += 1
	EndIf
Next nI
		
	//Percorre o array aNaoConc somando os registros de acordo com a data
dData:= CTOD("  /  /    ")
nPos := 0

For nI := 1 to Len(aNaoConc)
	//Verifica se ja existe um registro para a data em questao       
	If nPos == 0 .or. dData <> aNaoConc[nI][11]
		dData := aNaoConc[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aNaoConc[nI][11] })
	EndIf

	If nPos == 0
		aAdd(aTotais,{aNaoConc[nI][11],;	//Data de Credito
						0,;						//Valor Total da Coluna Conciliados
						0,;						//Quantidade de registros da Coluna Conciliados
						0,;						//Valor Total da Coluna Conciliados Parcialmente
						0,;						//Quantidade de registros da coluna Conciliados Parcialmente
						0,;						//Valor Total da Coluna Conciliados Manualmente
						0,;						//Quantidade de registros da coluna Conciliados Manualmente
						aNaoConc[nI][13],;	//Valor Total da Coluna Nao Conciliados
						1,;						//Quantidade de registros da coluna Nao Conciliados
						0})						//Total Geral
	Else
		aTotais[nPos][TOT_CNAO] += aNaoConc[nI][13] //Somatorio Nao Conciliados
		aTotais[nPos][TOT_CNAO] := Round(aTotais[nPos][TOT_CNAO],2)
		aTotais[nPos][TOT_QTDCNAO] += 1
	EndIf
Next nI
	
dData:= CTOD("  /  /    ")
nPos := 0

For nI := 1 to Len(aConcMan)
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConcMan[nI][11]
		dData := aConcMan[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConcMan[nI][11]})
	EndIf

	If nPos == 0
		aAdd(aTotais,{aConcMan[nI][11],;	//Data de Credito
						0,;						//Valor Total da Coluna Conciliados
						0,;						//Quantidade de registros da Coluna Conciliados
						0,;						//Valor Total da Coluna Conciliados Parcialmente
						0,;						//Quantidade de registros da coluna Conciliados Parcialmente
						aConcMan[nI][13],;	//Valor Total da Coluna Conciliados Manualmente
						1,;						//Quantidade de registros da coluna Conciliados Manualmente
						0,;						//Valor Total da Coluna Nao Conciliados
						0,;						//Quantidade de registros da coluna Nao Conciliados
						0})						//Total Geral
	Else
		aTotais[nPos][TOT_CMAN] += aConcMan[nI][13] //Somatorio Conciliados Manualmente
		aTotais[nPos][TOT_CMAN] := Round(aTotais[nPos][TOT_CMAN],2)
		aTotais[nPos][TOT_QTDCMAN] += 1
	EndIf
Next nI
		
//Percorre o array aConcMan somando os registros de acordo com a data
For nI := 1 to Len(aTotais)
	aTotais[nI][TOT_GERAL] := aTotais[nI][TOT_CONC]+aTotais[nI][TOT_CPAR]+aTotais[nI][TOT_CMAN]+aTotais[nI][TOT_CNAO]
	aTotais[nI][TOT_GERAL] := Round(aTotais[nI][TOT_GERAL],2)
Next nI
	
	//caso nao exista nenhum registro de somatoria, crio uma linha em branco para evitar erro
If Len(aTotais) == 0
	aAdd(aTotais,{cTod("  /  /  "),0,0,0,0,0,0,0,0,0})
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA910TitulosบAutor  ณRafael Rosa da SilvaบData  ณ  08/06/09  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que retorna todos os titulos do contas a receber que บฑฑ
ฑฑบ          ณpossuam dados parecidos com os recebidos do arquivo de      บฑฑ
ฑฑบ          ณConciliacao do SITEF                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaDados  - Array com os registros do arquivo de conciliacao  บฑฑ
ฑฑบ          ณ          do SITEF que nao possuem vinculo com qualquer     บฑฑ
ฑฑบ          ณ          registro do contas a receber                      บฑฑ
ฑฑบ          ณnLinha  - Linha do Array dos registros nao Conciliados      บฑฑ
ฑฑบ          ณoSelec  - Objeto para itens Nao Selecionados                บฑฑ
ฑฑบ          ณaTitulos- Array com os titulos que se assemelham ao posicio-บฑฑ
ฑฑบ          ณ          nado no array de Nao Conciliados                  บฑฑ
ฑฑบ          ณoTitulos- Objeto do array aTitulos                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910Titulos(aDados,nLinha,oSelec,aTitulos,oTitulos,oNSelec,aConc,aConcPar)

Local cQry	    		:= ""								//Instrucao de query no banco
Local cAliasSitef    := GetNextAlias()         			//Variavel que recebe o proximo Alias disponivel
	
Local nI				:= 0								//Variavel para incrementar intervalo selecionado
Local nNaoConc		:= 1								//Verificador se titulo possui vinculo com arquivos Sitef
Local nNaoConcPa		:= 1								//Verificador se titulo possui vinculo com arquivos Sitef
	
Local lExclusivo		:= !Empty(xFilial("SE1"))			//Verifica se SE1 esta' compartilhada ou exclusiva
Local lExclusZX3		:= !Empty(xFilial("ZX3"))			//Verifica se ZX3 esta' compartilhada ou exclusiva
Local lExclusMEP		:= !Empty(xFilial("MEP"))			//Verifica se MEP esta' compartilhada ou exclusiva
Local cSubstring		:= ""

	

        If ( AllTrim( Upper( TcGetDb() ) ) $ "ORACLE_INFORMIX" )
            cSubstring := "SUBSTR"
        ElseIf ( AllTrim( Upper( TcGetDb() ) ) $ "DB2|DB2/400")
            cSubstring := "SUBSTR"
        Else
            cSubstring := "SUBSTRING"
        EndIf
			
		 //Query para buscar os titulos no financeiro semelhantes aos titulos Sitef

            cQry := "SELECT SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_P_WLDPA, SE1.E1_DOCTEF ,SE1.E1_PREFIXO, SE1.E1_NUM, "
            cQry += "SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_MSFIL, SE1.E1_FILIAL, SE1.R_E_C_N_O_ RECNOSE1, "

            cQry += " '"+ Space(nTamParc) +"' AS MEP_PARTEF "
            cQry += "FROM " + RetSqlName("SE1") + " SE1 "

            cQry += "WHERE SE1.D_E_L_E_T_=' ' "

			cQry += "AND SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND SE1.E1_TIPO = 'NF'"
		
            cQry += "AND SE1.E1_VENCREA  BETWEEN '" + dTos(dDataCredI - nQtdDias) + "' AND '" + dTos(dDataCredF) + "' "
            cQry += "AND SE1.E1_SALDO > 0 "
            cQry += "ORDER BY SE1.E1_VALOR "
       

        cQry := ChangeQuery(cQry)
        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasSitef,.F.,.T.)
			
        While !(cAliasSitef)->(Eof())
				
			//Verifica se o titulo retornado encontra-se na pasta de conciliados
			//Se existir, nao sera exibido na pasta de nao conciliados
            nNaoConc := If( TMP->(MSSeek(PadR('CONC',10)+STRZERO((cAliasSitef)->RECNOSE1,10))), 1, 0 )
				
			//Verifica se o titulo retornado encontra-se na pasta de conciliados
			//Se existir, nao sera exibido na pasta de conciliados parcialmente
            nNaoConcPa := If( TMP->(MSSeek(PadR('CONCPAR',10)+STRZERO((cAliasSitef)->RECNOSE1,10))), 1, 0 )
				
            If (nNaoConc + nNaoConcPa) = 0 //Se nao encontrar o item e Nao Conciliado
					
                aColsAux := {}
					
                aAdd(aColsAux,LoadBitmap(GetResources(), "BR_BRANCO"))	//1-Status
                aAdd(aColsAux,StoD((cAliasSitef)->E1_EMISSAO))		//2-Emissao do Titulo
                aAdd(aColsAux,StoD((cAliasSitef)->E1_VENCREA))		//3-Vencimento real do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_SALDO)				//4-Valor do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_P_WLDPA)				//5-Numero NSU Sitef
                aAdd(aColsAux,(cAliasSitef)->E1_DOCTEF)				//6-Numero Documento Sitef
                aAdd(aColsAux,(cAliasSitef)->E1_PREFIXO)				//7-Prefixo do Titulo
                aAdd(aColsAux,(cAliasSitef)->E1_NUM)					//8-Numero do Titulo
                aAdd(aColsAux,(cAliasSitef)->E1_PARCELA)				//9-Parcela do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_TIPO)				//10-Tipo do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_CLIENTE)				//11-Cliente (Administradora)
                aAdd(aColsAux,(cAliasSitef)->E1_PARCELA)           //12 Parcela Sitef
					
					
                aAdd(aColsAux,(cAliasSitef)->E1_LOJA)				//13-Loja da venda
                aAdd(aColsAux,(cAliasSitef)->E1_MSFIL)				//14-Loja da venda
                aAdd(aColsAux,(cAliasSitef)->RECNOSE1)				//15-RECNO DO TITULO
                aAdd(aColsAux,(cAliasSitef)->E1_VALOR)				//16-vALOR DO TITULO
                aAdd(aColsAux,(cAliasSitef)->E1_FILIAL)	            //17-FILIAL DA SE1
					
                If Len(aColsAux) > 1
                    aAdd(aTitulos,aColsAux)
                EndIf
            EndIf
				
            (cAliasSitef)->(dbSkip())
        EndDo

//Atualiza objeto oTitulos com as informacoes encontradas na consulta
If Len(aTitulos) > 0
    oTitulos:SetArray(aTitulos)
    oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
    oTitulos:Refresh()
Else //Se nao encontrar titulos carrega array para evitar erro no objeto
    aAdd(aTitulos,{"",cTod("  /  /  "),cTod("  /  /  "),"","","","","","","","","","","",0})
		
    oTitulos:SetArray(aTitulos)
    oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
    oTitulos:Refresh()
EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA910EfetivaบAutor  ณTotvs               บData  ณ  28/04/11  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que ้ executada a partir do botao de efetivar conci- บฑฑ
ฑฑบ          ณliacao dos Folders Conciliadas, Conc. Parcialmente e Nใo    บฑฑ
ฑฑบ          ณConciliadas, tendo como funcionalidade baixar os titulos do บฑฑ
ฑฑบ          ณContas a Receber e alterar o status do mesmo na tabela ZX3  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaDados    - Array com os dados a serem baixados             บฑฑ
ฑฑบ          ณoObj      - Objeto do array aDados                          บฑฑ
ฑฑบ          ณoRedSelec - Objeto para mostrar o titulo como baixado       บฑฑ
ฑฑบ          ณoAmaSelec - Objeto para mostrar o titulo com divergencia    บฑฑ
ฑฑบ          ณaTitulos  - Array com os titulos do SE1                     บฑฑ
ฑฑบ          ณaConcMan  - Array com os conciliados manualmente            บฑฑ
ฑฑบ          ณoConcMan  - Objeto do array aConcMan                        บฑฑ
ฑฑบ          ณaTotais   - Array com os totais                             บฑฑ
ฑฑบ          ณoTotais   - Objeto do array aTotais						    บฑฑ
ฑฑบ          ณnTpConc   - Tipo de conciliacao                             บฑฑ
ฑฑบ          ณ          1 - Conciliados                                   บฑฑ
ฑฑบ          ณ          2 - Conciliados parcial					           บฑฑ
ฑฑบ          ณ          1 - Nao conciliados/manualmente                   บฑฑ
ฑฑบ          ณoTitulos  - Objeto do array aTitulos                        บฑฑ
ฑฑบ          ณoDlg      - Objeto da tela Dialog                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910Efetiva(aDados,oObj,oRedSelec,oAmaSelec,aTitulos,aConcMan,oConcMan,aTotais,oTotais,nTpConc,oTitulos,oDlg)

Local cMensagem := ''	//Mensagem utilizada na funcao processa
	
If cConcilia == 2
    //Baixa por lote
	cMensagem := STR0093
Else
	//"Baixa de Tํtulos Individual..."
	cMensagem := STR0105
EndIf

ProcLogAtu("MENSAGEM","INI -> Efetivando registros")
BEGIN TRANSACTION
Do Case
	//Efetivacao dos conciliados e conciliados parcial
	Case nTpConc == 1 .OR. nTpConc == 2
       ProcLogAtu(STR0138,STR0144)
		Processa(	{|| A910EfConc(aDados,oObj,oDlg,oRedSelec,oAmaSelec,aTotais,oTotais)},;
					STR0092,cMensagem)				//"Aguarde..."	### "Preparando Dados para Baixa..."

	//Efetiva็ใo dos nใo conciliados (Manualmente)					
	Case nTpConc == 3
       ProcLogAtu(STR0138,STR0145)
		Processa(	{|| A910EfNaoConc(aDados,oObj,aTitulos,oDlg,aConcMan,oConcMan,oRedSelec,oTitulos,aTotais,oTotais)},;
					STR0092, cMensagem)				//"Aguarde..."	### "Preparando Dados para Baixa..."
EndCase
END TRANSACTION	
ProcLogAtu(STR0138,STR0146)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA910EfNaoConcบAutor  ณTotvs             บData  ณ  08/06/09  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que ้ executada a partir do botao de efetivar conci- บฑฑ
ฑฑบ          ณliacao dos Folders Nใo Conciliadas,                         บฑฑ
ฑฑบ          ณ tendo como funcionalidade baixar os titulos do             บฑฑ
ฑฑบ          ณContas a Receber e alterar o status do mesmo na tabela ZX3  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaNaoConc  - Array com os dados a serem baixados             บฑฑ
ฑฑบ          ณoNaoConc  - Objeto do array aNaoConc                        บฑฑ
ฑฑบ          ณaTitulos  - Array com os titulos do SE1                     บฑฑ
ฑฑบ          ณoDlg      - Objeto da tela Dialog                           บฑฑ
ฑฑบ          ณaConcMan  - Array com os conciliados manualmente            บฑฑ
ฑฑบ          ณoConcMan  - Objeto do array aConcMan                        บฑฑ
ฑฑบ          ณoRedSelec - Objeto para mostrar o titulo como baixado       บฑฑ
ฑฑบ          ณoTitulos  - Objeto do array aTitulos                        บฑฑ
ฑฑบ          ณaTotais   - Array com os totais                             บฑฑ
ฑฑบ          ณoTotais   - Objeto do array aTotais                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910EfNaoConc(aNaoConc,oNaoConc,aTitulos,oDlg,aConcMan,oConcMan,oRedSelec,oTitulos,aTotais,oTotais)

Local nPos			:= 0									//Posicao do titulo selecionado
Local nCount		:= 0									//Contador utilizado para varrer o array da ZX3
Local aLotes		:= {}									//Array com os lotes para baixa
Local lRet			:= .F.									//Retorno da fun็ใo de baixa individual
Local cFilOri		:= cFilAnt  
Local aDadoBanco	:= {}									//Array com os dados de banco, agencia e conta
Local nLote		:= 0									//Posicao do lote no array
Local aTitInd		:= {}									//Dados do titulo individual  
	
//Verifica se algum item foi selecionado nos titulos
If (nPos := aScan(aTitulos,{|x| x[1]:cName == "BR_VERDE" })) == 0
	MsgInfo(STR0051) //"Nao ha' nenhum registro marcado"
	Return Nil
EndIf

ProcRegua(Len(aNaoConc))
	
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	                                                                                   
For nCount := 1 To Len(aNaoConc)

	//Verifica se o item esta selecionado
	If AllTrim(oNaoConc:aArray[nCount][1]:cName) == "BR_VERDE"
		
		//Procura no array de titulos nใo conciliados o recno correspondente a ZX3
		If (nPos := aScan(aTitulos,{|x| x[15] == oNaoConc:aArray[nCount][22] })) <> 0
			cFilAnt := aTitulos[nPos][17]
		
			//Verifica se existe o registro no SE1
			If !SE1->(dbSeek(xFilial("SE1")+aTitulos[nPos][7]+aTitulos[nPos][8]+aTitulos[nPos][9]+aTitulos[nPos][10]))
				MsgInfo(STR0050)			//"Arquivo nใo encontrado no Financeiro"
			Else
				//Lote - prepara os dados para baixa dos titulos em lote
				//Baixa Individual - prepara e ja executa a baixa do titulo.
				lRet := .F.

				//Busca banco / agencia / conta. Efetua atualiza็ใo do SE1
				aDadoBanco := BuscarBanco(oNaoConc:aArray[nCount][26], oNaoConc:aArray[nCount][24],oNaoConc:aArray[nCount][25],oNaoConc:aArray[nCount][13])
					
				//Conciliacao por lote
				If cConcilia == 2
						
					//Verifica se ja existe um lote para este Banco, Agencia, Conta e Data do Credito
					If Len(aLotes) > 0 .AND. ;
						(nLote := AScan (aLotes, {|aX| aX[2] + aX[3] + aX[4] + DToS(aX[8]) == oNaoConc:aArray[nCount][26] + oNaoConc:aArray[nCount][24] + oNaoConc:aArray[nCount][25] + DToS(oNaoConc:aArray[nCount][11])})) > 0
							
						//Adiciona ao lote o recno de mais um titulo SE1
						AADD(aLotes[nLote ][9], oNaoConc:aArray[nCount][22])
					Else
						//Busca o numero do lote
						cLote := BuscarLote()
							
						//Cria um lote com o titulo SE1
						AADD(	aLotes, {cLote, oNaoConc:aArray[nCount][26], oNaoConc:aArray[nCount][24], oNaoConc:aArray[nCount][25], aDadoBanco[1], aDadoBanco[2], ;
								aDadoBanco[3], oNaoConc:aArray[nCount][11], {oNaoConc:aArray[nCount][22]}})
					EndIf
						
					lRet := .T.
				Else
					//Array com os dados do titulo para baixa individual
					aTitInd	:=	{	{"E1_PREFIXO"		,oNaoConc:aArray[nCount][5]	 	 						,NiL},;
										{"E1_NUM"			,oNaoConc:aArray[nCount][6]			 					,NiL},;
										{"E1_PARCELA"		,oNaoConc:aArray[nCount][8]	     						,NiL},;
										{"E1_TIPO"			,oNaoConc:aArray[nCount][7]       	 					,NiL},;
										{"E1_CLIENTE"		,oNaoConc:aArray[nCount][4]     						,NiL},;
										{"E1_LOJA"			,oNaoConc:aArray[nCount][27]       	 				,NiL},;
										{"AUTMOTBX"		,"NOR"					     			 					,Nil},;
										{"AUTBANCO"		,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   			,Nil},;
										{"AUTAGENCIA"		,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))			,Nil},;
										{"AUTCONTA"		,If(lPontoF,(PadR(aDadoBanco[3],Len(SE8->E8_CONTA))),(PadR(StrTran(aDadoBanco[3],"-",""),Len(SE8->E8_CONTA)))),Nil},;
										{"AUTDTBAIXA"		,oNaoConc:aArray[nCount][11]	     	 				,Nil},;
										{"AUTDTCREDITO"	,oNaoConc:aArray[nCount][11]			 				,Nil},;
										{"AUTHIST"			,STR0110			           			 				,Nil},; //"Conciliador SITEF"
										{"AUTDESCONT"		,0					    	 			 					,Nil},; //Valores de desconto
										{"AUTACRESC"		,0					 	    			 					,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
										{"AUTDECRESC"		,0					 		 			 					,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
										{"AUTMULTA"		,0					 		 			 					,Nil},; //Valores de multa
										{"AUTJUROS"		,0					 				 	 					,Nil},; //Valores de Juros
										{"AUTVALREC"		,oNaoConc:aArray[nCount][13]   	 						,Nil}}  //Valor recebido
												
					//Efetua baixa individual
					A910EfetuaBX (aTitInd, oDlg, , @lRet)
				EndIf

				//TRECHO NOVO EXPERIMENTAL
				cFilAnt := cFilOri
				
				If lRet
					//Atualiza Folder Conciliados Manualmente Dinamicamente
					A910AtuMan(@aConcMan, @oConcMan, aTitulos, aNaoConc, nPos, nCount, oRedSelec, @oNaoConc, @oTitulos)
						
					//Atualizo folder de totais dinamicamente
					aTotais[01][TOT_CNAO] := aTotais[01][TOT_CNAO] - aNaoConc[nCount][13]
					aTotais[01][TOT_CMAN] := aTotais[01][TOT_CMAN] + aNaoConc[nCount][13]
						
					If Len(aConcMan) > 0
							
						//Atualizacao do Objeto na Aba Nao Conciliados	
						If Empty(aConcMan[1][2])
							aDel(aConcMan,1)
							aSize(aConcMan,Len(aConcMan)-1)
							oConcMan:SetArray(aConcMan)
							oConcMan:bLine := {||aEval(aConcMan[oConcMan:nAt],{|z,w| aConcMan[oConcMan:nAt,w]})}
							oConcMan:Refresh()
						EndIf
							
						aTotais[01][TOT_QTDCMAN] := Len(aConcMan)
					EndIf
	
					aTotais[01][TOT_GERAL] := aTotais[01][TOT_CONC]+aTotais[01][TOT_CPAR]+aTotais[01][TOT_CNAO]+aTotais[01][TOT_CMAN]
					aTotais[01][TOT_GERAL] := Round(aTotais[01][TOT_GERAL],2)
					//Inserir AtuTot
					aNaoConc[nCount][1]:cName := "BR_VERMELHO"
				Else
					aNaoConc[nCount][1]:cName := "BR_AMARELO"
				EndIf
					
			EndIf
		Else
			MsgInfo(STR0051)			//"Nao ha' nenhum registro marcado"
		EndIf
	EndIf
		
	IncProc()
Next
	
oNaoConc:Refresh()
	
	//Efetua a baixa por lote
If cConcilia == 2
	lRet := .F.
	Processa({|| A910EfetuaBX (aLotes, oDlg, aNaoConc, @lRet)},STR0106,STR0107) //"Aguarde..."#"Efetuando Baixa de Tํtulos Lote..."

	If !lRet
		Aeval(aNaoConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERMELHO", "BR_AMARELO", x[1]:cName)})
		oNaoConc:Refresh()
	EndIf
EndIf

Processa({|| AtuTabZX3 (aNaoConc)},STR0106,STR0108) //"Aguarde..."#"Atualizando Tabela ZX3..."

If lRet
	MsgInfo(STR0109) //"Baixa efetuada com sucesso!!!"
EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA910EfConc บAutor  ณTotvs               บData  ณ  08/06/09  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que ้ executada a partir do botao de efetivar conci- บฑฑ
ฑฑบ          ณliacao dos Folders Conciliadas e Conc. Parcialmente,        บฑฑ
ฑฑบ          ณtendo como funcionalidade baixar os titulos do              บฑฑ
ฑฑบ          ณContas a Receber e alterar o status do mesmo na tabela ZX3  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaConc     - Array com os dados a serem baixados             บฑฑ
ฑฑบ          ณoConc     - Objeto do array aConc                           บฑฑ
ฑฑบ          ณoDlg      - Objeto da tela Dialog                           บฑฑ
ฑฑบ          ณoRedSelec - Objeto para mostrar o titulo como baixado       บฑฑ
ฑฑบ          ณoAmaSelec - Objeto para mostrar o titulo com divergencia    บฑฑ
ฑฑบ          ณaTotais   - Array com os totais                             บฑฑ
ฑฑบ          ณoTotais   - Objeto do array aTotais                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910EfConc(aConc,oConc,oDlg,oRedSelec,oAmaSelec,aTotais,oTotais)

Local nPos			:= 0								//Variavel que verifica se item consta no array
Local nCount		:= 0								//Contador utilizado para varrer o array da ZX3
Local aLotes		:= {}								//Array com os lotes para baixa
Local lRet			:= .F.								//Retorno de Execu็ใo da fun็ใo de baixa individual
Local lMenorSitef	:= .F.								//Variavel para controlar a exibi็ใo de mensagem de valor menor sitef
Local lExist		:= .F.
Local aDadoBanco	:= {}								//Array com os dados de banco, agencia e conta
Local nLote		:= 0								//Posicao do lote no array
Local aTitInd		:= {}								//Dados do titulo individual

If Len(aConc) <= 1 .and. Empty(aConc[1][6])
	MsgInfo(STR0147)
Return Nil
EndIf
	
ProcRegua(Len(aConc))
	
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	
For nCount := 1 To Len(aConc)
    If cFilAnt<>aConc[nCount][28]
		cFilOld := cFilAnt
		cFilAnt := aConc[nCount][28]
	Endif		
		//Verifica se o item esta selecionado
	If AllTrim(oConc:aArray[nCount][1]:cName) == "BR_VERDE"

		//Verifica se existe o registro no SE1
		If !SE1->(DbSeek(xFilial("SE1")+aConc[nCount][5]+aConc[nCount][6]+aConc[nCount][8]+aConc[nCount][7]))
			MsgInfo(STR0050)		//"Arquivo nao encontrado no Financeiro"
		Else
			lExist := .T.
			//Tratamento Valor Sitef deve ser maior ou igual ao Valor no Financeiro
			If !(aConc[nCount][13] >= SE1->E1_SALDO - (SE1->E1_SALDO * (nMargem/100)))
				lMenorSitef := .T.
				aConc[nCount][01] := oAmaSelec
				Loop
			Else
				//Lote - prepara os dados para baixa dos titulos em lote
				//Baixa Individual - prepara e ja executa a baixa do titulo.
				lRet := .F.

				//Busca banco / agencia / conta. Efetua atualiza็ใo do SE1
				aDadoBanco := BuscarBanco(oConc:aArray[nCount][26], oConc:aArray[nCount][24],oConc:aArray[nCount][25],oConc:aArray[nCount][13],oConc:aArray[nCount][29])
					
				//Conciliacao por lote
				If cConcilia == 2
						
					//Verifica se ja existe um lote para este Banco, Agencia, Conta e Data do Credito
					If Len(aLotes) > 0 .AND. (nLote := AScan (aLotes, {|aX| aX[2] + aX[3] + aX[4] + DToS(aX[8]) == oConc:aArray[nCount][26] + oConc:aArray[nCount][24] + oConc:aArray[nCount][25] + DToS(oConc:aArray[nCount][11])})) > 0
						//Adiciona ao lote o recno de mais um titulo SE1
						AADD(aLotes[nLote ][9], oConc:aArray[nCount][22])
					Else
						//Busca o numero do lote
						cLote := BuscarLote()

						//Cria um lote com o titulo SE1
						AADD(aLotes, {cLote, oConc:aArray[nCount][26], oConc:aArray[nCount][24], oConc:aArray[nCount][25], aDadoBanco[1], aDadoBanco[2], ;
										aDadoBanco[3], oConc:aArray[nCount][11], {oConc:aArray[nCount][22]}})
					EndIf
						
					lRet := .T.
				Else
					aTitInd	:=	{	{"E1_PREFIXO"		,oConc:aArray[nCount][5]	 	 					,NiL},;
										{"E1_NUM"			,oConc:aArray[nCount][6]			 				,NiL},;
										{"E1_PARCELA"		,oConc:aArray[nCount][8]	     					,NiL},;
										{"E1_TIPO"			,oConc:aArray[nCount][7]       	 				,NiL},;
										{"AUTMOTBX"		,"NOR"					     			 			,Nil},;
										{"AUTBANCO"		,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   	,Nil},;
										{"AUTAGENCIA"		,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))	,Nil},;
										{"AUTCONTA"		,If(lPontoF,(PadR(aDadoBanco[3],Len(SE8->E8_CONTA))),(PadR(StrTran(aDadoBanco[3],"-",""),Len(SE8->E8_CONTA)))),Nil},;
										{"AUTDTBAIXA"		,oConc:aArray[nCount][11]	     	 			,Nil},;
										{"AUTDTCREDITO"	,oConc:aArray[nCount][11]			 			,Nil},;
										{"AUTHIST"			,STR0110			           			 		,Nil},; //"Conciliador SITEF"
										{"AUTDESCONT"		,0					    	 			 			,Nil},; //Valores de desconto
										{"AUTACRESC"		,0					 	    			 			,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
										{"AUTDECRESC"		,oConc:aArray[nCount][29]					 		 			 			,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
										{"AUTMULTA"		,0					 		 			 			,Nil},; //Valores de multa
										{"AUTJUROS"		,0					 				 	 			,Nil},; //Valores de Juros
										{"AUTVALREC"		,oConc:aArray[nCount][13]   	 				,Nil}}  //Valor recebido
								
						//Efetua baixa individual
					A910EfetuaBX (aTitInd, oDlg, , @lRet)
					
					If !lRet //Erro na Baixa do Tํtulo
						aConc[nCount][1] := LoadBitmap(GetResources(), "BR_AMARELO") //"BR_AMARELO"
						Loop
					Else
						aConc[nCount][1] := LoadBitmap(GetResources(), "BR_VERMELHO") //"BR_VERMELHO"
					EndIf
				EndIf
									
				//Atualiza Folder Totais Dinamicamente
				aTotais[01][TOT_CONC]	:= aTotais[01][TOT_CONC] - aConc[nCount][13]
				aTotais[01][TOT_GERAL]	:= aTotais[01][TOT_CONC] + aTotais[01][TOT_CPAR]+aTotais[01][TOT_CNAO]+aTotais[01][TOT_CMAN]
				aTotais[01][TOT_GERAL]	:= Round(aTotais[01][TOT_GERAL],2)
			EndIf
		EndIf
	EndIf
		
	IncProc()
Next

//Verifica se algum item foi selecionado
If !lExist
	MsgInfo(STR0051)		//"Nao ha' nenhum registro marcado"
	Return Nil
EndIf
	
If lMenorSitef
	Conout(STR0052)		//"Valor Sitef menor que o Valor Protheus, necessแrio corrigir no Financeiro"
EndIf

oConc:Refresh()
	
//Atualizacao do Objeto na Aba Totais
oTotais:SetArray(aTotais)
oTotais:bLine := {||aEval(aTotais[oTotais:nAt],{|z,w| aTotais[oTotais:nAt,w]})}
oTotais:Refresh()

//Efetua a baixa por lote
If cConcilia == 2
    ProcLogAtu(STR0138,STR0148)
    Processa({|| A910EfetuaBX(aLotes, oDlg, aConc, @lRet)},STR0106,STR0107) //"Aguarde..."#"Efetuando Baixa de Tํtulos Lote..."

    If !lRet
        ProcLogAtu(STR0149,STR0150)
        Aeval(aConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERDE", "BR_AMARELO", x[1]:cName)})
    Else
        Aeval(aConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERDE", "BR_VERMELHO", x[1]:cName)})
    EndIf

    ProcLogAtu(STR0138,STR0151)
    oConc:Refresh()
EndIf

Processa({|| AtuTabZX3 (aConc)},STR0106,STR0108) //"Aguarde..."#"Atualizando Tabela ZX3..."
	
If lRet
	MsgInfo(STR0109) //"Baixa efetuada com sucesso!!!"
EndIf
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณBuscarBanco  บAutor  ณTotvs			       บ Self:ณ  28/04/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca os dados de banco, agencia e conta (Ponto de entrada),   บฑฑ
ฑฑบDesc.     ณse nao existir, matem os parametros que foram passados para    บฑฑ
ฑฑบDesc.     ณfun็ใo.                                                        บฑฑ
ฑฑบDesc.     ณAtualiza informacoes do SE1                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFin				                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cBancoZX3)  	- Banco da ZX3.					       บฑฑ
ฑฑบ          ณExpC2 (2 - cAgZX3) 	  	- Ag da ZX3.   			              บฑฑ
ฑฑบ          ณExpC3 (3 - cContaZX3)  	- Conta da ZX3.			              บฑฑ
ฑฑบ          ณExpN1 (4 - nVlLiqZX3)     - Valor liquido da ZX3.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscarBanco(cBancoZX3,cAgZX3,cContaZX3,nVlLiqZX3,nTaxa)

Local aDados		:= {}							//Dados do retorno banco/agencia/conta
Local aArea		:= GetArea()                //Salva area local
Local aAliasSE1	:= SE1->(GetArea()) 			//Salva area SE1
Local aAliasZX3	:= ZX3->(GetArea()) 			//Salva area ZX3
Local nACRESC		:= 0
Local nDECRESC	:= 0
Default nTaxa := 0
If !lPontoF
	aDados := {cBancoZX3, cAgZX3, cContaZX3}
Else
	aDados := ExecBlock('FINA910F', .F., .F., {cBancoZX3, cAgZX3, cContaZX3})
	
	If !(ValType(aDados) == 'A' .AND. Len(aDados) == 3)
		aDados := {cBancoZX3, cAgZX3, cContaZX3}
	EndIf
EndIf


If nVlLiqZX3 > SE1->E1_SALDO
	nACRESC 	:= nVlLiqZX3 - SE1->E1_SALDO
EndIf

If nVlLiqZX3 < SE1->E1_SALDO
	nDECRESC := (nVlLiqZX3 - SE1->E1_SALDO) * (-1)
EndIf

RecLock("SE1",.F.)
		
SE1->E1_PORTADO	:= aDados[1]
SE1->E1_AGEDEP	:= aDados[2]
SE1->E1_CONTA		:= aDados[3]

//** Leandro Brito - O decrescimo virแ no arquivo
/*	
If nAcresc <> 0
	SE1->E1_ACRESC	:= nAcresc
	SE1->E1_SDACRES	:= nAcresc
EndIf
*/	
If nTaxa > 0
	SE1->E1_DECRESC	:= nTaxa
	SE1->E1_SDDECRE	:= nTaxa
EndIf
	
SE1->(MsUnlock())

//Restaura areas
RestArea(aAliasSE1)
RestArea(aAliasZX3)
RestArea(aArea)

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณBuscarLote   บAutor  ณTotvs               บ Self:ณ  28/04/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca o numero do proximo lote para baixa dos titulos          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFin				                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscarLote()

Local aArea		:= GetArea()				//Salva area local
Local aOrdSE5 	:= SE5->(GetArea())		//Salva area SE5
Local cLoteFin	:= ''						//Numero do lote
	
cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
	
DbSelectArea("SE5")
DbSetOrder(5)
	
While SE5->(MsSeek(xFilial("SE5")+cLoteFin))
	If (__lSx8)
		ConfirmSX8()
	EndIf
		
	cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
EndDo
	
ConfirmSX8()
	
	//Restaura areas
RestArea(aArea)
RestArea(aOrdSE5)
	
Return cLoteFin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAtuTabZX3    บAutor  ณTotvs               บ Self:ณ  28/04/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os dados da ZX3 apos a baixa dos titulos              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFin                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaRegConc - Array completo com o dados da ZX3                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function AtuTabZX3(aRegConc,cIsThread)

Local nCount		:= 0							//Utilizada para ler todos os registros baixados
Local aArea		:= GetArea()                    //Salva area local
Local aAliasZX3	:= ZX3->(GetArea()) 			//Salva area ZX3

DEFAULT cIsThread := ""
	
ProcRegua(Len(aRegConc))
IncProc(STR0108) //"Atualizando tabela ZX3..."
	
DbSelectArea("ZX3")
DbSetOrder(5)
	
//ZX3_FILIAL + ZX3_DTTEF + ZX3_WLDPA + ZX3_PARCEL
For nCount := 1 To Len( aRegConc )

	//Os registros que estiverem marcados como vermelho, sใo aqueles que foram conciliados e baixados
	If (cIsThread == "THREAD") .or. ( AllTrim(aRegConc[nCount][1]:cName) == "BR_VERMELHO" )

		If ZX3->(DbSeek(xFilial("ZX3") + DTOS(aRegConc[nCount][10]) + aRegConc[nCount][14] + aRegConc[nCount][15]))

			IncProc()
			While !ZX3->(Eof()) .AND. (ZX3->ZX3_FILIAL + DTOS(ZX3->ZX3_DTTEF) + ZX3->ZX3_WLDPA + ZX3->ZX3_PARCEL == xFilial("ZX3") + DTOS(aRegConc[nCount][10]) + aRegConc[nCount][14] + aRegConc[nCount][15])
				If AllTrim(Upper(ZX3->ZX3_CODLOJ)) == AllTrim(Upper(aRegConc[nCount][3])) .AND. ZX3->(Recno()) == aRegConc[nCount][23]
					Exit
				EndIf
				ZX3->(DbSkip())
			EndDo
			
			RecLock("ZX3",.F.)
			
			ZX3->ZX3_STATUS := "2"				    	//Conciliado
			ZX3->ZX3_PREFIX := aRegConc[nCount][5]   	//Rastro Prefixo SE1
			ZX3->ZX3_NUM    := aRegConc[nCount][6]   	//Rastro Num SE1
			ZX3->ZX3_PARC   := aRegConc[nCount][8]   	//Rastro Parcela SE1
			ZX3->ZX3_TIPO   := aRegConc[nCount][7]   	//Rastro Tipo SE1
			
			ZX3->(MsUnlock())
		EndIf
	EndIf
	
	If Empty(cIsThread)
		IncProc()
	EndIf
		
Next nCount

//Restaura areas
RestArea(aAliasZX3)
RestArea(aArea)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910SelRegบAutor  ณRafael Rosa da Silvaบ Data ณ  08/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao usada para atualizar a selecao do registro que esta  บฑฑ
ฑฑบ          ณposicionado ou de todos do array ou ordenar os registros    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaDados -Array com os dados a serem ordenados ou selecionadosบฑฑ
ฑฑบ          ณoObj   -Objeto do Array                                     บฑฑ
ฑฑบ          ณoSelec -Objeto da Selecao                                   บฑฑ
ฑฑบ          ณoNSelec-Objeto da Nao Selecao                               บฑฑ
ฑฑบ          ณnColPos-coluna que recebeu o clique                         บฑฑ
ฑฑบ          ณnPos   -Posicao do registro que recebeu o clique            บฑฑ
ฑฑบ          ณlCheck -mostra se deve ser feito o check ou ordena          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910SelReg(aDados, oObj, oSelec, oNSelec, nColPos, nPos, lCheck, aNaoConc, nPosNConc, oNaoConc, oBlcSelec)
Local nI				:= 0			//Variavel contadora
	
Default nPos			:= 0
Default nColPos		:= 1
Default lCheck		:= .T.
	
oSelec		:= LoadBitmap(GetResources(), "BR_VERDE")  //Objeto de tela para mostrar como marcado um registro
oNSelec	:= LoadBitmap(GetResources(), "BR_BRANCO") //Objeto de tela para mostrar como desmarcado um registro
oBlcSelec	:= LoadBitmap(GetResources(), "BR_PRETO")	 //Objeto de tela para mostrar como desmarcado um registro

//Itens baixados
If nPos <> 0 .And. ValType(nPosNConc) <> "U"
	If Alltrim(oObj:aArray[nPos][5]) <> Alltrim(aNaoConc[nPosNConc][14]) .And. MV_PAR14 == 1
		MsgStop(STR0116)			//"NSU e Nบ Comprovante selecionados estใo divergentes"
		Return()
	ElseIf aNaoConc[nPosNConc][1]:cName == "BR_PRETO"
		MsgStop(STR0132)
		Return()
	Endif

	If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_VERMELHO"
		Return()
	Else
		If !Empty(aNaoConc)
			If (Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO" .AND. (aNaoConc[nPosNConc][1]:cname == "BR_VERDE" .OR. ;
					aNaoConc[nPosNConc][1]:cname == "BR_VERMELHO"))
				Return()
			EndIf
		EndIf
	EndIf
EndIf
	
If nColPos == 1 .AND. lCheck //Atualiza selecao do registro posicionado
	If nPos > 0
		If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO"
			If Empty(aNaoConc)
				If aDados[nPos][20] = STR0104 //"OK"
					oObj:aArray[nPos][1] := oSelec
				Else
					MsgStop(STR0101)			//"Este registro nใo pode ser selecionado, pois nใo existe a conta cadastrada."
					Return()
				EndIf
			Else
				If aNaoConc[nPosNConc][20] = STR0104 //"OK"
					oObj:aArray[nPos][1]:cName := "BR_VERDE"
				Else
					MsgStop(STR0101) 			//"Este registro nใo pode ser selecionado, pois nใo existe a conta cadastrada."
					Return()
				EndIf
			EndIf
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_PRETO"
			MsgStop(STR0133)			//"Este registro nใo pode ser selecionado, pois nใo existe a conta cadastrada."
			Return()
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_VERMELHO"
			MsgStop(STR0134)
			Return()
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_AMARELO"
			MsgStop(STR0052)
			Return()
		Else
			If Empty(aNaoConc)
				//aDados[nPos][1] := oNSelec
				oObj:aArray[nPos][1] := oNSelec
			Else
				//Desmarca selecao dos nao conciliados
				//Verifica se o registro selecionado da ZX3 eh o mesmo do momento da selecao.
				If oNaoConc:aArray[nPosNConc][22] <> oObj:aArray[nPos][15] .and. (MV_PAR14 == 1) .OR. oNaoConc:aArray[nPosNConc][1]:cName <> "BR_VERDE" .and. (MV_PAR14 == 1)
					MsgStop(STR0113)  //"Nใo ้ possํvel desfazer a sele็ใo, porque o registro selecionado da ZX3 nใo corresponde ao da SE1."
					Return()
				Else
					oObj:aArray[nPos][1] := oNSelec
				EndIf
					
			EndIf
		EndIf
	Else
		If Len(aDados) == 1
			MsgStop(STR0102)					//"Nใo existe registro para selecionar"
			Return()
		EndIf
		For nI := 1 to Len(aDados)
			If Alltrim(oObj:aArray[nI][1]:cName) <> "BR_VERMELHO"
				If Alltrim(oObj:aArray[nI][1]:cName) == "BR_BRANCO"
					//aDados[nI][1] := oSelec
					oObj:aArray[nI][1] := oSelec
				ElseIf Alltrim(oObj:aArray[nI][1]:cName) == "BR_PRETO"
					oObj:aArray[nI][1] := oBlcSelec
				Else
					//aDados[nI][1] := oNSelec
					oObj:aArray[nI][1] := oNSelec
				EndIf
			EndIf
		Next nI
	EndIf
Else //Ordena registros
	aDados := aSort(aDados,,,{|x,y| x[nColPos] <= y[nColPos] })
EndIf
	
	//Atualiza Objeto oNaoConc
If (ValType(aNaoConc) <> "U" .AND. Len(aNaoConc) > 0)
	If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO"
		oNaoConc:aArray[nPosNConc][1] := oNSelec
		
		//Limpa os dados quando registro for desmarcado
		oNaoConc:aArray[nPosNConc][22] 	:= 0 							//recno SE1
		oNaoConc:aArray[nPosNConc][5] 	:= ""							//prefixo SE1
		oNaoConc:aArray[nPosNConc][7] 	:= ""							//tipo SE1
		oNaoConc:aArray[nPosNConc][8] 	:= ""							//parcela SE1
		oNaoConc:aArray[nPosNConc][6] 	:= ""							//num SE1
		oNaoConc:aArray[nPosNConc][27] 	:= ""							//loja SE1
	ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_PRETO"
		oNaoConc:aArray[nPosNConc][1] := oBlcSelec
	Else
		oNaoConc:aArray[nPosNConc][1]:cName := "BR_VERDE"
		//Atribui os valores do se1 no array da ZX3
		oNaoConc:aArray[nPosNConc][22] 	:= oObj:aArray[nPos][15]		//recno se1
		oNaoConc:aArray[nPosNConc][5] 	:= oObj:aArray[nPos][7]		//prefixo se1
		oNaoConc:aArray[nPosNConc][7] 	:= oObj:aArray[nPos][10]		//tipo se1
		oNaoConc:aArray[nPosNConc][8] 	:= oObj:aArray[nPos][9]		//parcela se1
		oNaoConc:aArray[nPosNConc][6] 	:= oObj:aArray[nPos][8]		//num se1
		oNaoConc:aArray[nPosNConc][27] 	:= oObj:aArray[nPos][12]		//loja se1
	EndIf

	oNaoConc:Refresh()
EndIf
	
oObj:Refresh()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798) .OR. (nHRes == 800)		// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf
	
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .OR. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf

Return Int(nTam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910AtuDivบAutor  ณAlessandro Santos   บ Data ณ  17/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza as divergencias em Conciliados Parcialmente para  บฑฑ
ฑฑบ          ณ exibir no Rodape.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Tellerina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910AtuDiv(aConcPar, aIndic, oConcPar, oIndic)

Local nPos		:= oConcPar	//Posicao Titulo Conciliado Parcialmente
Local aAux		:= {}			//Array auxiliar
Local nI		:= 0			//Variavel para contador
	
	//Verifica se arrays nao estao vazios
If aConcPar[1][14] <> ""
		
	//Compara item do Rodape com itens Sitef Conciliados Parcialmente para encontrar referencia
	For nI := 1 To Len(aIndic)
		If (aIndic[nI][9] == aConcPar[nPos][5] .AND. aIndic[nI][10] == aConcPar[nPos][6];
			.AND. aIndic[nI][11] == aConcPar[nPos][7] .AND. aIndic[nI][7] == aConcPar[nPos][8];
			.AND. aIndic[nI][8] == aConcPar[nPos][15])
			
			aAdd(aAux,aIndic[nI])
		EndIf
	Next nI
		
		//Atualiza Objeto oIndic
	If Len(aAux) > 0
		oIndic:SetArray(aAux)
		oIndic:bLine := {||aEval(aAux[oIndic:nAt],{|z,w| aAux[oIndic:nAt,w]})}
		oIndic:Refresh()
	EndIf
		
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910AtuManบAutor  ณAlessandro Santos   บ Data ณ  11/12/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualizacao Dinamica da Aba Conciliados Manualmente apos a  บฑฑ
ฑฑบ          ณConciliacao de item Nao Conciliado.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Tellerina                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910AtuMan(aConcMan, oConcMan, aTitulos, aDados, nPos, nPosCol, oRedSelec, oObj, oTitulos)

Local aArea		:= GetArea()				//Salva area atual
Local aAliasSE1	:= SE1->(GetArea())		//Salva area SE1
Local aAliasZX3	:= ZX3->(GetArea())		//Salva area ZX3
Local aColsAux	:= {}						//Array auxiliar na montagem do Array Conciliados manualmente
	
//Posiciona Titulo baixado no SE1
dbSelectArea("SE1")
SE1->(dbSetOrder(1))
SE1->(dbSeek(xFilial("SE1")+aTitulos[nPos][7]+aTitulos[nPos][8]+aTitulos[nPos][9]+aTitulos[nPos][10]))
	
//Posiciona arquivo SITEF Conciliado
dbSelectArea("ZX3")
ZX3->(dbSetOrder(5))
ZX3->(dbSeek(xFilial("ZX3")+DtoS(aDados[nPosCol][10])+aDados[nPosCol][14]+aDados[nPosCol][15]))
	
//Atualizacao do Array Conciliados Manualmente
aAdd(aColsAux,"")							//Status
aAdd(aColsAux, aDados[nPosCol][2])			//Codigo do Estabelecimento Sitef
aAdd(aColsAux, aDados[nPosCol][3])			//Codigo da Loja Sitef
aAdd(aColsAux, aDados[nPosCol][4])			//Codigo do Cliente (Administradora)
aAdd(aColsAux, aTitulos[nPos][7])			//Prefixo do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][8])			//Numero do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][10])			//Tipo do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][9])			//Numero da parcela Protheus
aAdd(aColsAux, aDados[nPosCol][9])			//Numero do Comprovante Sitef
aAdd(aColsAux, aDados[nPosCol][10])		//Data da Venda Sitef
aAdd(aColsAux, aDados[nPosCol][11])		//Data de Credito Sitef
aAdd(aColsAux, aDados[nPosCol][12])		//Valor do titulo Protheus
aAdd(aColsAux, aDados[nPosCol][13])		//Valor liquido Sitef
aAdd(aColsAux, aDados[nPosCol][14])		//Numero NSU Sitef
aAdd(aColsAux, aDados[nPosCol][15])		//Numero da parcela Sitef
aAdd(aColsAux, aDados[nPosCol][16])		//Documento TEF Protheus
aAdd(aColsAux, aDados[nPosCol][17])		//NSU Sitef Protheus
aAdd(aColsAux, aDados[nPosCol][18])		//Vencimento real do titulo
	
aAdd(aConcMan,aColsAux)
	
//Atualizacao do Objeto na Aba Conciliados Manualmente
oConcMan:SetArray(aConcMan)
oConcMan:bLine := {||aEval(aConcMan[oConcMan:nAt],{|z,w| aConcMan[oConcMan:nAt,w]})}
oConcMan:Refresh()
	
//Atualizacao do Objeto na Aba Nao Conciliados (Rodape)
aDel(aTitulos,nPos)
aSize(aTitulos,Len(aTitulos)-1)
oTitulos:SetArray(aTitulos)
oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
oTitulos:Refresh()
	
//Restaura Areas
RestArea(aAliasSE1)
RestArea(aAliasZX3)
RestArea(aArea)
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910BrowseบAutor  ณ  Totvs             บ Data ณ  06/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela com o browse dos lotes para selecionar quais lotes     บฑฑ
ฑฑบ          ณserao selecionados para o processo manual                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910Browse( aBrowse )
Local nX := 0		//Variavel Contadora
Local aX := {}	//Array de Retorno
	
Default aBrowse := {}
	
For nX := 1 To Len( aBrowse )
	aAdd( aX, aBrowse[nX] )
Next

Return aX

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCreateTMP บAutor  ณ  Totvs             บ Data ณ  07/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria tabela temporaria para armazenar registro conciliados, บฑฑ
ฑฑบ          ณnใo conciliadas evitando ascan em array                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreateTMP(aCampos,cArq,cAliasSitef,cArqINDEX,cChave)
Local aSaveArea	:= GetArea()

If Select(cAliasSitef) > 0
	A910CLOSEAREA(cAliasSitef, cArq)
EndIf

cArq := CriaTrab(aCampos,.t.)
dbUseArea(.t.,,cArq,cAliasSitef,.f.,.f.)

If !Empty(cChave)
	INDREGUA(cAliasSitef,cArqINDEX,cChave)
	DbSetIndex(cArqINDEX+OrdBagExt())
EndIf

RestArea( aSaveArea )

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910CLOSEAREAบAutor  ณMicrosiga         บ Data ณ  07/08/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFechamento da tabela temporaria                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910CLOSEAREA(cAliasSitef, cArqTMP)

If Select(cAliasSitef) > 0 
	(cAliasSitef)->(DbCloseArea())
Endif

If Select(cAliasSitef) = 0
	FErase(cArqTMP+GetDBExtension())
EndIf

Return nil


//NEW-RFC
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910VLDBCO บAutor  ณ Pedro Pereira Lima บ Data ณ  07/08/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFechamento da tabela temporaria                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910VLDBCO(cBanco,cAgencia,cConta,cTipo)                                                   
Local lRet 	:= .T.
Local nPos	:= 0

If __cFilSA6 == Nil
	__cFilSA6	:= xFilial( 'SA6' )
Endif

nPos := Ascan( __aBancos, {|x|	    alltrim(x[1]) == alltrim(__cFilSA6) .And. ;
									alltrim(x[2]) == alltrim(cBanco)    .And. ;
									alltrim(x[3]) == alltrim(cAgencia)  .And. ;
									alltrim(x[5]) == alltrim(cConta)          } )
lRet := ( nPos > 0 ) 

If lRet
	If cTipo == "1"
		if Empty( __aBancos[nPos,2] ) .and. Empty( __aBancos[nPos,5] ) .and. Empty( __aBancos[nPos,5] )
			lRet := .F.
		EndIF
	Else
		If __aBancos[nPos,7] == '1'
			lRet := .F.
		ElseIf !Empty( __aBancos[nPos,8] ) .And. __aBancos[nPos,8] == '1'
			lRet := .F.
		Endif
	Endif 
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGenRandThreadบAutorณ Pedro Pereira Lima บ Data ณ  30/10/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControle de numera็ใo das threads                            บฑฑ
ฑฑบ          ณ                                                             บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA910A                                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GenRandThread()
Local nThreadId := nRandThread

While nRandThread == nThreadId .Or. nRandThread == 0
	nRandThread := Randomize(10000,29999)
EndDo

nThreadId := nRandThread

Return nThreadId

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910aIniVarบAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia as variaveis staticas utilizadas no fonte            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910aIniVar()
 
If __nThreads == Nil 
	__nThreads	:= SuperGetMv( "MV_BLATHD" , .T. , 1 )	// Limite de 20 Threads permitidas
EndIf

If __nLoteThr == Nil
	__nLoteThr	:= SuperGetMv( "MV_BLALOT" , .T. , 50 )	// Quantidade de registros por lote
Endif

__nThreads := If( (__nThreads > 20) , 20 , __nThreads )

If __lProcDocTEF == Nil
    __lProcDocTEF  := SuperGetMv( "MV_BLADOC" , .T. , .F. ) // Verifica se irแ processar pelo DOCTEF ou pelo NSUTEF. Padrใo ้ pelo NSUTEF
Endif

If nTamBanco == Nil
	nTamBanco		:= TAMSX3("A6_COD")[1]
Endif

If nTamAgencia == Nil 
	nTamAgencia	:= TamSX3("A6_AGENCIA")[1]
Endif

If nTamCC == Nil
	nTamCC		:= TAMSX3("A6_NUMCON")[1]
Endif

If nTamCheque == Nil
	nTamCheque		:= TAMSX3("EF_NUM")[1]
Endif

If nTamNatureza == Nil
	nTamNatureza	:= TAMSX3("ED_CODIGO")[1]
Endif

If lMEP == Nil 
	lMEP		:= AliasInDic("MEP")
Endif

If nTamParc == Nil
	nTamParc		:= TamSX3("ZX3_PARCEL")[1]
Endif

If nTamParc2 == Nil
	nTamParc2		:= TamSX3("ZX3_PARALF")[1]
Endif

If lTamParc == Nil
	lTamParc	:= TamSX3("E1_PARCELA")[1] == TamSX3("ZX3_PARCEL")[1]
Endif

If lA6MSBLQL == Nil
	lA6MSBLQL := ( SA6->(FieldPos( 'A6_MSBLQL') ) > 0 )
Endif

If lZX3RecSE1 == Nil
    lZX3RecSE1 := ( ZX3->(FieldPos( 'ZX3_RECSE1' ) ) > 0 )
Endif

If nTamWLDPA == Nil 
    nTamWLDPA := TamSX3("ZX3_WLDPA")[1]
Endif

If nTamDOCTEF == Nil .And. __lDocTef 
    nTamDOCTEF := TamSX3("ZX3_DOCTEF")[1]
Endif

ProcLogAtu(STR0138,STR0152)

// Efetua a carga dos bancos
LoadBanco()

ProcLogAtu(STR0138,STR0153)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA910EfetuaBX บAutor  ณTotvs             บData  ณ  29/04/11  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a baixa do titulo por lote ou individual             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaLotes       - Array com os lotes ou array para baixa indiv บฑฑ
ฑฑบ          ณoDlg         - Objeto dialog                                บฑฑ
ฑฑบ          ณaRegConc     - Array com os dados da ZX3 (completo)         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910EfetuaBX(aLotes, oDlg, aRegConc, lRet)
Local aTitulosBx	:= {}

Local nCount 		:= 0							//Contador utilizado para varrer o array da ZX3
Local lOk			:= .F.							//Controla se a baixa por lote foi realizada com sucesso						//Array com os recnos dos titulos a serem baixados por lote
Local oIPC			:= nil							// Objeto controlador de MultThreads
Local nThreads		:= SuperGetMv( "MV_BLATHD" , .T. , 1 )	// Limite de 20 Threads permitidas
Local cChave		:= "A910EFETUABX_THRD"
Local i				:= 0
Local nCont			:= 0
Local aRecnosAux := {}	
Local nLote		:= SuperGetMv( "MV_BLALOT" , .T. , 50 )	// Quantidade de registros por lote
Default lRet := lOk

Private lMsErroAuto

ACESSAPERG("FIN070", .F.)
MV_PAR04 := 2

If cConcilia == 2    //Baixa por lote

	For nCount := 1 To Len(aLotes)
			
			lOk	:= .F.            

			aTitulosBX := aLotes[nCount][9]
            
			IncProc(STR0106+", "+ STR0111 + aLotes[nCount][1] + STR0112 + AllTrim(Str(Len(aTitulosBX))) + ")")    //"Aguarde..."#(Lote: "#" / Qtde Tํtulos: "

			If FBxLotAut("SE1", aTitulosBX, aLotes[nCount][5], aLotes[nCount][6], aLotes[nCount][7],,aLotes[nCount][1],, aLotes[nCount][8])
				lOk	:= .T.
			Else 
			    lOk := .F.
				DisarmTransaction()
				MsgStop (STR0056,STR0057) //"Inconsistencia encontradas no processo de Baixas por Lote. esta interface serแ encerrada para garantir a integridade dos dados na situa็ใo de baixa por lote."###"Opera็ใo Cancelada"
				Exit
				oDlg:End()
			EndIf
		Next			
		If __nThreads > 1
			lRet := A910ThrLote( aLotes, aRegConc, oDlg, lRet )
		Endif
Else  
	//Baixa individual
	lMsErroAuto	:= .F.
	
	aTitulosBX := aLotes
	
   MSExecAuto({|x, y| FINA070(x, y)}, aTitulosBX, 3)
	
	//Verifica se ExecAuto deu erro
	lRet := !lMsErroAuto

	If !lRet
		MostraErro()
		DisarmTransaction()
	EndIf
Endif

If !lRet
   MsgStop(STR0056,STR0057) //"Inconsistencia encontradas no processo de Baixas por Lote. esta interface serแ encerrada para garantir a integridade dos dados na situa็ใo de baixa por lote."###"Opera็ใo Cancelada"
   ProcLogAtu(STR0149,STR0056)
   oDlg:End()
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910ThrLoteบAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o controle das threads da concilia็ใo                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A910ThrLote( aLotes, aRegConc, oDlg, lRet )
Local aTitulosBX	:= {}
Local lOk			:= .T.
Local nIx			:= 0

Private oThredSE1	:= Nil							// Objeto controlador de MultThreads

ProcRegua(Len(aLotes))

For nIx := 1 TO Len( aLotes )

	lOk := A910VldLote( aLotes[nIx] )

	If !lOk
		Exit	
	Endif
Next

If lOk
	// Objeto controlador de Threads
	oThredSE1 := FWIPCWait():New( SubStr("FA110_" + AllTrim(Str(GenRandThread())),1,15) , 10000 )
	
	oThredSE1:SetThreads(__nThreads)
	oThredSE1:SetEnvironment(cEmpAnt,cFilAnt)
	
	oThredSE1:Start( "A910ATHRBX" )
	
	For nIx := 1 TO Len( aLotes )
		
		aTitulosBX := AClone( aLotes[nIx] )
		
       If __lConoutR
          ConoutR( STR0106+", "+ STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len(aTitulosBX[9]))) + ")" )
       Endif 
		
		IncProc(STR0106+", "+ STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len(aTitulosBX[9]))) + ")")    //"Aguarde..."#(Lote: "#" / Qtde Tํtulos: "
       
       ProcLogAtu(STR0138,StrZero( ThreadId(),10) + " " + STR0111 + aTitulosBX[1] + STR0112 + AllTrim(Str(Len(aTitulosBX[9]))) + ")")
	
		lOk := A910APreBx(oThredSE1, aTitulosBX, aRegConc)
		
		If !lOk
		   lRet := .F.
		   Exit
		EndIf
	Next 
	
   IncProc(STR0154)
   oThredSE1:Stop()	//Metodo aguarda o encerramento de todas as threads antes de retornar o controle.
   FreeObj(oThredSE1)
	
	oThredSE1 := Nil
Endif	

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910VldLoteบAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณefetua a valia็ใo do lote de processamento dos lotes        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910VldLote( aLotes )
Local lOk			:= .T.

Local cBanco		:= PADR(aLotes[5],nTamBanco  )
Local cAgencia	:= PADR(aLotes[6],nTamAgencia)
Local cConta		:= PADR(aLotes[7],nTamCC     )

//Verifico informacoes para processo
If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta) 
	Help(" ",1,"BXLTAUT1",,STR0049, 1, 0 )		//"Informa็๕es incorretas nใo permitem a baixa automแtica em lote. Verifique as informa็๕es passadas para a fun็ใo FBXLOTAUT()"
	lOk		:= .F.
ElseIf !CarregaSa6(@cBanco,@cAgencia,@cConta,.T.,,.F.)
	lOk		:= .F.
ElseIf Empty(aLotes[9])
	Help(" ",1,"RECNO")
	lOk		:= .F.
Endif

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910APreBx บAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia a prepara็ใo das baixas dos cart๕es                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A910APreBx(oThread, aTitulosBX, aRegConc)

Local aRecnosAux    := {}

Local cChave        := "FA110BXAUT_THRD"

Local cBanco        := PADR(aTitulosBX[5],nTamBanco  )
Local cAgencia      := PADR(aTitulosBX[6],nTamAgencia)
Local cConta        := PADR(aTitulosBX[7],nTamCC     )
Local cCheque       := ''
Local cLoteFin      := aTitulosBX[1]
Local cNatureza     := Nil
Local aRecnos       := aTitulosBX[9]

Local lOk           := .T.
Local lBaixaVenc    := lUseZX3DtCred //se deve gravar a data de credito na E1_BAIXA

Local nIx           := 0
Local nCont         := 0

Private dBaixa      := aTitulosBX[8]

If !LockByName( cChave, .F. , .F. )
	Help( " " ,1, cChave ,,STR0155,1, 0 )
Else
	// Abertura de Threads
	ProcRegua( Len( aRecnos ) )
					
	For nIx := 1 To Len( aRecnos )
		IncProc()
		nCont++
		aAdd(aRecnosAux, aRecnos[nIx])
	
		If nCont > __nLoteThr
           // Chamada da fun็ใo A910ATHRBX( aTitulos, aRegConc )
           oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc )
           Sleep(1000)
           aRecnosAux	:= {}
           nCont		:= 0
		EndIf
	Next
	
	If Len(aRecnosAux) > 0
		oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc )
       Sleep(1000)
	EndIf

	// Fechamento das Threads   
	UnLockByName( cChave, .F. , .F. )
Endif	

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA910ATHRBX บAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de controle das baixas. Inicializa uma trasa็ใo por  บฑฑ
ฑฑบ          ณpor thread. Caso caia, somente aquela thread ้ afetada.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC Function A910ATHRBX( aTitulos, aRegConc )

Local lOk := .F.

Begin Transaction

lMsErroAuto := .F.

Conout( StrZero(ThreadId(),10) + STR0156 )
Fina110(3, aTitulos)

//Verifica se ExecAuto deu erro
lOk := !lMsErroAuto

If lOk
    // se conseguiu efetuar a baixa, atualizo o registro da ZX3
    lOk := AtualizaZX3( aTitulos, aRegConc )
Endif

If !lOk
   Conout( StrZero(ThreadId(),10) + STR0157 )
   Conout( MostraErro() )
   DisarmTransaction()
Endif

Conout( StrZero(ThreadId(),10) + STR0158 )

End Transaction

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtualizaZX3บAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a baixa dos registros da ZX3. Estแ na mesma transa็ใoบฑฑ
ฑฑบ          ณda baixa por lote.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtualizaZX3( aTitulos, aRegConc )

Local aArea	:= GetArea()

Local lOk		:= .T.

Local nIx 		:= 0
Local nPosZX3	:= 0

Local aTitAux := aTitulos[1]

For nIx := 1 TO Len( aTitAux )

   nPosZX3 := aScan( aRegConc , {|x| x[22] == aTitAux[nIx] } )
	
	// se localizei o registro da ZX3 dentro do aTitulos e o recno da ZX3 nใo estแ em branco
	If nPosZX3 > 0 .And. !Empty( aRegConc[nPosZX3][23] )
      DbSelectArea( 'ZX3' )
      ZX3->( DbGoTo( aRegConc[nPosZX3][23] ) )
			
      If ZX3->( !Eof() ) .And. ZX3->( Recno() ) == aRegConc[nPosZX3][23]
         RecLock("ZX3",.F.)
			
         ZX3->ZX3_STATUS := "2"				    	//Conciliado
         ZX3->ZX3_PREFIX := aRegConc[nPosZX3][5]   	//Rastro Prefixo SE1
         ZX3->ZX3_NUM    := aRegConc[nPosZX3][6]   	//Rastro Num SE1
         ZX3->ZX3_PARC   := aRegConc[nPosZX3][8]   	//Rastro Parcela SE1
         ZX3->ZX3_TIPO   := aRegConc[nPosZX3][7]   	//Rastro Tipo SE1

         If __lZX3RecSE1
             ZX3->ZX3_RECSE1   := aRegConc[nPosZX3][22]    //Rastro Recno SE1
         Endif			

         ZX3->(MsUnlock())
      Else
         lOk := .F.
         
         ProcLogAtu(STR0149,STR0159 + Alltrim( Str( aRegConc[nPosZX3][23] ) ) + STR0160)         
      Endif

   Endif
Next nIx

RestArea( aArea )

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadBanco  บAutor  ณTOTVS              บ Data ณ  21/01/14   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega todos os bancos utiliados na concilia็ใo para a me- บฑฑ
ฑฑบ          ณmoria. Evitando a busca repetida de dados no banco de dados บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบretorno   ณ Nil                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function LoadBanco()

Local aArea		:= GetArea()
Local bCondWhile	:= {|| .T. }

Local cQuery
Local cAliasSA6	:= "SA6"
Local cFilSA6		:= xFilial( 'SA6' )

// garanto que a variavel estแ limpa para o carregamento
__aBancos := {}


	cAliasSA6 := GetNextAlias()
	
	cQuery := "SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, A6_BLOCKED"
	
	If lA6MSBLQL
		cQuery += ", A6_MSBLQL"
	Endif
	
	cQuery += "  FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.A6_FILIAL = '" + cFilSA6 + "'"
	cQuery += "   AND SA6.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )

	// verifica se temporario estแ aberto e tenta fechalo
	If Select( cAliasSA6 ) > 0
		DbSelectArea( cAliasSA6 )
		( cAliasSA6 )->( DbCloseArea() )
	Endif

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasSA6 )

If Select( cAliasSA6 ) > 0
	DbSelectArea( cAliasSA6 )
	(cAliasSA6)->(DbGoTop())

	nCont := 0
	While (cAliasSA6)->(!Eof()) .And. Eval( bCondWhile )
		// adiciono os bancos a serem utilizados na busca, otimiza็ใo do carregamento dos dados
		Aadd( __aBancos,	{	(cAliasSA6)->A6_FILIAL;
							,	(cAliasSA6)->A6_COD;
						 	,	(cAliasSA6)->A6_AGENCIA;
							,	(cAliasSA6)->A6_DVAGE;
							,	(cAliasSA6)->A6_NUMCON;
							,	(cAliasSA6)->A6_DVCTA;
							,	(cAliasSA6)->A6_BLOCKED;
							,	Iif( lA6MSBLQL, (cAliasSA6)->A6_MSBLQL, Nil );
							})
		(cAliasSA6)->( DbSkip() )
	EndDo
Endif

RestArea( aArea )

Return
