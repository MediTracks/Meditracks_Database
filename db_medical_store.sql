use master
go
if exists(select * from sys.databases where name='db_meditracks')
drop database db_meditracks
go
create database db_meditracks
go
use db_meditracks

--------------------------------------------- Codes Province --------------------------------------------------------
go
create table t_province
(
	id_province nvarchar(50),
	description_province nvarchar(50),
	constraint pk_province primary key(id_province)
)
go
create procedure afficher_province
as
	select top 50 
		id_province as 'Province', 
		description_province as 'Description'
	from t_province
		order by id_province asc
go
------------------------procedure enregistrer_province
go
create procedure enregistrer_province
(
	@id_province nvarchar(50),
	@description_province nvarchar(50)
)
as
begin
	if not exists(select * from t_province where id_province = @id_province)
		insert into t_province values(@id_province, @description_province)
	else
	update t_province set description_province = @description_province where id_province = @id_province
end
---------------------procedure recuperer_province

go
create procedure recuperer_province
as
	select id_province from t_province
		order by id_province asc

---------------------procedure supprimer_province
go
create procedure supprimer_province
@id_province nvarchar(50)
as
	delete from t_province
		where
			id_province=@id_province
------------------------------------------ fin codes province-------------------------------------------------------
---------------------------------------------- Codes Ville ---------------------------------------------------------

go
create table t_ville
(
	id_ville nvarchar(50),
	description_ville nvarchar(50),
	id_province nvarchar(50),
	constraint pk_ville primary key(id_ville),
	constraint fk_province_ville foreign key(id_province) references t_province(id_province) on delete cascade on update cascade
)
go
-------------------------------------------------procedure enregistrer_ville----------------------------------------
create procedure afficher_ville
as
	select top 50
		id_ville as 'Ville',
		description_ville as 'Description',
		id_province as 'Province'
	from t_ville
	order by id_ville asc
go
create procedure recuperer_ville
as
	select 
		id_ville 
	from
		t_ville
	order by id_ville asc
go
create procedure enregistrer_ville
(
	@id_ville nvarchar(50),
	@description_ville nvarchar(50),
	@province nvarchar(50)
)
as
begin
	declare @id_province nvarchar(50) = (select id_province from t_province where description_province = @province)
	if not exists (select * from t_ville where id_ville = @id_ville)
		insert into t_ville values (@id_ville, @description_ville, @id_province)
	else
		update t_ville set description_ville = @description_ville, id_province = @id_province where id_ville = @id_ville
end
go
---------- procedure supprimer_ville
go
create procedure supprimer_ville
@id_ville nvarchar(50)
as
	delete from t_ville
		where
			id_ville=@id_ville
go			
-------------------------------Fin Codes Villes---------------------------------------------------
--------------------------------------Codes Zones-------------------------------------------------
create table t_zone
(
	id_zone nvarchar(50),
	descr_zone nvarchar(50),
	adresse nvarchar(100),
	telephone nvarchar(50),
	id_ville nvarchar(50),
	constraint pk_primary primary key(id_zone),
	constraint fk_zone_ville foreign key(id_ville) references t_ville(id_ville) on delete cascade on update cascade
)
go
------------------------------procedure afficher_zone----------------------------------------------
create procedure afficher_zone
as
	select top 50 id_zone as 'code zone', descr_zone as 'description', adresse as 'adresse', telephone as 'telephone', id_ville as 'ville'  
	from t_zone
		order by id_ville asc, id_zone asc
go
-------------------------------procedure enregistrer_zone-------------------------------------------
create procedure enregistrer_zone
@id_zone nvarchar(50),
@descr_zone nvarchar(50),
@adresse nvarchar(100),
@telephone nvarchar(50),
@ville nvarchar(50)
as
	declare @id_ville nvarchar(50) = (select id_ville from t_ville where description_ville = @ville)
	merge into t_zone
	using (select @id_zone as x_id) as x_source
		on(x_source.x_id = t_zone.id_zone)
			when matched then
			 update set 
				descr_zone=@descr_zone,
				adresse=@adresse,
				telephone=@telephone,
				id_ville=@id_ville
			when not matched then
				insert 
					(id_zone, descr_zone, adresse, telephone, id_ville)
				values
					(@id_zone, @descr_zone, @adresse, @telephone, @id_ville);
