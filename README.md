# Vorbereitungen #
Installieren von Webserver, PHP und Datenbank.
`sudo apt-get install apache2 php5 mysql-server php5-mysql curl`

Um zu überprüfen ob die Installation von PHP erfolgreich ist es nur notwendig eine PHP - Datei zu erstellen mit folgendem Inhalt.
Dazu erstellen wir noch das Verzeichnis 'Verwaltungskonsole'
`sudo mkdir /var/www/html/verwaltungskonsole`

Danach wird die Datei erstellt.
`sudo touch /var/www/html/verwaltungskonsole/phpinfo.php`

Nun noch folgendes in die Datei schreiben:
`<?php
`phpinfo();
`?>```

Da wir nun wissen das PHP funktioniert müssen wir noch Composer installieren um es nachher einfacher mit dem PHP - Framework zu haben. 
Dazu einfach den folgenden Befehl in das Terminal kopieren und ausführen:
`curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer`
Nach der Ausführung des Befehls sollte ein ähnlicher Output erscheinen:
`#!/usr/bin/env php
`All settings correct for using Composer
`Downloading...
`
`Composer successfully installed to: /usr/local/bin/composer
`Use it: php /usr/local/bin/composer```

Um zu überprüfen ob die Installation funktioniert hat einfach mal `composer` eingeben im Terminal.
Der Output sollte wie folgt aussehen:

`   ______
`  / ____/___  ____ ___  ____  ____  ________  _____
` / /   / __ \/ __ `__ \/ __ \/ __ \/ ___/ _ \/ ___/
`/ /___/ /_/ / / / / / / /_/ / /_/ (__  )  __/ /
`\____/\____/_/ /_/ /_/ .___/\____/____/\___/_/
`                    /_/
`Composer version 1.0-dev (9859859f1082d94e546aa75746867df127aa0d9e) 2015-08-17 14:57:00
`
`Usage:
` command [options] [arguments]
`
`Options:
` --help (-h)           Display this help message
` --quiet (-q)          Do not output any message
` --verbose (-v|vv|vvv) Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug
` --version (-V)        Display this application version
` --ansi                Force ANSI output
` --no-ansi             Disable ANSI output
` --no-interaction (-n) Do not ask any interactive question
` --profile             Display timing and memory usage information
` --working-dir (-d)    If specified, use the given directory as working directory.
`
`. . .
```


# Installieren von Fat Free Framework #
Da wir nun alle Vorbereitungen abegschlossen haben können wir uns daran machen das Framework zu installieren.
Dazu wechseln wir in unser Verzeichnis:
`cd /var/www/html/verwaltungskonsole`

Nun geben wir ins Terminal `sudo composer init` ein.
Als erstes werden wir nach dem 'Package name' gefragt. Dort geben wir folgendes ein 'it4s/verwaltungskonsole'.
Die 'Description' können wir überspringen. Wer etwas eingeben möchte kann 'Verwaltungskonsole fuer ThinClients' eingeben.
Also 'Author' gebt ihr euren Namen und Mailadresse ein, nach folgendem Format: 'Raphael Lekies <raphael.lekies@it4s.eu>'.
Die nächsten Schritte können übersprungen werden in dem sie einfach mit 'ENTER' bestätigt werden.
Bei der Frage 'Would you like to define your dependencies (require) interactively [yes]?' muss 'yes' eingegeben werden.
Die Frage 'Would you like to define your dev dependencies (require-dev) interactively [yes]?' ist 'no' einzugeben.
'Do you confirm generation [yes]?' hier ist zwingend 'yes' einzugeben, da wir ja wollen das alles was wir eingegeben haben auch gespeichert wird.

Nun öffnen wir die Datei 'composer.json'. Dort steht erstmal nur '"require": {}'. Das ändern wir nun und fügen dort '"bcosca/fatfree": "3.5.0"' hinzu.
Die Datei sieht dann wie folgt aus:
`{
`    "name": "takacsmark/fatfreetutorial1",
`    "authors": [
`        {
`            "name": "Mark Takacs",
`            "email": "youremail@xxx.com"
`        }
`    ],
`    "require": {
`    	"bcosca/fatfree": "3.5.0"
`    }
`}
```
Zum Abschluss führen wir noch den Befehl `sudo composer update` auf dem Terminal durch. Nun sollte das Framework heruntergeladen und installiert werden von composer.

Um zu sehen ob auch alles funktioniert hat erstellen wir die Datei 'index.php' und fügen folgendes ein:
`<?php
` 
`require_once("vendor/autoload.php");
` 
`$f3 = Base::instance();
` 
`$f3->route('GET /',
`		function() {
`			echo 'Hello world!';
`		} 
`);
` 
`$f3->run();


# Installieren von Bootstrap #
Als erstes laden wir das Framework von Github herunter. 
`wget https://github.com/twbs/bootstrap/releases/download/v3.3.6/bootstrap-3.3.6-dist.zip`
Danach entpacken wir es mit unzip
`unzip bootstrap-3.3.6-dist.zip`
Wir haben ja vorher in unserem Projektverzeichnis die Struktur erstellt:
app
|_controllers
|_models
|_views
|_css
|_js
|_fonts

Wir kopieren nun aus dem Verzeichnis 'bootstrtap-3.3.36-dist' den Inhalt in die neue Verzeichnisstrukur
`sudo mv * /var/www/html/verwaltungskonsole/app/`

# Dependencies #
bootstrap-datetimepicker (v4.17.43) https://github.com/Eonasdan/bootstrap-datetimepicker
fontawesome (v4.6.3)

# Dokumentation #
Die Dokumentation findet nach dem Prinzip von Doxygen statt. 
Es kann unter umständen auch mit LaTex gearbeitet werden als Sprache.
In diesem Artikel ist ausführlich beschrieben wie Code zu dokumentieren ist: 
* http://www.stack.nl/~dimitri/doxygen/manual/docblocks.html
* https://code.google.com/p/agiletracking/wiki/DoxygenSyntax


# Todo #
## Device ##
Dem Gerät muss noch die Option gegeben werden DHCP oder Static für die IP / Gateway und Netmask einzustellen.

## Profile ##
Beim mergen aller Profile muss entweder ein RDP oder Citrix eintrag vorhanden sein, sonst kann nichts an das Gerät übertragen werden.

## System ##
Backup der Datenbank auf FTP / Samba-share.
Einstellbar in welchem Zeitintervall die Backups erstellt werden.
