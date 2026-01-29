#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Blueprint
from flask import request, render_template, redirect, abort, flash, session
from datetime import datetime

from connexion_db import get_db

client_panier = Blueprint('client_panier', __name__, template_folder='templates')

@client_panier.route('/client/panier/add', methods=['POST'])
def client_panier_add():
    mycursor = get_db().cursor()
    id_client = session['id_user']
    id_article = request.form.get('id_article')
    quantite = int(request.form.get('quantite', 1))

    # Vérifier le stock disponible
    sql = '''
        SELECT stock, prix_parfum 
        FROM parfum 
        WHERE id_parfum = %s
    '''
    mycursor.execute(sql, (id_article,))
    parfum = mycursor.fetchone()

    if parfum is None:
        flash("Parfum introuvable", "alert-danger")
        return redirect('/client/article/show')

    if parfum['stock'] < quantite:
        flash("Stock insuffisant", "alert-warning")
        return redirect('/client/article/show')

    # Vérifier si l'article est déjà dans le panier
    sql = '''
        SELECT quantite, date_ajout
        FROM ligne_panier
        WHERE utilisateur_id = %s AND parfum_id = %s
        ORDER BY date_ajout DESC
        LIMIT 1
    '''
    mycursor.execute(sql, (id_client, id_article))
    ligne_existante = mycursor.fetchone()

    if ligne_existante:
        # Mettre à jour la quantité
        nouvelle_quantite = ligne_existante['quantite'] + quantite
        sql = '''
            UPDATE ligne_panier 
            SET quantite = %s
            WHERE utilisateur_id = %s 
              AND parfum_id = %s 
              AND date_ajout = %s
        '''
        mycursor.execute(sql, (nouvelle_quantite, id_client, id_article, ligne_existante['date_ajout']))
    else:
        # Ajouter une nouvelle ligne au panier
        date_ajout = datetime.now()
        sql = '''
            INSERT INTO ligne_panier (utilisateur_id, parfum_id, date_ajout, quantite)
            VALUES (%s, %s, %s, %s)
        '''
        mycursor.execute(sql, (id_client, id_article, date_ajout, quantite))

    # Mettre à jour le stock
    sql = '''
        UPDATE parfum 
        SET stock = stock - %s 
        WHERE id_parfum = %s
    '''
    mycursor.execute(sql, (quantite, id_article))

    get_db().commit()
    flash("Parfum ajouté au panier", "alert-success")
    return redirect('/client/article/show')


@client_panier.route('/client/panier/delete', methods=['POST'])
def client_panier_delete():
    mycursor = get_db().cursor()
    id_client = session['id_user']
    id_article = request.form.get('id_article', '')

    # Sélection de la ligne du panier pour l'article et l'utilisateur connecté
    sql = '''
        SELECT quantite, date_ajout
        FROM ligne_panier
        WHERE utilisateur_id = %s AND parfum_id = %s
        ORDER BY date_ajout DESC
        LIMIT 1
    '''
    mycursor.execute(sql, (id_client, id_article))
    article_panier = mycursor.fetchone()

    if article_panier:
        if article_panier['quantite'] > 1:
            # Mise à jour de la quantité dans le panier => -1 article
            sql = '''
                UPDATE ligne_panier 
                SET quantite = quantite - 1
                WHERE utilisateur_id = %s 
                  AND parfum_id = %s 
                  AND date_ajout = %s
            '''
            mycursor.execute(sql, (id_client, id_article, article_panier['date_ajout']))
        else:
            # Suppression de la ligne de panier
            sql = '''
                DELETE FROM ligne_panier
                WHERE utilisateur_id = %s 
                  AND parfum_id = %s 
                  AND date_ajout = %s
            '''
            mycursor.execute(sql, (id_client, id_article, article_panier['date_ajout']))

        # Mise à jour du stock de l'article disponible
        sql = '''
            UPDATE parfum 
            SET stock = stock + 1 
            WHERE id_parfum = %s
        '''
        mycursor.execute(sql, (id_article,))

        get_db().commit()
        flash("Article retiré du panier", "alert-info")

    return redirect('/client/article/show')


@client_panier.route('/client/panier/vider', methods=['POST'])
def client_panier_vider():
    mycursor = get_db().cursor()
    client_id = session['id_user']

    # Sélection des lignes de panier
    sql = '''
        SELECT parfum_id, quantite, date_ajout
        FROM ligne_panier
        WHERE utilisateur_id = %s
    '''
    mycursor.execute(sql, (client_id,))
    items_panier = mycursor.fetchall()

    for item in items_panier:
        # Suppression de la ligne de panier de l'article pour l'utilisateur connecté
        sql = '''
            DELETE FROM ligne_panier
            WHERE utilisateur_id = %s 
              AND parfum_id = %s 
              AND date_ajout = %s
        '''
        mycursor.execute(sql, (client_id, item['parfum_id'], item['date_ajout']))

        # Mise à jour du stock de l'article : stock = stock + qté de la ligne pour l'article
        sql2 = '''
            UPDATE parfum 
            SET stock = stock + %s 
            WHERE id_parfum = %s
        '''
        mycursor.execute(sql2, (item['quantite'], item['parfum_id']))

    get_db().commit()
    flash("Panier vidé", "alert-info")
    return redirect('/client/article/show')


@client_panier.route('/client/panier/delete/line', methods=['POST'])
def client_panier_delete_line():
    mycursor = get_db().cursor()
    id_client = session['id_user']
    id_article = request.form.get('id_article')
    date_ajout = request.form.get('date_ajout')

    # Sélection de ligne du panier
    sql = '''
        SELECT quantite
        FROM ligne_panier
        WHERE utilisateur_id = %s 
          AND parfum_id = %s 
          AND date_ajout = %s
    '''
    mycursor.execute(sql, (id_client, id_article, date_ajout))
    ligne_panier = mycursor.fetchone()

    if ligne_panier:
        # Suppression de la ligne du panier
        sql = '''
            DELETE FROM ligne_panier
            WHERE utilisateur_id = %s 
              AND parfum_id = %s 
              AND date_ajout = %s
        '''
        mycursor.execute(sql, (id_client, id_article, date_ajout))

        # Mise à jour du stock de l'article : stock = stock + qté de la ligne pour l'article
        sql2 = '''
            UPDATE parfum 
            SET stock = stock + %s 
            WHERE id_parfum = %s
        '''
        mycursor.execute(sql2, (ligne_panier['quantite'], id_article))

        get_db().commit()
        flash("Ligne supprimée du panier", "alert-info")

    return redirect('/client/article/show')


@client_panier.route('/client/panier/filtre', methods=['POST'])
def client_panier_filtre():
    filter_word = request.form.get('filter_word', None)
    filter_prix_min = request.form.get('filter_prix_min', None)
    filter_prix_max = request.form.get('filter_prix_max', None)
    filter_types = request.form.getlist('filter_types', None)

    # Mise en session des variables de filtre
    session['filter_word'] = filter_word
    session['filter_prix_min'] = filter_prix_min
    session['filter_prix_max'] = filter_prix_max
    session['filter_types'] = filter_types

    return redirect('/client/article/show')


@client_panier.route('/client/panier/filtre/suppr', methods=['POST'])
def client_panier_filtre_suppr():
    # Suppression des variables en session
    print("suppr filtre")
    session.pop('filter_word', None)
    session.pop('filter_prix_min', None)
    session.pop('filter_prix_max', None)
    session.pop('filter_types', None)
    return redirect('/client/article/show')