go
create procedure supprimer_zone
@id_zone nvarchar(50)
as
	delete from t_zone
		where
			id_zone=@id_zone
go
create procedure recuperer_zone
@id_ville nvarchar(50)
as
	select 
		id_zone 
	from t_zone
		where
			id_ville like @id_ville
		order by id_zone asc
go
-----------------------------------Fin Codes Zone--------------------------------------------------
-----------------------------------Debut Codes Structure-------------------------------------------
create table t_structure
(
	id_structure nvarchar(50),
	descr_structure nvarchar(50),
	adresse nvarchar(50),
	telephone nvarchar(50),
	id_zone nvarchar(50),
	constraint pk_structure primary key(id_structure),
	constraint fk_structure_zone foreign key(id_zone) references t_zone(id_zone) on delete cascade on update cascade
)
----------------- procedure afficher_structure------------------------------------------------------
go
create procedure afficher_structure
as
	select top 50 id_structure as 'ID Structure', descr_structure as 'description', adresse as 'adresse', telephone as 'telephone', id_zone as 'Zone de Sante'  
	from t_structure
		order by id_structure asc

------------------ procedure enregistrer_structure

go
create procedure enregistrer_structure
@id_structure nvarchar(50),
@descr_structure nvarchar(50),
@adresse nvarchar(50),
@telephone nvarchar(50),
@zone nvarchar(50)
as
	declare @id_zone nvarchar(50) = (select id_zone from t_zone where descr_zone = @zone)
	merge into t_structure
	using (select @id_structure as x_id) as x_source
		on(x_source.x_id = t_structure.id_structure)
			when matched then
			 update set
				descr_structure=@descr_structure,
				adresse=@adresse,
				telephone=@telephone,
				id_zone=@id_zone
			when not matched then
				insert 
					(id_structure, descr_structure, adresse, telephone, id_zone)
				values
					(@id_structure, @descr_structure, @adresse, @telephone, @id_zone);


--------------------procedure supprimer_structure
go

create procedure supprimer_structure
	@id_structure nvarchar(50)
as
	delete from t_structure
		where
			id_structure=@id_structure

-----------------procedure recuperer_structure

go
create procedure recuperer_structure
@id_zone nvarchar(50)
as
	select id_structure  from t_structure
	where
		id_zone like @id_zone
	order by id_structure asc
go
-----------------------------les recherches structures-zone-ville

go
create procedure recuperer_ville_parID_province
@id_province nvarchar(50)
as
	select id_ville from t_ville
		where
			id_province like id_province
				order by id_ville asc

-------------------------------
go
create procedure recuperer_zone_parID_ville
@id_ville nvarchar(50)
as
select id_zone from t_zone
	where
		id_ville like @id_ville

--------------------------
go
create procedure recuperer_structure_parID_zone
@id_zone nvarchar(50)
as
	select id_structure from t_structure
		where
			id_zone=@id_zone
				order by 
					id_zone asc
-------------------------------- Fin des codes Structures--------------------------------------------------
go
create table t_effectifs
(
	id_effectif int identity,
	id_structure nvarchar(50),
	nbre_hommes int,
	nbre_femmes int,	
	date_enregistrement date,
	nbre_total int,
	constraint pk_effectif primary key(id_effectif),
	constraint fk_structure_effectif foreign key(id_structure) references t_structure(id_structure) on delete cascade on update cascade
)
go
create procedure afficher_effectifs
as
	select top 50 
		id_effectif as 'ID',
		id_structure as 'Structure',
		nbre_hommes as 'Hommes',
		nbre_femmes as 'Femmes',
		date_enregistrement as 'Date',
		nbre_total as 'Total'
	from t_effectifs
		order by
			date_enregistrement desc,
			id_effectif desc
go
create procedure inserer_effectif
@id_structure nvarchar(50),
@nbre_hommes int,
@nbre_femmes int
as
	insert into t_effectifs
		(id_structure, nbre_hommes, nbre_femmes, date_enregistrement, nbre_total)
	values
		(@id_structure, @nbre_hommes, @nbre_femmes, GETDATE(), @nbre_femmes + @nbre_hommes)
go
create procedure supprimer_effectif
@id_effectif int
as
	delete from t_effectifs
		where id_effectif like @id_effectif
