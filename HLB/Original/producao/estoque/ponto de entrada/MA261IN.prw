/*
Funcao       : MA261IN
Objetivos    : Preenche valores de campos na tela de estorno
			   OBS: Pode ser utilizado para preenchimento dos valores de campos que o usuario queira apresentar na tela.
					Pré Preenchimento Número Documento com '000000000'
EM QUE PONTO : E chamado apos a montagem do array aCols com as linhas do browse das transferencias, nas rotinas de visualizacao e estorno de transferencias.
Autor        : César Alves
Data/Hora    : 19/09/2018
*/ 

*--------------------------*
User Function MA261IN( )    
*--------------------------*   

//Local cPosCampo := aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='Campo do Usuario'    })
//aCols[n,nPosCampo := 'Conteudo do campo do usuario'

//CAS - Tratamento para empresa Exeltis (Conforme e-mail da Fabiana Leonel) 
//Pré Preenchimento Número Documento com '000000000'
If cEmpAnt $ 'LG'
	CDOCUMENTO := '000000000'
EndIF    

Return Nil