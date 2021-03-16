#include "protheus.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTHDA005
Parametros  : 
Retorno     : Nil
Objetivos   : Fonte utilizado por schedules, para deletar da tabela Z05(Colaborador) e Z08(Colaborador x Empresa) os usu�rios bloqueados no GTHD
Autor       : Matheus Massarotto
Data/Hora   : 28/05/2012    10:19
Revis�o		:                    
Data/Hora   : 
M�dulo      : Gen�rico
*/

*-----------------------*
User Function GTHDA005( )
*-----------------------*
Local cEmail	:= ""

if Select("SX3")<=0
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "01" Filial "01"
endif

CONOUT("FONTE -- > GTHDA005, Entrou no fonte")

DbSelectArea("Z05")
Z05->(DbSetOrder(1))
Z05->(DbGoTop())

While Z05->(!EOF())
	if SeBlocUser(Z05->Z05_EMAIL)
		cEmail:=Z05->Z05_EMAIL
		
		RecLock("Z05",.F.)
			Z05->(DbDelete())
		Z05->(MsUnlock())
		
		DbSelectArea("Z08")
		Z08->(DbGoTop())
		Z08->(DbSetOrder(3))
		if DbSeek(xFilial("Z08")+cEmail)
			While Z08->(!EOF()) .AND. alltrim(UPPER(Z08_FUNC))==alltrim(UPPER(cEmail))
				RecLock("Z08",.F.)
					Z08->(DbDelete())
				Z08->(MsUnlock())

				Z08->(DbSkip())
			Enddo
		endif
			
	endif
	Z05->(DbSkip())
Enddo

Return

Static function SeBlocUser(cEmail)
Local cUserID
Local nOrder 	:= 4 //e-mail
Local aArray	:= {}
Local lRet		:=.F.

// pesquisar pelo nome do usu�rio
PswOrder(nOrder)

If PswSeek( Upper(cEmail), .T. )    
	cUserId := PswID()
	aArray:=PswRet()
	if aArray[1][17] //Usu�rio bloqueado
		lRet:=.T.
	endif
EndIf


/*
Observa��es
nArray
1 - Informa��es do us�ario
2 - Detalhes do usu�rio (impress�o, configura��o de p�gina, tipo de ambiente e etc)
3 - Menus do usu�rio.

aRet
Informa��es do usu�rio:

�ndice       Tipo Conteudo
[1][1]   C     N�mero de identifica��o seq�encial com o tamanho de 6 caracteres
[1][2]   C     Nome do usu�rio
[1][3]   C     Senha (criptografada)
[1][4]   C     Nome completo do usu�rio
[1][5]   A     Vetor contendo as �ltimas n senhas do usu�rio
[1][6]   D     Data de validade
[1][7]   N     N�mero de dias para expirar
[1][8]   L      Autoriza��o para alterar a senha
[1][9]   L      Alterar a senha no pr�ximo logon
[1][10] A     Vetor com os grupos
[1][11] C     N�mero de identifica��o do superior
[1][12] C     Departamento
[1][13] C     Cargo
[1][14] C     E-mail
[1][15] N     N�mero de acessos simult�neos
[1][16] D     Data da �ltima altera��o
[1][17] L      Usu�rio bloqueado
[1][18] N     N�mero de d�gitos para o ano
[1][19] L      Listner de liga��es
[1][20] C     Ramal
[1][21] C     Log de opera��es
[1][22] C     Empresa, filial e matricula
[1][23] A     Informa��es do sistema 
    [1][23][1]  L  Permite alterar database do sistema
    [1][23][1]  N  Dias a retroceder
    [1][23][1]  N  Dias a avan�ar
[1][24] D     Data de inclus�o no sistema
[1][25] C     N�vel global de campo
[1][26] U     N�o usado   

[2][1]   A    Vetor contendo os hor�rios dos acessos, cada elemento do vetor corresponde um dia da semana com a hora inicial e final.
[2][2]   N    Uso interno
[2][3]   C    Caminho para impress�o em disco
[2][4]   C    Driver para impress�o direto na porta. Ex: EPSON.DRV
[2][5]   C    Acessos
[2][6]   A    Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:"9901", se existir "@@@@" significa acesso a todas as empresas
[2][7]   C    Elemento alimentado pelo ponto de entrada USERACS
[2][8]   N    Tipo de impress�o: 1 - em disco, 2 - via Windows e 3 direto na porta
[2][9]   N    Formato da p�gina: 1 � retrato, 2 - paisagem
[2][10] N    Tipo de Ambiente: 1 � servidor, 2 - cliente
[2][11] L     Priorizar configura��o do grupo
[2][12] C    Op��o de impress�o
[2][13] L    Acessar outros diret�rios de impress�o

[3]       A    Vetor contendo o m�dulo, o n�vel e o menu do usu�rio. 
      Ex: [3][1] = "019\sigaadv\sigaatf.xnu"
            [3][2] = "029\sigaadv\sigacom.xnu"

Se o par�metro lNoAll for igual a .F., a dimens�o 4 do array tamb�m ser� mostrada.

[4]       A    Vetor contendo as informa��es do SenhaP
[4][1]  L     Utiliza SenhaP
[4][2]  C    N�mero de s�rie do SenhaP
[4][3]  C    N�o usado
[4][4]  C    N�o usado

[5]       A    Array com as informa��es do painel de gest�o
[6]       A    Array com as informa��es dos indicadores nativos

Informa��es do grupo:

�ndice Tipo Conteudo

[1][1]   C      N�mero de identifica��o sequencial com o tamanho de 6 caracteres
[1][2]   C      Nome do grupo
[1][3]   A      Vetor contendo os hor�rios dos acessos,  cada elemento corresponde a um dia da semana com a hora inicial e final.
[1][4]   D      Data de validade
[1][5]   N      N�mero de dias para expirar
[1][6]   L      Autoriza��o para alterar a senha
[1][7]   N     Uso interno
[1][8]   C     Caminho para impress�o em disco
[1][9]   C     Driver para impress�o direto na porta. Ex: EPSON.DRV
[1][10] C     Acessos
[1][11] A     Vetor contendo as empresas, cada elemento contem a empresa e a filial. Ex:9901, se existir "@@@@" significa acesso a todas as empresas
[1][12] D     Data da �ltima altera��o
[1][13] N     Tipo de impress�o: 1 - em disco, 2 - via Windows e 3 direto na porta
[1][14] N     Formato da p�gina: 1 - retrato, 2 - paisagem
[1][15] N     Tipo de Ambiente: 1 - servidor, 2 - cliente
[1][16] C     Op��o de impress�o
[1][17] L      Acessar outros diret�rios de impress�o
[1][18] A      Range da database
     [1][18][1] - Permite retroceder ou avan�ar database.
     [1][18][2] - Dias a retroceder
     [1][18][3] - Dias a avan�ar
[1][19] D      Data de inclus�o
[1][20] C      N�vel global de campo


[2]  A Vetor contendo o m�dulo, o n�vel e o menu do usu�rio.
     Ex: [2][1] = "019\sigaadv\sigaatf.xnu"
           [2][2] = "029\sigaadv\sigacom.xnu"
*/
Return(lRet)