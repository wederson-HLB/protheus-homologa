#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Funcao      : GTCTB009
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Cadastro de registro I157 ECD - Saldos de Plano de Contas Anterior
Autor       : Anderson Arrais
Data	    : 30/11/2016
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/
*---------------------*
User Function GTCTB009
*---------------------*
Local oBrowse

Private aRotina		 := MenuDef() 
Private cCadastro	 := 'Saldos de Plano de Contas Anterior'

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( 'Z19' )
oBrowse:SetDescription( cCadastro )
oBrowse:Activate()

Return NIL

/*
Função		: MenuDef
Objetivo	: Criação do menu funcional
Autor		: Anderson Arrais
Data 		: 30/11/2016
*/
*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina := {}

aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;
               { "Visualizar"   ,"AxVisual" , 0, 2},;
               { "Incluir"      ,"AxInclui" , 0, 3},;
               { "Alterar"      ,"AxAltera" , 0, 4},;
               { "Excluir"      ,"AxDeleta" , 0, 5},;
               { "Exporta XLS"  ,"u_ExpXLS_Z19" , 0, 2},;
               { "Importa XLS"  ,"u_ImpXLS_Z19" , 0, 3} }               
               
Return aRotina 

/*
Funcao      : ExportaXLS
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Exporta o cadastro de registro I157 ECD - Saldos de Plano de Contas Anterior
Autor       : Richard S Busso	
Data	    : 09/05/2017
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*--------------------------------------------*
User Function ExpXLS_Z19	
*--------------------------------------------*
Local aAreaZ19 := GETAREA()
Local oExcel    
Local aAux := {} 
Local cFile := GetTempPath() + 'SaldContAnt_' + DtoS( dDatabase ) + "_" + StrTran( Time() , ':' , '' ) + '.csv'
Local aHeader := {}
Local cHeader := "" 
Local cRows	:= ""

//Limpa cash do arquivo
If File( cFile )
	FErase( cFile )
EndIf

nHFile := FCreate( cFile )

//Lista os campos da tabela.
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("Z19" + "01"))

While SX3->(!EOF() .and. SX3->X3_ARQUIVO == "Z19") 
	
	cHeader += alltrim(SX3->X3_CAMPO) + ";" 
	AADD(aHeader,SX3->X3_CAMPO)
    
    SX3->(dbSkip())
	Loop
Enddo

cHeader += CRLF
//Escreve no arquivo
FWrite( nHFile , cHeader , Len( cHeader ) )

//Lista todos os dados e preenche em formato de linha, separado por ";"
dbSelectArea("Z19")
Z19->(dbSetOrder(1)) 

While Z19->(!EOF())

	For i = 1 to Len( aHeader )
		cRows += cValtoChar(Z19->&(aHeader[i])) + ";"
	next
	cRows += CRLF		

	Z19->(dbSkip())
Loop
Enddo

FWrite( nHFile , cRows , Len( cRows ) )

FClose( nHFile )

//Chama a execução do Excel
oExcel1:=MsExcel():New()
oExcel1:WorkBooks:Open( cFile )  
oExcel1:SetVisible(.T.)

RestArea(aAreaZ19) 

Return


/*
Funcao      : ImpXLS_Z19
Parametros  : Nil                      
Retorno     : Nil
Objetivos   : Importa o cadastro de registro I157 ECD - Saldos de Plano de Contas Anterior
Autor       : Richard S Busso	
Data	    : 09/05/2017
Revisão		:                    
Data/Hora   : 
Módulo      : Genérico
*/

*--------------------------------------------*
User Function ImpXLS_Z19	
*--------------------------------------------* 
Local aAreaZ19 := GETAREA()
Local cPlanilha     
Local nLinha	:= 0 
Local aLinha  		
Local aDadosLog		:= {}
Local aAux			:= {}  
Local oDlg
Local cDados	
Local aFields	:= {} 
Local cTexto := " "   
Local lInc := .T.
Local lAlt := .F.
Local cFilZ19	:= ""  
Local cCONTAC	:= ""
Local cCONTAG	:= ""
Local cCC		:= ""
Local cVALOR	:= 0
Local cSITUA	:= ""
Local dDATA