go
create table t_moyenne
(
	num_moyenne int identity,
	id_structure nvarchar(50),
	code_produit nvarchar(50),
	avg_mensuel int,
	avg_marge int,
	date_enreg date,
	id_auto int identity,
	constraint pk_moyenne primary key(num_moyenne),
	constraint fk_structure_moyenne foreign key(id_structure) references t_structure(id_structure) on delete cascade on update cascade
)
go
alter table t_moyenne
add id_auto int identity,
create procedure afficher_moyenne
as
	select top 50 
		num_moyenne as "No.",
		id_structure as "Structure",
		code_produit as "Produit",
		avg_mensuel as "Moyenne",
		avg_marge as "Marge",
		date_enreg as "Date"
	from t_moyenne
		order by
			num_moyenne desc
go

create procedure inserer_moyenne
@id_structure nvarchar(50),
@code_produit nvarchar(50),
@avg_mensuel int,
@avg_marge int
as
	insert into t_moyenne
		(id_structure, code_produit, avg_mensuel, avg_marge, date_enreg)
	values
		(@id_structure, @code_produit, @avg_mensuel, @avg_marge, GETDATE())
go

create procedure recuperer_moyenne
@id_structure nvarchar(50),
@code_produit nvarchar(50)
as
	select top 1
		avg_mensuel,
		avg_marge
		from t_moyenne
		order by
			date_enreg desc, 

go
---------------------------------categorie produit-------------------------------------------
create table t_categorie_prod
(
	code_categorie nvarchar(50),
	designation_categorie nvarchar(50),
	constraint pk_categorie primary key(code_categorie)
);


--------------------procedure enregistrer_categorie

go
create procedure enregistrer_categorie
@code_categorie nvarchar(50),
@designation_categorie nvarchar(50)
as
begin
	if not exists(select * from t_categorie_prod where code_categorie = @code_categorie)
		insert into t_categorie_prod values (@code_categorie, @designation_categorie)
	else
		update t_categorie_prod set designation_categorie = @designation_categorie where code_categorie = @code_categorie
end

--------------------procedure recuperer categorie

go 
create procedure recuperer_categorie
as
	select * from t_categorie_prod order by code_categorie asc


---------------------procedure supprimer_categorie
go
create procedure supprimer_categorie
	@code_categorie nvarchar(50)
as
	delete from t_categorie_prod
		where
			code_categorie=@code_categorie
go
-------------------------fin categorie_prod-------------------------------------
------------------------Conditionnement produit---------------------------------
create table t_conditionnement
(
	id_conditionnement nvarchar(50),
	description_condition nvarchar(100),
	constraint pk_conditionnement primary key(id_conditionnement)
)
go
create table t_forme
(
	id_forme nvarchar(50),
	description_forme nvarchar(100),
	constraint pk_forme primary key(id_forme)
)
go
--------------------------------------------------------- Codes produit------------------------------------------------
create table t_produit
(
	code_produit nvarchar(50),
	designation_produit nvarchar(50),
	code_categorie nvarchar(50),
	id_forme nvarchar(50),
	id_conditionnement nvarchar(50),
    constraint pk_produit primary key(code_produit),
	constraint fk_categorie foreign key(code_categorie) references t_categorie_prod(code_categorie),
	constraint fk_forme foreign key(id_forme) references t_forme(id_forme),
	constraint fk_conditionnement foreign key(id_conditionnement) references t_conditionnement(id_conditionnement)
)
 go
 create procedure afficher_produit
 as
	select top 50
		code_produit ,
		designation_produit,
		code_categorie,
		id_forme,
		id_conditionnement
	from t_produit
	order by
		code_produit asc
go
------------ procedure enregistrer_produit
go
create procedure enregistrer_produit
(
	@code_produit nvarchar(50),
	@designation_produit nvarchar(50),
	@categorie nvarchar(50),
	@id_forme nvarchar(50),
	@id_conditionnement nvarchar(50)
)
as
begin
	declare @code_categorie nvarchar(50) = (select code_categorie from t_categorie_prod where designation_categorie = @categorie)
	if not exists(select * from t_produit where code_produit = @code_produit)
		insert into t_produit values (@code_produit, @designation_produit, @code_categorie,@id_forme,@id_conditionnement)
	else
		update t_produit set designation_produit = @designation_produit, code_categorie = @code_categorie where code_produit = @code_produit
