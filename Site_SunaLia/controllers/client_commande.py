#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Blueprint
from flask import request, render_template, redirect, flash, session
from datetime import datetime
from connexion_db import get_db

client_commande = Blueprint('client_commande', __name__,
                        template_folder='templates')


# Étape 1 : afficher le récap du panier avant validation (pas d'adresse dans ce schéma)
@client_commande.route('/client/commande/valide', methods=['POST'])
def client_commande_valide():
    mycursor = get_db().cursor()
    id_client = session['id_user']

    # Sélection des articles du panier
    sql = '''
        SELECT lp.parfum_id, lp.utilisateur_id, lp.date_ajout, lp.quantite
               , p.prix_parfum AS prix
               , p.nom_parfum AS nom
               , p.stock
               , p.id_parfum AS id_article
               , p.photo AS image
        FROM ligne_panier lp
        INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
        WHERE lp.utilisateur_id = %s
        ORDER BY lp.parfum_id
    '''
    mycursor.execute(sql, (id_client,))
    articles_panier = mycursor.fetchall()

    prix_total = 0
    if articles_panier:
        sql = '''
            SELECT SUM(p.prix_parfum * lp.quantite) AS prix_total
            FROM ligne_panier lp
            INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
            WHERE lp.utilisateur_id = %s
        '''
        mycursor.execute(sql, (id_client,))
        result = mycursor.fetchone()
        prix_total = result['prix_total'] if result and result['prix_total'] is not None else 0

    # Pas de table adresse dans ce projet : on passe directement la liste vide
    adresses = []
    id_adresse_fav = 0

    return render_template('client/boutique/panier_validation_adresses.html'
                           , adresses=adresses
                           , articles_panier=articles_panier
                           , prix_total=prix_total
                           , validation=1
                           , id_adresse_fav=id_adresse_fav
                           )


# Étape 2 : créer la commande en base
@client_commande.route('/client/commande/add', methods=['POST'])
def client_commande_add():
    mycursor = get_db().cursor()
    id_client = session['id_user']

    # Sélection du contenu du panier
    sql = '''
        SELECT lp.parfum_id, lp.date_ajout, lp.quantite
               , p.prix_parfum AS prix
        FROM ligne_panier lp
        INNER JOIN parfum p ON p.id_parfum = lp.parfum_id
        WHERE lp.utilisateur_id = %s
    '''
    mycursor.execute(sql, (id_client,))
    items_ligne_panier = mycursor.fetchall()

    if not items_ligne_panier or len(items_ligne_panier) < 1:
        flash(u'Pas d\'articles dans le panier', 'alert-warning')
        return redirect('/client/article/show')

    # Création de la commande
    date_commande = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    sql = '''
        INSERT INTO commande(date_achat, utilisateur_id, etat_id)
        VALUES (%s, %s, %s)
    '''
    mycursor.execute(sql, (date_commande, id_client, 1))

    # Récupération de l'id de la commande créée
    mycursor.execute("SELECT last_insert_id() as last_insert_id")
    commande_id = mycursor.fetchone()['last_insert_id']

    # Transfert panier → ligne_commande
    for item in items_ligne_panier:
        # Suppression de la ligne de panier
        sql = '''
            DELETE FROM ligne_panier
            WHERE utilisateur_id = %s AND parfum_id = %s AND date_ajout = %s
        '''
        mycursor.execute(sql, (id_client, item['parfum_id'], item['date_ajout']))

        # Ajout en ligne_commande
        sql = '''
            INSERT INTO ligne_commande(commande_id, parfum_id, prix, quantite)
            VALUES (%s, %s, %s, %s)
        '''
        mycursor.execute(sql, (commande_id, item['parfum_id'], item['prix'], item['quantite']))

    get_db().commit()
    flash(u'Commande ajoutée avec succès', 'alert-success')
    return redirect('/client/article/show')


# Affichage des commandes du client + détail
@client_commande.route('/client/commande/show', methods=['GET', 'POST'])
def client_commande_show():
    mycursor = get_db().cursor()
    id_client = session['id_user']

    # Liste de toutes les commandes du client
    sql = '''
        SELECT c.id_commande
               , c.date_achat
               , c.etat_id
               , e.libelle
               , COUNT(lc.parfum_id) AS nbr_articles
               , SUM(lc.prix * lc.quantite) AS prix_total
        FROM commande c
        INNER JOIN etat e ON e.id_etat = c.etat_id
        LEFT JOIN ligne_commande lc ON lc.commande_id = c.id_commande
        WHERE c.utilisateur_id = %s
        GROUP BY c.id_commande, c.date_achat, c.etat_id, e.libelle
        ORDER BY c.etat_id ASC, c.date_achat DESC
    '''
    mycursor.execute(sql, (id_client,))
    commandes = mycursor.fetchall()

    articles_commande = None
    commande_adresses = None
    id_commande = request.args.get('id_commande', None)

    if id_commande is not None:
        # Détail de la commande sélectionnée
        sql = '''
            SELECT lc.commande_id
                   , lc.parfum_id
                   , lc.prix
                   , lc.quantite
                   , (lc.prix * lc.quantite) AS prix_ligne
                   , p.nom_parfum AS nom
                   , p.photo AS image
            FROM ligne_commande lc
            INNER JOIN parfum p ON p.id_parfum = lc.parfum_id
            WHERE lc.commande_id = %s
            ORDER BY p.nom_parfum
        '''
        mycursor.execute(sql, (id_commande,))
        articles_commande = mycursor.fetchall()
        # Pas de table adresse dans ce projet
        commande_adresses = None

    return render_template('client/commandes/show.html'
                           , commandes=commandes
                           , articles_commande=articles_commande
                           , commande_adresses=commande_adresses
                           )
