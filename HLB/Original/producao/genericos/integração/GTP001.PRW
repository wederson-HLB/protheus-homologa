#include "protheus.ch"
#include "tbiconn.ch"
  
/*
+-----------------------------------------------------------------------------
| Função | GTP001   | Autor | Ana Carolina Gabriel		|  Data  | 11/10/2010|
+-----------------------------------------------------------------------------
| Descrição | Programa de cadastro que permite a visualização e				 |
|           |                                 manipulação das informações () |
+-----------------------------------------------------------------------------
| Uso | Projeto WEB	 -	GT                                                   |
+-----------------------------------------------------------------------------
| Objetivo | Disponibilidade de empresas no Portal        	         		 |
|-----------------------------------------------------------------------------
|Funções:												                     |
|												                             |
|ADD()	 :	Adiciona no Listbox2, o conteudo selecionado do Listbox1(SM0)    |
|REMOVE():	Remove no Listbox2 - o que está presente na tabela ZZB           |
|INCEMP(): 	Inclui as empresas presentes  na Listbox2 na Tabela ZZB          |
|CARGAEMP(): NA SUA FUNCAO DE CARGA NO OUTRO SERVER		                     |
+-----------------------------------------------------------------------------
*/

/*
Funcao      : GTP001
Parametros  : 
Retorno     : 
Objetivos   : Disponibilidade de empresas no Portal   
Autor       : Ana Carolina Gabriel
Data/Hora   : 11/10/2010
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Portal.
*/

      
*-----------------------*
 User Function GTP001()  
*-----------------------*

Private cAlias := "ZZB"
Private cCadastro := "Cadastro de Empresas"
Private aRotina := {}

AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})

AADD(aRotina,{"Atualiza" ,"U_Atual()",0,3}) 

dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6,1,22,75,cAlias)

Return Nil


/*
+------------------------------------------------------------------------------------------------------------------------------------------------------+
| Função | Relac() 						  | Autor | Ana Carolina Gabriel	   					|  Data  | 11/10/2010|                                 |
+------------------------------------------------------------------------------------------------------------------------------------------------------|
|																	 Descrição																		   |
|------------------------------------------------------------------------------------------------------------------------------------------------------|
| Função que relaciona em duas Listbox, sendo a primeira carregada via RPCCONNECT, função capaz de conectar outro server protheus e sendo              |
|		possivel acessar as tabelas do mesmo, sendo assim, a Listbox 1 é alimentada com dados de IPs diferentes, em ambientes diferentes,              |
|		A função então possibilita a inclusão de novas empresas dentro da Listbox 2, a qual é gravada dentro de uma tabela no Protheus, (ZZB).         |
+-----------------------------------------------------------------------------------------------------------------------------------------------------*/

//=================================================================================================================================================================
//																		CONECTA
//=================================================================================================================================================================
STATIC FUNCTION CONECTA(aList1)

//========================================= Popula aList1
//Busca o conteudo da SX5
DBSELECTAREA('SX5')
SX5->(DBSETORDER(1))
SX5->(DBSEEK(xfilial()+'WC'))

While X5_TABELA == 'WC'   // Enquanto existirem ambientes criados no SX5, FAÇA:
	
	cString := 	X5_DESCRI
	
	aConect:=STRTOKARR (cString, ';')
	
	cPort := aConect[2]
	cIp  :=  aConect[1]
	cAmbiente :=aConect[3]
	cEmp := aConect[4]
	cFil := alltrim(aConect[5])
	nPort:= val(cPort)
	
	
	 oServ:=  RpcConnect(cIp,nPort,cAmbiente,cEmp,cFil) 
	   
	if valtype(OsERV) == 'O'
		x := 1  
		aAux:={}
		aAUX := oServ:CALLPROC("U_CARGAEMP")

		for x:=1 to len(aAux)
			aadd(aList1,{aAux[x][1],aAux[x][2],aAux[x][3],aAux[x][4],cAmbiente,aAux[x][5],aAux[x][6]})
		next
		
		RpcDisconnect(oServ)// --  finaliza a conexao remota
		
		
		SX5->(dbskip())
	else
		msginfo('Não conectado! Verifique o cadastro de Conexão')
		exit
	endif
enddo
RETURN


//==================================================================================================================================================
//NA SUA FUNCAO DE CARGA NO OUTRO SERVER
//==================================================================================================================================================

USER FUNCTIOn CARGAEMP(cEmp,cFil,cAmbiente)

conout("==== ACEITANDO CONEXAO REMOTA")
conout("==== preparando ambiente")

PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil  MODULO "FAT"  

aList1:={}

dbselectarea("SM0")
SM0->(dbgotop())
conout("lendo empresas")

//cDtHora :=  DTOS(Date())

WHILE SM0->(!EOF())
	conout("empresa processada")
	aadd(aList1,{SM0->M0_NOME,SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL, SM0->M0_CGC, SM0->M0_NIRE})
	SM0->(dbskip())
enddo

RETURN(aList1)        



//==================================================================================================================================================
//								ATUAL() - Atualiza SM0 na ZZB
//==================================================================================================================================================


User Function Atual

cAlias:='ZZB'
aList1:={}

Conecta(aList1)

cQry:= " DELETE FROM "+ RETSQLNAME(cAlias) 
TCSQLExec(cQry)

for y:=1 to len( aList1 )
	cQuery := 'SELECT MAX(R_E_C_N_O_)+1 AS RECNO1 FROM '+ RETSQLNAME(cAlias)
	DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'TRB',.T.,.T.)
	
	Tmp:= TRB->RECNO1
	
	IF Tmp = 0
		Tmp ++
	ENDIF    

	cQEry :=  " INSERT INTO "+ RETSQLNAME(cAlias) +" ( ZZB_NOME , ZZB_CODEMP , ZZB_CODFIL , ZZB_NFIL , ZZB_AMB, ZZB_DATA , ZZB_HORA , ZZB_CNPJ , ZZB_NIRE , R_E_C_N_O_ )"
	cQEry +=  " VALUES ('" + RTRIM(aList1[y][1]) + "','" + RTRIM(aList1[y][2]) +  "','" + RTRIM(aList1[y][3]) + "','" + RTRIM(aList1[y][4]) +"','"+  RTRIM(aList1[y][5]) +"','"+  RTRIM(DTOS(DATE()))  +"','"+ ALLTRIM(TIME()) +"','"+  RTRIM(aList1[y][6]) +"','"+   RTRIM(aList1[y][7]) +"', CAST(" + CVALTOCHAR(Tmp) + " AS INTEGER) )"
	TCSQLExec(cQEry)
	TRB->(DBCLOSEAREA())
next

MSGINFO('Empresas atualizadas com Sucesso!')



Return


