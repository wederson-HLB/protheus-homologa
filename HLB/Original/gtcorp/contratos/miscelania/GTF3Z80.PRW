#INCLUDE "PROTHEUS.CH"
/*
Funcao      : GTF3Z80
Parametros  : 
Retorno     : 
Objetivos   : Fonte que busca as amarrações Departamento X Area X Serviço, focando serviçoes
Autor       : Matheus Massarotto
Data/Hora   : 08/10/2012    11:20
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*----------------------*
User Function GTF3Z80()
*----------------------*

Local cGet1	 := Space(25)

if !TCCANOPEN("Z80"+cEmpAnt+"0")
	Alert("Opção não disponível!")
	Return()
endif

Private oGet1

Private oDlgBusc

Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
					{"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}


Private _oDlg,oListBox
Private aListBox	:={}
Private aHeader		:={}
Private aHeader2	:={}
Private aCols		:={}
Private aCols2		:={}
Private aCols3		:={}
Private aAlter		:={"M_OK"}
Private oOk 		:= LoadBitmap( nil, "LBOK")
Private oNo 		:= LoadBitmap( nil, "LBNO")
Private oExcluir	:= LoadBitmap( nil, "EXCLUIR")
Private nUsado		:=0
Private nUsado2		:=0
Private aObjects    := {}


			AADD(aHeader,{ TRIM(""),;
								 "M_OK",;
								 "@BMP",;
								 2,;
			 					 0,;
			 					 "ALLWAYSFALSE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "V",;
			 					 "",;
			 					 "",;
			 					 "",;
			 					 "V" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("SERVICO"),;
								 "M_CODS",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("DESC_SERV"),;
								 "M_DESCS",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("AREA"),;
								 "M_CODA",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("DESC_AREA"),;
								 "M_DESCA",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("DEPARTAMENTO"),;
								 "M_CODD",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado:=nUsado+1
			AADD(aHeader,{ TRIM("DESC_DEP"),;
								 "M_DESCA",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado:=nUsado+1
            //Montagem do segundo aHeader para o getdados da parte de baixo
 			AADD(aHeader2,{ TRIM("SERVICO"),;
								 "M_CODS",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado2:=nUsado2+1
			AADD(aHeader2,{ TRIM("DESC_SERV"),;
								 "M_DESCS",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado2:=nUsado2+1
			AADD(aHeader2,{ TRIM("AREA"),;
								 "M_CODA",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado2:=nUsado2+1
			AADD(aHeader2,{ TRIM("DESC_AREA"),;
								 "M_DESCA",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado2:=nUsado2+1
			AADD(aHeader2,{ TRIM("DEPARTAMENTO"),;
								 "M_CODD",;
								 "@X  ",;
								 6,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )
		    nUsado2:=nUsado2+1
			AADD(aHeader2,{ TRIM("DESC_DEP"),;
								 "M_DESCA",;
								 "@X  ",;
								 50,;
			 					 0,;
			 					 "ALLWAYSTRUE()",;
			 					 "€€€€€€€€€€€€€€ ",;
			 					 "C",;
			 					 "",;
			 					 "" } )    
		    nUsado2:=nUsado2+1
		    
	CarregaAcols(@aCols)
	
	nMax:=len(aCols)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()

AAdd( aObjects,	{ 100, 50, .T., .T. } )
AAdd( aObjects, { 100, 50, .T., .T. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

aPosObjoDlg		:= {aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]}
	
/*   	AADD(aCols2,Array(nUsado+1))
	//Montagem do aCols
	for i:=1 to nUsado
		if aHeader[i,2] $ ("M_OK")
			aCols2[Len(aCols2)][i]:=oNo
		else	
			aCols2[Len(aCols2)][i]:=""
		endif
	next
	aCols2[Len(aCols2)][nUsado+1] := .F.
*/
		    
DEFINE MSDIALOG oDlgBusc TITLE "Serviços" FROM aSize[7],0 TO aSize[6]-20,aSize[5]-200 PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(006),C(257) Button "Buscar" Size C(037),C(011) action(BuscaServ(cGet1)) PIXEL OF oDlgBusc
	@ C(007),C(035) MsGet oGet1 Var cGet1 Size C(217),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgBusc
	@ C(009),C(005) Say "Pesquisar" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgBusc

    //Grupo com os serviços para busca
	@ aPosObj[1,1]+20,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-100 LABEL "Buscar Serviços" PIXEL OF oDlgBusc

	oGetDados1 := MsGetDados():New(aPosObj[1,1]+30, aPosObj[1,2]+2, (aPosObj[1,3])-2, aPosObj[1,4]-102, 4, "AllwaysTrue()", "AllwaysTrue()",;
	"", .F., aAlter, , .F., nMax, "AllwaysTrue()", "AllwaysTrue()",,;
	"AllwaysTrue()", oDlgBusc)

    
   	oBtn := TButton():New((aPosObj[1,3])+3, (aPosObj[1,4]-130)/2,"      Adicionar",oDlgBusc,{|| Preenche(@aCols2,@aCols) },;
                   50,17,,,.F.,.T.,.F.,,.F.,,,.F. )           
    // O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão,     
    oBtn:SetCss("QPushButton{ background-image: url(rpo:SDUCOUNT.png);"+;
                                " background-repeat: none; margin: 2px }")     
    
	//Grupo com os itens da proposta adicionados	
	@ aPosObj[2,1]+20,aPosObj[2,2] TO aPosObj[2,3]-28,aPosObj[2,4]-100 LABEL "Itens da Proposta" PIXEL OF oDlgBusc
	
	oGetDados2 := MsNewGetDados():New(aPosObj[2,1]+30, aPosObj[2,2]+2, (aPosObj[2,3])-30, aPosObj[2,4]-102, GD_UPDATE+GD_DELETE , "AllwaysTrue()", "AllwaysTrue()",;
	"", aAlter,, 99, "AllwaysTrue()", "AllwaysTrue()",;
	"AllwaysTrue()", oDlgBusc,aHeader2, aCols2)
    
	@ (aPosObj[2,3])-15,(aPosObj[2,4]-102)/4 Button "Ok" Size C(037),C(012) action(aCols3:=aCols2,oDlgBusc:end()) PIXEL OF oDlgBusc
	@ (aPosObj[2,3])-15,((aPosObj[2,4]-122)-(aPosObj[2,4]-102)/4) Button "Cancelar" Size C(037),C(012) action(oDlgBusc:end()) PIXEL OF oDlgBusc	
	

	oGetDados1 :AddAction ( "M_OK"		, {||MudaStatus()	})

	oGetDados1 :ForceRefresh()
	oGetDados2:ForceRefresh()  
	
	oDlgBusc:oWnd:align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlgBusc CENTERED 

