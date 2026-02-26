#! /usr/bin/python
# -*- coding:utf-8 -*-
import math
import os.path
from random import random

from flask import Blueprint
from flask import request, render_template, redirect, flash
#from werkzeug.utils import secure_filename

from connexion_db import get_db

admin_article = Blueprint('admin_article', __name__,
                          template_folder='templates')


@admin_article.route('/admin/article/show')
def show_article():
    mycursor = get_db().cursor()
    sql = '''
        SELECT p.id_parfum      AS id_article
             , p.nom_parfum     AS nom
             , p.prix_parfum    AS prix
             , p.stock
             , p.photo          AS image
             , p.marque         AS libelle
             , p.type_parfum_id AS type_article_id
        FROM parfum p
        ORDER BY p.nom_parfum
    '''
    mycursor.execute(sql)
    articles = mycursor.fetchall()
    return render_template('admin/article/show_article.html', articles=articles)


@admin_article.route('/admin/article/add', methods=['GET'])
def add_article():
    mycursor = get_db().cursor()
    sql = "SELECT id_type_parfum AS id_type_article, type_parfum_libelle AS libelle FROM type_parfum ORDER BY type_parfum_libelle"
    mycursor.execute(sql)
    types_article = mycursor.fetchall()
    return render_template('admin/article/add_article.html', types_article=types_article)


@admin_article.route('/admin/article/add', methods=['POST'])
def valid_add_article():
    mycursor = get_db().cursor()

    nom = request.form.get('nom', '')
    type_article_id = request.form.get('type_article_id', '')
    prix = request.form.get('prix', '')
    description = request.form.get('description', '')
    marque = request.form.get('marque', '')
    stock = request.form.get('stock', 0)
    image = request.files.get('image', '')

    if image and image.filename:
        filename = 'img_upload' + str(int(2147483647 * random())) + '.png'
        image.save(os.path.join('static/images/', filename))
    else:
        filename = None

    sql = '''
        INSERT INTO parfum(nom_parfum, photo, prix_parfum, type_parfum_id, description, marque, stock)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    '''
    tuple_add = (nom, filename, prix, type_article_id, description, marque, stock)
    mycursor.execute(sql, tuple_add)
    get_db().commit()

    flash(u'Article ajouté : ' + nom, 'alert-success')
    return redirect('/admin/article/show')


@admin_article.route('/admin/article/delete', methods=['GET'])
def delete_article():
    id_article = request.args.get('id_article')
    mycursor = get_db().cursor()

    # Vérifier s'il y a des lignes de commande liées
    sql = "SELECT COUNT(*) AS nb FROM ligne_commande WHERE parfum_id = %s"
    mycursor.execute(sql, (id_article,))
    result = mycursor.fetchone()
    if result['nb'] > 0:
        flash(u'Cet article est lié à des commandes : vous ne pouvez pas le supprimer', 'alert-warning')
        return redirect('/admin/article/show')

    # Récupérer l'image avant suppression
    sql = "SELECT photo AS image FROM parfum WHERE id_parfum = %s"
    mycursor.execute(sql, (id_article,))
    article = mycursor.fetchone()

    sql = "DELETE FROM parfum WHERE id_parfum = %s"
    mycursor.execute(sql, (id_article,))
    get_db().commit()

    if article and article['image']:
        img_path = 'static/images/' + article['image']
        if os.path.exists(img_path):
            os.remove(img_path)

    flash(u'Article supprimé, id : ' + str(id_article), 'alert-success')
    return redirect('/admin/article/show')


@admin_article.route('/admin/article/edit', methods=['GET'])
def edit_article():
    id_article = request.args.get('id_article')
    mycursor = get_db().cursor()

    sql = '''
        SELECT id_parfum AS id_article, nom_parfum AS nom, prix_parfum AS prix,
               stock, photo AS image, description, marque, type_parfum_id AS type_article_id
        FROM parfum WHERE id_parfum = %s
    '''
    mycursor.execute(sql, (id_article,))
    article = mycursor.fetchone()

    sql = "SELECT id_type_parfum AS id_type_article, type_parfum_libelle AS libelle FROM type_parfum ORDER BY type_parfum_libelle"
    mycursor.execute(sql)
    types_article = mycursor.fetchall()

    return render_template('admin/article/edit_article.html',
                           article=article,
                           types_article=types_article)


@admin_article.route('/admin/article/edit', methods=['POST'])
def valid_edit_article():
    mycursor = get_db().cursor()
    nom = request.form.get('nom')
    id_article = request.form.get('id_article')
    image = request.files.get('image', '')
    type_article_id = request.form.get('type_article_id', '')
    prix = request.form.get('prix', '')
    description = request.form.get('description')
    marque = request.form.get('marque', '')

    # Récupérer l'image actuelle
    sql = "SELECT photo AS image FROM parfum WHERE id_parfum = %s"
    mycursor.execute(sql, (id_article,))
    row = mycursor.fetchone()
    image_nom = row['image'] if row else None

    if image and image.filename:
        if image_nom and os.path.exists(os.path.join('static/images/', image_nom)):
            os.remove(os.path.join('static/images/', image_nom))
        filename = 'img_upload_' + str(int(2147483647 * random())) + '.png'
        image.save(os.path.join('static/images/', filename))
        image_nom = filename

    sql = '''
        UPDATE parfum
        SET nom_parfum = %s, photo = %s, prix_parfum = %s,
            type_parfum_id = %s, description = %s, marque = %s
        WHERE id_parfum = %s
    '''
    mycursor.execute(sql, (nom, image_nom, prix, type_article_id, description, marque, id_article))
    get_db().commit()

    flash(u'Article modifié : ' + nom, 'alert-success')
    return redirect('/admin/article/show')


@admin_article.route('/admin/article/stock/edit', methods=['POST'])
def admin_article_stock_edit():
    """Modification du stock d'un article depuis l'interface admin."""
    mycursor = get_db().cursor()
    id_article = request.form.get('id_article')
    nouveau_stock = request.form.get('stock', '0')

    if not id_article:
        flash(u'Données manquantes pour la modification du stock', 'alert-warning')
        return redirect('/admin/article/show')

    sql = "UPDATE parfum SET stock = %s WHERE id_parfum = %s"
    mycursor.execute(sql, (nouveau_stock, id_article))
    get_db().commit()

    flash(u'Stock mis à jour : ' + str(nouveau_stock) + ' unités', 'alert-success')
    return redirect('/admin/article/show')


@admin_article.route('/admin/article/avis/<int:id>', methods=['GET'])
def admin_avis(id):
    mycursor = get_db().cursor()
    article = []
    commentaires = {}
    return render_template('admin/article/show_avis.html',
                           article=article,
                           commentaires=commentaires)


@admin_article.route('/admin/comment/delete', methods=['POST'])
def admin_avis_delete():
    mycursor = get_db().cursor()
    article_id = request.form.get('idArticle', None)
    userId = request.form.get('idUser', None)
    return admin_avis(article_id)