end
------------------ procedure recuperer_produit
go
create procedure recuperer_produit
as
	select designation_produit from t_produit order by code_produit asc
go
create procedure rechercher_produit
@texte nvarchar(50)
as
	select designation_produit from t_produit order by code_produit asc
go
create procedure rechercher_code_produit
@designation_produit nvarchar(50)
as
	select code_produit from t_produit
---------------------procedure supprimer_produit
create procedure supprimer_produit
	@code_produit nvarchar(50)
as
	delete from t_produit
		where
			code_produit=@code_produit
go
------------------------------------------------------fin codes produits
create table t_projet
(
	id_projet nvarchar(50),
	description_projet nvarchar(200),
	constraint pk_projet primary key(id_projet)
)
go
create procedure afficher_projet
as
	select top 50
		id_projet as 'Projet',
		description_projet as 'Description'
	from t_projet
		order by id_projet asc
go
create procedure supprimer_projet
@id_projet nvarchar(50)
as
	delete from t_projet	
		where
			id_projet like @id_projet
go
------------ procedure enregistrer_produit
go
create table t_affectation_projet
(
	num_affectation int identity,
	date_affectation date,
	code_produit nvarchar(50),
	id_projet nvarchar(50),
	constraint pk_affectation primary key(num_affectation),
	constraint fk_produit foreign key(code_produit) references t_produit(code_produit),
	constraint fk_projet foreign key(id_projet) references t_projet(id_projet)
)
go
/****** Object:  Table t_depot     ******/
create table t_depot
(
	code_depot nvarchar(50),
	designation_depot nvarchar(50),
 constraint pk_depot primary key (code_depot)
 )

/****** Object:  StoredProcedure enregistrer_depot     ******/

go
create procedure enregistrer_depot
	@code_depot nvarchar(50),
	@designation_depot nvarchar(50)
	as
		merge t_depot as t_depot
		using (select @code_depot, @designation_depot)
			as t_depot_values(v_code_depot, v_designation_depot)
		on (code_depot=v_code_depot)
		when matched then
			update set
				designation_depot=v_code_depot
		when not matched then
			insert (code_depot,designation_depot)
			values(v_code_depot, v_designation_depot);
go
/****** Object:  StoredProcedure afficher_depot     ******/

create procedure afficher_depot
	as
		select top 500 code_depot,designation_depot
			from t_depot
				order by code_depot asc
go
/****** Object:  StoredProcedure charger_depot     ******/

create procedure charger_depot
as
select 
	code_depot from t_depot
	order by code_depot asc
go
/****** Object:  StoredProcedure rechercher_depot     ******/

create procedure rechercher_depot
	@code_depot nvarchar(50)
	as
	select * from t_depot
		where code_depot=@code_depot
go
/****** Object:  StoredProcedure supprimer_depot     ******/

create procedure supprimer_depot
	@code_depot nvarchar(50)
	as
	delete from t_depot
		where code_depot=@code_depot

------------------------------------------fin codes depot--------------------------------------------
-------------------------------- Codes fournisseur ------------------------------------------------

go
/****** Object:  Table t_fournisseur     ******/

create table t_fournisseur
(
	code_fournisseur nvarchar(50),
	noms_fournisseur nvarchar(50),
	adresse_fournisseur nvarchar(50),
	telephone_fournisseur nvarchar(50),
	mail_fournisseur nvarchar(50),
 constraint pk_fournisseur primary key (code_fournisseur)
 )
go
---------------procedure enregistrer_fournisseur

create procedure enregistrer_fournisseur
	@code_fournisseur nvarchar(50),
	@noms_fournisseur nvarchar(50),
	@adresse_fournisseur nvarchar(50),
	@telephone_fournisseur nvarchar(50),
	@mail_fournisseur nvarchar(50)
	as
		merge t_fournisseur
			using (select @code_fournisseur, 
						  @noms_fournisseur, 
						  @adresse_fournisseur,
						  @telephone_fournisseur,
						  @mail_fournisseur)
						  as
					t_source_fournisseur
					(
						  code_fournisseur_source,
						  noms_fournisseur_source, 
						  adresse_fournisseur_source,
						  telephone_fournisseur_source,
						  mail_fournisseur_source)
				on(code_fournisseur=code_fournisseur_source)
				when matched then
				update set
					noms_fournisseur=@noms_fournisseur,
					adresse_fournisseur=@adresse_fournisseur,
					telephone_fournisseur=@telephone_fournisseur,
					mail_fournisseur=@mail_fournisseur
				when not matched then
					insert (code_fournisseur,
							noms_fournisseur,
							adresse_fournisseur,
							telephone_fournisseur,
							mail_fournisseur)
					values (@code_fournisseur,
							@noms_fournisseur,
							@adresse_fournisseur,
							@telephone_fournisseur,
							@mail_fournisseur);

