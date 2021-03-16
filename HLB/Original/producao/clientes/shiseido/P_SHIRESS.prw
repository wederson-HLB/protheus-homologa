#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P_SHIRESS     º Autor ³                º Data ³ 03/05/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório  		                                          º±±
±±º          ³ OBS: parte comentada é para gerar relatório de sistema     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
Funcao      : P_SHIRESS
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relatorio
Autor     	:                                
Data     	: 03/05/2011                      
Obs         : parte comentada é para gerar relatório de sistema 
TDN         : 
Revisão     : Tiago Luiz Mendonça	
Data/Hora   : 17/07/12
Módulo      : Faturamento. 
Cliente     : Shiseido
*/

*--------------------------*
 User Function P_SHIRESS()
*--------------------------*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""                                                                                                                
Local titulo       := "RELATORIO" //- DATA DE "+mv_par01+" ATE "+mv_par02+" / RESPONSAVEL "+mv_par03+" Ate "+mv_par04+""
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "P_SHIRESS" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "P_SHIRESS" // Coloque aqui o nome do arquivo usado para impressao em disco

//Definição das perguntas.


U_PUTSX1( "RP_SHIRESS", "01", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","U_ValSHIRE(MV_PAR01)" , "","","","MV_PAR01")
U_PUTSX1( "RP_SHIRESS", "02", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","U_ValSHIRE(MV_PAR02)" , "","","","MV_PAR02")
//PutSx1( "RP_SHIRESS", "03", "Gera Excel?:", "Gera Excel?", "Gera Excel?", "", "N",1,00,00,"C","" , "","","","MV_PAR03","Sim","","","","Não") 

Private cString := "SD2" 
Private cPerg := "RP_SHIRESS"

dbSelectArea(cString)
dbSetOrder(1)  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If !Pergunte(cPerg,.T.)
	Return()
EndIf   
/*
If MV_PAR03==2
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
  
If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³       
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Else
RptStatus({|| ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf
*/
RptStatus({|| ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  04/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ³RUNREPORT(Cabec1,Cabec2,Titulo,nLin)
                                                         
Local cQry1:=""

cQry1 :=" SELECT SD2.D2_EMISSAO,SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_COD,SD2.D2_ITEM, SD2.D2_PRUNIT, SD2.D2_QUANT, SD2.D2_LOCAL,SD2.D2_CF, SD2.D2_TES, SD2.D2_CLIENTE, SD2.D2_LOJA, (SD1.D1_ICMSRET/(SD1.D1_QUANT*SD2.D2_QUANT)) AS ICMS_PAGO, "+CRLF
cQry1 +=" SD1.D1_EMISSAO,SD1.D1_DOC, SD1.D1_SERIE,SD1.D1_TIPO , SD1.D1_COD,SB1.B1_POSIPI, SD1.D1_VUNIT, SD1.D1_QUANT,SD1.D1_LOCAL, SD1.D1_TOTAL, SD1.D1_CF, SD1.D1_TES,SD1.D1_IPI, SD1.D1_VALIPI, SB1.B1_PICM, SD1.D1_VALICM, SD1.D1_BRICMS,SD1.D1_ICMSRET "+CRLF
cQry1 +=" FROM "+RETSQLNAME("SD1")+" SD1, "+RETSQLNAME("SD2")+" SD2, "+RETSQLNAME("SB1")+" SB1 "+CRLF
cQry1 +=" WHERE SD1.D_E_L_E_T_<> '*' "+CRLF
cQry1 +=" and SD2.D_E_L_E_T_ <> '*' "+CRLF
cQry1 +=" AND SB1.D_E_L_E_T_ <> '*' "+CRLF
cQry1 +=" AND SD1.D1_DOC = SD2.D2_P_DOCST "+CRLF
cQry1 +=" AND SD1.D1_SERIE = SD2.D2_P_SERST "+CRLF
cQry1 +=" AND SD1.D1_COD = SD2.D2_COD "+CRLF
cQry1 +=" AND SD1.D1_COD = SB1.B1_COD "+CRLF
cQry1 +=" AND SD1.D1_FILIAL = SD2.D2_FILIAL"+CRLF //RRP - 09/09/213 - Inclusão da filial para validação
cQry1 +=" AND SD2.D2_TIPO NOT IN ('C','I','P') "+CRLF //RRP - 06/11/2012 - Retirado Notas de Complemento
cQry1 +=" AND SD1.D1_TIPO NOT IN ('C','I','P') "+CRLF //RRP - 06/11/2012 - Retirado Notas de Complemento
cQry1 +=" AND SD2.D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQry1 +=" ORDER BY SD2.D2_EMISSAO + SD2.D2_DOC + SD2.D2_SERIE + SD2.D2_ITEM "


//memowrite("C:\Grant Thorntom\Querys\cQry2.sql",cQry1)  
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRB_D2D1",.T.,.T.)                                                         

				//#################### REGUA CABEÇALHO ###################\\ 
				
		//		     10   	   20 	  	 30		   40		 50	       60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230       240       250       260
		//	 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890					
		//   XXXXXXXX  XXXXXXXXXX  XX     XXXXX        XX    XXXXXXXXXXXXXX  XXXXXX    XX       XXXX  XXX  XXXXXX   XX    XXXXXXXX  XXXXXXXXXX  XX    XX    XXXXXX    XXXXXXXX  XXXXXXXXXXXXXX  XXXXXX  XX       XXXXXXXXXXXXXX  XXXX  XXX  XXX   XXXXXXXXXXXXXXX  XX    XXXXXXX
                                        
//Cabec1 := 	"EMISSAO   NOTA        SERIE  COD.PRODUTO  ITEM  PRECO UN.       QTDE      ARMAZEM  CFOP  TES  CLIENTE  LOJA  EMISSAO   NOTA        LOJA  TIPO  COD.PROD  NCM       V.UNIT          QTDE    ARMAZEM  TOTAL           CFOP  TES  IPI%  VAL.IPI          ICM%  VAL.ICM

Private aDadTemp:={}

//Saida
AADD(aDadTemp,{"S_Emissao","C",8,0})
AADD(aDadTemp,{"S_Nota","C",9,0}) //RRP - 09/09/2013 - Alteração para 9 caracteres
AADD(aDadTemp,{"S_Serie","C",3,0})
AADD(aDadTemp,{"S_Cod_Prod","C",15,0})
AADD(aDadTemp,{"S_Item","C",2,0})
AADD(aDadTemp,{"S_Preco_Un","N",14,2})
AADD(aDadTemp,{"S_Qtde","N",11,2})
AADD(aDadTemp,{"S_Armazem","C",2,0})
AADD(aDadTemp,{"S_CFOP","C",5,0})
AADD(aDadTemp,{"S_TES","C",3,0})
AADD(aDadTemp,{"S_Cliente","C",6,0})
AADD(aDadTemp,{"S_Loja","C",2,0})
AADD(aDadTemp,{"ICMS_PAGO","N",14,2})

//Entrada
AADD(aDadTemp,{"E_Emissao","C",8,0})
AADD(aDadTemp,{"E_Nota","C",9,0}) //RRP - 09/09/2013 - Alteração para 9 caracteres
AADD(aDadTemp,{"E_Loja","C",2,0})
AADD(aDadTemp,{"E_Tipo","C",2,0})
AADD(aDadTemp,{"E_Cod_Prod","C",15,0})
AADD(aDadTemp,{"E_NCM","C",10,0})
AADD(aDadTemp,{"E_Preco_Un","N",14,2})
AADD(aDadTemp,{"E_Qtde","N",11,2})
AADD(aDadTemp,{"E_Armazem","C",2,0})
AADD(aDadTemp,{"E_Total","N",14,2})
AADD(aDadTemp,{"E_CFOP","C",5,0})
AADD(aDadTemp,{"E_TES","C",3,0})
AADD(aDadTemp,{"E_IPI_Porc","N",14,0})
AADD(aDadTemp,{"E_Val_IPI","N",14,2})
AADD(aDadTemp,{"E_ICM_Porc","N",14,0})
AADD(aDadTemp,{"E_Val_ICM","N",14,2})
AADD(aDadTemp,{"E_Base_Ret","N",14,2})
AADD(aDadTemp,{"E_Icms_Ret","N",14,2})

//TESTE
//cNome := CriaTrab(aDadTemp,.t.)
//RRP - 06/03/2019 - Ajuste para gerar em DBF o relatorio
cNome := CriaTrab(Nil,.F.)
dbCreate(cNome,aDadTemp,"DBFCDXADS" ) 
dbUseArea(.T.,"DBFCDXADS",cNome,"DADXLS",.F.,.F.)
 
cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADXLS",cIndex,"S_NOTA",,,"Selecionando Registro...")

DbSelectArea("DADXLS")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)


TRB_D2D1->(DBGotop())
SetRegua(TRB_D2D1->(RecCount()))

While TRB_D2D1->(!EOF())
/*
If MV_PAR03==2
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ							ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif                              
EndIf
 
If MV_PAR03==2
   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   
//Saida
@nLin,01 PSAY TRB_D2D1->D2_EMISSAO
@nLin,11 PSAY TRB_D2D1->D2_DOC
@nLin,23 PSAY TRB_D2D1->D2_SERIE
@nLin,30 PSAY TRB_D2D1->D2_COD
@nLin,43 PSAY TRB_D2D1->D2_ITEM
@nLin,49 PSAY Transform(TRB_D2D1->D2_PRUNIT,PesqPict("SD2",D2_PRUNIT))
@nLin,65 PSAY TRB_D2D1->D2_QUANT
@nLin,75 PSAY TRB_D2D1->D2_LOCAL
@nLin,84 PSAY TRB_D2D1->D2_CF
@nLin,90 PSAY TRB_D2D1->D2_TES
@nLin,95 PSAY TRB_D2D1->D2_CLIENTE
@nLin,104 PSAY TRB_D2D1->D2_LOJA
//Entrada  


@nLin,110 PSAY TRB_D2D1->D1_EMISSAO
@nLin,120 PSAY TRB_D2D1->D1_DOC
@nLin,132 PSAY TRB_D2D1->D1_SERIE
@nLin,138 PSAY TRB_D2D1->D1_TIPO
@nLin,144 PSAY TRB_D2D1->D1_COD
@nLin,154 PSAY TRB_D2D1->B1_POSIPI
@nLin,164 PSAY Transform(TRB_D2D1->D1_VUNIT,PesqPict("SD1",D1_VUNIT))
@nLin,180 PSAY TRB_D2D1->D1_QUANT
@nLin,188 PSAY TRB_D2D1->D1_LOCAL
@nLin,197 PSAY Transform(TRB_D2D1->D1_TOTAL,PesqPict("SD1",D1_TOTAL)) 
@nLin,213 PSAY TRB_D2D1->D1_CF
@nLin,219 PSAY TRB_D2D1->D1_TES
@nLin,224 PSAY TRB_D2D1->D1_IPI
@nLin,230 PSAY TRB_D2D1->D1_VALIPI
@nLin,247 PSAY TRB_D2D1->B1_PICM
@nLin,253 PSAY TRB_D2D1->D1_VALICM

   nLin := nLin + 1 // Avanca a linha de impressao     
EndIf 
*/
RecLock("DADXLS",.T.)

//Saida
DADXLS->S_Emissao:=TRB_D2D1->D2_EMISSAO
DADXLS->S_Nota:=TRB_D2D1->D2_DOC
DADXLS->S_Serie:=TRB_D2D1->D2_SERIE
DADXLS->S_Cod_Prod:=TRB_D2D1->D2_COD
DADXLS->S_Item:=TRB_D2D1->D2_ITEM
DADXLS->S_Preco_Un:=TRB_D2D1->D2_PRUNIT
DADXLS->S_Qtde:=TRB_D2D1->D2_QUANT
DADXLS->S_Armazem:=TRB_D2D1->D2_LOCAL
DADXLS->S_CFOP:=TRB_D2D1->D2_CF
DADXLS->S_TES:=TRB_D2D1->D2_TES
DADXLS->S_Cliente:=TRB_D2D1->D2_CLIENTE
DADXLS->S_Loja:=TRB_D2D1->D2_LOJA
DADXLS->ICMS_PAGO:=TRB_D2D1->ICMS_PAGO
//Entrada      

DADXLS->E_Emissao:=TRB_D2D1->D1_EMISSAO
DADXLS->E_Nota:=TRB_D2D1->D1_DOC
DADXLS->E_Loja:=TRB_D2D1->D1_SERIE
DADXLS->E_Tipo:=TRB_D2D1->D1_TIPO
DADXLS->E_Cod_Prod:=TRB_D2D1->D1_COD
DADXLS->E_NCM:=TRB_D2D1->B1_POSIPI
DADXLS->E_Preco_Un:=TRB_D2D1->D1_VUNIT
DADXLS->E_Qtde:=TRB_D2D1->D1_QUANT
DADXLS->E_Armazem:=TRB_D2D1->D1_LOCAL
DADXLS->E_Total:=TRB_D2D1->D1_TOTAL
DADXLS->E_CFOP:=TRB_D2D1->D1_CF
DADXLS->E_TES:=TRB_D2D1->D1_TES
DADXLS->E_IPI_Porc:=TRB_D2D1->D1_IPI
DADXLS->E_Val_IPI:=TRB_D2D1->D1_VALIPI
DADXLS->E_ICM_Porc:=TRB_D2D1->B1_PICM
DADXLS->E_Val_ICM:=TRB_D2D1->D1_VALICM
DADXLS->E_Base_Ret:=TRB_D2D1->D1_BRICMS
DADXLS->E_Icms_Ret:=TRB_D2D1->D1_ICMSRET

DADXLS->(MsUnlock())

   TRB_D2D1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

DADXLS->(DbCloseArea())
/*
If MV_PAR03==2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif


MS_FLUSH()

EndIf
*/
TRB_D2D1->(DBCloseArea())

//If MV_PAR03==1
//	Geraexcel()

If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")
     Return
EndIf 
	
	cArqOrig := "\"+CURDIR()+cNome+".DBF"
   	cPath     := AllTrim(GetTempPath())                                                   
   	CpyS2T( cArqOrig , cPath, .T. )
     //cPath:="C:\PROTHEUS\PROTHEUS_DATA\sysgt\" 
       
    oExcelApp:=MsExcel():New()
    //oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
    oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
    oExcelApp:SetVisible(.T.)   

sleep(05)	
//EndIf 

Erase &cNome+".DBF" 

Return
 
/*
 ----------------------------------------------------
|	Função para validar se a data da                 |
|   Pergunta está vazia. Obs: Ñ permite Data Vazia.  |
 ----------------------------------------------------
*/
User function ValSHIRE(cData)
local lRet:=.T.

If Empty(cData)
	msginfo("Campo Data Vazio!!")
	lRet:=.F. 
EndIf

Return(lRet)
/*
 ----------------------------------------------------
|	Função para exportar para o excel                |
|                                                    |
 ----------------------------------------------------
*/
Static function Geraexcel()
 
   cArqOrig := "\SYSgt\"+cNome+".DBF"
   cPath     := AllTrim(GetTempPath())                                                   
   CpyS2T( cArqOrig , cPath, .T. )
     //cPath:="C:\PROTHEUS\PROTHEUS_DATA\sysgt\"                  

If !ApOleClient("MsExcel")
     MsgStop("Microsoft Excel nao instalado.")
     Return
EndIf
       
      oExcelApp:=MsExcel():New()
      //oExcelApp:WorkBooks:Open("Z:\AMB01\SYSTEM\"+cNome+".DBF") 
      oExcelApp:WorkBooks:Open(cPath+cNome+".DBF")  
      oExcelApp:SetVisible(.T.)   
      
//sleep(20)
Return
