#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Blueprint
from flask import request, render_template, redirect, session

from connexion_db import get_db

client_article = Blueprint('client_article', __name__, template_folder='templates')

@client_article.route('/client/index')
@client_article.route('/client/article/show')
def client_article_show():
    mycursor = get_db().cursor()
    id_client = session['id_user']

    # 1. Sélection des articles avec tous les filtres
    sql = '''
        SELECT p.id_parfum AS id_article
               , p.nom_parfum AS nom
               , p.prix_parfum AS prix
               , p.stock AS stock
               , p.description
               , p.photo AS image
               , v.nom_volume AS libelle_volume
               , g.nom_genre AS libelle_genre
               , p.marque AS libelle_marque
        FROM parfum p
        LEFT JOIN volume v ON v.id_volume = p.volume_id
        LEFT JOIN genre g ON g.id_genre = p.genre_id
        WHERE 1=1
    '''

    list_param = []

    # Filtre par mot-clé (depuis session)
    if session.get('filter_word'):
        sql += " AND p.nom_parfum LIKE %s"
        list_param.append(f"%{session['filter_word']}%")

    # Filtre par prix minimum (depuis session)
    if session.get('filter_prix_min'):
        sql += " AND p.prix_parfum >= %s"
        list_param.append(session['filter_prix_min'])

    # Filtre par prix maximum (depuis session)
    if session.get('filter_prix_max'):
        sql += " AND p.prix_parfum <= %s"
        list_param.append(session['filter_prix_max'])

    # Filtre par marque (depuis URL - pour compatibilité)
    filter_marque = request.args.get('filter_marque', None)
    if filter_marque is not None and filter_marque != '':
        sql += " AND p.marque = %s"
        list_param.append(filter_marque)

    # Filtre par types (depuis session)
    if session.get('filter_types'):
        filter_types = session['filter_types']
        if filter_types and len(filter_types) > 0:
            placeholders = ', '.join(['%s'] * len(filter_types))
            sql += f" AND p.marque IN ({placeholders})"
            list_param.extend(filter_types)

    # Filtre par genre (depuis session)
    if session.get('filter_genres'):
        filter_genres = session['filter_genres']
        if filter_genres and len(filter_genres) > 0:
            placeholders = ', '.join(['%s'] * len(filter_genres))
            sql += f" AND p.genre_id IN ({placeholders})"
            list_param.extend(filter_genres)

    # Filtre par types de parfum (depuis session)
    if session.get('filter_types_parfum'):
        filter_types_parfum = session['filter_types_parfum']
        if filter_types_parfum and len(filter_types_parfum) > 0:
            placeholders = ', '.join(['%s'] * len(filter_types_parfum))
            sql += f" AND p.type_parfum_id IN ({placeholders})"
            list_param.extend(filter_types_parfum)

    sql += " ORDER BY p.nom_parfum"

    # Exécution de la requête
    if len(list_param) > 0:
        mycursor.execute(sql, tuple(list_param))
    else:
        mycursor.execute(sql)
    articles = mycursor.fetchall()

    # 2. Récupération des marques uniques pour le filtre
    sql_marques = '''
        SELECT DISTINCT marque AS id_type_article
               , marque AS libelle            
        FROM parfum
        WHERE marque IS NOT NULL AND marque != ''
        ORDER BY marque
    '''
    mycursor.execute(sql_marques)
    types_article = mycursor.fetchall()

    sql_genres = '''
                 SELECT id_genre, nom_genre
                 FROM genre
                 ORDER BY nom_genre \
                 '''
    mycursor.execute(sql_genres)
    genres = mycursor.fetchall()

    sql_types_parfum = '''
        SELECT id_type_parfum, type_parfum_libelle
        FROM type_parfum
        ORDER BY type_parfum_libelle
    '''
    mycursor.execute(sql_types_parfum)
    types_parfum = mycursor.fetchall()

    # 3. Récupération du panier
    sql_panier = '''
        SELECT lp.parfum_id, lp.utilisateur_id, lp.date_ajout, lp.quantite
               , p.prix_parfum AS prix
               , p.nom_parfum AS nom
               , p.stock
               , p.id_parfum AS id_article
               , p.photo AS image
               , p.description
               , v.nom_volume AS libelle_volume
               , g.nom_genre AS libelle_genre
               , p.marque AS libelle_marque
               , (p.prix_parfum * lp.quantite) AS sous_total
        FROM ligne_panier lp
        INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
        LEFT JOIN volume v ON v.id_volume = p.volume_id
        LEFT JOIN genre g ON g.id_genre = p.genre_id
        WHERE lp.utilisateur_id = %s
        ORDER BY lp.parfum_id
    '''
    mycursor.execute(sql_panier, (id_client,))
    articles_panier = mycursor.fetchall()

    # 4. Calcul du prix total du panier
    prix_total = 0
    if articles_panier:
        sql_total = '''
            SELECT SUM(p.prix_parfum * lp.quantite) AS prix_total
            FROM ligne_panier lp
            INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
            WHERE lp.utilisateur_id = %s
        '''
        mycursor.execute(sql_total, (id_client,))
        result = mycursor.fetchone()
        prix_total = result['prix_total'] if result and result['prix_total'] is not None else 0

    return render_template('client/boutique/panier_article.html',
                           articles=articles,
                           articles_panier=articles_panier,
                           prix_total=prix_total,
                           items_filtre=types_article,
                           types_articles=types_article,
                           genres=genres,
                           types_parfum=types_parfum)