go
/****** Object:  StoredProcedure afficher_fournisseur     ******/

create procedure afficher_fournisseur
	as
		select top 500 code_fournisseur, 
					   noms_fournisseur, 
					   adresse_fournisseur, 
					   telephone_fournisseur, 
					   mail_fournisseur
		from t_fournisseur
				order by noms_fournisseur asc


go

create procedure rechercher_fournisseur
	@code_fournisseur nvarchar(50)
	as
		select top 500 code_fournisseur, 
					   noms_fournisseur, 
					   adresse_fournisseur, 
					   telephone_fournisseur, 
					   mail_fournisseur
		from t_fournisseur
			where code_fournisseur=@code_fournisseur
				order by noms_fournisseur asc


go
/****** Object:  StoredProcedure charger_fournisseur     ******/

create procedure charger_fournisseur
as
select
	code_fournisseur 
	from t_fournisseur
	order by code_fournisseur asc

/****** Object:  StoredProcedure supprimer_fournisseur     ******/

go
create procedure supprimer_fournisseur
	@code_fournisseur nvarchar(50)
	as
		delete from t_fournisseur
			where code_fournisseur=@code_fournisseur


-----------------------------------------------fin codes fournisseur-----------------------------------------

----------------------------------------------- Codes approvisionnement-------------------------------
go
/****** Object:  Table t_approvisionnement  ******/
create table t_approvisionnement
(
	code_approvisionnement nvarchar(50),
	date_approvisionnement date,
	date_fabrication date,
	date_expiration date,
	code_produit nvarchar(50),
	code_fournisseur nvarchar(50),
	code_depot nvarchar(50),
    ugs nvarchar(50), ----unite de gestion de stock, milligrammes
	quantite int,
	cout_total decimal(18,0),	
 constraint pk_approvisionnement primary key(code_approvisionnement),
 constraint fk_fournisseur_approv foreign key(code_fournisseur) references t_fournisseur(code_fournisseur),
 constraint fk_produit_approv foreign key(code_produit) references t_produit(code_produit),
 constraint fk_depot_approv foreign key(code_depot) references t_depot(code_depot), 
)
go
/****** Object:  StoredProcedure inserer_approvisionnement     ******/

create procedure inserer_approvisionnement
	@code_approvisionnement nvarchar(50),
	@date_approvisionnement date,
	@date_fabrication date,
	@date_expiration date,
	@code_produit nvarchar(50),
	@code_fournisseur nvarchar(50),
	@code_depot nvarchar(50),
    @ugs nvarchar(50), ----unite de gestion de stock, milligrammes
	@quantite int,
	@cout_total decimal(18,0)
	as
		merge t_approvisionnement
		using (select @code_approvisionnement, @date_approvisionnement, @date_fabrication, @date_expiration, @code_produit, @code_fournisseur, @code_depot, @ugs, @quantite, @cout_total) 
			as xapprovisionnement(xcode_approvisionnement, xdate_approvisionnement, xdate_fabrication, xdate_expiration, xcode_produit, xcode_fournisseur, xcode_depot, xugs, xquantite, xcout_total)
		on(t_approvisionnement.code_approvisionnement=xapprovisionnement.xcode_approvisionnement)
		when matched then
			update set 
				date_approvisionnement=@date_approvisionnement, 
				date_fabrication=@date_fabrication, 
				date_expiration=@date_expiration, 
				code_produit=@code_produit, 
				code_fournisseur=@code_fournisseur, 
				code_depot=@code_depot, 
				ugs=@ugs, 
				quantite=@quantite, 
				cout_total=@cout_total
		when not matched then
			insert (code_approvisionnement, date_approvisionnement, date_fabrication, date_expiration, code_produit, code_fournisseur, code_depot, ugs, quantite, cout_total)
			values (@code_approvisionnement, @date_approvisionnement, @date_fabrication, @date_expiration, @code_produit, @code_fournisseur, @code_depot, @ugs, @quantite, @cout_total);
