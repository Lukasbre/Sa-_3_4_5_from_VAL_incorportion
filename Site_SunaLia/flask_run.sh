#!/bin/bash

# remplacer serveurmysql par localhost sur votre machine perso.
# mysql --user=login --password=secret --host=serveurmysql --database=BDD_login

# pour tester votre application, lancer la commande dans un terminal : bash flask_run.sh

source .env

echo "HOST=$HOST"
echo "LOGIN=$LOGIN"
echo "DATABASE=$DATABASE"

sed -i "s/host=.*/host=\"${HOST}\",/g" connexion_db.py
sed -i "s/user=.*/user=\"${LOGIN}\",/g" connexion_db.py
sed -i "s/password=.*/password=\"${PASSWORD}\",/g" connexion_db.py
sed -i "s/database=.*/database=\"${DATABASE}\",/g" connexion_db.py

projet=$(ls -l sae_sql.sql)
if [ $? -ne 0 ]
    then
    echo -e "\033[0;31m \n* pas de fichier sae_sql.sql \033[0m"
    nb_fic_sql=$(ls -l *.sql | wc -l)
    if [ "${nb_fic_sql}" -eq "1" ]
    then
        NOM_FIC_SQL=$(echo *.sql)
        cp "$NOM_FIC_SQL" sae_sql.sql
        echo -e "\033[0;32m \n* fichier copier $NOM_FIC_SQL sae_sql.sql \033[0m"
    else
        echo -e "\033[0;31m \n* pas de fichier ****.sql \033[0m"
        exit 2
    fi
fi


mysql --user=${LOGIN} --password=${PASSWORD} --host=${HOST} -e "DROP DATABASE IF EXISTS ${DATABASE}; CREATE DATABASE ${DATABASE};"
mysql --user=${LOGIN} --password=${PASSWORD} --host=${HOST} -e "USE ${DATABASE}; SOURCE sae_sql.sql;"


echo "mysql --user=${LOGIN} --password=${PASSWORD} --host=${HOST} ${DATABASE}" > connect.sh
chmod a+x connect.sh
# gnome-terminal --tab -- ./connect.sh  &

# xed sql_projet.sql app.py &


# python app.py
# killall python3
flask --debug  --app app  run   --host 0.0.0.0
# start http://127.0.0.1:5000
# firefox 127.0.0.1:5000

# flask --debug  --app app  run   --host 0.0.0.0
