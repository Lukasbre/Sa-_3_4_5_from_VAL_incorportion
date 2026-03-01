#! /usr/bin/python
# -*- coding:utf-8 -*-
from flask import Blueprint
from flask import request, render_template, redirect, flash, session

from connexion_db import get_db

admin_commande = Blueprint('admin_commande', __name__,
                        template_folder='templates')

@admin_commande.route('/admin')
@admin_commande.route('/admin/commande/index')
def admin_index():
    return render_template('admin/layout_admin.html')


@admin_commande.route('/admin/commande/show', methods=['GET', 'POST'])
def admin_commande_show():
    mycursor = get_db().cursor()

    # Toutes les commandes avec infos client, état, nbr articles, coût total
    sql = '''
        SELECT c.id_commande
               , c.date_achat
               , c.etat_id
               , e.libelle
               , u.login
               , SUM(lc.quantite) AS nbr_articles
               , SUM(lc.prix * lc.quantite) AS prix_total
        FROM commande c
        INNER JOIN etat e ON e.id_etat = c.etat_id
        INNER JOIN utilisateur u ON u.id_utilisateur = c.utilisateur_id
        LEFT JOIN ligne_commande lc ON lc.commande_id = c.id_commande
        GROUP BY c.id_commande, c.date_achat, c.etat_id, e.libelle, u.login
        ORDER BY c.etat_id ASC, c.date_achat DESC
    '''
    mycursor.execute(sql)
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
                   , c.etat_id
                   , c.id_commande AS id
            FROM ligne_commande lc
            INNER JOIN parfum p ON p.id_parfum = lc.parfum_id
            INNER JOIN commande c ON c.id_commande = lc.commande_id
            WHERE lc.commande_id = %s
            ORDER BY p.nom_parfum
        '''
        mycursor.execute(sql, (id_commande,))
        articles_commande = mycursor.fetchall()
        # Pas de table adresse dans ce projet
        commande_adresses = None

    return render_template('admin/commandes/show.html'
                           , commandes=commandes
                           , articles_commande=articles_commande
                           , commande_adresses=commande_adresses
                           )


@admin_commande.route('/admin/commande/valider', methods=['GET', 'POST'])
def admin_commande_valider():
    mycursor = get_db().cursor()
    commande_id = request.form.get('id_commande', None)
    if commande_id is not None:
        # Passage de l'état 1 (en cours) → 2 (expédié)
        sql = '''
            UPDATE commande
            SET etat_id = 2
            WHERE id_commande = %s AND etat_id = 1
        '''
        mycursor.execute(sql, (commande_id,))
        get_db().commit()
        flash(u'Commande expédiée', 'alert-success')
    return redirect('/admin/commande/show')