go
/****** Object:  StoredProcedure supprimer_approvisionnement     ******/

create procedure supprimer_approvisionnement
	@code_approvisionnement nvarchar(50)
	as
	delete from t_approvisionnement
		where code_approvisionnement=@code_approvisionnement

go
/****** Object:  StoredProcedure rechercher_approvisionnement_entre_date     ******/

create procedure rechercher_approvisionnement_entre_date
	@date_un date,
	@date_deux date
	as
	select * from t_approvisionnement
		where date_approvisionnement between @date_un and @date_deux
			order by code_approvisionnement desc



GO
/****** Object:  StoredProcedure afficher_approvisionnement     ******/

create procedure afficher_approvisionnement
as
select top 500 code_approvisionnement as 'Code', date_approvisionnement as 'Date', code_fournisseur as 'Fournisseur', code_depot as 'Depot', quantite as 'Qte', cout_total as 'Prix'
	from t_approvisionnement
		order by date_approvisionnement desc, code_approvisionnement desc
go
/****** Object:  StoredProcedure charger_approvisionnement     ******/

create procedure charger_approvisionnement
as
	select 
	code_approvisionnement
	from t_approvisionnement
	order by code_approvisionnement desc
go
create procedure recuperer_approvisionnement
@code_produit nvarchar(50)
as
select
	t_approvisionnement.code_approvisionnement as 'Code Approvisionnement', 
	t_approvisionnement.code_produit as 'Code Produit', 
	t_produit.designation_produit as 'Designation',
	t_approvisionnement.code_fournisseur as 'Fournisseur', 
	t_produit.code_categorie as 'Categorie',
	t_approvisionnement.date_approvisionnement as 'Date Entree', 
	t_approvisionnement.date_expiration as 'Expiration',	 
    t_approvisionnement.quantite as 'Quantite Initiale',	
	t_approvisionnement.ugs as 'UGS',
	t_situation_stock.qte_restante as 'Quantite Restante',
	t_situation_stock.status_stock as 'Status Stock',
	t_situation_stock.date_situation as 'Derniere Date'	
from           
	t_approvisionnement inner join
                t_produit on t_approvisionnement.code_produit = t_produit.code_produit inner join
                        t_situation_stock on t_approvisionnement.code_approvisionnement = t_situation_stock.code_approvisionnement
where
	t_approvisionnement.code_produit like @code_produit and t_situation_stock.status_stock <> 'Epuisee'
order by
	t_approvisionnement.date_approvisionnement asc,  t_situation_stock.date_situation desc
go
create table t_situation_stock
(
	num_situation int identity,
	code_approvisionnement nvarchar(50),
	date_situation date,
	qte_restante int,
	status_stock nvarchar(50), ----- soit epuisee, soit perimee, soit en rupture, ......
	constraint pk_situation primary key(num_situation),
	constraint fk foreign key(code_approvisionnement) references t_approvisionnement(code_approvisionnement) on delete cascade on update cascade
)
go
create procedure afficher_situation_stock
as
select
	t_approvisionnement.code_approvisionnement as 'Code Approvisionnement', 
	t_approvisionnement.code_produit as 'Code Produit', 
	t_produit.designation_produit as 'Designation',
	t_approvisionnement.code_fournisseur as 'Fournisseur', 
	t_produit.code_categorie as 'Categorie',
	t_approvisionnement.date_approvisionnement as 'Date Entree', 
	t_approvisionnement.date_expiration as 'Expiration',	 
    t_approvisionnement.quantite as 'Quantite Initiale',	
	t_approvisionnement.ugs as 'UGS',
	t_situation_stock.qte_restante as 'Quantite Restante',
	t_situation_stock.status_stock as 'Status Stock',
	t_situation_stock.date_situation as 'Derniere Date'	
from           
	t_approvisionnement inner join
                t_produit on t_approvisionnement.code_produit = t_produit.code_produit inner join
                        t_situation_tock on t_approvisionnement.code_approvisionnement = t_situation_tock.code_approvisionnement
	order by
		t_approvisionnement.date_approvisionnement asc,  t_situation_stock.date_situation desc
