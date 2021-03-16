#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �N6GEN003  � Autor � William Souza      � Data �  18/01/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Fonte gen�rico para gera��o de numero randomico            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function N6GEN003(nTamanho)

local vogais    := 'AEIOU'
local consoante := 'BCDFGHJKLMNPQRSTVWXYZBCDFGHJKLMNPQRSTVWXYZ'
local numeros   := '123456789'
local resultado := '' 

for x:=1 to nTamanho*2
    
	str1 := ""
	str2 := ""
	str3 := ""
	str1 := substr(consoante,aleatorio(len(consoante),26),1)
	str2 := substr(vogais,aleatorio(len(vogais),5),1)
	str3 := left(fwuuid(consoante),4)
	resultado += alltrim(str1+str2+str3)
	
next 

Return left(resultado,nTamanho)