cPlanilha := cGetFile( "Arquivos CSV (*.csv) |*.csv","Selecione o arquivo" , 0 , "C:\" , .F. , (GETF_LOCALHARD+GETF_NETWORKDRIVE))

If Empty( cPlanilha )
	MsgStop( 'Planilha nao informada.' )
	Return
EndIf

If !MsgYesNo( 'Confirma importação da planilha ?' )
	Return
EndIf     
/*
//FUNÇÕES COMENTADAS, PODE OCASIONAR DO COLABORADOR ADICIONAR APENAS UM LINHA DE REGISTRO E APAGAR O RESTATE.


//Marca todos os registros como deletado.
nStatusUpd := TCSqlExec(" UPDATE "+RetSqlName("Z19")+" SET D_E_L_E_T_ = '*'  ")
 
if (nStatusUpd < 0)
	conout("TCSQLError() " + TCSQLError())
endif

//Deleta todos os registros marcados como deletado. (PACK)
nStatusDel := TCSqlExec(" DELETE FROM "+RetSqlName("Z19")+" WHERE D_E_L_E_T_ = '*' ")
 
if (nStatusDel < 0)
	conout("TCSQLError() " + TCSQLError())
endif  
*/



//Abre o arquivo
Ft_Fuse( cPlanilha ) 

//Busca os campos do cabeçalho
aFields	:= StrTokArr( Ft_FReadLn() , ";" )

dbSelectArea("Z19")   
Z19->(dbSetOrder(1))

//Pega a posição de cada campo do cabeçalho
nFilZ19	:= Ascan( aFields , "Z19_FILIAL" )
nLenFilial 	:= Len( Z19->Z19_FILIAL )   
nCONTAC	:= Ascan( aFields , "Z19_CONTAC" ) 
nLenConta 	:= Len( Z19->Z19_CONTAC )
nCONTAG	:= Ascan( aFields , "Z19_CONTAG" )
nLenContaG 	:= Len( Z19->Z19_CONTAG )
nCC		:= Ascan( aFields , "Z19_CC" )
nLenCC 	:= Len( Z19->Z19_CC )
nVALOR	:= Ascan( aFields , "Z19_VALOR" )
nSITUA	:= Ascan( aFields , "Z19_SITUA" )
nLenSitua 	:= Len( Z19->Z19_SITUA )
nDATA	:= Ascan( aFields , "Z19_DATA" )

//Preenchimento dos campos
While !Ft_FEof()
    //Monta o array com a informação de cada linha
   	aLinha := Separa( Ft_FReadLn() , ";" , .t.) 
   	        
	If nLinha > 0 
		
		cFilZ19	:= PadR( AllTrim( cValtoChar(aLinha[nFilZ19]) ) , nLenFilial )    
		cCONTAC	:= PadR( AllTrim( cValtoChar(aLinha[nCONTAC]) ) , nLenConta ) 
		cCONTAG	:= PadR( AllTrim( cValtoChar(aLinha[nCONTAG]) ) , nLenContaG ) 
		cCC		:= PadR( AllTrim( cValtoChar(aLinha[nCC]) ) , nLenCC ) 
		cVALOR	:= val(aLinha[nVALOR]) 
		cSITUA	:= PadR( AllTrim( cValtoChar(aLinha[nSITUA]) ) , nLenSitua ) 
		dDATA	:= CTOD(aLinha[nDATA])
		
	   	If Z19->(!dbSeek(cFilZ19 + cCONTAC + cCONTAG + cSITUA + DTOS(dDATA)))	    
	    	lInc := .T.
	   	Else
			lInc := .F.
	    Endif

	    If !lInc
		    cTexto += "Filial: " + cFilZ19  
		    cTexto += " Conta: " + cCONTAC
		    cTexto += " Conta HLB: " + cCONTAG
		    cTexto += " CC: " + cCC
		    cTexto += " Valor: " + cValtoChar(cVALOR)
		    cTexto += " Situacao: " + cSITUA
		    cTexto += " Data: " + DTOS(dDATA)
		    cTexto += " - Já Existe)." + CRLF 
	      Else
	    	Reclock("Z19",.T.)                        
				Z19->Z19_FILIAL := cFilZ19	
				Z19->Z19_CONTAC := cCONTAC
				Z19->Z19_CONTAG := cCONTAG
				Z19->Z19_CC 	:= cCC
				Z19->Z19_VALOR 	:= cVALOR
				Z19->Z19_SITUA 	:= cSITUA
				Z19->Z19_DATA 	:= dDATA
	        MSUNLOCK() 
	     	cTexto += "Filial: " + cFilZ19  
	        cTexto += " Conta: " + cCONTAC
	        cTexto += " Conta HLB: " + cCONTAG
	        cTexto += " CC: " + cCC
	        cTexto += " Valor: " + cValtoChar(cVALOR)
	        cTexto += " Situacao: " + cSITUA
	        cTexto += " Data: " + DTOS(dDATA)
	        cTexto += " - Incluido " + CRLF 
	     Endif   
	Endif 
	
Ft_FSkip()
nLinha ++
Loop
Enddo

Ft_Fuse()

RestArea(aAreaZ19) 

	If !Empty(cTexto)
		LogInclusao(cTexto) 
	Endif
Return   

Static Function LogInclusao(cTexto)

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

Return()