go
--------------------------------------------------------------fin codes approvisionnement------------------------------------------

------------------------------------Debut codes de la commande-------------------------------------------------------------

create table t_commandes
	(
	num_commande int identity,
	code_produit nvarchar(50),
	qte decimal,
	alerte_level nvarchar(50),------- critique,
	date_commande date,
	date_souhaitee date,
	status_commande nvarchar(50),
	id_structure nvarchar(50),
	description_commande nvarchar(max),
  constraint pk_commande primary key (num_commande),
	constraint fk_commandes_structure foreign key(id_structure) references t_structure(id_structure)
)
go
create procedure afficher_commandes
as
	select top 50
		num_commande as "Commande No",
		code_produit as "Produit",
		qte as "QTE",
		alerte_level as "Level",
		date_commande as "Date Commande",
		date_souhaitee as "Date Souhaitee",
		status_commande as "Status Commandes",
		id_structure as "Strucuture",
		description_commande as "Description"
	from t_commandes
		order by num_commande desc
go
create procedure inserer_commande
@code_produit nvarchar(50),
@qte decimal,
@alerte_level nvarchar(50),
@date_commande date,
@date_souhaitee date,
@status_commande nvarchar(50),
@id_structure nvarchar(50),
@description_commande nvarchar(max)
as
	insert into t_commandes
		(code_produit, qte, alerte_level, date_commande, date_souhaitee, status_commande, id_structure, description_commande)
	values
		(@code_produit, @qte, @alerte_level, @date_commande, @date_souhaitee, @status_commande, @id_structure, @description_commande)
go
create procedure modifier_commande
@num_commande int,
@code_produit nvarchar(50),
@qte decimal,
@alerte_level nvarchar(50),
@date_commande date,
@date_souhaitee date,
@status_commande nvarchar(50),
@id_structure nvarchar(50),
@description_commande nvarchar(max)
as
	update t_commandes
		set
			code_produit=@code_produit,
			qte=@qte,
			alerte_level=@alerte_level,
			date_commande=@date_commande,
			date_souhaitee=@date_souhaitee,
			status_commande=@status_commande,
			id_structure=@id_structure,
			description_commande=@description_commande
		where
			num_commande like @num_commande
go
create procedure modifier_status_commande
@num_commande int,
@status_commande nvarchar(50)
as
	update t_commandes
		set
			status_commande=@status_commande
		where
			num_commande like @num_commande
go
create procedure compteur_commande
@status_commande nvarchar(50)
as
	select 
		count(distinct num_commande)
	from t_commandes
		where
			status_commande like @status_commande
go
create procedure commande_en_cours
@status_commande nvarchar(50)
as
	select top 50
		num_commande as "Commande No",
		code_produit as "Produit",
		qte as "QTE",
		alerte_level as "Level",
		date_commande as "Date Commande",
		date_souhaitee as "Date Souhaitee",
		status_commande as "Status Commandes",
		id_structure as "Strucuture",
		description_commande as "Description"
	from t_commandes
		where
			status_commande like @status_commande
		order by num_commande desc
go
--------------------------------------------
create procedure supprimer_commande
@num_commande int
as
	delete from t_commandes
		where
			num_commande=@num_commande

	
-----------------------------------Fin des codes de la commande-----------------------------------------------------------

/****** Object:  Table t_attribution_facture    ******/
go
create table t_transporteur
(
	code_transporteur nvarchar(50),
	descr_transporteur nvarchar(50),
	num_phone nvarchar(50),
	adresse_transporteur nvarchar(50),
	constraint pk_transporteur primary key(code_transporteur))
go
create procedure enregistrer_transporteur
	@code_transporteur nvarchar(50),
	@descr_transporteur nvarchar(50),
	@num_phone nvarchar(50),
	@adresse_transporteur nvarchar(50)
as
	insert into t_transporteur 
		(code_transporteur, descr_transporteur, num_phone, adresse_transporteur)
	values
		(@code_transporteur, @descr_transporteur, @num_phone, @adresse_transporteur)