Return(aCols3)

/*
Funcao      : C()
Parametros  : nTam
Retorno     : nTam
Objetivos   : Função para tratamento de valores para posicionamento na tela
Autor       : Matheus Massarotto
Data/Hora   : 26/09/2012
*/
*---------------------*
Static Function C(nTam)                                                         
*---------------------*
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*
Funcao      : CarregaAcols()
Parametros  : aCols
Retorno     : 
Objetivos   : Função para carregar o Acols principal com os serviços vinculados na tabela Z80
Autor       : Matheus Massarotto
Data/Hora   : 26/09/2012
*/
*---------------------------------*
Static Function CarregaAcols(aCols)
*---------------------------------*
Local cQry:=""

	cQry+=" SELECT Z80_CODSER,Z80_DESCSE,Z80_CODARE,Z80_DESCAR,Z80_CODDEP,Z80_DESCDE FROM "+RETSQLNAME("Z80")

	if select("TRBCOLS")>0
		TRBCOLS->(DbCloseArea())
	endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBCOLS",.T.,.T.)

	COUNT TO nRecCount
    
	if nRecCount >0
		TRBCOLS->(DbGotop())
		While TRBCOLS->(!EOF())
				AADD(aCols,{oNo,TRBCOLS->Z80_CODSER,TRBCOLS->Z80_DESCSE,TRBCOLS->Z80_CODARE,TRBCOLS->Z80_DESCAR,TRBCOLS->Z80_CODDEP,TRBCOLS->Z80_DESCDE,.F.})
			TRBCOLS->(DbSkip())
		Enddo
	endif
Return

/*
Funcao      : MudaStatus()
Parametros  : 
Retorno     : cArqConte
Objetivos   : Função para mudar a imagem do primeiro campo, para selecionado ou não selecionado
Autor       : Matheus Massarotto
Data/Hora   : 26/09/2012
*/
*-----------------------------*
Static Function MudaStatus()
*-----------------------------*
Local cArqConte:=aCols[oGetDados1:Obrowse:nAt][oGetDados1:Obrowse:ColPos]

if oOk==cArqConte
	cArqConte:=oNo
else 
	cArqConte:=oOk
endif

Return(cArqConte)

/*
Funcao      : BuscaServ()
Parametros  : 
Retorno     : 
Objetivos   : Função para buscar o serviço no aCols, posicionando caso encontre
Autor       : Matheus Massarotto
Data/Hora   : 26/09/2012
*/
*-------------------------------*
Static Function BuscaServ(cBusca)
*-------------------------------*
Local nGo		:= 0
Local nTamBusca	:= len(alltrim(cBusca))

nGo:= aScan( aCols, { |x|   UPPER(alltrim(cBusca)) $  UPPER(x[2]) } )

if nGo == 0
	nGo:= aScan( aCols, { |x|   UPPER(alltrim(cBusca)) $  SUBSTR(UPPER(x[3]),1,nTamBusca)  } )
endif	

oGetDados1:GoTo(nGo)

Return()


/*
Funcao      : Preenche()
Parametros  : 
Retorno     : 
Objetivos   : Função para preencher o acols2 baseado no 1
Autor       : Matheus Massarotto
Data/Hora   : 26/09/2012
*/
*------------------------------------*
Static Function Preenche(aCols2,aCols)
*------------------------------------*

if empty(aCols2)
	oGetDados2:ACOLS:={}
endif

aCols2:=oGetDados2:ACOLS

	for j:=1 to len(aCols)
		if aCols[j][1]:cName==oOk:cName
		   	AADD(aCols2,Array(nUsado+1))
			nII:=0
			for k:=2 to len(aCols[j])-1
				nII++
				if aHeader[k,2] $ ("M_OK")
					aCols2[Len(aCols2)][nII]:=oExcluir
				else	
					aCols2[Len(aCols2)][nII]:=aCols[j][k]
				endif

			next
			aCols2[Len(aCols2)][nUsado+1] := .F.
		endif
		aCols[j][1]:=oNo
	next

Return

