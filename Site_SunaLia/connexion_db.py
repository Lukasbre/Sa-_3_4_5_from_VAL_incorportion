from flask import Flask, request, render_template, redirect, url_for, abort, flash, session, g
import os
from dotenv import load_dotenv
import pymysql.cursors

# Charger les variables du fichier .env
load_dotenv()

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        # Utilisation de os.getenv pour lire le fichier .env
        db = pymysql.connect(
            host=os.environ.get("HOST"),
            user=os.environ.get("LOGIN"),
            password=os.environ.get("PASSWORD"),
            database=os.environ.get("DATABASE"),
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        # Activation des options spécifiques (important pour les TP)
        g._database = db
        activate_db_options(db)
    return db


def activate_db_options(db):
    cursor = db.cursor()
    # Vérifier et activer l'option ONLY_FULL_GROUP_BY si nécessaire
    cursor.execute("SHOW VARIABLES LIKE 'sql_mode'")
    result = cursor.fetchone()
    if result:
        modes = result['Value'].split(',')
        if 'ONLY_FULL_GROUP_BY' not in modes:
            print('MYSQL : il manque le mode ONLY_FULL_GROUP_BY')
            cursor.execute("SET sql_mode=(SELECT CONCAT(@@sql_mode, ',ONLY_FULL_GROUP_BY'))")
            db.commit()
        else:
            print('MYSQL : mode ONLY_FULL_GROUP_BY  ok')

    # Vérifier l'option lower_case_table_names (LECTURE SEULE)
    cursor.execute("SHOW VARIABLES LIKE 'lower_case_table_names'")
    result = cursor.fetchone()
    if result:
        if result['Value'] != '0':
            print('MYSQL : ATTENTION - valeur de lower_case_table_names differente de 0')
            print('MYSQL : Cette variable ne peut être modifiée que dans my.cnf')
        else:
            print('MYSQL : variable globale lower_case_table_names=0  ok')
    cursor.close()