go
create table t_distribution
	(
		num_distribution int identity,
		date_distribution date,
		code_transporteur nvarchar(50),
		num_commande int,
		code_approvisionnement nvarchar(50),
		qte_demande decimal,
		descr_distribution nvarchar(50),
		constraint pk_distribution primary key(num_distribution),
		constraint fk_distr_approv foreign key(code_approvisionnement) references t_approvisionnement(code_approvisionnement) on delete cascade on update cascade,
		constraint fk_distr_commande foreign key(num_commande) references t_commandes(num_commande) on delete cascade on update cascade,
		constraint fk_distr_transporteur foreign key(code_transporteur) references t_transporteur(code_transporteur) on delete cascade on update cascade
	)
go
create table t_confirmation_reception
(
	num_confirmation int identity,
	num_commande int,
	date_confirmation date,
	qte_recue decimal,
    observations nvarchar(500),
	constraint pk_confirmation primary key(num_confirmation),
	constraint fk_conf_commande foreign key(num_commande) references t_commandes (num_commande) on delete cascade on update cascade ---modified
);


-------------------------------------------------------Codes Login------------------------------------------------------------------
/****** Object:  Table t_login     ******/

create table t_login(
	nom_utilisateur nvarchar(50),
	mot_de_passe nvarchar(50),
	niveau_acces nvarchar(50),
	id_structure nvarchar(50)
 constraint pk_login primary key(nom_utilisateur),
 constraint fk_structure_login foreign key(id_structure) references t_structure(id_structure) on delete cascade on update cascade
 )
 
go
/****** Object:  StoredProcedure enregistrer_login     ******/

create procedure enregistrer_login
	@nom_utilisateur nvarchar(50),
	@mot_de_passe nvarchar(50),
	@niveau_acces nvarchar(50),
	@id_structure nvarchar(50)
	as
	merge t_login as t_logins
	using(select @nom_utilisateur, @mot_de_passe, @niveau_acces, @id_structure) 
		as t_parametres(prm_nom_utilisateur, prm_mot_de_passe, prm_niveau_acces, prm_id_structure)
	on(t_logins.nom_utilisateur=t_parametres.prm_nom_utilisateur)
		when matched then
			update set mot_de_passe=t_parametres.prm_mot_de_passe,
					   niveau_acces=t_parametres.prm_niveau_acces,
					   id_structure=t_parametres.prm_id_structure
		when not matched then
			insert (nom_utilisateur, mot_de_passe, niveau_acces,id_structure)
			values(@nom_utilisateur, @mot_de_passe, @niveau_acces, @id_structure);
go
/****** Object:  StoredProcedure supprimer_login     ******/

create procedure supprimer_login
	@nom_utilisateur nvarchar(50)
	as
	delete from t_login
		where nom_utilisateur=@nom_utilisateur;


go
/****** Object:  StoredProcedure rechercher_login     ******/

create procedure rechercher_login
	@nom_utilisateur nvarchar(50),
	@mot_de_passe nvarchar(50)
	as
	select niveau_acces from t_login 
		where nom_utilisateur 
			like @nom_utilisateur and mot_de_passe=@mot_de_passe
go
-------------------------------------------------------- fin Codes Login-----------------------------------------------------------

----------------------------------------------------Codes facture------------------------------------------------------------------

go
create table t_stock
(
	numero int identity,
	date_stock date,
	designation nvarchar(50),
	stock_initial decimal,
	qte_entree decimal,
	qte_sortie decimal,
	stock_final decimal,
	constraint pk_stock primary key(numero)
)
go----------------------------------------Debut insertion_stock-----------------------------------------
create procedure inserer_stock
@designation nvarchar(50),
@stock_initial decimal,
@qte_entree decimal,
@qte_sortie decimal,
@stock_final decimal
as
	insert into t_stock
		(date_stock, designation,stock_initial,qte_entree,qte_sortie,stock_final)
	values
		(getdate(), @designation, @stock_initial, @qte_entree, @qte_sortie, @stock_final)
go
--------------------------Fin ajout stock informations -------------------------------------------------
-------------------------- procedure rechercher_stock
go
create procedure rechercher_stock
as
	select top 500
		date_stock,
		designation,
		stock_initial,
		qte_entree,
		qte_sortie,
		stock_final
	from t_stock
		order by date_stock desc, designation desc
go
--------------------------------------------------- fin codes stock----------------------------------------------------------
