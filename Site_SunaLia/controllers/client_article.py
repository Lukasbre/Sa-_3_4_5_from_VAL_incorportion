#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Blueprint
from flask import Flask, request, render_template, redirect, abort, flash, session

from connexion_db import get_db

client_article = Blueprint('client_article', __name__, template_folder='templates')

@client_article.route('/client/index')
@client_article.route('/client/article/show')
def client_article_show():
    mycursor = get_db().cursor()
    id_client = session['id_user']

    # Sélection des articles avec gestion du filtre
    sql = '''
        SELECT p.id_parfum AS id_article
               , p.nom_parfum AS nom
               , p.prix_parfum AS prix
               , p.stock AS stock
               , p.description
               , p.photo
               , v.nom_volume AS libelle_volume
               , g.nom_genre AS libelle_genre
               , m.nom_marque AS libelle_marque
        FROM parfum p
        LEFT JOIN volume v ON v.id_volume = p.volume_id
        LEFT JOIN genre g ON g.id_genre = p.genre_id
        LEFT JOIN marque m ON m.id_marque = p.marque_id
        WHERE 1=1
    '''

    list_param = []
    condition_and = ""

    # Utilisation du filtre par marque
    id_marque = request.args.get('id_marque', None)
    if id_marque is not None and id_marque != '':
        condition_and += " AND p.marque_id = %s"
        list_param.append(id_marque)

    sql += condition_and
    sql += " ORDER BY p.nom_parfum"

    # Exécution de la requête avec les paramètres
    if len(list_param) > 0:
        mycursor.execute(sql, tuple(list_param))
    else:
        mycursor.execute(sql)

    articles = mycursor.fetchall()

    # Récupération des marques pour le filtre
    sql = '''
        SELECT id_marque AS id_type_article
               , nom_marque AS libelle            
        FROM marque
        ORDER BY nom_marque
    '''
    mycursor.execute(sql)
    types_article = mycursor.fetchall()

    # Récupération du panier de l'utilisateur
    sql = '''
        SELECT lp.parfum_id, lp.utilisateur_id, lp.date_ajout, lp.quantite
               , p.prix_parfum AS prix
               , p.nom_parfum AS nom
               , p.stock
               , p.id_parfum AS id_article
               , p.photo
               , v.nom_volume AS libelle_volume
               , v.id_volume
               , g.nom_genre AS libelle_genre
               , g.id_genre
               , m.nom_marque AS libelle_marque
        FROM ligne_panier lp
        INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
        LEFT JOIN volume v ON v.id_volume = p.volume_id
        LEFT JOIN genre g ON g.id_genre = p.genre_id
        LEFT JOIN marque m ON m.id_marque = p.marque_id
        WHERE lp.utilisateur_id = %s
        ORDER BY lp.parfum_id
    '''
    mycursor.execute(sql, (id_client,))
    articles_panier = mycursor.fetchall()

    # Calcul du prix total du panier
    if len(articles_panier) >= 1:
        sql = '''
            SELECT SUM(p.prix_parfum * lp.quantite) AS prix_total
            FROM ligne_panier lp
            INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
            WHERE lp.utilisateur_id = %s
        '''
        mycursor.execute(sql, (id_client,))
        result = mycursor.fetchone()
        prix_total = result['prix_total'] if result['prix_total'] is not None else 0
    else:
        prix_total = None

    return render_template('client/boutique/panier_article.html', articles=articles, articles_panier=articles_panier, prix_total=prix_total, items_filtre=types_article)