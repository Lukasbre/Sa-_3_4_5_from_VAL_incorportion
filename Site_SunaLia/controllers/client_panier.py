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
    mycursor.execute("SELECT stock, prix_parfum FROM parfum WHERE id_parfum = %s", (id_article,))
    parfum = mycursor.fetchone()

    if parfum is None:
        flash("Parfum introuvable", "alert-danger")
        return redirect('/client/article/show')

    if parfum['stock'] < quantite:
        flash("Stock insuffisant", "alert-warning")
        return redirect('/client/article/show')

    # Vérifier si l'article est déjà dans le panier
    sql = "SELECT quantite FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
    mycursor.execute(sql, (id_client, id_article))
    ligne_existante = mycursor.fetchone()

    if ligne_existante:
        # Mettre à jour la quantité
        nouvelle_quantite = ligne_existante['quantite'] + quantite
        sql = "UPDATE ligne_panier SET quantite = %s WHERE utilisateur_id = %s AND parfum_id = %s"
        mycursor.execute(sql, (nouvelle_quantite, id_client, id_article))
    else:
        # Ajouter une nouvelle ligne au panier
        date_ajout = datetime.now()
        sql = "INSERT INTO ligne_panier (utilisateur_id, parfum_id, date_ajout, quantite) VALUES (%s, %s, %s, %s)"
        mycursor.execute(sql, (id_client, id_article, date_ajout, quantite))

    # Décrémenter le stock
    sql = "UPDATE parfum SET stock = stock - %s WHERE id_parfum = %s"
    mycursor.execute(sql, (quantite, id_article))

    get_db().commit()
    flash("Parfum ajouté au panier", "alert-success")
    return redirect('/client/article/show')


@client_panier.route('/client/panier/delete', methods=['POST'])
def client_panier_delete():
    """Retire 1 unité de l'article du panier (bouton -)"""
    mycursor = get_db().cursor()
    id_client = session['id_user']
    id_article = request.form.get('id_article', '')

    sql = "SELECT quantite FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
    mycursor.execute(sql, (id_client, id_article))
    article_panier = mycursor.fetchone()

    if article_panier:
        if article_panier['quantite'] > 1:
            sql = "UPDATE ligne_panier SET quantite = quantite - 1 WHERE utilisateur_id = %s AND parfum_id = %s"
            mycursor.execute(sql, (id_client, id_article))
        else:
            sql = "DELETE FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
            mycursor.execute(sql, (id_client, id_article))

        # Remettre 1 unité en stock
        sql = "UPDATE parfum SET stock = stock + 1 WHERE id_parfum = %s"
        mycursor.execute(sql, (id_article,))

        get_db().commit()
        flash("Article retiré du panier", "alert-info")

    return redirect('/client/article/show')


@client_panier.route('/client/panier/vider', methods=['POST'])
def client_panier_vider():
    mycursor = get_db().cursor()
    client_id = session['id_user']

    sql = "SELECT parfum_id, quantite FROM ligne_panier WHERE utilisateur_id = %s"
    mycursor.execute(sql, (client_id,))
    items_panier = mycursor.fetchall()

    for item in items_panier:
        sql = "DELETE FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
        mycursor.execute(sql, (client_id, item['parfum_id']))
        sql2 = "UPDATE parfum SET stock = stock + %s WHERE id_parfum = %s"
        mycursor.execute(sql2, (item['quantite'], item['parfum_id']))

    get_db().commit()
    flash("Panier vidé", "alert-info")
    return redirect('/client/article/show')


@client_panier.route('/client/panier/delete/line', methods=['POST'])
def client_panier_delete_line():
    """Supprime entièrement la ligne de l'article dans le panier (bouton Supprimer)"""
    mycursor = get_db().cursor()
    id_client = session['id_user']
    id_article = request.form.get('id_article')

    sql = "SELECT quantite FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
    mycursor.execute(sql, (id_client, id_article))
    ligne_panier = mycursor.fetchone()

    if ligne_panier:
        sql = "DELETE FROM ligne_panier WHERE utilisateur_id = %s AND parfum_id = %s"
        mycursor.execute(sql, (id_client, id_article))

        # Remettre toute la quantité en stock
        sql2 = "UPDATE parfum SET stock = stock + %s WHERE id_parfum = %s"
        mycursor.execute(sql2, (ligne_panier['quantite'], id_article))

        get_db().commit()
        flash("Article supprimé du panier", "alert-info")

    return redirect('/client/article/show')


@client_panier.route('/client/panier/filtre', methods=['POST'])
def client_panier_filtre():
    filter_word = request.form.get('filter_word', None)
    filter_prix_min = request.form.get('filter_prix_min', None)
    filter_prix_max = request.form.get('filter_prix_max', None)
    filter_types = request.form.getlist('filter_types')

    session['filter_word'] = filter_word
    session['filter_prix_min'] = filter_prix_min
    session['filter_prix_max'] = filter_prix_max
    session['filter_types'] = filter_types

    return redirect('/client/article/show')


@client_panier.route('/client/panier/filtre/suppr', methods=['POST'])
def client_panier_filtre_suppr():
    session.pop('filter_word', None)
    session.pop('filter_prix_min', None)
    session.pop('filter_prix_max', None)
    session.pop('filter_types', None)
    return redirect('/client/article/show')
