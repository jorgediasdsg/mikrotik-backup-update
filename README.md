<h1 align="center">:rocket: Learn Shell: Make Mikrotik Backup :rocket:</h1>

<p align="center">

:us: Script for Backup and Update of Mikrotik in batches.

:brazil: Script para Backup e Update de Mikrotik em lotes.

</p>
<p align="center">
 <a href="#history">History</a> •
 <a href="#objective">Objective</a> •
 <a href="#technologies">Technologies</a> •
 <a href="#how-to-run">How to run the application</a>
</p>

<h1 id="history">:book: History</h1>

:us: 

The motivation to create this project came before I joined the CBMSC technology team, when I got there, there was already this script developed by ST Duwe to backup the emergency servers of the Fire Department of the State of Santa Catarina Brazil.

The backups of the mikrotik equipment were made with scripts inside each router, sending the backup file to an FTP, making maintenance of the backups difficult since it was necessary to enter each one of them to configure or change some information, and when there was a problem with backups in the backups. we didn't know.

With the collaboration of Sgt Leonardo, even when I was still working in the CBMSC network team, we remodeled this script to back up the mikrotik using an ssh key by running the commands in shellscript in a centralized location generating reports of all backups.

Some functions were improved over time, after the backup base was working we implemented the upgrade function, so when it was necessary to update some mikrotik or just run a mass command it was only to point in the file which devices will be updated and in the other file which ones commands will be run.

I hope this script can help the linux community as it helped me understand the basics of shellscript.

:brazil:

A motivação para criar esse projeto veio antes de eu entrar para a equipe de tecnologia do CBMSC, quando cheguei lá já existia esse script desenvolvido pelo ST Duwe para fazer backup dos servidores de emergência do Corpo de Bombeiros do Estado de Santa Catarina Brasil. 

Os backups dos equipamentos mikrotiks eram feitos com scripts dentro de cada roteador enviando para um FTP o arquivo de backup, deixando a manutenção dos backups difícil pois era necessário entrar em cada um deles para configurar ou alterar alguma informação, e quando dava problemas de backup nos não ficavamos sabendo. 

Com a colaboração do Sgt Leonardo ainda quando eu ainda trabalhava na equipe de redes do CBMSC remodelamos esse script para fazer backup dos mikrotiks usando uma chave ssh rodando os comandos em shellscript em um local centralizado gerando relatório de todos os backups.

Algumas funções foram melhoradas ao longo do tempo, depois da base do backup estar funcionando implementamos a função de upgrade, para quando fosse necessário atualizar algum mikrotik ou apenas rodar um comando em massa era só apontar no arquivo quais aparelhos serão atualizados e no outro arquivo quais comandos serão rodados.

Espero que esse script possa ajudar a comunidade linux como me ajudou a entender os fundamentos de shellscript.

<h1 id="objective">:bulb: Objective</h1>

:us:

    - Create backup user into Routerboard
    - Connect with ssh key
    - Make dump Backup and Export file
    - Verify version Firmware and model
    - Run update commands.
    - Copy to server backup file
    - Send email report.

:brazil:

    - Criar usuário de backup na Routerboard
    - Conecte-se com a chave ssh
    - Fazer backup de despejo e exportar arquivo
    - Verifique a versão do firmware e modelo
    - Execute comandos de atualização.
    - Copiar para arquivo de backup do servidor
    - Enviar relatório por email.

</p>

<h1 id="technologies">:rocket: Technologies</h1>

<p>It was used these technologies in this job.</p>

- [Shell](https://en.wikipedia.org/wiki/Shell_script "shell")
- [Sendmail](http://expressjs.com/ "Sendmail")

<h1 id="how-to-run">:computer: How to run the application</h1>

<h2>Pre Requirements</h2>

<h4>You will need these tools instaled in your machine:</h4>

- [Linux](https://www.linux.com/what-is-linux/ "Linux")
- [Sendmail](https://help.dreamhost.com/hc/en-us/articles/216687518-How-do-I-use-Sendmail "Sendmail")
- [sshpass](https://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/ "sshpass")


```bash
# Clone this repository
$ git clone git@github.com:jorgediasdsg/mikrotik-backup-update.git

# Go into the folder of the project
$ cd mikrotik-backup-update

# edit enviroments **Important!**
$ vim bkmk

#If you want to run the project
/bin/bash bkmk
```
<hr>

@jorgediasdsg 2020
